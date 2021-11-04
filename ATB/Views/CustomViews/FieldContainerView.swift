//
//  FieldContainerView.swift
//  ATB
//
//  Created by YueXi on 11/6/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class FieldContainerView: UIView {
    
    enum FieldState: Int {
        case normal
        case active
    }

    var state: FieldState = .normal {
        didSet {
            if state == .normal {
                layer.borderColor = normalBorderColor.cgColor
                backgroundColor = normalBackgroundColor
                
            } else {
                layer.borderColor = activeBorderColor.cgColor
                backgroundColor = activeBackgroundColor
            }
        }
    }
    
    var normalBorderColor: UIColor = .colorGray17
    var normalBackgroundColor: UIColor = .white
    
    var activeBorderColor: UIColor = .colorPrimary
    var activeBackgroundColor: UIColor = .white
    
    var borderWidth: CGFloat = 1.0
    var cornerRadius: CGFloat = 5.0
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupView()
    }
    
    private func setupView() {
        backgroundColor = (state == .normal ? normalBackgroundColor : activeBackgroundColor)
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = state == .normal ? normalBorderColor.cgColor : activeBorderColor.cgColor
        layer.masksToBounds = true
    }
}
