//
//  BusinessStoreOwnItemViewCell.swift
//  ATB
//
//  Created by YueXi on 7/30/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Kingfisher

class BusinessStoreOwnItemViewCell: UICollectionViewCell {
    
    static let reusableIdentifier = "BusinessStoreOwnItemViewCell"
    
    @IBOutlet weak var vContainer: UIView! { didSet {
        vContainer.layer.cornerRadius = 5
        vContainer.layer.masksToBounds = true
        }}
    
    @IBOutlet weak var imvPost: UIImageView! { didSet {
        imvPost.contentMode = .scaleAspectFill
        imvPost.layer.masksToBounds = true
        }}
    @IBOutlet weak var imvPostTag: UIImageView! { didSet {
        imvPostTag.contentMode = .scaleAspectFit
        imvPostTag.tintColor = .white
        }}
    @IBOutlet weak var lblPost: UILabel! { didSet {
        lblPost.font = UIFont(name: Font.SegoeUILight, size: 20)
        lblPost.textColor = .colorGray1
        }}
    @IBOutlet weak var btnEdit: UIButton! { didSet {
        btnEdit.setTitle(" Edit", for: .normal)
        if #available(iOS 13.0, *) {
            btnEdit.setImage(UIImage(systemName: "pencil"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnEdit.tintColor = .white
        btnEdit.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        btnEdit.setTitleColor(.white, for: .normal)
        btnEdit.backgroundColor = .colorGray10
        btnEdit.layer.cornerRadius = 5
        btnEdit.layer.masksToBounds = true
        }}
    @IBOutlet weak var btnMakePost: UIButton! { didSet {
        btnMakePost.setTitle(" Make a Post", for: .normal)
        btnMakePost.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        btnMakePost.setTitleColor(.white, for: .normal)
        btnMakePost.backgroundColor = .colorPrimary
        btnMakePost.layer.cornerRadius = 5
        btnMakePost.layer.masksToBounds = true
        }}
    
    @IBOutlet weak var vPlay: UIView!
    
    var postBlock: (() -> Void)?
    var editBlock: (() -> Void)?
    
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
        
        let tagImage = post.Post_Type == "Sales" ?  UIImage(named: "tag.sale")?.withRenderingMode(.alwaysTemplate) : UIImage(named: "tag.service")?.withRenderingMode(.alwaysTemplate)
        imvPostTag.image = tagImage
    }
    
    @IBAction func didTapEdit(_ sender: Any) {
        editBlock?()
    }
    
    @IBAction func didTapMakePost(_ sender: Any) {
        postBlock?()
    }
}
