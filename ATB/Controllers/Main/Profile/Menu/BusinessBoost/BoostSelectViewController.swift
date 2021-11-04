//
//  BoostSelectViewController.swift
//  ATB
//
//  Created by YueXi on 3/17/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons

class BoostSelectViewController: BaseViewController {
    
    static let kStoryboardID = "BoostSelectViewController"
    class func instance() -> BoostSelectViewController {
        let storyboard = UIStoryboard(name: "BusinessBoost", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: BoostSelectViewController.kStoryboardID) as? BoostSelectViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    
    @IBOutlet weak var saleTagContainer: UIView!
    @IBOutlet weak var imvSaleTag: UIImageView!
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var imvProfile: ProfileView!
    @IBOutlet weak var serviceTagContainer: UIView!
    @IBOutlet weak var imvServiceTag: UIImageView!
    
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var btnProfilePin: MDCRaisedButton!
    @IBOutlet weak var btnPinPoint: MDCRaisedButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        saleTagContainer.layer.cornerRadius = saleTagContainer.bounds.width/2.0
        saleTagContainer.layer.borderWidth = 2
        saleTagContainer.layer.borderColor = UIColor.colorPrimary.cgColor
        
        serviceTagContainer.layer.cornerRadius = serviceTagContainer.bounds.width/2.0
        serviceTagContainer.layer.borderWidth = 2
        serviceTagContainer.layer.borderColor = UIColor.colorPrimary.cgColor
    }
    
    private func setupViews() {
        if #available(iOS 13.0, *) {
            btnClose.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnClose.tintColor = UIColor.white.withAlphaComponent(0.3)
        
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 27)
        lblTitle.textColor = .white
        let titleString = "Boost your Business"
        let attributedTitle = NSMutableAttributedString(string: titleString)
        attributedTitle.addAttributes(
            [.font : UIFont(name: Font.SegoeUIBold, size: 27)!],
            range: (titleString as NSString).range(of: "Business"))
        lblTitle.attributedText = attributedTitle
        
        lblSubtitle.text = "Feature your business and\nhelp customers find you!"
        lblSubtitle.font = UIFont(name: Font.SegoeUILight, size: 21)
        lblSubtitle.textColor = .white
        lblSubtitle.numberOfLines = 0
        lblSubtitle.setLineSpacing(lineHeightMultiple: 0.8)
        lblSubtitle.textAlignment = .center
        
        imvSaleTag.image = UIImage(named: "tag.sale.medium")?.withRenderingMode(.alwaysTemplate)
        imvSaleTag.tintColor = .colorPrimary
        imvSaleTag.contentMode = .scaleAspectFit
        
        imvProfile.borderWidth = 2
        imvProfile.borderColor = .colorPrimary
        let business = g_myInfo.business_profile
        imvProfile.loadImageFromUrl(business.businessPicUrl, placeholder: "profile.placeholder")
        
        imvServiceTag.image = UIImage(named: "tag.service.medium")?.withRenderingMode(.alwaysTemplate)
        imvServiceTag.tintColor = .colorPrimary
        imvServiceTag.contentMode = .scaleAspectFit
        
        lblDescription.text = "It allows you to quickly increase your\nvisibility and reach a large potential\naudience."
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 16)
        lblDescription.textColor = .colorBlue12
        lblDescription.setLineSpacing(lineHeightMultiple: 0.8)
        lblDescription.textAlignment = .center
        lblDescription.numberOfLines = 0
        
        setupButton(for: btnProfilePin, withTitle: "Profile Pin")
        setupButton(for: btnPinPoint, withTitle: "Pin Point")
    }
    
    private func setupButton(for button: MDCRaisedButton, withTitle title: String) {
        button.isUppercaseTitle = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(.colorPrimary, for: .normal)
        button.setTitleFont(UIFont(name: Font.SegoeUISemibold, size: 21), for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .white
        button.imageEdgeInsets.left = SCREEN_WIDTH - 94 // 40(left & right margin) + 30 + 24(image width)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.setImageTintColor(.colorPrimary, for: .normal)
        button.tintColor = .colorPrimary
    }
    
    @IBAction func didTapProfilePin(_ sender: Any) {
        let toVC = ProfilePinViewController.instance()
        navigationController?.pushViewController(toVC, animated: true)
    }
    
    @IBAction func didTapPinPoint(_ sender: Any) {
        let toVC = PinPointViewController.instance()
        navigationController?.pushViewController(toVC, animated: true)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
