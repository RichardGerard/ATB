//
//  BusinessStoreItemViewCell.swift
//  ATB
//
//  Created by YueXi on 7/30/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Kingfisher

class BusinessStoreItemViewCell: UICollectionViewCell {
    
    static let reusableIdentifier = "BusinessStoreItemViewCell"
    
    @IBOutlet weak var vContainer: UIView! { didSet {
        vContainer.layer.cornerRadius = 5
        vContainer.layer.masksToBounds = true
        }}
    
    @IBOutlet weak var imvPost: UIImageView! { didSet {
        imvPost.contentMode = .scaleAspectFill
        }}
    @IBOutlet weak var imvPostTag: UIImageView! { didSet {
        imvPostTag.contentMode = .scaleAspectFit
        imvPostTag.tintColor = .white
        }}
    @IBOutlet weak var lblPost: UILabel! { didSet {
        lblPost.text = ""
        lblPost.font = UIFont(name: Font.SegoeUILight, size: 19)
        lblPost.textColor = .colorGray1
        }}
    
    let normalAttrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: Font.SegoeUILight, size: 15)!,
        .foregroundColor: UIColor.white
    ]
    
    let boldAttrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: Font.SegoeUISemibold, size: 15)!
    ]
    
    @IBOutlet weak var btnAction: UIButton! { didSet {
        btnAction.backgroundColor = .colorPrimary
        btnAction.layer.cornerRadius = 5
        btnAction.layer.masksToBounds = true
        }}
      
    @IBOutlet weak var vPlay: UIView!
    
    // This will be called for buy or book
    var actionBlock: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureCell(_ post: PostModel) {
        lblPost.text = post.Post_Title
        
        let url = post.Post_Media_Urls.count > 0 ? post.Post_Media_Urls[0] : ""
        if post.isVideoPost {
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
        
        var title = ""
        if post.Post_Type == "Sales" {
            imvPostTag.image = UIImage(named: "tag.sale")?.withRenderingMode(.alwaysTemplate)
            
            title = "Buy"
            
        } else {
            imvPostTag.image = UIImage(named: "tag.service")?.withRenderingMode(.alwaysTemplate)
            
            title = "Book"
        }
        
        title += " £" + post.Post_Price
        
        let attributedTitle = NSMutableAttributedString(string: title, attributes: normalAttrs)
        let boldRange = (title as NSString).range(of: "£" + post.Post_Price)
        attributedTitle.addAttributes(boldAttrs, range: boldRange)
        btnAction.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    @IBAction func didTapAction(_ sender: Any) {
        actionBlock?()
    }
}
