//
//  InsuranceCell.swift
//  ATB
//
//  Created by YueXi on 8/5/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import DropDown

class InsuranceCell: DropDownCell {
    
    @IBOutlet weak var lblExpiry: UILabel! { didSet {
        lblExpiry.font = UIFont(name: Font.SegoeUILight, size: 16)
        lblExpiry.textColor = .colorPrimary
        lblExpiry.numberOfLines = 2
        lblExpiry.setLineSpacing(lineHeightMultiple: 0.75)
        lblExpiry.textAlignment = .right
        }}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    

}
