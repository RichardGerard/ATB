//
//  TextToastView.swift
//  ATB
//
//  Created by YueXi on 9/10/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import VisualEffectView

class TextToastView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Font.SegoeUILight, size: 18)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    var toastMessage: String? = nil { didSet {
        messageLabel.text = toastMessage
        }}
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
       
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    private func setupViews() {
        backgroundColor = UIColor.black.withAlphaComponent(0.12)
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        let blurEffectView = VisualEffectView(frame: self.frame)
        blurEffectView.colorTint = UIColor.black
        blurEffectView.colorTintAlpha = 0.35
        blurEffectView.blurRadius = 6
        blurEffectView.scale = 1
        self.insertSubview(blurEffectView, at: 0)
        
        self.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            messageLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            messageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
}
