//
//  VariationAttributeCell.swift
//  ATB
//
//  Created by YueXi on 11/11/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class VariationAttributeCell: UITableViewCell {
    
    static let reuseIdentifier = "VariationAttributeCell"
    
    @IBOutlet weak var optionField: RoundRectTextField!
    @IBOutlet weak var deleteContainer: UIView!
    @IBOutlet weak var imvDelete: UIImageView!
    
    var optionDeleted: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        backgroundColor = .clear
        
        initViews()
    }
    
    private func initViews() {
        setupTextField(optionField, font: Font.SegoeUILight, placeholder: "Option")
       
        if #available(iOS 13.0, *) {
            imvDelete.image = UIImage(systemName: "trash.fill")
        } else {
            // Fallback on earlier versions
        }
        imvDelete.tintColor = .colorRed1
        
        deleteContainer.backgroundColor = UIColor.colorRed1.withAlphaComponent(0.09)
        deleteContainer.layer.cornerRadius = 5
    }
    
    private func setupTextField(_ textField: RoundRectTextField, font: String, placeholder: String? = nil) {
        textField.backgroundColor = .white
        textField.borderColor = .colorGray17
        textField.borderWidth = 1
        textField.autocapitalizationType = .words
        
        textField.placeholder = placeholder
        textField.tintColor = .colorGray5
        textField.textColor = .colorGray5
        
        textField.font = UIFont(name: font, size: 18)
        textField.inputPadding = 12
    }
    
    func setTextFieldDelegate(_ delegate: UITextFieldDelegate, indexPath: IndexPath) {
        optionField.delegate = delegate
        optionField.tag = 500 + indexPath.section
    }

    @IBAction func didTapDelete(_ sender: Any) {
        optionDeleted?()
    }
}
