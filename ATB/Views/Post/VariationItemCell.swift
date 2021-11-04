//
//  VariationItemCell.swift
//  ATB
//
//  Created by YueXi on 11/11/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class VariationItemCell: UITableViewCell {
    
    static let reuseIdentifier = "VariationItemCell"
    
    @IBOutlet weak var lblName: UILabel! { didSet {
        lblName.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblName.textColor = .colorPrimary
    }}
    @IBOutlet weak var lblOptions: UILabel! { didSet {
        lblOptions.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblOptions.textColor = .colorGray2
    }}
    
    @IBOutlet weak var imvAccessory: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvAccessory.image = UIImage(systemName: "chevron.right")
        } else {
            // Fallback on earlier versions
        }
        imvAccessory.tintColor = .colorPrimary
    }}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ name: String, options: String) {
        lblName.text = name
        let values = options.components(separatedBy: ",")
        var spacedOptions = ""
        for value in values {
            spacedOptions += ", " + value
        }
        spacedOptions = String(spacedOptions.dropFirst(2))
        
        lblOptions.text = spacedOptions
    }
}
