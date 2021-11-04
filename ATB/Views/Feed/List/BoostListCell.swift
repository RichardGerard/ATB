//
//  BoostListCell.swift
//  ATB
//
//  Created by YueXi on 3/19/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit

class BoostListCell: UICollectionViewCell {
    
    static let reuseIdentifier = "BoostListCell"
    
    let profileView: ProfileView = {
        let view = ProfileView()
//        view.image = UIImage(named: "prototype.manicure.logo")
        view.borderColor = .colorPrimary
        view.borderWidth = 1.5
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: Font.SegoeUISemibold, size: 11)
        label.textColor = .colorGray2
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
        addSubview(profileView)
        addSubview(nameLabel)
        
        addConstraintWithFormat("H:|[v0]|", views: profileView)
        addConstraintWithFormat("V:|[v0(60)]", views: profileView)
        
        addConstraintWithFormat("H:|[v0]|", views: nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 4),
        ])
        
        layoutIfNeeded()
    }
    
    func configureCell(_ user: UserModel) {
        let businessProfile = user.business_profile
        nameLabel.text = businessProfile.businessName
        profileView.loadImageFromUrl(businessProfile.businessPicUrl, placeholder: "profile.placehoolder")
    }
}
