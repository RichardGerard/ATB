//
//  DateViewCell.swift
//  ATB
//
//  Created by YueXi on 10/18/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class DateViewCell: UITableViewCell {
    
    static let reuseIdentifier = "DateViewCell"
    
    @IBOutlet weak var lblDate: UILabel! { didSet {
        lblDate.font = UIFont(name: Font.SegoeUILight, size: 20)
        lblDate.textColor = .colorGray2
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

}
