//
//  PasswordTextField.swift
//  ATB
//
//  Created by YueXi on 4/19/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit

class PasswordTextField: UITextField {

    var borderRadius: CGFloat = 5 { didSet {
        layer.cornerRadius = borderRadius
    }}
    
    var borderColor: UIColor? = nil { didSet {
        layer.borderColor = borderColor?.cgColor
    }}
    
    var borderWidth: CGFloat = 0 { didSet {
        layer.borderWidth = borderWidth
    }}
    
    /// TextField input padding
    var inputPadding: CGFloat = 16.0 { didSet {
        self.layoutIfNeeded()
    }}
    
    // value added for the right view
    var rightPadding: CGFloat = 0.0 { didSet {
        self.layoutIfNeeded()
    }}
    
    var showSecureTextImage: UIImage?
    var hideSecureTextImage: UIImage? { didSet {
        self.secureTextImageView.image = hideSecureTextImage
    }}
    
    var showTintColor: UIColor = .systemRed
    var hideTintColor: UIColor = .lightGray { didSet {
        self.secureTextImageView.tintColor = hideTintColor
    }}
    
    // KVO Context
    private var kvoContext: UInt8 = 0
    
    private var isSecure: Bool = true
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupViews()
    }
    
    private lazy var secureTextImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 3, y: 3, width: 24, height: 24))
        imageView.contentMode = .center
        return imageView
    }()
    
    private func setupViews() {
        isSecureTextEntry = true
        
        layer.cornerRadius = borderRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor?.cgColor
        
        let secureToggleView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        
        secureTextImageView.image = hideSecureTextImage
        secureTextImageView.tintColor = hideTintColor
        secureToggleView.addSubview(secureTextImageView)
        
        let secureToggleButton = UIButton(type: .custom)
        secureToggleButton.frame = secureToggleView.frame
        secureToggleView.addSubview(secureToggleButton)
        secureToggleButton.addTarget(self, action: #selector(toggle(_:)), for: .touchUpInside)
        
        rightView = secureToggleView
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
        rect.size.height = self.font != nil ? self.font!.lineHeight : rect.size.height

        return rect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let padding = bounds.inset(by: UIEdgeInsets(top: 0, left: inputPadding, bottom: 0, right: inputPadding + rightPadding))
        return padding
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let padding = bounds.inset(by: UIEdgeInsets(top: 0, left: inputPadding, bottom: 0, right: inputPadding + rightPadding))
        return padding
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let padding = bounds.inset(by: UIEdgeInsets(top: 0, left: inputPadding, bottom: 0, right: inputPadding + rightPadding))
        return padding
    }
    
    @objc private func toggle(_ sender: Any) {
        isSecure = !isSecure
        
        setSecureMode(isSecure)
    }
    
    private func setSecureMode(_ isSecure: Bool) {
        self.isSecureTextEntry = isSecure
        
        if isSecure {
            secureTextImageView.image = hideSecureTextImage
            secureTextImageView.tintColor = hideTintColor
            
        } else {
            secureTextImageView.image = showSecureTextImage
            secureTextImageView.tintColor = showTintColor
        }
    }
}
