//
//  CardView.swift
//  ATB
//
//  Created by YueXi on 4/28/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

@IBDesignable class CardView: UIView {
    
    var cornerRadius: CGFloat = 10
    var shadowOffsetWidth: CGFloat = 0
    var shadowOffsetHeight: CGFloat = 4
    var shadowRadius: CGFloat = 4
    
    var shadowColor: UIColor = UIColor.lightGray
    var shadowOpacity: CGFloat = 0.5
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = Float(shadowOpacity)
    }
}

@IBDesignable class DashlineView: CardView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.lightGray.cgColor
        layer.lineDashPattern = [2, 2]
        layer.fillColor = nil
        layer.path = UIBezierPath(roundedRect: CGRect(x: 4, y: 4, width: bounds.width - 8, height: bounds.height - 8), cornerRadius: cornerRadius).cgPath
        self.layer.addSublayer(layer)
    }
}

@IBDesignable class GradientView: UIView {
    @IBInspectable var startColor: UIColor = .clear
    @IBInspectable var endColor: UIColor = .clear
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addGradient()
    }
    
    func addGradient() {
        // gradient layer
        let gradientLayer = CAGradientLayer()
        
        // define colors
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        
        // define locations of colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // define frame
        gradientLayer.frame = self.bounds
        
        // insert the gradient layer to the view layer
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

@IBDesignable class GradientButton: UIButton {
    
    @IBInspectable var startColor: UIColor = .clear
    @IBInspectable var endColor: UIColor = .clear
    
    var cornerRadius: CGFloat = 5.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        
        addGradient()
    }
    
    func addGradient() {
        // gradient layer
        let gradientLayer = CAGradientLayer()
        
        // define colors
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        
        // define locations of colors
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // define frame
        gradientLayer.frame = self.bounds
        
        // insert the gradient layer to the view layer
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
