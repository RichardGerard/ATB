//
//  BookingServiceItemCell.swift
//  ATB
//
//  Created by YueXi on 11/6/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Kingfisher

class BookingServiceItemCell: UITableViewCell {
    
    static let reuseIdentifier = "BookingServiceItemCell"
    
    // for shadow effect
    @IBOutlet weak var vCard: CardView! { didSet {
        vCard.cornerRadius = 4
        vCard.shadowOffsetHeight = 2
        vCard.shadowRadius = 2
        vCard.shadowOpacity = 0.22
    }}
    
    @IBOutlet weak var vContainer: UIView! { didSet {
        vContainer.layer.cornerRadius = 5
        vContainer.layer.masksToBounds = true
    }}
    
    @IBOutlet weak var vPlay: UIView!
    @IBOutlet weak var imvService: UIImageView! { didSet {
        imvService.contentMode = .scaleAspectFill
    }}
    
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        lblTitle.textColor = .colorGray2
    }}
    @IBOutlet weak var lblPrice: UILabel! { didSet {
        lblPrice.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblPrice.textColor = .colorPrimary
    }}
    
    @IBOutlet weak var imvArrow: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvArrow.image = UIImage(systemName: "chevron.right")
        } else {
            // Fallback on earlier versions
        }
        imvArrow.tintColor = .colorPrimary
    }}

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

    func configureCell(_ service: PostModel) {
        let url = service.Post_Media_Urls.count > 0 ? service.Post_Media_Urls[0] : ""
        if service.isVideoPost {
            vPlay.isHidden = false
            
            // set placeholder
            imvService.image = UIImage(named: "post.placeholder")
            
            if ImageCache.default.imageCachedType(forKey: url).cached {
                ImageCache.default.retrieveImage(forKey: url) { result in
                    switch result {
                    case .success(let cacheResult):
                        if let image = cacheResult.image {
                            let animation = CATransition()
                            animation.type = .fade
                            animation.duration = 0.25
                            self.imvService.layer.add(animation, forKey: "transition")
                            self.imvService.image = image
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
                        self.imvService.layer.add(animation, forKey: "transition")
                        self.imvService.image = thumbnail
                        
                        ImageCache.default.store(thumbnail, forKey: url)
                    }
                }
            }
            
        } else {
            vPlay.isHidden = true
            imvService.loadImageFromUrl(url, placeholder: "post.placeholder")
        }
        
        let serviceName = service.Post_Title
        let infoAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            infoAttachment.image = UIImage(systemName: "info.circle.fill")?.withTintColor(.colorGray2)
        } else {
            // Fallback on earlier versions
        }
        let attributedTitle = NSMutableAttributedString(string: serviceName + " ")
        attributedTitle.append(NSAttributedString(attachment: infoAttachment))
        lblTitle.attributedText = attributedTitle
        lblTitle.lineBreakMode = .byTruncatingMiddle
        
        lblPrice.text = "£" + service.Post_Price
    }
}
