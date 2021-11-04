//
//  ProfileView.swift
//  ATB
//
//  Created by YueXi on 10/18/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

@IBDesignable class ProfileView: UIImageView {
    
    var borderColor: UIColor = .clear { didSet {
        layer.borderColor = borderColor.cgColor
    }}
    
    var borderWidth: CGFloat = 0 { didSet {
        layer.borderWidth = borderWidth
    }}
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.bounds.width / 2.0
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
        
        contentMode = .scaleAspectFill
    }
}
