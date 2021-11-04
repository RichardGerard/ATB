//
//  RoundedBouncingCheckButton.swift
//  ATB
//
//  Created by mobdev on 2019/5/13.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class RoundedBouncingCheckButton:BouncingCheckButton
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //To apply border
        layer.borderWidth = 0.25
        layer.borderColor = UIColor.white.cgColor
        
        //To apply Shadow
        layer.shadowOffset = CGSize(width: 1, height: 5)
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5.0
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.height / 2
    }
}
