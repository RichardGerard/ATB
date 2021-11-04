//
//  UITextField.swift
//  ATB
//
//  Created by mobdev on 11/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UITextField
extension UITextField
{
    func isEmpty()->Bool
    {
        var strText = self.text!
        strText = strText.replacingOccurrences(of: " ", with: "")
        
        if(strText == "")
        {
            return true
        }
        return false
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

// MARK: - UITextView
extension UITextView {
    
    var isEmpty: Bool {
        guard let text = self.text,
            !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return true
        }
        
        return false
    }
}


