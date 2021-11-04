//
//  MultiplePostCell.swift
//  ATB
//
//  Created by YueXi on 8/24/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation

class MultiplePostCell: UITableViewCell, ASAutoPlayVideoLayerContainer {
    
    static let reuseIdentifier = "MultiplePostCell"
    
    // MARK: - ASAutoPlayViewLayerContainer
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    var videoURL: String?
    
    // This is only used to calculate visibleVideoHeight
    // Please make sure that layout structure is same as others, otherwise intersectioned will have difference
    @IBOutlet weak var videoView: UIImageView!
    
    func visibleVideoHeight() -> CGFloat {
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.convert(videoView.frame, from: videoView)
        guard let videoFrame = videoFrameInParentSuperView,
            let superViewFrame = superview?.frame else {
             return 0
        }
        
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        return visibleVideoFrame.size.height
    }
    
    @IBOutlet weak var clvPost: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
        selectionStyle = .none
        
        setupCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func setupCollectionView() {
        clvPost.showsHorizontalScrollIndicator = false
        clvPost.contentInsetAdjustmentBehavior = .never
        clvPost.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        clvPost.backgroundColor = .clear
        
        let itemWidth: CGFloat = SCREEN_WIDTH - 10 - 31 // left padding, right item content initial width
        // top & bottom default padding, profile container, media container,
        // title, price, desctiption, like & comments
        var itemHeight: CGFloat = 16 + 42 + (itemWidth - 12) * 358/340.0
        // height for title, price, description
        // title
        // title top margin
        itemHeight += 10
        itemHeight += UIFont(name: Font.SegoeUISemibold, size: 15)!.lineHeight
        // price
        // price top margin
        itemHeight += 2
        itemHeight += UIFont(name: Font.SegoeUISemibold, size: 16)!.lineHeight
        // description top margin
        itemHeight += 5
        // description
        itemHeight += UIFont(name: Font.SegoeUILight, size: 15)!.lineHeight
        // description bottom margin
        itemHeight += 2
        // comments and likes
        itemHeight += 36
        
        // bottom padding
        itemHeight += 4
        
        // collectionView FlowLayout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        clvPost.collectionViewLayout = layout
        
        clvPost.register(UINib(nibName: "MultiplePostCollectionCell", bundle: nil), forCellWithReuseIdentifier: MultiplePostCollectionCell.reuseIdentifier)
    }
    
    func setCollectionViewDataSourceDelegate(_ dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        clvPost.dataSource = dataSourceDelegate
        clvPost.delegate = dataSourceDelegate
        clvPost.tag = 300 + row
        
        clvPost.reloadData()
    }
    
    class func cellHeight(_ post: PostModel, isProfile: Bool = false) -> CGFloat {
        // shadow container default top & bottom padding - (8 + 8)
        // like & comments - 36
        // container stack view bottom padding - 4
        var height: CGFloat = 16 + 36 + 4
        
        // top profile container - 42
        if !isProfile {
            height += 42
        }
        
        let itemWidth: CGFloat = SCREEN_WIDTH - 10 - 31 // left padding, right item content initial width
        // media container
        height += (itemWidth - 12) * 179/170.0
        // title
        // top margin for title (post container stackview)
        height += 10
        height += UIFont(name: Font.SegoeUISemibold, size: 15)!.lineHeight
        // price
        // top margin for price
        height += 2
        height += UIFont(name: Font.SegoeUISemibold, size: 16)!.lineHeight
        // description
        // top margin for description
        height += 5
        height += UIFont(name: Font.SegoeUILight, size: 15)!.lineHeight
        
        height += 4 // an experience value
        
        return height
    }
}

class MultiplePostCollectionCell: UICollectionViewCell, ASAutoPlayVideoLayerContainer {
    
    static let reuseIdentifier = "MultiplePostCollectionCell"
    
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
    
    @IBOutlet weak var vProfileContainer: UIView!
    @IBOutlet weak var imvPosterProfile: ProfileView! { didSet {
        imvPosterProfile.borderWidth = 2
        imvPosterProfile.borderColor = .colorPrimary
        }}
    @IBOutlet weak var lblPosterName: UILabel! { didSet {
        lblPosterName.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblPosterName.textColor = .colorGray2
        }}
    @IBOutlet weak var lblPostDate: UILabel! { didSet {
        lblPostDate.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblPostDate.textColor = .colorGray6
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
    @IBOutlet weak var imvGroupPostTag: UIImageView! { didSet {
        imvGroupPostTag.image = UIImage(named: "tag.group")
        imvGroupPostTag.contentMode = .center
        }}
    @IBOutlet weak var imvPostTag: UIImageView! { didSet {
        imvPostTag.image = UIImage(named: "tag.sale")
        imvPostTag.contentMode = .center
        }}
    
    @IBOutlet weak var bottomContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblTitle.textColor = .colorGray13
        }}
    @IBOutlet weak var lblPrice: UILabel! { didSet {
        lblPrice.font = UIFont(name: Font.SegoeUISemibold, size: 16)
        lblPrice.textColor = .colorPrimary
        }}
    @IBOutlet weak var lblDescription: UILabel! { didSet {
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray13
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
    var playerController: ASVideoPlayerController?
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    var videoURL: String? {
        didSet {
            if let videoURL = videoURL {
                ASVideoPlayerController.sharedVideoPlayer.setupVideoFor(url: videoURL)
            }
            
            videoLayer.isHidden = (videoURL == nil)
        }
    }
    
    func visibleVideoWidth() -> CGFloat {
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.convert(imvPost.frame, from: imvPost)
        guard let videoFrame = videoFrameInParentSuperView,
            let superViewFrame = superview?.frame else {
             return 0
        }
        
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        return visibleVideoFrame.size.width
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        imvPost.layer.addSublayer(videoLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let horizontalMargin: CGFloat = 6
        let width: CGFloat = bounds.size.width - horizontalMargin * 2
        let height: CGFloat = (width * 358/340).rounded(.up)
        videoLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
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
        vProfileContainer.isHidden = (page == 1)
        
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
        
        if post.isSale {
            imvPostTag.image = UIImage(named: "tag.sale")
            
        } else {
            imvPostTag.image = UIImage(named: "tag.service")
        }
        
        lblTitle.text = post.Post_Title
        lblDescription.text = post.Post_Text
        lblLikes.text = post.Post_Likes
        lblComments.text = post.Post_Comments
        
        if post.isSale {
            if post.isSoldOut {
                lblPrice.text = "SOLD"
                lblPrice.textColor = .colorRed1
                
            } else {
                lblPrice.text = "£" + post.Post_Price
                lblPrice.textColor = isBusinessPost ? .white : .colorPrimary
            }
            
            
        } else {
            let priceString = "Starting at £" + post.Post_Price
            let attributedPrice = NSMutableAttributedString(string: priceString)
            let startAtRange = (priceString as NSString).range(of: "Starting at ")
            attributedPrice.addAttributes(normalPriceAttrs, range: startAtRange)
            
            lblPrice.attributedText = attributedPrice
            lblPrice.textColor =  isBusinessPost ? .white : .colorPrimary
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
        
        imvPosterProfile.loadImageFromUrl(post.Poster_Profile_Img, placeholder: "profile.placeholder")
        lblPosterName.text = post.Poster_Name
        lblPostDate.text = post.Post_Human_Date
        
        if isBusinessPost {
            vProfileContainer.backgroundColor = .colorPrimary
            imvPosterProfile.borderColor = .white
            lblPosterName.textColor = .white
            lblPostDate.textColor = .white
            
        } else {
            vProfileContainer.backgroundColor = .white
            imvPosterProfile.borderColor = .colorPrimary
            lblPosterName.textColor = .colorGray2
            lblPostDate.textColor = .colorGray6
        }
    }
    
    @IBAction func didTapProfile(_ sender: Any) {
        profileTapBlock?()
    }
    
    @IBAction func didTapLike(_ sender: Any) {
        likeBlock?()
    }
}
