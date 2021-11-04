//
//  VariationPriceStockCell.swift
//  ATB

import UIKit

class VariationPriceStockCell: UITableViewCell {
    
    static let reuseIdentifier = "VariationPriceStockCell"
    
    @IBOutlet weak var priceField: RoundRectTextField!
    @IBOutlet weak var stockField: RoundRectTextField!
    @IBOutlet weak var variantDescription: UILabel!
    
    var variantId = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        backgroundColor = .clear
        
        initViews()
    }
    
    private func initViews() {
        setupTextField(priceField, font: Font.SegoeUILight, placeholder: "Price")
        setupTextField(stockField, font: Font.SegoeUILight, placeholder: "Stock Level")
        variantDescription.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        variantDescription.textColor = .colorGray1
    }
    
    private func setupTextField(_ textField: RoundRectTextField, font: String, placeholder: String? = nil) {
        textField.backgroundColor = .white
        textField.borderColor = .colorGray17
        textField.borderWidth = 1
        
        textField.placeholder = placeholder
        textField.tintColor = .colorGray5
        textField.textColor = .colorGray5
        
        textField.font = UIFont(name: font, size: 18)
        textField.inputPadding = 12
    }

    @IBAction func didTapDelete(_ sender: Any) {
        
    }
}
