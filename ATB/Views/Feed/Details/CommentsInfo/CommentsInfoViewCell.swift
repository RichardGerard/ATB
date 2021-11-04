//
//  CommentsInfoViewCell.swift
//  ATB
//
//  Created by YueXi on 9/11/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class CommentsInfoViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CommentsInfoViewCell"
    
    @IBOutlet weak var imvComment: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvComment.image = UIImage(systemName: "bubble.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvComment.tintColor = .colorGray2
        imvComment.contentMode = .scaleAspectFit
        }}
    @IBOutlet weak var lblComments: UILabel! { didSet {
        lblComments.text = "1,1k Comments"
        lblComments.font = UIFont(name: Font.SegoeUILight, size: 17)
        lblComments.textColor = .colorGray2
        }}
    @IBOutlet weak var vSeparator: UIView! { didSet {
        vSeparator.backgroundColor = .colorGray4
        }}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(_ commentsCount: Int) {
        if commentsCount > 0 {
            lblComments.text = "\(commentsCount)" + (commentsCount > 1 ? " Comments" : "Comment")
            
        } else {
            lblComments.text = "No Comments"
        }
    }
}
