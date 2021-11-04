//
//  TextPostCell.swift
//  ATB
//
//  Created by YueXi on 8/24/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

// only advice
class TextPostCell: UITableViewCell {
    
    static let reuseIdentifier = "TextPostCell"

    // shadow effect will be applied to this container view
    @IBOutlet weak var shadowEffectView: UIView! { didSet {
        shadowEffectView.layer.cornerRadius = 5
        shadowEffectView.layer.shadowOffset = CGSize.zero
        shadowEffectView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowEffectView.layer.shadowRadius = 2
        shadowEffectView.layer.shadowOpacity = 0.4
        }}
    
    @IBOutlet weak var vContainer: UIView! { didSet {
        vContainer.layer.cornerRadius = 5
        vContainer.layer.masksToBounds = true
        }}
    
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var imvProfile: ProfileView! { didSet {
        imvProfile.borderWidth = 2
        imvProfile.borderColor = .colorPrimary
        }}
    @IBOutlet weak var lblName: UILabel! { didSet {
        lblName.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblName.textColor = .colorGray2
        }}
    @IBOutlet weak var lblDate: UILabel! { didSet {
        lblDate.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDate.textColor = .colorGray6
        }}
    
    @IBOutlet weak var postContainer: UIView!
    @IBOutlet weak var imvPostTag: UIImageView! { didSet {
        imvPostTag.image = UIImage(named: "tag.advice.medium")?.withRenderingMode(.alwaysTemplate)
        imvPostTag.contentMode = .scaleAspectFit
        }}
    
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblTitle.textColor = .colorGray13
        }}
    @IBOutlet weak var lblDescription: UILabel! { didSet {
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray13
        lblDescription.numberOfLines = 0
//        lblDescription.lineBreakMode = .byClipping // remove three dots(ellipsis)
        }}
    
    @IBOutlet weak var imvLikes: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvLikes.image = UIImage(systemName: "suit.heart.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvLikes.tintColor = .colorGray2
        imvLikes.contentMode = .scaleAspectFit
        }}
    @IBOutlet weak var lblLikes: UILabel! { didSet {
        lblLikes.font = UIFont(name: Font.SegoeUISemibold, size: 16)
        lblLikes.textColor = .colorGray2
        }}
    
    @IBOutlet weak var imvComments: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvComments.image = UIImage(systemName: "bubble.left.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvComments.tintColor = .colorGray2
        imvComments.contentMode = .scaleAspectFit
        }}
    @IBOutlet weak var lblComments: UILabel! { didSet {
        lblComments.font = UIFont(name: Font.SegoeUISemibold, size: 16)
        lblComments.textColor = .colorGray2
        }}
    
    var likeBlock: (() -> Void)? = nil
    var profileTapBlock: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // page
    // 0: in feed, hide the play sign
    // 1: in profile
    // 2: others
    func configureCell(_ post: PostModel, in page: Int = 0) {
        // no need to show poster's profile on the profile page
        profileContainer.isHidden = page == 1
        
        lblTitle.text = post.Post_Title.capitalizingFirstLetter
        lblDescription.text = post.Post_Text.capitalizingFirstLetter
        lblLikes.text = post.Post_Likes
        lblComments.text = post.Post_Comments
        
        let isBusinessPost = post.isBusinessPost
        if isBusinessPost {
            postContainer.backgroundColor = .colorPrimary
            
            imvPostTag.tintColor = .white
            lblTitle.textColor = .white
            lblDescription.textColor = .white
            
            imvLikes.tintColor = .white
            lblLikes.textColor = .white
            imvComments.tintColor = .white
            lblComments.textColor = .white
            
        } else {
            postContainer.backgroundColor = .white
            
            imvPostTag.tintColor = .colorPrimary
            lblTitle.textColor = .colorGray13
            lblDescription.textColor = .colorGray13
            
            imvLikes.tintColor = .colorGray2
            lblLikes.textColor = .colorGray2
            imvComments.tintColor = .colorGray2
            lblComments.textColor = .colorGray2
        }
        
        guard page != 1 else { return }

        imvProfile.loadImageFromUrl(post.Poster_Profile_Img, placeholder: "profile.placeholder")
        lblName.text = post.Poster_Name
        lblDate.text = post.Post_Human_Date
        
        if isBusinessPost {
            profileContainer.backgroundColor = .colorPrimary
            imvProfile.borderColor = .white
            lblName.textColor = .white
            lblDate.textColor = .white
            
        } else {
            profileContainer.backgroundColor = .white
            imvProfile.borderColor = .colorPrimary
            lblName.textColor = .colorGray2
            lblDate.textColor = .colorGray6
        }
    }
    
    @IBAction func didTapProfile(_ sender: Any) {
        profileTapBlock?()
    }
    
    @IBAction func didTapLike(_ sender: Any) {
        likeBlock?()
    }
    
    // content preferred width for title, description
    // 32 - container left & right padding (16*2)
    // 10 - tag image view left margin
    // 34 - tag image view width
    // 20 - left and right padding of title & description
    private static let CONTENT_PREFERRED_WIDTH = SCREEN_WIDTH - 32 - 10 - 34 - 20
    class func cellHeight(_ post: PostModel, isProfile: Bool = false) -> CGFloat {
        // shadow container default top & bottom padding - (8 + 8)
        // like & comments - 36
        // container stack view bottom padding - 4
        var height: CGFloat = 16 + 36 + 4
        
        // top profile container - 42
        if !isProfile {
            height += 42
        }
        
        // add post container height
        height += post.Post_Title.heightForString(CONTENT_PREFERRED_WIDTH, font: UIFont(name: Font.SegoeUISemibold, size: 15)).height
        height += post.Post_Text.heightForString(CONTENT_PREFERRED_WIDTH, font: UIFont(name: Font.SegoeUILight, size: 15)).height
        
        height += 10 // post cotainer stack view bottom padding
        height += 4 // an experience value
        
        return height
    }
}
