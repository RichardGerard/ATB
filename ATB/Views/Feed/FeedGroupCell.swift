//
//  FeedGroupCell.swift
//  ATB
//
//  Created by YueXi on 5/30/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class FeedGroupCell: UICollectionViewCell {
    
    static let reuseIdentifier = "FeedGroupCell"
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var imvGroup: UIImageView! { didSet {
        imvGroup.contentMode = .scaleAspectFit
        }}
    @IBOutlet weak var lblGroup: UILabel! { didSet {
        lblGroup.font = UIFont(name: "SegoeUI-Semibold", size: 15)
        lblGroup.adjustsFontSizeToFitWidth = true
        lblGroup.minimumScaleFactor = 0.8
        }}
    
    @IBOutlet weak var imvSelected: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvSelected.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvSelected.tintColor = .colorBlue8
        }}
    
    func configureCell(_ feedGroup: FeedGroup) {
        imvGroup.image = UIImage(named: feedGroup.icon)?.withRenderingMode(.alwaysTemplate)
        lblGroup.text = feedGroup.name
        
        if feedGroup.isSelected {
            cardView.backgroundColor = .colorPrimary
            
            imvGroup.tintColor = .white
            lblGroup.textColor = .white
            
            imvSelected.isHidden = false
            
        } else {
            cardView.backgroundColor = .white
            
            imvGroup.tintColor = .colorPrimary
            lblGroup.textColor = .colorGray5
            
            imvSelected.isHidden = true
        }
    }
}
