//
//  UnfocusTextField.swift
//  ATB
//
//  Created by administrator on 24/02/2020.
//  Copyright © 2020 mobdev. All rights reserved.
//

import Foundation
import UIKit
import DropDown


class UnfocusTextField:UITextField
{
    public var isLeftEnabled:Bool = false
    public var isNumInput:Bool = false
    public var isRightEnabled:Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
    }
    
    required override init(frame: CGRect){
        super.init(frame: frame)
        setupTextField()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.size.height / 2
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds)
        if(self.isLeftEnabled)
        {
            let padding = bounds.inset(by: UIEdgeInsets.init(top: 0, left: self.frame.size.height * 0.6, bottom: 0, right: (self.frame.size.height / 2) * 0.8))
            return padding
        }
        else if(self.isRightEnabled)
        {
            let padding = bounds.inset(by: UIEdgeInsets.init(top: 0, left: (self.frame.size.height / 2) * 0.8, bottom: 0, right: self.frame.size.height))
            return padding
        }
        else
        {
            let padding = bounds.inset(by: UIEdgeInsets.init(top: 0, left: (self.frame.size.height / 2) * 0.8, bottom: 0, right: (self.frame.size.height / 2) * 0.8))
            return padding
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        if(self.isLeftEnabled)
        {
            let padding = bounds.inset(by: UIEdgeInsets.init(top: 0, left: self.frame.size.height * 0.6, bottom: 0, right: (self.frame.size.height / 2) * 0.8))
            return padding
        }
        else if(self.isRightEnabled)
        {
            let padding = bounds.inset(by: UIEdgeInsets.init(top: 0, left: (self.frame.size.height / 2) * 0.8, bottom: 0, right: self.frame.size.height))
            return padding
        }
        else
        {
            let padding = bounds.inset(by: UIEdgeInsets.init(top: 0, left: (self.frame.size.height / 2) * 0.8, bottom: 0, right: (self.frame.size.height / 2) * 0.8))
            return padding
        }
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        super.placeholderRect(forBounds: bounds)
        if(self.isLeftEnabled)
        {
            let padding = bounds.inset(by: UIEdgeInsets.init(top: 0, left: self.frame.size.height * 0.6, bottom: 0, right: (self.frame.size.height / 2) * 0.8))
            return padding
        }
        else if(self.isRightEnabled)
        {
            let padding = bounds.inset(by: UIEdgeInsets.init(top: 0, left: (self.frame.size.height / 2) * 0.8, bottom: 0, right: self.frame.size.height))
            return padding
        }
        else
        {
            let padding = bounds.inset(by: UIEdgeInsets.init(top: 0, left: (self.frame.size.height / 2) * 0.8, bottom: 0, right: (self.frame.size.height / 2) * 0.8))
            return padding
        }
    }
    
    func setupTextField()
    {
        
        if(self.text == "")
        {
            layer.borderWidth = 1.0
            layer.borderColor = UIColor.lightGray.cgColor
        }
        else
        {
            layer.shadowOffset = CGSize(width: 1, height: 5)
            layer.shadowColor = UIColor.lightGray.cgColor
            layer.shadowOpacity = 0.5
            layer.shadowRadius = 5.0
            layer.borderColor = UIColor.primaryButtonColor.cgColor
            layer.borderWidth = 1.0
        }
    }
}
