//
//  SectionSeparatorViewCell.swift
//  ATB
//
//  Created by YueXi on 10/18/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class SectionSeparatorViewCell: UITableViewCell {
    
    static let reuseIdentifier = "ItemSeparatorViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        backgroundColor = .clear
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupViews() {
        let lineView = UIView()
        lineView.backgroundColor = UIColor.colorGray2.withAlphaComponent(0.34)
        contentView.addSubview(lineView)
        // add constraints
        addConstraintWithFormat("H:|-16-[v0]-16-|", views: lineView)
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

}
