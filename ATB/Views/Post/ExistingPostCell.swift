//
//  ExistingPostCell.swift
//  ATB
//
//  Created by YueXi on 9/6/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Kingfisher

class ExistingPostCell: UITableViewCell {
    
    static let reuseIdentifier = "ExistingPostCell"
    static let rowHeight: CGFloat = 96
    
    @IBOutlet weak var vCheckbox: CheckBox! { didSet {
        vCheckbox.borderStyle = .roundedSquare(radius: 2)
        vCheckbox.style = .tick
        vCheckbox.borderWidth = 2
        vCheckbox.tintColor = .colorPrimary
        vCheckbox.uncheckedBorderColor = .colorPrimary
        vCheckbox.checkedBorderColor = .colorPrimary
        vCheckbox.checkmarkSize = 0.8
        vCheckbox.checkmarkColor = .colorPrimary
        vCheckbox.checkboxBackgroundColor = .colorPrimary
        }}
    
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
    
    @IBOutlet weak var vPlay: UIView!
    @IBOutlet weak var imvPost: UIImageView! { didSet {
        imvPost.contentMode = .scaleAspectFill
        }}
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.text = ""
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 19)
        lblTitle.textColor = .colorGray1
        }}
    @IBOutlet weak var lblPrice: UILabel! { didSet {
        lblPrice.text = ""
        lblPrice.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        lblPrice.textColor = .colorPrimary
        }}
    
    private let normalPriceAttrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: Font.SegoeUILight, size: 19)!
    ]

    var didSelectPost: ((Bool) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
        selectionStyle = .none
        
        vCheckbox.addTarget(self, action: #selector(didTapCheckbox(_:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        imvPost.image = nil
    }
    
    func configureCell(_ post: PostToPublishModel, isSelected: Bool) {
        let url = post.mediaUrls.count > 0 ? post.mediaUrls[0] : ""
        
        if post.media_type == "Video" {
            vPlay.isHidden = false
            
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

        } else {
            vPlay.isHidden = true
            imvPost.loadImageFromUrl(url, placeholder: "post.placeholder")
        }
        
        lblTitle.text = post.title
        
        if post.isSale {
            lblPrice.text = "£" + post.price
            
        } else {
            let priceString = "Starting at £" + post.price
            let attributedPrice = NSMutableAttributedString(string: priceString)
            let startAtRange = (priceString as NSString).range(of: "Starting at ")
            attributedPrice.addAttributes(normalPriceAttrs, range: startAtRange)
            
            lblPrice.attributedText = attributedPrice
        }
        
        vCheckbox.isChecked = isSelected
    }
    
    @objc func didTapCheckbox(_ checkbox: CheckBox) {
        didSelectPost?(checkbox.isChecked)
    }
}
