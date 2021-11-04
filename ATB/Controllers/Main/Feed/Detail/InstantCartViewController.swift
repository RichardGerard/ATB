//
//  InstantCartViewController.swift
//  ATB
//
//  Created by YueXi on 2/28/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit

protocol InstantCartDelegate {
    
    func buyProduct(_ product: PostModel, vid: String, quantity: Int)
}

class InstantCartViewController: BaseViewController {
    
    static let kStoryboardID = "InstantCartViewController"
    class func instance() -> InstantCartViewController {
        let storyboard = UIStoryboard(name: "Sheet", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: InstantCartViewController.kStoryboardID) as? InstantCartViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    // Material Tab View
    @IBOutlet weak var vMaterialTab: UIView!
    @IBOutlet weak var quanityContainer: UIView!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAdded: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var btnContainer: UIView!
    @IBOutlet weak var btnDecrease: UIButton!
    @IBOutlet weak var btnIncrease: UIButton!
    @IBOutlet weak var btnBuy: UIButton!
    
    @IBOutlet weak var btnDelete: UIButton!
        
    var cartItem: PostModel!
    var quantity: Int = 0
    var vid: String = ""
    
    var delegate: InstantCartDelegate?
    
    var isFromBusinessStore = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .colorPrimary
        
        // Material tab
        vMaterialTab.backgroundColor = UIColor.black.withAlphaComponent(0.17)
        
        // Quantity
        quanityContainer.layer.cornerRadius
         = 12
        quanityContainer.layer.masksToBounds = true
        
        lblQuantity.text = "\(quantity)"
        lblQuantity.font = UIFont(name: Font.SegoeUIBold, size: 13)
        lblQuantity.textColor = .colorPrimary
        lblQuantity.textAlignment = .center
        
        // Name
        let name = cartItem.Post_Title.capitalizingFirstLetter + " "
        let attributedName = NSMutableAttributedString(string: name)
        let arrowAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            arrowAttachment.image = UIImage(systemName: "chevron.right")?.withTintColor(.white)
        } else {
            // Fallback on earlier versions
        }
        attributedName.insert(NSAttributedString(attachment: arrowAttachment), at: name.count)
        lblName.attributedText = attributedName
        lblName.font = UIFont(name: Font.SegoeUISemibold, size: 22)
        lblName.textColor = .white
        
        lblAdded.text = "Added to cart"
        lblAdded.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblAdded.textColor = .white
        
        // Price
        updateCartValues()
        lblPrice.font = UIFont(name: Font.SegoeUIBold, size: 24)
        lblPrice.textColor = .white
        lblPrice.textAlignment = .right
        
        btnContainer.layer.cornerRadius = 5
        btnContainer.layer.masksToBounds = true
        
        if #available(iOS 13.0, *) {
            btnDecrease.setImage(UIImage(systemName: "minus"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnDecrease.tintColor = .colorPrimary
        
        btnBuy.setTitle("Buy Now", for: .normal)
        btnBuy.setTitleColor(.colorPrimary, for: .normal)
        btnBuy.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 20)
        
        if #available(iOS 13.0, *) {
            btnIncrease.setImage(UIImage(systemName: "plus"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnIncrease.tintColor = .colorPrimary
                
        // Delete
        btnDelete.layer.cornerRadius = 5
        btnDelete.layer.masksToBounds = true
        btnDelete.backgroundColor = UIColor.black.withAlphaComponent(0.23)
        if #available(iOS 13.0, *) {
            btnDelete.setImage(UIImage(systemName: "cart.fill.badge.minus"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        
        btnDelete.tintColor = .white
    }
    
    private func delete(isAll: Bool) {
        let pid = isFromBusinessStore ? cartItem.Post_ID : cartItem.pid ?? ""
        // will not get empty as validation check was done before.
        // be sure to not send an invalid product id
        guard !pid.isEmpty else { return }
        
        showIndicator()
        APIManager.shared.deleteItemInCart(g_myToken, pid: pid, vid: vid.isEmpty ? "0" : vid, isAll: isAll) { (result, mesasge) in
            self.hideIndicator()
            
            guard result else {
                self.showErrorVC(msg: "It's failed to delete the item in the cart!")
                return
            }
            
            if isAll {
                self.dismiss(animated: true, completion: nil)
                
            } else {
                if self.quantity <= 1 {
                    self.dismiss(animated: true, completion: nil)
                    
                } else {
                    self.quantity -= 1
                    self.updateCartValues()
                }
            }
        }
    }
    
    private func updateCartValues() {
        lblQuantity.text = "\(quantity)"
        
        var unitPrice = cartItem.Post_Price.floatValue
        if !vid.isEmpty,
           let selectedVariant = cartItem.productVariants.first(where: { $0.id == vid }) {
            unitPrice = selectedVariant.price.floatValue
        }
        
        lblPrice.text = "+£" + (unitPrice*Float(quantity)).priceString
    }
    
    @IBAction func didTapDecrease(_ sender: Any) {
        delete(isAll: false)
    }
    
    @IBAction func didTapBuy(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.buyProduct(self.cartItem, vid: self.vid, quantity: self.quantity)
        }
    }
    
    @IBAction func didTapIncrease(_ sender: Any) {
        let pid = isFromBusinessStore ? cartItem.Post_ID : cartItem.pid ?? ""
        // will not get empty as validation check was done before.
        // be sure to not send an invalid product id
        guard !pid.isEmpty else { return }
        
        showIndicator()
        APIManager.shared.addItemInCart(g_myToken, pid: pid, vid: vid.isEmpty ? "0" : vid) { (result, message, cartInfo) in
            self.hideIndicator()
            
            guard result else {
                self.showErrorVC(msg: "It's been failed to add the product to your cart!")
                return
            }
            
            self.quantity += 1
            self.updateCartValues()
        }
    }
    
    @IBAction func didTapDelete(_ sender: Any) {
        delete(isAll: true)
    }
}

