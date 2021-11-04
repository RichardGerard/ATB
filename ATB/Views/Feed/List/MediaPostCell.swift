//
//  MediaPostCell.swift
//  ATB
//
//  Created by YueXi on 8/24/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Kingfisher
import AVKit
import AVFoundation

// advice post with media
// sale post with media
// service post with media
class MediaPostCell: UITableViewCell, ASAutoPlayVideoLayerContainer {
    
    static let reuseIdentifier = "MediaPostCell"
    
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
        lblName.textColor = .colorGray2  // normal color
        }}
    @IBOutlet weak var lblDate: UILabel! { didSet {
        lblDate.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDate.textColor = .colorGray6 // normal color
        }}
    
    @IBOutlet weak var imvPost: UIImageView! { didSet {
        imvPost.contentMode = .scaleAspectFill
        }}
    @IBOutlet weak var vPlay: UIView!
    @IBOutlet weak var vBadgeContainer: UIView! { didSet {
        vBadgeContainer.backgroundColor = UIColor.black.withAlphaComponent(0.22)
        vBadgeContainer.layer.cornerRadius = 13
        vBadgeContainer.layer.masksToBounds = true
        }}
    @IBOutlet weak var imvPostTag: UIImageView! { didSet {
        imvPostTag.contentMode = .center
        }}
    
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblTitle.textColor = .colorGray13
        lblTitle.minimumScaleFactor = 0.9
        lblTitle.adjustsFontSizeToFitWidth = true
        }}
    @IBOutlet weak var lblPrice: UILabel! { didSet {
        lblPrice.font = UIFont(name: Font.SegoeUISemibold, size: 16)
        lblPrice.textColor = .colorPrimary
        }}
    @IBOutlet weak var lblDescription: UILabel! { didSet {
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray13
        lblDescription.numberOfLines = 2
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
    
    private let normalPriceAttrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: Font.SegoeUILight, size: 16)!
    ]
    
    var likeBlock: (() -> Void)? = nil
    var profileTapBlock: (() -> Void)? = nil
    
    // MARK: - ASAutoPlayViewLayerContainer
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    var videoURL: String? {
        didSet {
            if let videoURL = videoURL {
                ASVideoPlayerController.sharedVideoPlayer.setupVideoFor(url: videoURL)
            }
            
            videoLayer.isHidden = (videoURL == nil)
        }
    }
    
    func visibleVideoHeight() -> CGFloat {
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.convert(imvPost.frame, from: imvPost)
        guard let videoFrame = videoFrameInParentSuperView,
            let superViewFrame = superview?.frame else {
             return 0
        }
        
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        return visibleVideoFrame.size.height
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
        selectionStyle = .none
        
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        imvPost.layer.addSublayer(videoLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let horizontalMargin: CGFloat = 16
        let width: CGFloat = bounds.size.width - horizontalMargin * 2
        let height: CGFloat = (width * 358/340).rounded(.up)
        videoLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        lblPrice.textColor = .colorPrimary
        imvPost.image = nil
    }
    
    // page
    // 0: in feed, hide the play sign
    // 1: in profile
    // 2: others
    func configureCell(_ post: PostModel, in page: Int = 0) {
        // no need to show poster's profile on the profile page
        profileContainer.isHidden = page == 1
        
        // hide the play sign on the feed
        vPlay.isHidden = (page == 0) || !post.isVideoPost
                        
        let url = post.Post_Media_Urls.count > 0 ? post.Post_Media_Urls[0] : ""
        if post.isVideoPost {
            // set placeholder
            imvPost.image = UIImage(named: "post.placeholder")
            
            if ImageCache.default.imageCachedType(forKey: url).cached {
                ImageCache.default.retrieveImage(forKey: url) { result in
                    switch result {
                    case .success(let cacheResult):
                        if let image = cacheResult.image {
                            let animation = CATransition()
                            animation.type = .fade
                            animation.duration = 0.25
                            self.imvPost.layer.add(animation, forKey: "transition")
                            self.imvPost.image = image
                        }
                        
                        break
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                }
                
            } else {
                // thumbnail is not cached, get thumbnail from video url
                Utils.shared.getThumbnailImageFromVideoUrl(url) { thumbnail in
                    if let thumbnail = thumbnail {
                        let animation = CATransition()
                        animation.type = .fade
                        animation.duration = 0.3
                        self.imvPost.layer.add(animation, forKey: "transition")
                        self.imvPost.image = thumbnail
                        
                        ImageCache.default.store(thumbnail, forKey: url)
                    }
                }
            }
            
            if page == 0 {
                videoURL = url
            }
            
        } else {
            imvPost.loadImageFromUrl(url, placeholder: "post.placeholder")
            
            if page == 0 {
                videoURL = nil
            }
        }
        
        let isBusinessPost = post.isBusinessPost        
        vBadgeContainer.isHidden = !isBusinessPost
        
        switch post.Post_Type {
            case "Advice": imvPostTag.image = UIImage(named: "tag.advice")
            case "Sales": imvPostTag.image = UIImage(named: "tag.sale")
            case "Service": imvPostTag.image = UIImage(named: "tag.service")
            case "Poll": imvPostTag.image = UIImage(named: "tag.poll")
            default: imvPostTag.image = nil
        }
        
        lblTitle.text = post.Post_Title.capitalizingFirstLetter
        lblDescription.text = post.Post_Text.capitalizingFirstLetter
        lblLikes.text = post.Post_Likes
        lblComments.text = post.Post_Comments
                
        if post.isSale || post.isService {
            lblPrice.isHidden = false
            
            if post.isSale {
                if post.isSoldOut {
                    lblPrice.text = "SOLD"
                    lblPrice.textColor = .colorRed1
                    
                } else {
                    lblPrice.text = "£" + post.Post_Price
                    lblPrice.textColor =  isBusinessPost ? .white : .colorPrimary
                }
                
            } else {
                let priceString = "Starting at £" + post.Post_Price
                let attributedPrice = NSMutableAttributedString(string: priceString)
                let startAtRange = (priceString as NSString).range(of: "Starting at ")
                attributedPrice.addAttributes(normalPriceAttrs, range: startAtRange)
                
                lblPrice.attributedText = attributedPrice
                lblPrice.textColor =  isBusinessPost ? .white : .colorPrimary
            }
            
        } else {
            lblPrice.text = ""
            lblPrice.isHidden = true
        }
        
        if isBusinessPost {
            bottomContainer.backgroundColor = .colorPrimary
            lblTitle.textColor = .white
            lblDescription.textColor = .white
            
            imvLikes.tintColor = .white
            lblLikes.textColor = .white
            
            imvComments.tintColor = .white
            lblComments.textColor = .white
            
        } else {
            bottomContainer.backgroundColor = .white
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
    
    // content preferred width for title, price, description
    // 32 - container left & right padding (16*2)
    // 20 - left and right padding of title & description
    private static let CONTENT_PREFERRED_WIDTH = SCREEN_WIDTH - 32 - 20
    class func cellHeight(_ post: PostModel, isProfile: Bool = false) -> CGFloat {
        // shadow container default top & bottom padding - (8 + 8)
        // like & comments - 36
        // container stack view bottom padding - 4
        var height: CGFloat = 16 + 36 + 4
        
        // top profile container - 42
        if !isProfile {
            height += 42
        }
        
        // media container height
        height += (SCREEN_WIDTH - 32) * 179/170.0 // the design ratio
        
        // height for title, price, description
        // price is hidden for advice post with media
        // only shows for product & service post(this always has media)
        
        // top margin for title (post container stackview)
        height += 10
        // title - 1 line
        // height for title
        height += UIFont(name: Font.SegoeUISemibold, size: 15)!.lineHeight
//        height += post.Post_Title.heightForString(CONTENT_PREFERRED_WIDTH, font: UIFont(name: Font.SegoeUISemibold, size: 15)).height
        
        // price
        if post.isSale || post.isService {
            // top margin for price
            height += 2
            // height for price
            height += ("£ " + post.Post_Price).heightForString(CONTENT_PREFERRED_WIDTH, font: UIFont(name: Font.SegoeUISemibold, size: 16)).height
        }
        
        // description
        // top margin for description
        height += 5
        let estimatedFrame = post.Post_Text.heightForString(CONTENT_PREFERRED_WIDTH, font: UIFont(name: Font.SegoeUILight, size: 15))
        let lineHeight = UIFont(name: Font.SegoeUILight, size: 15)!.lineHeight
        // limit post description as 2 lines
        if estimatedFrame.height > 2.0*lineHeight {
            height += 2.0*lineHeight
            
        } else {
            height += estimatedFrame.height
        }
        
        // description bottom margin
        height += 2
        
        height += 4 // an experience value
        
        return height
    }
}
