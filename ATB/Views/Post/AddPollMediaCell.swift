//
//  AddPollMediaCell.swift
//  ATB
//
//  Created by YueXi on 8/19/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class AddPollMediaCell: UICollectionViewCell {
    
    static let reusableIdentifier = "AddPollMediaCell"
    
    @IBOutlet weak var vContainer: UIView! { didSet {
        vContainer.backgroundColor = .colorGray17
        vContainer.layer.cornerRadius = 5
        vContainer.layer.masksToBounds = true
        }}
    @IBOutlet weak var imvAdd: UIImageView! { didSet {
        imvAdd.image = UIImage(named: "add.new.image")?.withRenderingMode(.alwaysTemplate)
        imvAdd.tintColor = .colorGray18
        }}
    @IBOutlet weak var lblAdd: UILabel! { didSet {
        lblAdd.text = "Add more\npictures"
        lblAdd.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        lblAdd.textColor = .colorGray18
        lblAdd.numberOfLines = 0
        lblAdd.setLineSpacing(lineHeightMultiple: 0.75)
        lblAdd.textAlignment = .center
        }}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
    }
}
