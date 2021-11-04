//
//  RoundViews.swift
//  ATB
//
//  Created by mobdev on 2019/5/13.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class ExtendedScrollView:UIScrollView
{
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton
        {
            return false
        }
        return true
    }
}

class RoundView: UIView {
    
    var borderColor: UIColor = .clear { didSet {
        layer.borderColor = borderColor.cgColor
    }}
    
    var borderWidth: CGFloat = 0 { didSet {
        layer.borderWidth = borderWidth
    }}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //To apply corner radius
        layer.cornerRadius = self.bounds.width / 2
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        
        layer.masksToBounds = true
    }
}

class RoundShadowViewWithoutBorder: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //To apply Shadow
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowOffset = CGSize(width: 1, height: 5)
        layer.shadowRadius = 5.0
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //To apply Shadow
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowOffset = CGSize(width: 1, height: 5)
        layer.shadowRadius = 5.0
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.size.height / 2
    }
}

class RoundShadowView: RoundView
{
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //To apply border
        layer.borderWidth = 0.25
        layer.borderColor = UIColor.white.cgColor
        
        //To apply Shadow
        layer.shadowOffset = CGSize(width: 1, height: 5)
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
    }
    
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
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
}

class RoundImageView:UIImageView
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        //To apply corner radius
        layer.cornerRadius = self.frame.size.height / 2
    }
}
