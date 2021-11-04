//
//  MediaPostTableViewCell.swift
//  ATB
//
//  Created by mobdev on 2019/5/21.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

protocol postTableCellDelegate {
    func clickedOnCell(postData:PostModel, index:Int)
}

class MediaPostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainView: ShadowView!
    @IBOutlet weak var imgviewPosterProfile: RoundImageView!
    @IBOutlet weak var lblPosterName: UILabel!
    @IBOutlet weak var lblPostDate: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var viewApproved: UIView!
    
    @IBOutlet weak var btnPlay: RoundView!
    @IBOutlet weak var constraintPriceHeight: NSLayoutConstraint!
    
    var postData:PostModel = PostModel()
    var index:Int = 0
    var cellDelegate:postTableCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }
    
    func configureWithData(model:PostModel, index:Int)
    {
        self.postData = model
        self.index = index
        self.mainView.backgroundColor = UIColor.white
        
        imgviewPosterProfile.loadImageFromUrl(model.Poster_Profile_Img, placeholder: "profile.placeholder")
        
        self.lblPosterName.text = model.Poster_Name
        self.lblPostDate.text = model.Post_Human_Date
        
        let url = model.Post_Media_Urls.count > 0 ? model.Post_Media_Urls[0] : ""
        if(model.Post_Media_Type == "Video")
        {
            // set the post imageview's with placeholder
            imgView.image = UIImage(named: "post.placeholder")
            
            if ImageCache.default.imageCachedType(forKey: url).cached {
                ImageCache.default.retrieveImage(forKey: url) { result in
                    switch result {
                    case .success(let cacheResult):
                        if let image = cacheResult.image {
                            self.imgView.image = image
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
                        self.imgView.image = thumbnail
                        
                        ImageCache.default.store(thumbnail, forKey: url)
                    }
                }
            }
            
            self.btnPlay.isHidden = false
        }
        else
        {
            imgView.loadImageFromUrl(url, placeholder: "post.placeholder")
            self.btnPlay.isHidden = true
        }
        
        self.lblTitle.text = model.Post_Title
        
        if(model.Post_Type == "Sales" || model.Post_Type == "Service")
        {
            self.lblPrice.isHidden = false
            constraintPriceHeight.constant = 20.0
            
            if( model.Post_Is_Sold == "1") {
                lblPrice.text =  "SOLD"
                lblPrice.textColor = UIColor.red
            } else {
                lblPrice.text =  "£ " + model.Post_Price
                lblPrice.textColor = UIColor(red: 0.65, green: 0.75, blue: 0.87, alpha: 1.00)
            }
        }
        else
        {
            self.lblPrice.isHidden = true
            constraintPriceHeight.constant = 0.0
            lblPrice.text = ""
        }
        
        self.lblText.text = model.Post_Text
        self.lblLikes.text = model.Post_Likes
        self.lblComments.text = model.Post_Comments
        
        if (model.Poster_Account_Type == "Business") {
            self.mainView.backgroundColor = UIColor(red:0.60, green:0.71, blue:0.87, alpha:1.0)
            //self.lblPosterName.textColor = UIColor.white
            //self.lblPostDate.textColor = UIColor.white
            self.lblTitle.textColor = UIColor.white
            self.lblText.textColor = UIColor.white
            self.lblPrice.textColor = UIColor.white
            self.lblLikes.textColor = UIColor.white
            self.lblComments.textColor = UIColor.white
            if self.viewApproved != nil {
                self.viewApproved.isHidden = false
            }
            
        } else {
            self.mainView.backgroundColor = UIColor.white
            //self.lblPosterName.textColor = UIColor.darkGray
            //self.lblPostDate.textColor = UIColor.darkGray
            self.lblTitle.textColor = UIColor.darkGray
            self.lblText.textColor = UIColor.darkGray
            //self.lblPrice.textColor = UIColor.darkGray
            self.lblLikes.textColor = UIColor.darkGray
            self.lblComments.textColor = UIColor.darkGray
            if self.viewApproved != nil {
                self.viewApproved.isHidden = true
            }
        }
    }
    
//    func setPostText(strText:String, strName:String)
//    {
//        let text = strName + ". " + strText
//        let BoldAttriString = NSMutableAttributedString(string: text)
//        let range = (text as NSString).range(of: strName + ".")
//
//        UIFont.familyNames.forEach({ familyName in
//            let fontNames = UIFont.fontNames(forFamilyName: familyName)
//            print(familyName, fontNames)
//        })
//
//        let boldFont = UIFont(name: "SegoeUI-SemiBold", size: 14.0)!
//        BoldAttriString.addAttribute(.font, value: boldFont, range: range)
//
//        self.lblText.attributedText = BoldAttriString
//    }
    
    @IBAction func OnClickCell(_ sender: UIButton) {
        cellDelegate.clickedOnCell(postData: self.postData, index: self.index)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgView.image = UIImage()
    }
}
