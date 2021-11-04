//
//  UILabelExtension.swift
//  ATB
//
//  Created by mobdev on 2019/5/27.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    /// Will auto resize the contained text to a font size which fits the frames bounds.
    /// Uses the pre-set font to dynamically determine the proper sizing
    func fitTextToBounds() {
        guard let text = text, let currentFont = font else { return }
        
        let bestFittingFont = UIFont.bestFittingFont(for: text, in: bounds, fontDescriptor: currentFont.fontDescriptor, additionalAttributes: basicStringAttributes)
        font = bestFittingFont
    }
    
    private var basicStringAttributes: [NSAttributedString.Key: Any] {
        var attribs = [NSAttributedString.Key: Any]()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineBreakMode = self.lineBreakMode
        attribs[.paragraphStyle] = paragraphStyle
        
        return attribs
    }
    
    func setFontSizeToFill() {
        let frameSize  = self.bounds.size
        guard frameSize.height>0 && frameSize.width>0 && self.text != nil else {return}
        
        var fontPoints = self.font.pointSize
        var fontSize   = self.text!.size(withAttributes: [NSAttributedString.Key.font: self.font.withSize(fontPoints)])
        var increment  = CGFloat(0)
        
        if fontSize.width > frameSize.width || fontSize.height > frameSize.height {
            increment = -1
        } else {
            increment = 1
        }
        
        while true {
            fontSize = self.text!.size(withAttributes: [NSAttributedString.Key.font: self.font.withSize(fontPoints+increment)])
            if increment < 0 {
                if fontSize.width < frameSize.width && fontSize.height < frameSize.height {
                    fontPoints += increment
                    break
                }
            } else {
                if fontSize.width > frameSize.width || fontSize.height > frameSize.height {
                    break
                }
            }
            fontPoints += increment
        }
        
        self.font = self.font.withSize(fontPoints)
    }
    
    // Pass value for any one of both parameters and see result
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        guard let labelText = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
            
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        // Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

        self.attributedText = attributedString
    }
}
