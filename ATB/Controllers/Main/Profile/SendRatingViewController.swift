//
//  SendRatingViewController.swift
//  ATB
//
//  Created by mobdev on 2019/5/27.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import VisualEffectView

class SendRatingViewController: BaseViewController {
    
    static let kStoryboardID = "SendRatingViewController"
    class func instance() -> SendRatingViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: SendRatingViewController.kStoryboardID) as? SendRatingViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvBack.tintColor = .white
        imvBack.contentMode = .scaleAspectFit
        }}
    
    @IBOutlet weak var imvBusinessProfile: UIImageView!
    
    @IBOutlet weak var lblBusinessName: UILabel! { didSet {
        lblBusinessName.text = ""
        lblBusinessName.font = UIFont(name: Font.SegoeUISemibold, size: 36)
        lblBusinessName.textColor = .white
        }}
    @IBOutlet weak var lblBusinessUsername: UILabel! { didSet {
        lblBusinessName.text = "@"
        lblBusinessUsername.font = UIFont(name: Font.SegoeUILight, size: 22)
        lblBusinessUsername.textColor = .white
        }}
    
    @IBOutlet weak var lblDescription: UILabel! { didSet {
        lblDescription.text = "What do you think about this\nbusiness?"
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 23)
        lblDescription.textColor = .white
        lblDescription.numberOfLines = 0
        lblDescription.setLineSpacing(lineHeightMultiple: 0.75)
        // make sure to set text alignment after linespacing
        lblDescription.textAlignment = .center
        }}
  
    @IBOutlet weak var vRatingContainer: UIView! { didSet {
        vRatingContainer.backgroundColor = .colorGray14
        vRatingContainer.layer.cornerRadius = 5
        }}
    @IBOutlet weak var ratingView: CosmosView! { didSet {
        ratingView.settings.starSize = 46
        ratingView.settings.totalStars = 5
        ratingView.settings.fillMode = .full
        ratingView.settings.minTouchRating = 0
        ratingView.settings.filledImage = UIImage(named: "star.rating.fill")
        ratingView.settings.emptyImage = UIImage(named: "star.rating.empty")
        }}
    @IBOutlet weak var lblRatingDescription: UILabel!{ didSet {
        lblRatingDescription.textColor = .colorGray5
        lblRatingDescription.font = UIFont(name: Font.SegoeUISemibold, size: 23)
        lblRatingDescription.numberOfLines = 2
        lblRatingDescription.textAlignment = .center
        }}
    @IBOutlet weak var txvCommnet: RoundRectTextView! { didSet {
        txvCommnet.font = UIFont(name: Font.SegoeUILight, size: 18)
        txvCommnet.textColor = .colorGray19
        txvCommnet.tintColor = .colorGray19
        txvCommnet.placeholder = "Leave an optional comment, so the other user can read your personal advise"
        }}
    
    @IBOutlet weak var btnSendRating: RoundedShadowButton! { didSet {
        btnSendRating.setTitle("Send Rating", for: .normal)
        btnSendRating.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        btnSendRating.setTitleColor(.white, for: .normal)
        btnSendRating.backgroundColor = .colorBlue5
        }}
    
    var viewingUser: UserModel? = nil
    
    var shadowBackView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    var isAlreadyRated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        hideKeyboardWhenTapped()
    }

    private func setupViews() {
        view.addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 47)
        
        if let viewingUser = self.viewingUser {
            let businessProfile = viewingUser.business_profile
            lblBusinessName.text = businessProfile.businessProfileName
            lblBusinessUsername.text = "@" + businessProfile.businessName
            
            imvBusinessProfile.loadImageFromUrl(businessProfile.businessPicUrl, placeholder: "profile.placeholder")
        }
        
        
        ratingView.rating = 4
        
        let ratingDescription = "Why makes it good?\n(optional)"
        let attributedDesc = NSMutableAttributedString(string: ratingDescription)

        let optionAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUILight, size: 16)!
        ]
        let optionRange = (ratingDescription as NSString).range(of: "(optional)")
        attributedDesc.addAttributes(optionAttrs, range: optionRange)
        lblRatingDescription.attributedText = attributedDesc
        lblRatingDescription.setLineSpacing(lineHeightMultiple: 0.75)
        lblRatingDescription.textAlignment = .center
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapSendRating(_ sender: Any) {
        guard let viewingUser = self.viewingUser else { return }
        
        if (isAlreadyRated) {
            self.showErrorVC(msg: "Rating already submitted.")

        } else {
            let rating = self.ratingView.rating

            let params = [
                "token" : g_myToken,
                "business_id" : viewingUser.business_profile.ID,
                "rating" : rating,
                "review" : txvCommnet.text!
                ] as [String : Any]

            _ = ATB_Alamofire.POST(ADD_BUSINESS_REVIEWS, parameters: params as [String : AnyObject], showLoading: true) { (result, response) in
                if result {
                    self.showThanksView()
                    
                    self.isAlreadyRated = true
                }
            }
        }
    }
    
    private func showThanksView() {
        let toastView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        toastView.backgroundColor = .clear
        toastView.layer.cornerRadius = 5
        toastView.layer.masksToBounds = true
        
        let blurEffectView = VisualEffectView()
        blurEffectView.frame = toastView.frame
        blurEffectView.colorTint = UIColor.black
        blurEffectView.colorTintAlpha = 0.35
        blurEffectView.blurRadius = 6
        blurEffectView.scale = 1
        toastView.insertSubview(blurEffectView, at: 0)
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        toastView.addSubview(imageView)
        toastView.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: toastView.topAnchor, constant: 25),
            imageView.centerXAnchor.constraint(equalTo: toastView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            label.leftAnchor.constraint(equalTo: toastView.leftAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: toastView.rightAnchor, constant: -20),
        ])
        
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imageView.tintColor = .white

        let message = "Thanks!\nYour rating has been posted"
        label.font = UIFont(name: Font.SegoeUILight, size: 20)
        label.textColor = .white
        label.numberOfLines = 0
        
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUISemibold, size: 34)!
        ]
        
        let attributedMsg = NSMutableAttributedString(string: message)
        let thanksRange = (message as NSString).range(of: "Thanks!")
        attributedMsg.addAttributes(boldAttrs, range: thanksRange)
        
        label.attributedText = attributedMsg
        label.setLineSpacing(lineHeightMultiple: 0.8)
        label.textAlignment = .center
        
        showToast(toastView, position: .center)
    }
}

