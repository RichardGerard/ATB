//
//  AddQualifiedServiceView.swift
//  ATB
//
//  Created by mobdev on 2019/6/1.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class AddQualifiedServiceView:UIView
{
    public var cornerRadius:CGFloat = 0
    public var isExtended:Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.primaryButtonColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.primaryButtonColor
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
    }
}

class AddServiceFileView:UIView
{
    public var cornerRadius:CGFloat = 0{
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
    }
}
