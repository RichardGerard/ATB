//
//  FileListTableViewCell.swift
//  ATB
//
//  Created by mobdev on 6/8/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class FileListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblFileName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.lblFileName.text = ""
    }
}
