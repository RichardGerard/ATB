//
//  NoBorderTextField.swift
//  ATB
//
//  Created by YueXi on 11/6/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class NoBorderTextField: UITextField {
    
    /// TextField input padding
    var inputPadding: CGFloat = 16.0

    /// padding for left or right view
    var rightPadding: CGFloat = 0.0
    var leftPadding: CGFloat = 0.0
    
    var iconTintColor: UIColor = .clear { didSet {
        
    }}
    
    var leftIcon: UIImage? { didSet {
        updateView()
    }}
    
    var rightIcon: UIImage? { didSet {
        updateView()
    }}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupViews()
    }
    
    private func setupViews() {
        
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
        
//        superRect.origin.y += font.ascender
        // ascender: CGFloat
        // The top y-coordinate, offset from the baseline, of the font’s longest ascender.
        // descendr: CGFloat
        // The bottom y-coordinate, offset from the baseline, of the font’s longest descender.
        // descender is expressed as a negative value
        superRect.origin.y -= font.descender/2.0
        superRect.size.height = font.pointSize - font.descender
        
        return superRect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let padding = bounds.inset(by: UIEdgeInsets(top: 0, left: inputPadding + leftPadding, bottom: 0, right: inputPadding + rightPadding))
        return padding
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let padding = bounds.inset(by: UIEdgeInsets(top: 0, left: inputPadding + leftPadding, bottom: 0, right: inputPadding + rightPadding))
        return padding
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let padding = bounds.inset(by: UIEdgeInsets(top: 0, left: inputPadding + leftPadding, bottom: 0, right: inputPadding + rightPadding))
        return padding
    }
    
    private func updateView() {
        if let rightImage = rightIcon {
            let imageView = UIImageView()
            
            imageView.contentMode = .center
            imageView.image = rightImage.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = iconTintColor

            self.rightView = imageView
            
        } else {
            self.rightView = nil
        }
        
        if let leftImage = leftIcon {
            let imageView = UIImageView()
            
            imageView.contentMode = .center
            imageView.image = leftImage.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = iconTintColor

            self.leftView = imageView
            
        } else {
            self.leftView = nil
        }
    }
    
    private func updateTintColor() {
        if  let _ = rightIcon,
            let rightView = rightView,
            let imageView = rightView as? UIImageView {
            imageView.tintColor = iconTintColor
        }
        
        if  let _ = leftIcon,
            let leftView = leftView,
            let imageView = leftView as? UIImageView {
            imageView.tintColor = iconTintColor
        }
    }
}
