//
//  SelectDeliveryViewController.swift
//  ATB
//
//  Created by YueXi on 11/14/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import NBBottomSheet
import CoreLocation

protocol SelectDeliveryDelegate {
    
    // pass the delivery selected option here
    func purchaseProduct(_ product: PostModel, vid: String, quantity: Int, deliveryOption: Int)
}

class SelectDeliveryViewController: BaseViewController {
    
    static let kStoryboardID = "SelectDeliveryViewController"
    class func instance() -> SelectDeliveryViewController {
        let storyboard = UIStoryboard(name: "Sheet", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: SelectDeliveryViewController.kStoryboardID) as? SelectDeliveryViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    var configuration: NBBottomSheetConfiguration!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var freeContainer: FieldContainerView! { didSet {
        freeContainer.activeBackgroundColor = .colorPrimary
    }}
    @IBOutlet weak var imvPostage: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvPostage.image = UIImage(systemName: "paperplane.fill")
        } else {
            // Fallback on earlier versions
        }
        imvPostage.tintColor = .colorGray18
    }}
    @IBOutlet weak var freeLabelContainer: UIView!
    @IBOutlet weak var lblFree: UILabel! { didSet {
        lblFree.text = "Free postage"
        lblFree.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblFree.textColor = .colorGray5
    }}
    @IBOutlet weak var lblFreePrice: UILabel!
    
    @IBOutlet weak var collectContainer: FieldContainerView! { didSet {
        collectContainer.activeBackgroundColor = .colorPrimary
    }}
    @IBOutlet weak var imvCollect: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvCollect.image = UIImage(systemName: "car.fill")
        } else {
            // Fallback on earlier versions
        }
        imvCollect.tintColor = .colorGray18
    }}
    @IBOutlet weak var collectLabelContainer: UIView!
    @IBOutlet weak var lblCollect: UILabel! { didSet {
        lblCollect.text = "I'll Collect"
        lblCollect.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblCollect.textColor = .colorGray5
    }}
    @IBOutlet weak var lblCollectPrice: UILabel!
    
    @IBOutlet weak var deliverContainer: FieldContainerView! { didSet {
        deliverContainer.activeBackgroundColor = .colorPrimary
    }}
    @IBOutlet weak var imvDeliver: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvDeliver.image = UIImage(systemName: "cube.box.fill")
        } else {
            // Fallback on earlier versions
        }
        imvDeliver.tintColor = .colorGray18
    }}
    @IBOutlet weak var deliverLabelContainer: UIView!
    @IBOutlet weak var lblDeliver: UILabel! { didSet {
        lblDeliver.text = "Deliver"
        lblDeliver.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblDeliver.textColor = .colorGray5
    }}
    @IBOutlet weak var lblDeliverPrice: UILabel!
    
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var imvLocationAccessory: UIImageView!
    @IBOutlet weak var btnBuy: UIButton!
    
    var selectedProduct: PostModel!
    var vid: String = "" // variat id
    var quantity: Int = 0
    
    private var selectedOption: Int = -1
    
    var delegate: SelectDeliveryDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
    }
    
    private func initView() {
        view.backgroundColor = .colorGray14
        
        lblTitle.text = "Select a Delivery Option"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 22)
        lblTitle.textColor = .colorGray5
        
        lblAddress.font = UIFont(name: Font.SegoeUILight, size: 16)
        lblAddress.textColor = .colorPrimary
        lblAddress.numberOfLines = 0
        
        updateLocationLabel(forOption: 1)
        
        if #available(iOS 13.0, *) {
            imvLocationAccessory.image = UIImage(systemName: "chevron.right")
        } else {
            // Fallback on earlier versions
        }
        imvLocationAccessory.tintColor = .colorPrimary
        
        btnBuy.backgroundColor = .colorPrimary
        btnBuy.layer.cornerRadius = 5
        updatePrice(withDeliveryOption: selectedOption)
        updateBuyButton(false)
        
        lblFreePrice.text = "+£0.00"
        lblFreePrice.font = UIFont(name: Font.SegoeUILight, size: 14)
        lblFreePrice.textColor = .colorGray18
        
        lblCollectPrice.text = "+£0.00"
        lblCollectPrice.font = UIFont(name: Font.SegoeUILight, size: 14)
        lblCollectPrice.textColor = .colorGray18
        
        lblDeliverPrice.text = "+£\(selectedProduct.deliveryCost.floatValue.priceString)"
        lblDeliverPrice.font = UIFont(name: Font.SegoeUILight, size: 14)
        lblDeliverPrice.textColor = .colorGray18
    }
    
    private func updateBuyButton(_ enabled: Bool) {
        UIView.setAnimationsEnabled(false)
        btnBuy.backgroundColor = enabled ? .colorPrimary : UIColor.colorPrimary.withAlphaComponent(0.5)
        btnBuy.setTitleColor(enabled ? .white : UIColor.white.withAlphaComponent(0.5), for: .normal)
        UIView.setAnimationsEnabled(true)
    }
    
    private func updateLocationLabel(forOption selected: Int) {
        if selected == 3 {
            lblAddress.text = "We will send you the indications of the location after completing your order."
            
        } else {
            let address = "This product includes free postage at your current location "
            let location = " \(selectedProduct.Post_Location)"
            let attributedAddress = NSMutableAttributedString(string: address + location)
            
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: Font.SegoeUISemibold, size: 16)!,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor.colorPrimary
            ]
            
            let locationRange = ((address + location) as NSString).range(of: location)
            attributedAddress.addAttributes(linkAttributes, range: locationRange)
            
            let locationAttachment = NSTextAttachment()
            if #available(iOS 13.0, *) {
                locationAttachment.image = UIImage(systemName: "mappin.and.ellipse")?.withTintColor(.colorPrimary)
                locationAttachment.setImageHeight(height: 18, verticalOffset: -2)
            } else {
                // Fallback on earlier versions
            }
            
            attributedAddress.insert(NSAttributedString(attachment: locationAttachment), at: address.count)
            lblAddress.attributedText = attributedAddress
        }
    }
    
    private func updatePrice(withDeliveryOption deliveryOption: Int) {
        var unitPrice = selectedProduct.Post_Price.floatValue
        if !vid.isEmpty,
           let selectedVariant = selectedProduct.productVariants.first(where: { $0.id == vid }) {
            unitPrice = selectedVariant.price.floatValue
        }
        
        var price = unitPrice * Float(quantity)
        if deliveryOption == 5 {
            price += selectedProduct.deliveryCost.floatValue
        }
        
        let title = "Buy Now £" + price.priceString
        let attributedTitle = NSMutableAttributedString(string: title)
        
        attributedTitle.addAttributes([
            .foregroundColor: UIColor.white,
            .font: UIFont(name: Font.SegoeUILight, size: 19)!
        ], range: NSRange(location: 0, length: attributedTitle.length))
        
        attributedTitle.addAttributes([
            .font: UIFont(name: Font.SegoeUISemibold, size: 20)!
        ], range: (title as NSString).range(of: "£" + price.priceString))
        
        UIView.setAnimationsEnabled(false)
        btnBuy.setAttributedTitle(attributedTitle, for: .normal)
        UIView.setAnimationsEnabled(true)
    }
    
    @IBAction func didSelectFreeDelivery(_ sender: Any) {
        guard selectedProduct.isFreeEnabled else {
            showErrorVC(msg: "The option was disabled by the seller!")
            return
        }
        
        selectDelivery(forOption: 1, selected: true)
    }
    
    @IBAction func didSelectCollect(_ sender: Any) {
        guard selectedProduct.isCollectEnabled else {
            showErrorVC(msg: "The option was disabled by the seller!")
            return
        }
        
        selectDelivery(forOption: 3, selected: true)
    }
    
    @IBAction func didSelectDeliver(_ sender: Any) {
        guard selectedProduct.isDeliverEnabled else {
            showErrorVC(msg: "The option was disabled by the seller!")
            return
        }
        
        selectDelivery(forOption: 5, selected: true)
    }
    
    // -1: no selected
    // 1: free postage
    // 3: I'll collect
    // 5: deliver
    private func selectDelivery(forOption selectedIndex: Int, selected: Bool) {
        // if an option is selected, just animate the selected one
        var tx: CGFloat = 0.0, ty: CGFloat = freeLabelContainer.frame.height + 2 + freeContainer.frame.height*0.3/2.0
        var labelTx: CGFloat = 0.0, labelTy: CGFloat = -((freeContainer.frame.height*0.7-freeLabelContainer.frame.height)/2.0)
        
        updateBuyButton(selected)
        updateLocationLabel(forOption: selectedIndex)
        
        if selected {
            updatePrice(withDeliveryOption: selectedIndex)
        }

        switch selectedIndex {
        case 1:
            freeContainer.state = selected ? .active : .normal

            imvPostage.tintColor = selected ? .white : .colorGray18

            // calculate tx for box container
            tx = -(freeContainer.frame.width*0.3/2.0)
            // calculate tx for label container
            labelTx = freeContainer.frame.width*0.7 + 8
            
            break

        case 3:
            collectContainer.state = selected ? .active : .normal

            imvCollect.tintColor = selected ? .white : .colorGray18

            // calculate tx for box container
            tx = -(collectContainer.frame.origin.x - 20 + collectContainer.frame.width*0.3/2.0)
            // calculate tx for label container
            labelTx = -(collectLabelContainer.frame.origin.x - 20 - collectContainer.frame.width*0.7 - 8)
            break

        case 5:
            deliverContainer.state = selected ? .active : .normal

            imvDeliver.tintColor = selected ? .white : .colorGray18

            // calculate tx for box container
            tx = -(deliverContainer.frame.origin.x - 20 + deliverContainer.frame.width*0.3/2.0)
            // calculate tx for label container
            labelTx = -(deliverLabelContainer.frame.origin.x - 20 - deliverContainer.frame.width*0.7 - 8)
            break

        default:
            break
        }
        
        animationStarted(forSelectedIndex: selectedIndex, selected: selected)

        UIView.animate(withDuration: 0.35) {
            var identity = CGAffineTransform.identity
            identity = identity.translatedBy(x: tx, y: ty)
            identity = identity.scaledBy(x: 0.7, y: 0.7)

            switch selectedIndex {
            case 1:
                self.freeContainer.transform = selected ? identity : .identity
                self.freeLabelContainer.transform = selected ? CGAffineTransform(translationX: labelTx, y: labelTy) : .identity
                break

            case 3:
                self.collectContainer.transform = selected ? identity : .identity
                self.collectLabelContainer.transform = selected ? CGAffineTransform(translationX: labelTx, y: labelTy) : .identity
                break

            case 5:
                self.deliverContainer.transform = selected ? identity : .identity
                self.deliverLabelContainer.transform = selected ? CGAffineTransform(translationX: labelTx, y: labelTy) : .identity
                break

            default: break
            }

        } completion: { _ in
            if selected {
                /// add a new button
                self.deliveryOptionSelected(selectedIndex)

            } else {
                /// remove the button
                if let removableButton = self.view.viewWithTag(selectedIndex + 500) {
                    removableButton.removeFromSuperview()
                }
            }
        }
        
        let current = 380 - UIApplication.safeAreaBottom()
        let delta = freeLabelContainer.bounds.height + freeContainer.bounds.height * 0.3 + 2
        configuration.sheetSize = .fixed(selected ? current - delta : current)
        
        guard let presentationController = self.presentationController else { return }
//        UIView.animate(withDuration: 0.35) {
            presentationController.containerViewWillLayoutSubviews()
//        }
    }
    
    private func animationStarted(forSelectedIndex: Int, selected: Bool) {
        switch forSelectedIndex {
        case 1:
            if !selected {
                collectContainer.isHidden = false
                collectLabelContainer.isHidden = false
                
                deliverContainer.isHidden = false
                deliverLabelContainer.isHidden = false
            }
            
            // hide collect & deliver option
            UIView.animate(withDuration: 0.15) {
                self.collectContainer.alpha = selected ? 0.0 : 1.0
                self.collectLabelContainer.alpha = selected ? 0.0 : 1.0
                
                self.deliverContainer.alpha = selected ? 0.0 : 1.0
                self.deliverLabelContainer.alpha = selected ? 0.0 : 1.0
                
            } completion: { _ in
                if selected {
                    self.collectContainer.isHidden = true
                    self.collectLabelContainer.isHidden = true
                    
                    self.deliverContainer.isHidden = true
                    self.deliverLabelContainer.isHidden = true
                }
            }
            break
            
        case 3:
            if !selected {
                freeContainer.isHidden = false
                freeLabelContainer.isHidden = false
                
                deliverContainer.isHidden = false
                deliverLabelContainer.isHidden = false
            }
            
            // hide collect & deliver option
            UIView.animate(withDuration: 0.15) {
                self.freeContainer.alpha = selected ? 0.0 : 1.0
                self.freeLabelContainer.alpha = selected ? 0.0 : 1.0
                
                self.deliverContainer.alpha = selected ? 0.0 : 1.0
                self.deliverLabelContainer.alpha = selected ? 0.0 : 1.0
                
            } completion: { _ in
                if selected {
                    self.freeContainer.isHidden = true
                    self.freeLabelContainer.isHidden = true
                    
                    self.deliverContainer.isHidden = true
                    self.deliverLabelContainer.isHidden = true
                }
            }
            break
            
        case 5:
            if !selected {
                freeContainer.isHidden = false
                freeLabelContainer.isHidden = false
                
                collectContainer.isHidden = false
                collectLabelContainer.isHidden = false
            }
            
            // hide collect & deliver option
            UIView.animate(withDuration: 0.15) {
                self.freeContainer.alpha = selected ? 0.0 : 1.0
                self.freeLabelContainer.alpha = selected ? 0.0 : 1.0
                
                self.collectContainer.alpha = selected ? 0.0 : 1.0
                self.collectLabelContainer.alpha = selected ? 0.0 : 1.0
                
            } completion: { _ in
                if selected {
                    self.freeContainer.isHidden = true
                    self.freeLabelContainer.isHidden = true
                    
                    self.collectContainer.isHidden = true
                    self.collectLabelContainer.isHidden = true
                }
            }
            break
            
        default: break
        }
    }
    
    // This will be called after animation completed
    // And will add a new button, and down arrow accessory view
    private func deliveryOptionSelected(_ selectedIndex: Int) {
        selectedOption = selectedIndex
        
        let deselectButton = UIButton()
        deselectButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // to test & see button added result
//        deselectButton.backgroundColor = .colorRed1
        deselectButton.tag = selectedIndex + 500
        
        switch selectedIndex{
        case 1:
            deselectButton.frame.origin.x = freeContainer.frame.origin.x
            deselectButton.frame.origin.y = freeContainer.frame.origin.y
            deselectButton.frame.size = CGSize(width: freeContainer.frame.width + freeLabelContainer.frame.width + 36, height: freeContainer.frame.height)
            view.addSubview(deselectButton)
            deselectButton.addTarget(self, action: #selector(deselectOption(_:)), for: .touchUpInside)
            break
            
        case 3:
            deselectButton.frame.origin.x = collectContainer.frame.origin.x
            deselectButton.frame.origin.y = collectContainer.frame.origin.y
            deselectButton.frame.size = CGSize(width: collectContainer.frame.width + collectLabelContainer.frame.width + 36, height: collectContainer.frame.height)
            view.addSubview(deselectButton)
            deselectButton.addTarget(self, action: #selector(deselectOption(_:)), for: .touchUpInside)
            break
            
        case 5:
            deselectButton.frame.origin.x = deliverContainer.frame.origin.x
            deselectButton.frame.origin.y = deliverContainer.frame.origin.y
            deselectButton.frame.size = CGSize(width: deliverContainer.frame.width + deliverLabelContainer.frame.width + 36, height: deliverContainer.frame.height)
            view.addSubview(deselectButton)
            deselectButton.addTarget(self, action: #selector(deselectOption(_:)), for: .touchUpInside)
            break
            
        default:
            break
        }
    }
    
    @objc func deselectOption(_ sender: Any) {
        guard let deselectButton = sender as? UIButton else { return }
        
        selectedOption = -1
                
        let current = deselectButton.tag - 500
        selectDelivery(forOption: current, selected: false)
        
        updatePrice(withDeliveryOption: -1) // none selected
        updateLocationLabel(forOption: selectedOption)
    }
    
    @IBAction func didTapLocation(_ sender: Any) {
        guard let locationVC = PostLocationViewController.instance() else { return }
        
        locationVC.postLocation = CLLocation(latitude: selectedProduct.Post_Position.latitude, longitude: selectedProduct.Post_Position.longitude)
        locationVC.postAddress = selectedProduct.Post_Location
        locationVC.strTitle = "Location"
        locationVC.isPresented = true
        
        self.present(locationVC, animated: true, completion: nil)
    }

    @IBAction func didTapBuy(_ sender: Any) {
        guard selectedOption > 0 else {
            showErrorVC(msg: "Please select a delivery option!")
            return
        }
        
        dismiss(animated: true) {
            self.delegate?.purchaseProduct(self.selectedProduct, vid: self.vid, quantity: self.quantity, deliveryOption: self.selectedOption)
        }
    }
}


