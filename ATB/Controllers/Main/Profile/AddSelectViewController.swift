//
//  AddSelectViewController.swift
//  ATB
//
//  Created by YueXi on 7/26/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons
import SemiModalViewController

class AddSelectViewController: BaseViewController {
    
    static let kStoryboardID = "AddSelectViewController"
    class func instance() -> AddSelectViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: AddSelectViewController.kStoryboardID) as? AddSelectViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var vProductContainer: UIView!
    @IBOutlet weak var imvProduct: UIImageView!
    @IBOutlet weak var lblProduct: UILabel!
    @IBOutlet weak var btnAddProduct: MDCRaisedButton!
    
    @IBOutlet weak var vServiceContainer: UIView!
    @IBOutlet weak var imvService: UIImageView!
    @IBOutlet weak var lblService: UILabel!
    @IBOutlet weak var btnAddService: MDCRaisedButton!
    
    var delegate: BusinessAddDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        self.view.backgroundColor = UIColor.colorPrimary.withAlphaComponent(0.8)
        
        lblDescription.text = "What do you want\nto add?"
        lblDescription.font = UIFont(name: Font.SegoeUISemibold, size: 29)
        lblDescription.textColor = .white
        lblDescription.numberOfLines = 2
        lblDescription.setLineSpacing(lineHeightMultiple: 0.75)
        
        if #available(iOS 13.0, *) {
            btnClose.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnClose.tintColor = UIColor.white
        
        vProductContainer.layer.cornerRadius = 10
        setupIconView(imvProduct, iconName: "tag.sale")
        setupLabel(lblProduct, title: "Product")
        btnAddProduct.layer.cornerRadius = 10
        btnAddProduct.backgroundColor = .white
        
        vServiceContainer.layer.cornerRadius = 10
        setupIconView(imvService, iconName: "tag.service")
        setupLabel(lblService, title: "Service")
        btnAddService.layer.cornerRadius = 10
        btnAddService.backgroundColor = .white
    }
    
    private func setupIconView(_ imageView: UIImageView, iconName: String) {
        imageView.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .colorPrimary
    }
    
    private func setupLabel(_ label: UILabel, title: String) {
        label.text = title
        label.font = UIFont(name: Font.SegoeUISemibold, size: 24)
        label.textColor = .colorPrimary
    }
    
    @IBAction func didTapAddProduct(_ sender: Any) {
        let postProductVC = PostProductViewController.instance()
        postProductVC.isPosting = false
        postProductVC.view.frame.size.height = SCREEN_HEIGHT - 44
        // just send over self.delegate
        postProductVC.delegate = delegate
        // set this flag as 'True' to get the profile page directly
        // as soon as new products are added
        postProductVC.isFromBusinessStore = true
        
        let options: [SemiModalOption : Any] = [
            SemiModalOption.pushParentBack: false,
            SemiModalOption.parentScale: 1.0,
            SemiModalOption.animationDuration: 0.35]
        
        presentSemiViewController(postProductVC, options: options)
    }
    
    @IBAction func didTapAddService(_ sender: Any) {
        let postServiceVC = PostServiceViewController.instance()
        postServiceVC.isPosting = false
        postServiceVC.view.frame.size.height = SCREEN_HEIGHT - 44
        // just send over self.delegate
        postServiceVC.delegate = delegate
        // set this flag as 'True' to get the profile page directly
        // as soon as a new service ia added/posted
        postServiceVC.isFromBusinessStore = true
        
        let options: [SemiModalOption : Any] = [
            SemiModalOption.pushParentBack: false,
            SemiModalOption.parentScale: 1.0,
            SemiModalOption.animationDuration: 0.35]
        
        presentSemiViewController(postServiceVC, options: options)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}


