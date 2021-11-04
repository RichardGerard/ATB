//
//  NSLayoutConstraint+Extension.swift
//  ATB
//
//  Created by YueXi on 3/26/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import Foundation

extension NSLayoutConstraint {
    
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}
