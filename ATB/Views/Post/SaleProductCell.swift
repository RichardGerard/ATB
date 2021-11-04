//
//  SaleProductCell.swift
//  ATB
//
//  Created by YueXi on 4/28/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Kingfisher

class SaleProductCell: UITableViewCell {
    
    static let reuseIdentifier = "SaleProductCell"
    
    @IBOutlet weak var vShadowEffect: UIView! { didSet {
        vShadowEffect.layer.cornerRadius = 5
        vShadowEffect.layer.shadowOffset = CGSize(width: 2, height: 2)
        vShadowEffect.layer.shadowColor = UIColor.lightGray.cgColor
        vShadowEffect.layer.shadowRadius = 4
        vShadowEffect.layer.shadowOpacity = 0.4
        }}
    
    @IBOutlet weak var vContainer: UIView! { didSet {
        vContainer.layer.cornerRadius = 5
        vContainer.layer.masksToBounds = true
        }}
    
    @IBOutlet weak var imvPost: UIImageView! { didSet {
        imvPost.contentMode = .scaleAspectFill
        }}
    
    @IBOutlet weak var lblTitle: UILabel! {
        didSet {
            lblTitle.font = UIFont(name: "SegoeUI-Light", size: 19)
            lblTitle.textColor = .colorGray13
        }
    }
    @IBOutlet weak var lblPrice: UILabel! {
        didSet {
            lblPrice.font = UIFont(name: "SegoeUI-Light", size: 19)
            lblPrice.textColor = .colorPrimary
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(_ item: PostToPublishModel) {
        if item.media_type == "1" {
            imvPost.image = UIImage(data: item.photoDatas[0])
            
        } else {
            imvPost.image = UIImage(named: "post.placeholder")
            
            if let url = item.videoURL {
                let cacheKey = url.absoluteString
                if ImageCache.default.imageCachedType(forKey: cacheKey).cached {
                    ImageCache.default.retrieveImage(forKey: cacheKey) { result in
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
                    Utils.shared.getThumbnailImageFromVideoUrl(cacheKey) { thumbnail in
                        if let thumbnail = thumbnail {
                            let animation = CATransition()
                            animation.type = .fade
                            animation.duration = 0.3
                            self.imvPost.layer.add(animation, forKey: "transition")
                            self.imvPost.image = thumbnail
                            
                            ImageCache.default.store(thumbnail, forKey: cacheKey)
                        }
                    }
                }
            }
        }
        
        lblTitle.text = item.title
        lblPrice.text = "£" + item.price
    }
}
