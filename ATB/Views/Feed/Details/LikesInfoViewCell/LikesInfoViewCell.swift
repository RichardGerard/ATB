//
//  LikesInfoViewCell.swift
//  ATB
//
//  Created by YueXi on 9/11/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

// MARK: - @Protocol LikesInfoDelegate
protocol LikesInfoDelegate {
    
    func didTapLike()
    func didTapSave()
}

class LikesInfoViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "LikesInfoViewCell"
    
    @IBOutlet weak var vContainer: UIView! { didSet {
        vContainer.backgroundColor = .colorGray7
        }}
    
    @IBOutlet weak var imvLike: UIImageView! { didSet {
        imvLike.contentMode = .scaleAspectFit
        }}
    @IBOutlet weak var lblLikes: UILabel! { didSet {
        lblLikes.text = ""
        lblLikes.font = UIFont(name: Font.SegoeUILight, size: 17)
        }}
    
    @IBOutlet weak var imvComment: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvComment.image = UIImage(systemName: "bubble.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvComment.tintColor = .colorGray2
        imvComment.contentMode = .scaleAspectFit
        }}
    @IBOutlet weak var lblComments: UILabel! { didSet {
        lblComments.text = "1,1k Comments"
        lblComments.font = UIFont(name: Font.SegoeUILight, size: 17)
        lblComments.textColor = .colorGray2
        }}
    
    @IBOutlet weak var vBookmakrContainer: UIView!
    @IBOutlet weak var imvBookmark: UIImageView! { didSet {
        imvBookmark.contentMode = .scaleAspectFit
        }}
    
    @IBOutlet weak var vSeparator: UIView! { didSet {
        vSeparator.backgroundColor = .colorGray4
        }}
    
    private let boldAttrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: Font.SegoeUISemibold, size: 19)!
    ]
    
    var delegate: LikesInfoDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureCell(_ post: PostModel, isOwnPost: Bool = false, isLiked: Bool, isSaved: Bool) {
        if isLiked {
            if #available(iOS 13.0, *) {
                imvLike.image = UIImage(systemName: "suit.heart.fill")?.withRenderingMode(.alwaysTemplate)
            } else {
                // Fallback on earlier versions
            }
            imvLike.tintColor = .colorPrimary
            
            lblLikes.textColor = .colorPrimary
            
        } else {
            if #available(iOS 13.0, *) {
                imvLike.image = UIImage(systemName: "suit.heart")?.withRenderingMode(.alwaysTemplate)
            } else {
                // Fallback on earlier versions
            }
            imvLike.tintColor = .colorGray2

            lblLikes.textColor = .colorGray2
        }
        
        let likes = post.Post_Likes.intValue
        let likesString = "\(likes)" + (likes > 1 ? " Likes" : " Like")
        let attributedLikes = NSMutableAttributedString(string: likesString)
        let likesRange = (likesString as NSString).range(of: "\(likes)")
        attributedLikes.addAttributes(boldAttrs, range: likesRange)
        lblLikes.attributedText = attributedLikes
        
        let comments = post.Post_Comments.intValue
        let commentsString = "\(comments)" + (comments > 1 ? " Comments" : " Comment")
        let attributedComments = NSMutableAttributedString(string: commentsString)
        let commentsRange = (commentsString as NSString).range(of: "\(comments)")
        attributedComments.addAttributes(boldAttrs, range: commentsRange)
        lblComments.attributedText = attributedComments
        
        vBookmakrContainer.isHidden = isOwnPost
        
        if isSaved {
            if #available(iOS 13.0, *) {
                imvBookmark.image = UIImage(systemName: "bookmark.fill")?.withRenderingMode(.alwaysTemplate)
            } else {
                // Fallback on earlier versions
            }
            imvBookmark.tintColor = .colorPrimary
            
        } else {
            if #available(iOS 13.0, *) {
                imvBookmark.image = UIImage(systemName: "bookmark")?.withRenderingMode(.alwaysTemplate)
            } else {
                // Fallback on earlier versions
            }
            imvBookmark.tintColor = .colorGray2
        }
    }
    
    @IBAction func didTapLike(_ sender: Any) {
        delegate?.didTapLike()
    }
    
    @IBAction func didTapBookmark(_ sender: Any) {
        delegate?.didTapSave()
    }
}
