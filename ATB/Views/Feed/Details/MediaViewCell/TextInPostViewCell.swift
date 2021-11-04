//
//  TextInPostViewCell.swift
//  ATB
//
//  Created by YueXi on 11/12/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class TextInPostViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TextInPostViewCell"
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var imvTag: UIImageView! { didSet {
        imvTag.image = UIImage(named: "tag.advice.medium")?.withRenderingMode(.alwaysTemplate)
        imvTag.contentMode = .scaleAspectFit
        }}
    
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 22)
        lblTitle.textColor = .colorGray5
        }}
    @IBOutlet weak var lblDescription: UILabel! { didSet {
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 20)
        lblDescription.textColor = .colorGray5
        lblDescription.numberOfLines = 0
//        lblDescription.lineBreakMode = .byClipping // remove three dots(ellipsis)
        }}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(_ post: PostModel) {
        lblTitle.text = post.Post_Title.capitalizingFirstLetter
        lblDescription.text = post.Post_Text.capitalizingFirstLetter
        
        if post.isBusinessPost {
            container.backgroundColor = .colorPrimary
            imvTag.tintColor = .white
            lblTitle.textColor = .white
            lblDescription.textColor = .white
            
        } else {
            container.backgroundColor = .white
            imvTag.tintColor = .colorPrimary
            lblTitle.textColor = .colorGray5
            lblDescription.textColor = .colorGray5
        }
    }

    private static let CONTENT_PREFERRED_WIDTH = SCREEN_WIDTH - 32 - 10 - 34
    class func sizeForItem(_ post: PostModel) -> CGSize {
        // top & bottom padding
        var height: CGFloat = 32
        
        // add post container height
        height += post.Post_Title.heightForString(CONTENT_PREFERRED_WIDTH, font: UIFont(name: Font.SegoeUISemibold, size: 22)).height
        height += post.Post_Text.heightForString(CONTENT_PREFERRED_WIDTH, font: UIFont(name: Font.SegoeUILight, size: 20)).height
        
        height += 4 // an experience value
        
        return CGSize(width: SCREEN_WIDTH, height: height)
    }
}
