//
//  RoundRectTextField.swift
//  ATB
//
//  Created by YueXi on 7/19/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class RoundRectTextField: UITextField {
    
    var borderRadius: CGFloat = 5
    
    var borderColor: UIColor? = nil { didSet {
        layer.borderColor = borderColor?.cgColor
    }}
    
    var borderWidth: CGFloat = 0
    
    var iconTintColor: UIColor = .clear { didSet {
        updateTintColor()
        }}
    
    /// TextField input padding
    var inputPadding: CGFloat = 16.0
    
    // value added for left or right view
    var rightPadding: CGFloat = 0.0
    var leftPadding: CGFloat = 0.0
 
    var leftImage: UIImage? { didSet {
        updateView()
        }}
    
    var rightImage: UIImage? { didSet {
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
        layer.cornerRadius = borderRadius
        
        if let borderColor = borderColor {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = borderWidth
        }
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
        var rect = super.caretRect(for: position)
        rect.size.width = 3
//        if let font = self.font {
//            rect.size.height = font.pointSize
//        }
        rect.size.height = self.font != nil ? self.font!.lineHeight : rect.size.height

        return rect
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
        if let rightImage = rightImage {
            let imageView = UIImageView()
            
            imageView.contentMode = .center
            imageView.image = rightImage.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = iconTintColor

            self.rightView = imageView
            
        } else {
            self.rightView = nil
        }
        
        if let leftImage = leftImage {
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
        if  let _ = rightImage,
            let rightView = rightView,
            let imageView = rightView as? UIImageView {
            imageView.tintColor = iconTintColor
        }
        
        if  let _ = leftImage,
            let leftView = leftView,
            let imageView = leftView as? UIImageView {
            imageView.tintColor = iconTintColor
        }
    }
}
