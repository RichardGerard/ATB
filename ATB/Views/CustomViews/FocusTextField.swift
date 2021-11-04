//
//  FocusTextField.swift
//  ATB
//
//  Created by mobdev on 2019/5/31.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import DropDown

class FocusTextField:UITextField
{
    public var isLeftEnabled:Bool = false
    public var isNumInput:Bool = false
    public var isRightEnabled:Bool = false
    
    var textFieldDelegate: TextFieldDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTextField()
        self.delegate = self
    }
    
    required override init(frame: CGRect){
        super.init(frame: frame)
        setupTextField()
        self.delegate = self
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = 5
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
            layer.borderWidth = 0.0
            layer.borderColor = UIColor.lightGray.cgColor
        }
        else
        {
            layer.shadowOffset = CGSize(width: 1, height: 5)
            layer.shadowColor = UIColor.lightGray.cgColor
            layer.shadowOpacity = 0.5
            layer.shadowRadius = 5.0
            layer.borderColor = UIColor.primaryButtonColor.cgColor
            layer.borderWidth = 0.0
        }
    }
    
    func setupShadow(textField: UITextField)
    {
        if(textField.text == "")
        {
            layer.shadowOpacity = 0.0
            layer.borderColor = UIColor.lightGray.cgColor
        }
        else
        {
            layer.shadowOpacity = 0.5
            layer.borderColor = UIColor.primaryButtonColor.cgColor
        }
    }
}

extension FocusTextField : UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        superview?.endEditing(true)
        self.resignFirstResponder()
        
        setupShadow(textField: textField)
        return false
    }

    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        layer.shadowOffset = CGSize(width: 1, height: 5)
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5.0
        layer.borderColor = UIColor.primaryButtonColor.cgColor
        layer.borderWidth = 0.0
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setupShadow(textField: textField)
        
        textFieldDelegate?.textFieldDidEndEditing(textField)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        setupShadow(textField: textField)
        
        if(isNumInput)
        {
            var currentText = textField.text ?? "0.00"
            
            if(textField.text == "")
            {
                currentText = "0.00"
            }
            
            let dblCurrentText = Double(currentText)
            let formatted = String(format: "%.2f", dblCurrentText!)
            textField.text = formatted
        }
        
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(self.isNumInput)
        {
            if string.isEmpty { return true }
            
            let currentText = textField.text ?? ""
            let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
            return replacementText.isValidDouble(maxDecimalPlaces: 2)
        }
        return true
    }
}

protocol TextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField)
}

class RoundTextField: FocusTextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required init(frame: CGRect){
        super.init(frame: frame)
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size.width = 3
        rect.size.height = self.font != nil ? self.font!.lineHeight : rect.size.height
        
        return rect
    }
    
    override func setupTextField()
    {
        if(self.text == "")
        {
            layer.borderWidth = 0.0
            layer.borderColor = UIColor.colorGray17.cgColor
        }
        else
        {
            layer.shadowOffset = CGSize(width: 1, height: 5)
            layer.shadowColor = UIColor.lightGray.cgColor
            layer.shadowOpacity = 0.5
            layer.shadowRadius = 5.0
            layer.borderColor = UIColor.colorPrimary.cgColor
            layer.borderWidth = 0.0
        }
    }
    
    override func setupShadow(textField: UITextField) {
        if (textField.text == "") {
            layer.shadowOpacity = 0.0
            layer.borderColor = UIColor.colorGray17.cgColor
            
        } else {
            layer.shadowOpacity = 0.5
            layer.borderColor = UIColor.colorPrimary.cgColor
        }
    }
}

protocol SuffixTextFieldDelegate {
    func durationUpdated(_ textField: UITextField)
}

class SuffixTextField: UITextField, UITextFieldDelegate {
    
    let MAX_LENGTH_DURATION = 1         // updaet this if you want to allow more days (2, 3.. )
    let ACCEPTABLE_NUMBERS     = "123456789"
    
    private let suffixLabel: UILabel = {
        let label = UILabel()
        return UILabel()
    }()
    
    var suffix: String? {
        didSet {
            updateSuffix()
        }
    }
    
    var suffixTextFieldDelegate: SuffixTextFieldDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSuffixView()
        
        self.delegate = self
        
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupSuffixView()
        
        self.delegate = self
        
        self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    private func setupSuffixView() {
        rightViewMode = .always
        rightView = suffixLabel
    }
    
    private func updateSuffix() {
        if let text = suffix {
            // bounds of suffix
            let labelFrame = CGRect(x: 0, y: 0, width: 50, height: self.bounds.height)
            suffixLabel.frame = labelFrame
            suffixLabel.font = self.font
            suffixLabel.textColor = self.textColor
            suffixLabel.text = text
            self.layoutIfNeeded()
        }
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size.width = 3
        rect.size.height = self.font != nil ? self.font!.lineHeight : rect.size.height
        
        return rect
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text,
           let day = Int(text) else {
            suffix = " day"
            return
        }
        
        if day > 1 {
            suffix = " days"
            
        } else {
            suffix = " day"
        }
        
        suffixTextFieldDelegate?.durationUpdated(textField)
    }
       
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        guard let currentText = textField.text else {
            return true
        }
        
        let newLength: Int = currentText.count + string.count - range.length
        let numberOnly = NSCharacterSet.init(charactersIn: ACCEPTABLE_NUMBERS).inverted
        let strValid = string.rangeOfCharacter(from: numberOnly) == nil
        
        return (strValid && (newLength <= MAX_LENGTH_DURATION))
    }
}

