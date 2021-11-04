//
//  ItemListHeaderView.swift
//  ATB
//
//  Created by YueXi on 10/18/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class ItemListHeaderView: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "ItemListHeaderView"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Font.SegoeUISemibold, size: 33)
        label.textColor = .colorPrimary
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
    }
    
    private func setupViews() {
        let bgView = UIView()
        bgView.backgroundColor = .colorGray14
        contentView.addSubview(bgView)
        // add constraints
        addConstraintWithFormat("H:|[v0]|", views: bgView)
        addConstraintWithFormat("V:|[v0]|", views: bgView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        // add constraints
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
