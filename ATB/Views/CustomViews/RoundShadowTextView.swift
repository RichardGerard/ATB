//
//  RoundShadowTextView.swift
//  ATB
//
//  Created by mobdev on 2019/5/31.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class BorderedSwitch:UISwitch
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.0
        //backgroundColor = UIColor(displayP3Red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0)
        tintColor = UIColor.lightGray
        onTintColor = UIColor.primaryButtonColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.0
        //backgroundColor = UIColor(displayP3Red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0)
        tintColor = UIColor.lightGray
        onTintColor = UIColor.primaryButtonColor
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = 5
    }
}

class RoundShadowTextView:UITextView
{
    var setManualCorner:Bool = false
    var cornerHeight:CGFloat = 5.0
    var textInnerSpace:CGFloat = 0.0
    
    var textViewTextColor: UIColor = .darkGray
    
    var placeHolderText:String = "" {
        didSet {
            self.textColor = UIColor.textViewPlaceHolderColor
            self.text = placeHolderText
        }
    }
    
    public func setText(text:String)
    {
        if(text != "")
        {
            self.text = text
            self.textColor = textViewTextColor
        }
    }
    
    public func isEmpty()->Bool
    {
        if(self.text == "")
        {
            return true
        }
        
        if(self.text == self.placeHolderText && self.textColor == UIColor.textViewPlaceHolderColor)
        {
            return true
        }
        
        return false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.0
        self.delegate = self
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.0
        self.delegate = self
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()

        if(self.setManualCorner)
        {
            layer.cornerRadius = self.cornerHeight
            textContainerInset = UIEdgeInsets.init(top: self.textInnerSpace, left: self.textInnerSpace, bottom: self.textInnerSpace, right: self.textInnerSpace)
        }
        else
        {
            layer.cornerRadius = 5
            textContainerInset = UIEdgeInsets.init(top: (self.frame.size.height / 6) * 0.5, left: 10, bottom: (self.frame.size.height / 6) * 0.5, right: 10)
        }
    }
}

extension RoundShadowTextView: UITextViewDelegate
{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        //Drop shadow to container view of the textview
        self.superview!.layer.shadowOffset = CGSize(width: 1, height: 5)
        self.superview!.layer.shadowColor = UIColor.lightGray.cgColor
        self.superview!.layer.shadowOpacity = 0.5
        self.superview!.layer.shadowRadius = 5.0
        self.superview!.layer.masksToBounds = false
        
        //Change the border color of the textview
        layer.borderColor = UIColor.primaryButtonColor.cgColor
        //layer.borderWidth = 1.0
        
        if(self.textColor == UIColor.textViewPlaceHolderColor)
        {
            self.text = ""
            self.textColor = textViewTextColor
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.contentInset = UIEdgeInsets.zero
        textView.clipsToBounds = true
    }
    
    override func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
        self.contentInset = UIEdgeInsets.zero
        self.clipsToBounds = true
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        setupShadowAndPlaceHolder(textView: textView)
        return true
    }
    
    func setupShadowAndPlaceHolder(textView:UITextView)
    {
        if(textView.text == "")
        {
            self.superview!.layer.shadowOpacity = 0.0
            layer.borderColor = UIColor.lightGray.cgColor
            textView.text = self.placeHolderText
            textView.textColor = UIColor.textViewPlaceHolderColor
        }
        else
        {
            self.superview!.layer.shadowOpacity = 0.5
            layer.borderColor = UIColor.primaryButtonColor.cgColor
            textView.textColor = textViewTextColor
        }
    }
}
