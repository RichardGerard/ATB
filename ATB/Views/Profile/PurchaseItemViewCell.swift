//
//  PurchaseItemViewCell.swift
//  ATB
//
//  Created by YueXi on 10/24/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Kingfisher

class PurchaseItemViewCell: UITableViewCell {
    
    static let reuseIdentifier = "PurchaseItemViewCell"
    
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
    
    @IBOutlet weak var imvProduct: UIImageView!
    
    @IBOutlet weak var vPlay: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    @IBOutlet weak var imvRightArrow: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvRightArrow.image = UIImage(systemName: "chevron.right")
        } else {
            // Fallback on earlier versions
        }
        imvRightArrow.tintColor = .colorPrimary
    }}

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
        imvProduct.contentMode = .scaleAspectFill
        
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 19)
        lblTitle.textColor = .colorGray1
        
        lblPrice.font = UIFont(name: Font.SegoeUILight, size: 19)
        lblPrice.textColor = .colorBlue8
    }
    
    func configureCell(withPurchase purchase: TransactionHistoryModel) {
        let purchasedItem = purchase.item!
        let url = purchasedItem.Post_Media_Urls.count > 0 ? purchasedItem.Post_Media_Urls[0] : ""
        
        if purchasedItem.isVideoPost {
            vPlay.isHidden = false
            
            // set placeholder
            imvProduct.image = UIImage(named: "post.placeholder")
            
            if ImageCache.default.imageCachedType(forKey: url).cached {
                ImageCache.default.retrieveImage(forKey: url) { result in
                    switch result {
                    case .success(let cacheResult):
                        if let image = cacheResult.image {
                            let animation = CATransition()
                            animation.type = .fade
                            animation.duration = 0.25
                            self.imvProduct.layer.add(animation, forKey: "transition")
                            self.imvProduct.image = image
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
                        self.imvProduct.layer.add(animation, forKey: "transition")
                        self.imvProduct.image = thumbnail
                        
                        ImageCache.default.store(thumbnail, forKey: url)
                    }
                }
            }

        } else {
            vPlay.isHidden = true
            imvProduct.loadImageFromUrl(url, placeholder: "post.placeholder")
        }
        
        if purchase.quantity > 1 {
            lblTitle.text = "\(purchase.quantity) Items"
            
        } else {
            lblTitle.text = purchasedItem.Post_Title.capitalizingFirstLetter
        }
                
        if purchase.quantity > 1 {
            let total = purchase.amount*Float(purchase.quantity)*(-1)
            lblPrice.text = "Order Total: £" + total.priceString
            
        } else {
            lblPrice.text = "£" + (-purchase.amount).priceString
        }
        
        let date = Date(timeIntervalSince1970: purchase.date.doubleValue)
        let dateString = " " + date.toString("dd.MM.yy", timeZone: .current)
        let calendarAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            calendarAttachment.image = UIImage(systemName: "calendar")?.withTintColor(.colorGray11)
            calendarAttachment.setImageHeight(height: 12, verticalOffset: -2)
        } else {
            // Fallback on earlier versions
        }
        
        let attributedDates = NSMutableAttributedString(string: dateString)
        attributedDates.insert(NSAttributedString(attachment: calendarAttachment), at: 0)
        
        let calendarAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.colorGray11,
            .font: UIFont(name: Font.SegoeUILight, size: 12)!
        ]
        attributedDates.addAttributes(calendarAttrs, range: NSRange(location: 0, length: attributedDates.length))
        lblDate.attributedText = attributedDates
    }
}
