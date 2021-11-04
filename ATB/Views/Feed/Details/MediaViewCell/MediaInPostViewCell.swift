//
//  MediaInPostViewCell.swift
//  ATB
//
//  Created by YueXi on 11/12/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import ImageSlideshow
import AVKit
import Kingfisher

class MediaInPostViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MediaInPostViewCell"
    
    @IBOutlet weak var container: UIView!
    
    @IBOutlet weak var imvPost: UIImageView! { didSet {
        imvPost.contentMode = .scaleAspectFill
        }}
    
    @IBOutlet weak var vBadgeContainer: UIView! { didSet {
        vBadgeContainer.backgroundColor = UIColor.black.withAlphaComponent(0.22)
        vBadgeContainer.layer.cornerRadius = 13
        vBadgeContainer.layer.masksToBounds = true
        }}
    @IBOutlet weak var imvTag: UIImageView! { didSet {
        imvTag.contentMode = .center
        }}
    
    private lazy var imageSlide: ImageSlideshow = {
        let imageSlide = ImageSlideshow(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH*3/4.0))
        imageSlide.slideshowInterval = 5
        imageSlide.contentScaleMode = .scaleAspectFill
        imageSlide.pageIndicatorPosition = .init(horizontal: .center, vertical: .bottom)
        imageSlide.contentScaleMode = .scaleAspectFill
        if #available(iOS 13.0, *) {
            imageSlide.activityIndicator = DefaultActivityIndicator(style: .medium, color: .white)
            
        } else {
            // Fallback on earlier versions
            imageSlide.activityIndicator = DefaultActivityIndicator(style: .white)
        }
        return imageSlide
    }()
    
    @IBOutlet weak var vPlay: UIView!
    
    var tapOnImage: ((UITapGestureRecognizer) -> Void)? = nil
    
    var tapOnVideo: (() -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(_ post: PostModel, isApproved: Bool) {
        // business badge
        vBadgeContainer.isHidden = !isApproved
        
        // post tag
        switch post.Post_Type {
            case "Advice": imvTag.image = UIImage(named: "tag.advice")
            case "Sales": imvTag.image = UIImage(named: "tag.sale")
            case "Service": imvTag.image = UIImage(named: "tag.service")
            default: imvTag.image = nil
        }
        
        vPlay.isHidden = !post.isVideoPost
        
        if post.isVideoPost {
            setupPlayerWith(post)
            
        } else {
            setupImageSlideWith(post)
        }
    }
    
    private func setupPlayerWith(_ post: PostModel) {
        let url = post.Post_Media_Urls.count > 0 ? post.Post_Media_Urls[0] : ""
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
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapVideo(_:)))
        contentView.addGestureRecognizer(recognizer)
    }
    
    private func setupImageSlideWith(_ post: PostModel) {
        container.insertSubview(imageSlide, at: 0)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapPostImage(_:)))
        imageSlide.addGestureRecognizer(recognizer)
        
        var imageSources = [KingfisherSource]()
        for mediaUrl in post.Post_Media_Urls {
            if let imageSource = KingfisherSource(urlString: mediaUrl, placeholder: UIImage(named: "post.placeholder")) {
                imageSources.append(imageSource)
            }
        }
        
        imageSlide.setImageInputs(imageSources)
    }
    
    @objc fileprivate func didTapPostImage(_ sender: UITapGestureRecognizer) {
        tapOnImage?(sender)
    }
    
    @objc fileprivate func didTapVideo(_ sender: UITapGestureRecognizer) {
        tapOnVideo?()
    }
    
    class func sizeForItem() -> CGSize {
        return CGSize(width: SCREEN_WIDTH, height: SCREEN_WIDTH*3/4.0)
    }
}

// MARK: - AVPortraitVideoController
class AVPortraitVideoController: AVPlayerViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.window?.rootViewController?.view.frame = UIScreen.main.bounds
    }
}
