//
//  DeleteButton.swift
//  ATB
//
//  Created by mobdev on 2019/5/13.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class DeleteButton:UIButton
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //To apply border
        layer.borderWidth = 1
        layer.borderColor = UIColor.init(hex: "E25A74")?.cgColor
        self.setTitleColor(UIColor.init(hex: "E25A74"), for: .normal)
        self.setTitle("DELETE", for: .normal)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 5
    }
}
