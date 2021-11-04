//
//  AdviceInfoViewCell.swift
//  ATB
//
//  Created by YueXi on 11/13/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class AdviceInfoViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "AdviceInfoViewCell"
    
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 23)
        lblTitle.textColor = .colorGray5
        lblTitle.minimumScaleFactor = 0.75
        lblTitle.adjustsFontSizeToFitWidth = true
        }}
    @IBOutlet weak var lblDescription: UILabel! { didSet {
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray5
        lblDescription.numberOfLines = 0
        }}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(_ post: PostModel) {
        lblTitle.text = post.Post_Title.capitalizingFirstLetter
        lblDescription.text = post.Post_Text.capitalizingFirstLetter
    }
    
    class func sizeForItem(_ post: PostModel) -> CGSize {
        let preferredWidth = SCREEN_WIDTH - 32
        // top padding
        var height: CGFloat = 10
        // height for post title
//        height += post.Post_Title.heightForString(preferredWidth, font: UIFont(name: Font.SegoeUISemibold, size: 23)).height
        height += UIFont(name: Font.SegoeUISemibold, size: 23)!.lineHeight
    
        // height for post description
        // description top padding
        height += 4
        height += post.Post_Text.heightForString(preferredWidth, font: UIFont(name: Font.SegoeUILight, size: 15)).height
        // description bottom padding
        height += 6
        
        // separator height
        height += 11
        
        height += 4 // an experience value
        
        return CGSize(width: SCREEN_WIDTH, height: height)
    }

}
