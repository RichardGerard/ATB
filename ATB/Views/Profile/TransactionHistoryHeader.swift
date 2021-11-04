//
//  TransactionHistoryHeader.swift
//  ATB
//
//  Created by YueXi on 5/21/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class TransactionHistoryHeader: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "TransactionHistoryHeader"
    static let headerHeight: CGFloat = 60
 
    @IBOutlet weak var lblDate: UILabel! { didSet {
        lblDate.textColor = .colorPrimary
        lblDate.font = UIFont(name: "SegoeUI-Semibold", size: 21)
        }}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundView = UIView(frame: self.bounds)
        backgroundView?.backgroundColor = .colorGray7
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    

}
