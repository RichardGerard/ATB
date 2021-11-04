//
//  PostViewController.swift
//  ATB
//
//  Created by YueXi on 7/27/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons

class PostSelectViewController: BaseViewController {
    
    static let kStoryboardID = "PostSelectViewController"
    class func instance() -> PostSelectViewController {
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: PostSelectViewController.kStoryboardID) as? PostSelectViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var vAdviceContainer: UIView!
    @IBOutlet weak var imvAdvice: UIImageView!
    @IBOutlet weak var lblAdvice: UILabel!
    @IBOutlet weak var btnAdvice: MDCRaisedButton!
    
    @IBOutlet weak var vSaleContainer: UIView!
    @IBOutlet weak var imvSale: UIImageView!
    @IBOutlet weak var lblSale: UILabel!
    @IBOutlet weak var btnSale: MDCRaisedButton!
    
    @IBOutlet weak var vServiceContainer: UIView!
    @IBOutlet weak var imvService: UIImageView!
    @IBOutlet weak var lblService: UILabel!
    @IBOutlet weak var btnService: MDCRaisedButton!
    
    @IBOutlet weak var vPollContainer: UIView!
    @IBOutlet weak var imvPoll: UIImageView!
    @IBOutlet weak var lblPoll: UILabel!
    @IBOutlet weak var btnPoll: MDCRaisedButton!
    
    @IBOutlet weak var vPostContainer: UIView!
    @IBOutlet weak var lblPost: UILabel!
    @IBOutlet weak var imvPost: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        self.view.backgroundColor = UIColor.colorPrimary.withAlphaComponent(0.8)
        
        lblDescription.text = "What do you want\nto post?"
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
        
        vAdviceContainer.layer.cornerRadius = 10
        setupIconView(imvAdvice, iconName: "tag.advice")
        lblAdvice.font = UIFont(name: Font.SegoeUILight, size: 16)
        lblAdvice.textColor = .colorPrimary
        
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUISemibold, size: 24)!
        ]
        
        let adviceText = "Advice\nRecommendations or Help"
        let attributedAdvice = NSMutableAttributedString(string: adviceText)
        let adviceRange = (adviceText as NSString).range(of: "Advice")
        attributedAdvice.addAttributes(boldAttrs, range: adviceRange)
        
        lblAdvice.attributedText = attributedAdvice
        lblAdvice.numberOfLines = 2
        lblAdvice.setLineSpacing(lineHeightMultiple: 0.75)
        setupButton(btnAdvice)
        
        vSaleContainer.layer.cornerRadius = 10
        setupIconView(imvSale, iconName: "tag.sale")
        setupLabel(lblSale, title: "Sale Posts")
        setupButton(btnSale)
        
        vServiceContainer.layer.cornerRadius = 10
        setupIconView(imvService, iconName: "tag.service")
        setupLabel(lblService, title: "Service Offered")
        setupButton(btnService)
        
        vPollContainer.layer.cornerRadius = 10
        setupIconView(imvPoll, iconName: "tag.poll")
        setupLabel(lblPoll, title: "Poll/Voting")
        setupButton(btnPoll)
        
        vPostContainer.layer.cornerRadius = 52
        vPostContainer.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        
        lblPost.text = "Post"
        lblPost.font = UIFont(name: Font.SegoeUIBold, size: 16)
        lblPost.textColor = .white
        
        imvPost.image = UIImage(named: "WhitePostIcon")?.withRenderingMode(.alwaysTemplate)
        imvPost.contentMode = .scaleAspectFit
        imvPost.tintColor = .white
        
        // posting a service is only available for only approved businesses
        vServiceContainer.isHidden = !g_myInfo.isBusinessApproved
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
    
    private func setupButton(_ button: UIButton) {
        button.layer.cornerRadius = 10
        button.backgroundColor = .white
    }
    
    @IBAction func didTapAdvice(_ sender: Any) {
        let postAdviceVC = PostAdviceViewController.instance()
        self.navigationController?.pushViewController(postAdviceVC, animated: true)
    }
    
    @IBAction func didTapSale(_ sender: Any) {
        let saleSelectVC = NewExistSelectViewController.instance()
        
        let nvc = UINavigationController(rootViewController: saleSelectVC)
        nvc.isNavigationBarHidden = true        
        nvc.modalPresentationStyle = .overFullScreen
        nvc.modalTransitionStyle = .crossDissolve
        
        self.present(nvc, animated: true)
    }
    
    @IBAction func didTapService(_ sender: Any) {
        let serviceSelectVC = NewExistSelectViewController.instance()
        serviceSelectVC.isSales = false
        
        let nvc = UINavigationController(rootViewController: serviceSelectVC)
        nvc.isNavigationBarHidden = true
        nvc.modalPresentationStyle = .overFullScreen
        nvc.modalTransitionStyle = .crossDissolve
        
        self.present(nvc, animated: true)
    }
    
    @IBAction func didTapPoll(_ sender: Any) {
        // Post Poll
        let newPollPostVC = PostPollViewController.instance()
        self.navigationController?.pushViewController(newPollPostVC, animated: true)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
}

