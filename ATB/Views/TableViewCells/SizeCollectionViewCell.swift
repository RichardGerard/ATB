//
//  SizeCollectionViewCell.swift
//  ATB
//
//  Created by mobdev on 11/2/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class SizeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var lblSizeTitle: UILabel!
    
    var sizeVal:String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func configureWithData(sizeVal:String)
    {
        self.sizeVal = sizeVal
        self.lblSizeTitle.text = self.sizeVal
    }
}
