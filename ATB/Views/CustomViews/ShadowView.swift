//
//  ShadowView.swift
//  ATB
//
//  Created by mobdev on 2019/5/21.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class ShadowView:UIView
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = .white
        
        //To apply border
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        
        //To apply Shadow
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 2.0
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        //To apply corner radius
        layer.cornerRadius = 5.0
    }
}

class SearchFieldView:UIView
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //To apply border
        layer.borderWidth = 0.25
        layer.borderColor = UIColor.white.cgColor
        
        //To apply Shadow
        layer.shadowOffset = CGSize(width: 1, height: 5)
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 27.0
    }
}

class ReportView: UIView {
    
    var cornerRadius:CGFloat = 5.0
    
    required override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = .white
        
        //To apply border
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.colorGray7.cgColor
        
        //To apply Shadow
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 2.0
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        //To apply corner radius
        layer.cornerRadius = cornerRadius
    }
}

class StepContentView:UIView
{
    required override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = .white
        
        //To apply border
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        
        //To apply Shadow
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius = 2.0
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        //To apply corner radius
        layer.cornerRadius = 20.0
    }
}

class SearchBoxView:UIView
{
    var cornerRadius:CGFloat = 5.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //To apply border
        layer.borderWidth = 0.25
        layer.borderColor = UIColor.white.cgColor
        
        //To apply Shadow
        layer.shadowOffset = CGSize(width: 1, height: 5)
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = cornerRadius
    }
}
