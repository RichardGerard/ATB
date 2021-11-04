//
//  BookMarkCollectionViewCell.swift
//  ATB
//
//  Created by mobdev on 2019/5/23.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class BookMarkCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var textBookmark: UILabel!
    @IBOutlet weak var imgBookmark: UIImageView!
    var postData:PostDetailModel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //        self.xibViewSet()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        //        self.xibViewSet()
    }
    
    func configureWithData(userInfo:PostDetailModel, index:Int)
    {
        self.postData = userInfo
        
        let summery = self.postData.Post_Summerize
        
        if(summery.Post_Media_Type == "Image")
        {
            let url = URL(string: DOMAIN_URL + summery.Post_Media_Urls[0])
            self.imgBookmark.kf.setImage(with: url)
            self.textBookmark.isHidden = true
            self.imgBookmark.isHidden = false
        }
        else if (summery.Post_Media_Type == "Video")
        {
            let url = URL(string: DOMAIN_URL + summery.Post_Media_Urls[0])
            self.textBookmark.isHidden = true
            self.imgBookmark.isHidden = false
//            DispatchQueue.main.async {
//
//                if ImageCache.default.imageCachedType(forKey: summery.Post_Media_Urls[0]).cached {
//                    ImageCache.default.retrieveImage(forKey: summery.Post_Media_Urls[0], options: nil, completionHandler: { image, _ in
//                        self.imgBookmark.image = image
//                    })
//                } else {
//                    if let thumbnailImage = UIImage().thumbnailForVideoAtURL(url: url! as NSURL) {
//                        self.imgBookmark.image = thumbnailImage
//                        ImageCache.default.store(thumbnailImage, forKey: summery.Post_Media_Urls[0])
//                    }
//                }
//            }
        } else {
            self.textBookmark.text = summery.Post_Text
            self.textBookmark.isHidden = false
            self.imgBookmark.isHidden = true
        }
        
        //self.imgBookmark.image = UIImage(named: userInfo.profile_image)
    }
}
