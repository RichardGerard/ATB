//
//  AddBoostCell.swift
//  ATB
//
//  Created by YueXi on 3/19/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit

class AddBoostCell: UICollectionViewCell {
    
    static let reuseIdentifier = "AddBoostCell"
    
    private let roundView: UIView = {
        let view = UIView()
        view.backgroundColor = .colorPrimary
        view.layer.cornerRadius = 30
        view.layer.masksToBounds = true
        return view
    }()
    
    private let addImageView: UIImageView = {
        let imageView = UIImageView()
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: "plus.circle")
        } else {
            // Fallback on earlier versions
        }
        imageView.tintColor = .white
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Boost your\nBusiness"
        label.font = UIFont(name: Font.SegoeUISemibold, size: 11)
        label.textColor = .colorPrimary
        label.numberOfLines = 2
        label.setLineSpacing(lineHeightMultiple: 0.75)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupSubviews() {
        addSubview(roundView)
        roundView.addSubview(addImageView)
        
        addConstraintWithFormat("H:|[v0]|", views: roundView)
        addConstraintWithFormat("V:|[v0(60)]", views: roundView)
        
        addConstraintWithFormat("H:|-10-[v0]-10-|", views: addImageView)
        addConstraintWithFormat("V:|-10-[v0(40)]", views: addImageView)
        
        addSubview(nameLabel)
        addConstraintWithFormat("H:|[v0]|", views: nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            nameLabel.topAnchor.constraint(equalTo: roundView.bottomAnchor, constant: 4),
        ])
    }
}
