//
//  TagInputField.swift
//  ATB
//
//  Created by YueXi on 3/30/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit

protocol TagInputFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
}

class TagInputField: UITextField {

    var inputPadding: CGFloat = 0.0
    var inputMaxLength: Int = -1 // no limit
    
    var tagInputFieldDelegate: TagInputFieldDelegate?
    
    // when the field is created programmatially
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initTextField()
        self.delegate = self
    }
    
    // when the field is created from storyboard
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initTextField()
        self.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func initTextField() {
//        let attributedString = NSMutableAttributedString(string: "#")
//        attributedString.addAttributes(
//            [.foregroundColor: UIColor.colorPrimary,
//             .font: UIFont(name: Font.SegoeUILight, size: 18)!],
//            range: NSRange(location: 0, length: 1))
//        .attributedText = attributedString
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var superRect = super.leftViewRect(forBounds: bounds)
        superRect.origin.x += inputPadding
        return superRect
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var superRect = super.rightViewRect(forBounds: bounds)
        superRect.origin.x -= inputPadding
        return superRect
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var superRect = super.caretRect(for: position)
        superRect.size.width = 3
        guard let font = self.font else { return superRect}
        
        superRect.origin.y -= font.descender/2.0
        superRect.size.height = font.pointSize - font.descender
        
        return superRect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let padding = bounds.inset(by: UIEdgeInsets(top: 0, left: inputPadding, bottom: 0, right: inputPadding))
        return padding
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let padding = bounds.inset(by: UIEdgeInsets(top: 0, left: inputPadding, bottom: 0, right: inputPadding))
        return padding
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let padding = bounds.inset(by: UIEdgeInsets(top: 0, left: inputPadding, bottom: 0, right: inputPadding))
        return padding
    }
}

// MARK: - UITextFieldDelegate
extension TagInputField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // This makes the next text black
//        textField.typingAttributes = [
//            NSAttributedString.Key.foregroundColor: textColor ?? UIColor.black,
//            NSAttributedString.Key.font: font ?? UIFont.systemFont(ofSize: 17)]
        
        let protectedRange = NSRange(location: 0, length: 1)
        let intersection = NSIntersectionRange(protectedRange, range)
        if intersection.length > 0 {
            return false
        }
        
        if inputMaxLength > 0 && range.location + range.length > inputMaxLength {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let tagInputFieldDelegate = tagInputFieldDelegate {
            return tagInputFieldDelegate.textFieldShouldReturn(textField)
            
        } else {
            return true
        }
    }
}
