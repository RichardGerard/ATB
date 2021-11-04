//
//  LikesTableViewCell.swift
//  ATB
//
//  Created by mobdev on 2019/5/23.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class LikesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imvProfile: RoundImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    
    @IBOutlet weak var btnAction: UIButton!
    
    var actionBlock: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        btnAction.layer.cornerRadius = 5
        btnAction.layer.borderWidth = 1
        btnAction.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 13)
    }
    
    // isFollowers - represent whether you are on Followers or Followings list
    // isFollowing - useful only when you are seeing other's profile and represents whether you are following or not
    func configure(withUser user: UserModel, isOwnProfile: Bool, isFollowers: Bool, isFollowing: Bool) {
        if isFollowers {
            imvProfile.loadImageFromUrl(user.profile_image, placeholder: "profile.placeholder")
            lblName.text = user.firstName + " " + user.lastName
            lblUsername.text = "@" + user.user_name
            lblUsername.textColor = .colorGray2
            
        } else {
            if user.isBusiness {
                let business = user.business_profile
                imvProfile.loadImageFromUrl(business.businessPicUrl, placeholder: "post.placeholder")
                lblName.text = business.businessProfileName
                lblUsername.text = business.businessWebsite
                lblUsername.textColor = .colorPrimary
                
            } else {
                imvProfile.loadImageFromUrl(user.profile_image, placeholder: "profile.placeholder")
                lblName.text = user.firstName + " " + user.lastName
                lblUsername.text = "@" + user.user_name
                lblUsername.textColor = .colorGray2
            }
        }
        
        if isOwnProfile {
            btnAction.backgroundColor = .clear
            
            if isFollowers {
                btnAction.layer.borderColor = UIColor.colorRed2.cgColor
                
                btnAction.setTitle("DELETE", for: .normal)
                btnAction.setTitleColor(.colorRed2, for: .normal)
                
            } else {
                btnAction.layer.borderColor = UIColor.colorPrimary.cgColor
                
                btnAction.setTitle("UNFOLLOW", for: .normal)
                btnAction.setTitleColor(.colorPrimary, for: .normal)
            }
            
        } else {
            btnAction.layer.borderColor = UIColor.colorPrimary.cgColor
            
            if user.ID == g_myInfo.ID {
                btnAction.isHidden = true
                
            } else {
                btnAction.isHidden = false
                
                if isFollowing {
                    btnAction.backgroundColor = .colorPrimary
                    
                    btnAction.setTitle("FOLLOWING", for: .normal)
                    btnAction.setTitleColor(.white, for: .normal)
                    
                } else {
                    btnAction.backgroundColor = .clear
                    
                    btnAction.setTitle("FOLLOW", for: .normal)
                    btnAction.setTitleColor(.colorPrimary, for: .normal)
                }
            }
        }
    }
    
    @IBAction func didTapActionButton(_ sender: Any) {
        actionBlock?()
    }
}
