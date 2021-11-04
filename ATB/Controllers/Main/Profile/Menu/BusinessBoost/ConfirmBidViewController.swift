//
//  ConfirmBidViewController.swift
//  ATB
//
//  Created by YueXi on 3/29/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit

class ConfirmBidViewController: BaseViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "confirm.bid")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm Your Bid"
        label.font = UIFont(name: Font.SegoeUISemibold, size: 17)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Once you confirm the bid this cannot be reversed. If your bid is successful and once the auction has completed, we will take the payment for the bid amount."
        label.font = UIFont(name: Font.SegoeUILight, size: 13)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
        view.addSubview(imageView)
        view.addSubview(titleLabel)
        view.addSubview(messageLabel)
        view.addConstraintWithFormat("H:[v0(54)]", views: imageView)
        view.addConstraintWithFormat("H:|-16-[v0]-16-|", views: titleLabel)
        view.addConstraintWithFormat("H:|-16-[v0]-16-|", views: messageLabel)
        view.addConstraintWithFormat("V:|-20-[v0(54)]-4-[v1]-4-[v2]-20-|", views: imageView, titleLabel, messageLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
