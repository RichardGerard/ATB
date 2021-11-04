//
//  TransactionHistoryTableViewCell.swift
//  ATB
//
//  Created by mobdev on 2019/5/26.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class TransactionHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgService: UIImageView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblServiceTitle: UILabel!
    
    var userData:UserModel!
    let money_symbol = "£"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureWithData(userInfo:UserModel, index:Int)
    {

    }
}
