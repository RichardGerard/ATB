//
//  HolidaysTableHeaderView.swift
//  ATB
//
//  Created by YueXi on 11/7/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class HolidaysTableHeaderView: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "HolidaysTableHeaderView"

    @IBOutlet weak var imvMinus: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvMinus.image = UIImage(systemName: "minus.circle")
        } else {
            // Fallback on earlier versions
        }
        imvMinus.tintColor = .colorRed1
    }}
    
    @IBOutlet weak var lblDescription: UILabel! { didSet {
        lblDescription.text = "The Following days will be closed for any reservation"
        lblDescription.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblDescription.textColor = .colorRed1
        lblDescription.numberOfLines = 0
        lblDescription.setLineSpacing(lineHeightMultiple: 0.75)
    }}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let bgView = UIView()
        bgView.backgroundColor = .colorGray14
        contentView.addSubview(bgView)
        // add constraints
        addConstraintWithFormat("H:|[v0]|", views: bgView)
        addConstraintWithFormat("V:|[v0]|", views: bgView)
    }
}
