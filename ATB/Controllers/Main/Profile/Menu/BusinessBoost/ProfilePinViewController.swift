//
//  ProfilePinViewController.swift
//  ATB
//
//  Created by YueXi on 3/17/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import BadgeHub
import SkeletonView

class ProfilePinViewController: BaseViewController {
    
    static let kStoryboardID = "ProfilePinViewController"
    class func instance() -> ProfilePinViewController {
        let storyboard = UIStoryboard(name: "BusinessBoost", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: ProfilePinViewController.kStoryboardID) as? ProfilePinViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")
        } else {
            // Fallback on earlier versions
        }
        imvBack.tintColor = .white
    }}
    
    @IBOutlet weak var backHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var containerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    private var notificationHub: BadgeHub?
    @IBOutlet weak var imvNotification: UIImageView!
    private var chatHub: BadgeHub?
    @IBOutlet weak var imvChat: UIImageView!
    
    @IBOutlet weak var serviceView: RoundView!
    @IBOutlet weak var imvServiceTag: UIImageView!
    @IBOutlet weak var saleView: RoundView!
    @IBOutlet weak var imvSaleTag: UIImageView!
    @IBOutlet weak var imvProfile: ProfileView!
    @IBOutlet weak var adviceView: RoundView!
    @IBOutlet weak var imvAdviceTag: UIImageView!
    @IBOutlet weak var pollView: RoundView!
    @IBOutlet weak var imvPollTag: UIImageView!
    
    @IBOutlet weak var skeletonContainer: UIView!
    @IBOutlet var skeletonViews: [UIView]!
    
    @IBOutlet weak var txvInformation: UITextView!
    @IBOutlet weak var fadeView: UIView!
    @IBOutlet weak var btnTake: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.extendContainerView()
        }
    }

    private func setupViews() {
        lblTitle.text = "Profile Pin"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 29)
        lblTitle.textColor = .white
        
        if SCREEN_HEIGHT <= 568 {
            // iPhone SE 1st generation
            backHeightConstraint.constant = 1.02 * SCREEN_HEIGHT
            
        } else if SCREEN_HEIGHT <= 667 {
            // iPhone SE 2nd generation, 6, 6s, 7, 8
            backHeightConstraint.constant = 0.99 * SCREEN_HEIGHT
            
        } else if SCREEN_HEIGHT <= 736 {
            // iPhone 6 Plus, 7 Plus, 8 Plus
            backHeightConstraint.constant = 0.96 * SCREEN_HEIGHT
            
        } else if SCREEN_HEIGHT <= 844 {
            // iPhone 12 Pro, 12, 12 mini, 11 Pro, Xs, X
            backHeightConstraint.constant = 0.87 * SCREEN_HEIGHT
            
        } else { //896
            // above iPhone X, Xs Max, 11, 11 Pro Max, 12 Pro Max
            backHeightConstraint.constant = 0.85 * SCREEN_HEIGHT
        }
        
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.layer.cornerRadius = 30
        
        containerWidthConstraint.constant = SCREEN_WIDTH - 36
        
        if #available(iOS 13.0, *) {
            imvNotification.image = UIImage(systemName: "bell.fill")
        } else {
            // Fallback on earlier versions
        }
        imvNotification.tintColor = .colorPrimary
        imvNotification.clipsToBounds = false
        notificationHub = BadgeHub(view: imvNotification)
        notificationHub?.setCircleBorderColor(.white, borderWidth: 1.5)
        notificationHub?.setCircleColor(.colorRed1, label: .clear)
        notificationHub?.scaleCircleSize(by: 0.5)
        notificationHub?.moveCircleBy(x: -4, y: 0)
        notificationHub?.show()
        
        if #available(iOS 13.0, *) {
            imvChat.image = UIImage(systemName: "quote.bubble.fill")
        } else {
            // Fallback on earlier versions
        }
        imvChat.tintColor = .colorPrimary
        imvChat.clipsToBounds = false
        chatHub = BadgeHub(view: imvChat)
        chatHub?.setCircleBorderColor(.white, borderWidth: 1.5)
        chatHub?.setCircleColor(.colorRed1, label: .clear)
        chatHub?.scaleCircleSize(by: 0.5)
        chatHub?.show()
        
        setupTagView(serviceView, tagView: imvServiceTag, imageName: "tag.service.medium")
        setupTagView(saleView, tagView: imvSaleTag, imageName: "tag.sale.medium")
        setupTagView(adviceView, tagView: imvAdviceTag, imageName: "tag.advice.medium")
        setupTagView(pollView, tagView: imvPollTag, imageName: "tag.poll.medium")
        
        let business = g_myInfo.business_profile
        imvProfile.borderWidth = 1.5
        imvProfile.borderColor = .colorPrimary
        imvProfile.loadImageFromUrl(business.businessPicUrl, placeholder: "profile.placeholder")
        
        skeletonContainer.isSkeletonable = true
        for skeletonView in skeletonViews {
            skeletonView.isSkeletonable = true
            skeletonView.skeletonCornerRadius = 5
        }
        
        var skeletonAppearance = SkeletonAppearance.default
        skeletonAppearance.tintColor = .colorGray7
                
        skeletonContainer.showAnimatedSkeleton()
        
        // information
        let profilePinText = "Profile pin gives the business the opportunity to pin their profile at the top of a group as detailed below for 1 week.\n\nHow does this work?\n\nEach week, the 5 slots at the top of the relevant feed become available for businesses to promote themselves via an auction process.\n\nBids begin on Monday at 00:00 with each pin starting at £5.00 with the acution process lasting for one week, during this time all businesses can bid to have their profile promoted.\n\nOnce the bidding process has completed, the 5 businesses with the highest bid will have their Logo pinned to the top of the feed which will have linked to their profile.\n\nAdditionally, each business will have a post of their Store Profile posted every X number of posts on the relevant feed and will have a notification sent to all users informing them of their promotion**\n\nOnce the auction process for the week has completed, it will be reset back to £5.00 giving all businesses equal opportunity to promote their business."
        
        let attributedText = NSMutableAttributedString(string: profilePinText)
        // to the entire text
        attributedText.addAttributes(
            [.font : UIFont(name: Font.SegoeUILight, size: 15)!,
             .foregroundColor: UIColor.colorGray1],
            range: NSRange(location: 0, length: profilePinText.count))
        attributedText.addAttributes(
            [.font: UIFont(name: Font.SegoeUIBold, size: 20)!,
             .foregroundColor: UIColor.colorPrimary],
            range: (profilePinText as NSString).range(of: "How does this work?"))
        let primaryColorAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUISemibold, size: 16)!,
            .foregroundColor: UIColor.colorPrimary
        ]
        attributedText.addAttributes(primaryColorAttrs,
            range: (profilePinText as NSString).range(of: "00:00"))
        attributedText.addAttributes(primaryColorAttrs,
            range: (profilePinText as NSString).range(of: "£5.00"))
        attributedText.addAttributes(primaryColorAttrs,
            range: (profilePinText as NSString).range(of: "the 5 businesses"))
        
        txvInformation.attributedText = attributedText
        
        txvInformation.showsVerticalScrollIndicator = false
        txvInformation.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 150, right: 16)
        txvInformation.isEditable = false
        txvInformation.isSelectable = false
        txvInformation.isHidden = true
        
        txvInformation.transform = CGAffineTransform(translationX: 0, y: txvInformation.bounds.height - 100)
        
        fadeView.fadeOut(style: .top, percentage: 0.9)
        
        
        btnTake.setTitle("Take me to Profile Pin ", for: .normal)
        btnTake.backgroundColor = .colorPrimary
        btnTake.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        btnTake.setTitleColor(.white, for: .normal)
        if #available(iOS 13.0, *) {
            btnTake.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        
        // make sure to set this after setting icon and title
        if let imageView = btnTake.imageView,
           let titleLabel = btnTake.titleLabel {
            btnTake.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageView.frame.size.width, bottom: 0, right: imageView.frame.size.width)
            btnTake.imageEdgeInsets = UIEdgeInsets(top: 0, left: titleLabel.frame.size.width, bottom: 0, right: -titleLabel.frame.size.width)
        }
        
        btnTake.layer.cornerRadius = 5
        btnTake.tintColor = .white
        btnTake.alpha = 0
        
        btnTake.transform = CGAffineTransform(translationX: 0, y: 90)
        
        view.isUserInteractionEnabled = false
    }
    
    private func setupTagView(_ container: RoundView, tagView: UIImageView, imageName: String) {
        container.borderWidth = 1.5
        container.borderColor = .colorPrimary
        
        tagView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        tagView.tintColor = .colorPrimary
        tagView.contentMode = .scaleAspectFit
    }
    
    private func extendContainerView() {
        containerWidthConstraint.constant = SCREEN_WIDTH
        
        skeletonContainer.hideSkeleton(transition: .crossDissolve(0.5))
        
        UIView.animate(withDuration: 0.75, delay: 0.0, options: .curveEaseInOut, animations: {
            self.containerView.layer.cornerRadius = 0
            self.view.layoutIfNeeded()
            
        }, completion: { _ in
            self.autoScrollTextView()
        })
    }
    
    private func autoScrollTextView() {
        txvInformation.isHidden = false
        
        UIView.animate(withDuration: 0.8, animations: {
            self.txvInformation.transform = .identity
            
            self.btnTake.transform = .identity
            self.btnTake.alpha = 1
            
        }, completion: { _  in
            self.view.isUserInteractionEnabled = true
        })
    }
    
    @IBAction func didTapNotification(_ sender: Any) {
        
    }
    
    @IBAction func didTapChat(_ sender: Any) {
        
    }
    
    @IBAction func didTapATB(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func didTapTake(_ sender: Any) {
        let toVC = ProfileAuctionViewController.instance()
        navigationController?.pushViewController(toVC, animated: true)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
