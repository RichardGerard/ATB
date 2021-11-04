//
//  MediaTableViewCell.swift
//  ATB
//
//  Created by mobdev on 2019/5/31.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class MediaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgCell: UIImageView!
    @IBOutlet weak var iconAddImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    func configureCell(withData data: Data?) {
        if let imageData = data {
            imgCell.image = UIImage(data: imageData)
            iconAddImg.isHidden = true
            
        } else {
            imgCell.image = nil
            iconAddImg.isHidden = false
        }
    }
    
    // used in editing
    // media can be data or url
    func configureCell(with media: Any?) {
        if let media = media {
            if media is Data,
               let mediaData = media as? Data {
                imgCell.image = UIImage(data: mediaData)
                
            } else {
                if let mediaUrl = media as? String {
                    imgCell.loadImageFromUrl(mediaUrl, placeholder: "post.placeholder")
                }
            }
            
            iconAddImg.isHidden = true
            
        } else {
            imgCell.image = nil
            iconAddImg.isHidden = false
        }
    }
}
