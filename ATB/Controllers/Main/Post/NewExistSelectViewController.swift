//
//  NewExistSelectViewController.swift
//  ATB
//
//  Created by YueXi on 7/27/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons
import VisualEffectView

class NewExistSelectViewController: BaseViewController {
    
    static let kStoryboardID = "NewExistSelectViewController"
    class func instance() -> NewExistSelectViewController {
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: NewExistSelectViewController.kStoryboardID) as? NewExistSelectViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    // This will be true when user selected "Post Sale"
    // service selected: false
    var isSales: Bool = true

    @IBOutlet weak var blurView: UIView!
    @IBOutlet weak var imvLogo: UIImageView!
    
    @IBOutlet weak var lblDescription: UILabel!
    
//    @IBOutlet weak var
    
    @IBOutlet weak var btnCancel: MDCButton!
    
    @IBOutlet weak var vNewContainer: UIView!
    @IBOutlet weak var lblNewPost: UILabel!
    @IBOutlet weak var imvNewPost: UIImageView!
    @IBOutlet weak var btnNewPost: MDCRaisedButton!
    
    @IBOutlet weak var vExistingContainer: UIView!
    @IBOutlet weak var lblExistingPost: UILabel!
    @IBOutlet weak var imvExistingPost: UIImageView!
    @IBOutlet weak var btnExistingPost: MDCRaisedButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        self.view.backgroundColor = .clear
        blurView.backgroundColor = .clear
        
        let blurEffectView = VisualEffectView()
        blurEffectView.frame = self.view.bounds
        blurEffectView.colorTint = UIColor.colorPrimary
        blurEffectView.colorTintAlpha = 0.69
        blurEffectView.blurRadius = 5
        blurEffectView.scale = 1
        
        blurView.insertSubview(blurEffectView, at: 0)
        
        imvLogo.image = isSales ? UIImage(named: "tag.sale.high")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "tag.service.high")?.withRenderingMode(.alwaysTemplate)
        imvLogo.tintColor = UIColor.colorBlue9.withAlphaComponent(0.7)
        imvLogo.contentMode = .scaleAspectFit
        
        lblDescription.text = "I want to post"
        lblDescription.font = UIFont(name: Font.SegoeUISemibold, size: 30)
        lblDescription.textColor = .white
        
        vNewContainer.layer.cornerRadius = 10
        setupIconView(imvNewPost, iconName: "plus")
        setupLabel(lblNewPost, title: isSales ? "A New Product" : "A New Service")
        setupButton(btnNewPost)
        
        vExistingContainer.layer.cornerRadius = 10
        setupIconView(imvExistingPost, iconName: "chevron.right")
        setupLabel(lblExistingPost, title: isSales ? "One of My Existing Products" : "One of My Services")
        setupButton(btnExistingPost)
        
        btnCancel.isUppercaseTitle = false
        let underlineAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUILight, size: 16)!,
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.white
        ]
        btnCancel.setAttributedTitle(NSAttributedString(string: "Cancel", attributes: underlineAttributes), for: .normal)
        btnCancel.backgroundColor = .clear
        btnCancel.tintColor = .white
    }
    
    private func setupIconView(_ imageView: UIImageView, iconName: String) {
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: iconName)?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .colorPrimary
    }
    
    private func setupLabel(_ label: UILabel, title: String) {
        label.text = title
        label.font = UIFont(name: Font.SegoeUIBold, size: 18)
        label.textColor = .colorPrimary
    }
    
    private func setupButton(_ button: UIButton) {
        button.layer.cornerRadius = 10
        button.backgroundColor = .white
    }
    
    @IBAction func didTapPostNew(_ sender: Any) {
        let newPostVC = isSales ? PostProductViewController.instance() : PostServiceViewController.instance()
        self.navigationController?.pushViewController(newPostVC, animated: true)
    }
    
    @IBAction func didTapPostExist(_ sender: Any) {
        let postExistingVC = PostExistingViewController.instance()
        postExistingVC.isSales = isSales
              
        self.navigationController?.pushViewController(postExistingVC, animated: true)
    }
    

    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true)
    }
}


