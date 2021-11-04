//
//  BouncingCheckButton.swift
//  ATB
//
//  Created by mobdev on 2019/5/13.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class BouncingCheckButton:UIButton
{
    var isChecked = false
    var buttonWidth:CGFloat = 0.0
    var buttonHeight:CGFloat = 0.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.white
        self.setTitleColor(UIColor.textFieldPlaceHolderColor, for: .normal)
        self.setImage(UIImage(named: "checkmark-1")?.withRenderingMode(.alwaysOriginal), for: .normal)
        self.imageView?.contentMode = .scaleAspectFill
        
        self.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        self.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        self.addTarget(self, action: #selector(buttonCancel), for: .touchUpOutside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.buttonWidth = self.frame.size.width
        self.buttonHeight = self.frame.size.height
        
        let imageSize:CGSize = CGSize(width: 16, height: 16)

        self.imageEdgeInsets = UIEdgeInsets(top: (buttonHeight - imageSize.height) / 2, left: 15, bottom: (buttonHeight - imageSize.height) / 2, right: (buttonWidth - imageSize.width - 15) )
        
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 15)
    }
    
    @objc func buttonDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.05, delay: 0, options: .curveLinear, animations: {
            self.imageView?.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { (isCompleted) in
            
        }
    }
    
    @objc func buttonClick(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
            self.setChecked(checkVal: true)
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (isCompleted) in
            UIView.animate(withDuration: 0.08, delay: 0, options: .curveLinear, animations: {
                self.imageView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { (isCompleted) in
            }
            
        }
    }
    
    @objc func buttonCancel(_ sender: UIButton) {
        UIView.animate(withDuration: 0.03, delay: 0, options: .curveLinear, animations: {
            self.setChecked(checkVal: self.isChecked)
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (isCompleted) in
            if(self.isChecked)
            {
                UIView.animate(withDuration: 0.08, delay: 0, options: .curveLinear, animations: {
                    self.imageView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }) { (isCompleted) in
                }
            }
        }
    }
    
    func setChecked(checkVal:Bool)
    {
        self.isChecked = checkVal
        
        if(checkVal)
        {
            self.setTitleColor(UIColor.white, for: .normal)
            self.backgroundColor = UIColor.primaryButtonColor
        }
        else
        {
            self.backgroundColor = UIColor.white
            self.setTitleColor(UIColor.textFieldPlaceHolderColor, for: .normal)
        }
    }
}
