//
//  ConfigurationTableViewCell.swift
//  ATB
//
//  Created by mobdev on 2019/5/23.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import ReadMoreTextView

class ConfigurationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewSeparator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        lblTitle.text = ""
    }
}
