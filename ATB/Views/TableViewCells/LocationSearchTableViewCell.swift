//
//  LocationSearchTableViewCell.swift
//  ATB
//
//  Created by mobdev on 17/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class LocationSearchTableViewCell: UITableViewCell {
    var index:Int!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblDes: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureWithData(index:Int)
    {
        self.index = index
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
