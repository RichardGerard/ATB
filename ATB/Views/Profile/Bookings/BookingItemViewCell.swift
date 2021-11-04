//
//  BookingItemViewCell.swift
//  ATB
//
//  Created by YueXi on 10/18/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Kingfisher

class BookingItemViewCell: UITableViewCell {
    
    static let reuseIdentifier = "BookingItemViewCell"
    
    @IBOutlet weak var vCard: CardView! { didSet {
        vCard.cornerRadius = 4
        vCard.shadowOffsetHeight = 2
        vCard.shadowRadius = 2
        vCard.shadowOpacity = 0.22
    }}
    
    @IBOutlet weak var vContainer: UIView! { didSet {
        vContainer.layer.cornerRadius = 4
        vContainer.layer.masksToBounds = true
    }}
    
    @IBOutlet weak var imvItem: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblBusinessName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var imvRightArrow: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvRightArrow.image = UIImage(systemName: "chevron.right")
        } else {
            // Fallback on earlier versions
        }
        imvRightArrow.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var vPlay: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        backgroundColor = .clear
        
        setupViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupViews() {
        imvItem.contentMode = .scaleAspectFill
        
        lblTitle.text = ""
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 19)
        lblTitle.textColor = .colorGray1
        lblTitle.lineBreakMode = .byTruncatingMiddle
        
        lblBusinessName.text = ""
        lblBusinessName.font = UIFont(name: Font.SegoeUILight, size: 19)
        lblBusinessName.textColor = .colorPrimary
        
        lblTime.text = ""
        lblTime.font = UIFont(name: Font.SegoeUISemibold, size: 16)
        lblTime.textColor = .colorGray2
    }

    func configureCell(_ booking: BookingModel) {
        guard let service = booking.service else { return }
        let url = service.Post_Media_Urls.count > 0 ? service.Post_Media_Urls[0] : ""
        if service.isVideoPost {
            vPlay.isHidden = false
            
            // set placeholder
            imvItem.image = UIImage(named: "post.placeholder")
            
            if ImageCache.default.imageCachedType(forKey: url).cached {
                ImageCache.default.retrieveImage(forKey: url) { result in
                    switch result {
                    case .success(let cacheResult):
                        if let image = cacheResult.image {
                            let animation = CATransition()
                            animation.type = .fade
                            animation.duration = 0.25
                            self.imvItem.layer.add(animation, forKey: "transition")
                            self.imvItem.image = image
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
                        self.imvItem.layer.add(animation, forKey: "transition")
                        self.imvItem.image = thumbnail
                        
                        ImageCache.default.store(thumbnail, forKey: url)
                    }
                }
            }
            
        } else {
            vPlay.isHidden = true
            imvItem.loadImageFromUrl(url, placeholder: "post.placeholder")
        }
        
        lblTitle.text = booking.service.Post_Title.capitalizingFirstLetter
        
        if let business = booking.business {
            lblBusinessName.text = business.businessName
            
        } else {
            lblBusinessName.text = ""
        }
        
        lblTime.text = Date(timeIntervalSince1970: booking.date.doubleValue).toString("h:mm a", timeZone: .current)
    }
}
