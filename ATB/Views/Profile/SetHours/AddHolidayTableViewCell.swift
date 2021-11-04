//
//  AddHolidayTableViewCell.swift
//  ATB
//
//  Created by YueXi on 11/7/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class AddHolidayTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "AddHolidayTableViewCell"
    
    @IBOutlet weak var imvCalendar: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvCalendar.image = UIImage(systemName: "calendar.badge.plus")
        } else {
            // Fallback on earlier versions
        }
        imvCalendar.tintColor = .colorPrimary
    }}
    @IBOutlet weak var lblAdd: UILabel! { didSet {
        lblAdd.text = "Add another custom holiday"
        lblAdd.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        lblAdd.textColor = .colorPrimary
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
