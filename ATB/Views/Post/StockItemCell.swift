//
//  StockItemCell.swift
//  ATB
//
//  Created by YueXi on 11/11/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class StockItemCell: UITableViewCell {
    
    static let reuseIdentifier = "StockItemCell"
    
    @IBOutlet weak var imvEnabled: UIImageView! { didSet {
        imvEnabled.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblTitle.textColor = .colorGray5
        lblTitle.numberOfLines = 0
    }}
    
    @IBOutlet weak var stockStepper: GMStepper! { didSet {
        stockStepper.minimumValue = 0
        stockStepper.maximumValue = 100
        stockStepper.stepValue = 1
        stockStepper.buttonsTextColor = .colorPrimary
        stockStepper.buttonsFont = UIFont(name: Font.SegoeUISemibold, size: 24)!
        stockStepper.buttonsBackgroundColor = .white
        stockStepper.labelTextColor = .colorGray5
        stockStepper.labelFont = UIFont(name: Font.SegoeUILight, size: 19)!
        stockStepper.labelBackgroundColor = .white
        stockStepper.cornerRadius = 5
        stockStepper.borderWidth = 1
        stockStepper.borderColor = .colorGray17
        stockStepper.limitHitAnimationColor = .colorRed1
        stockStepper.value = 1
        stockStepper.leftButtonText = ""
        stockStepper.rightButtonText = ""
        if #available(iOS 13.0, *) {
            stockStepper.leftButton.setImage(UIImage(systemName: "arrowtriangle.left.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        stockStepper.leftButton.tintColor = .colorPrimary
        
        if #available(iOS 13.0, *) {
            stockStepper.rightButton.setImage(UIImage(systemName: "arrowtriangle.right.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        stockStepper.rightButton.tintColor = .colorPrimary
        
        stockStepper.delegate = self
    }}
    
    @IBOutlet weak var priceField: RoundRectTextField! { didSet {
        priceField.backgroundColor = .white
        priceField.borderColor = .colorGray17
        priceField.borderWidth = 1
        priceField.textAlignment = .center
        
        priceField.placeholder = "0.00"
        priceField.tintColor = .colorGray5
        priceField.textColor = .colorGray5
        
        priceField.font = UIFont(name: Font.SegoeUILight, size: 19)
        priceField.inputPadding = 8
        priceField.keyboardType = .decimalPad
        priceField.leftPadding = 16
        priceField.iconTintColor = .colorPrimary
        priceField.leftImage = UIImage(named: "sterlingsign")
        priceField.leftViewMode = .always
    }}
    
    var stockValueChanged: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    func configureCell(withProductVariant variant: ProductVariant) {
        // Configure the view for the selected state
        if #available(iOS 13.0, *) {
            imvEnabled.image = UIImage(systemName: variant.isSelected ? "checkmark.square.fill" : "square")
        } else {
            // Fallback on earlier versions
        }

        stockStepper.isEnabled = variant.isSelected
        
        if variant.price.doubleValue > 0 {
            priceField.text = variant.price
        }
        
        stockStepper.value = variant.stock_level.doubleValue
        
        let attributesTitle = NSMutableAttributedString()
        for (index, attribute) in variant.attributes.enumerated() {
            var stockTitle = "\(attribute.name): \(attribute.value)"
            
            if index < variant.attributes.count-1 {
                stockTitle += "\n"
            }
            
            let attributedTitle = NSMutableAttributedString(string: stockTitle)
            
            let normalAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: Font.SegoeUILight, size: 14)!
            ]
            
            let nameRange = (stockTitle as NSString).range(of: "\(attribute.name): ")
            attributedTitle.addAttributes(normalAttrs, range: nameRange)
            
            attributesTitle.append(attributedTitle)
        }
        
        lblTitle.attributedText = attributesTitle
    }
    
    func setTextFieldDelegate(_ delegate: UITextFieldDelegate, indexPath: IndexPath) {
        priceField.delegate = delegate
        priceField.tag = 500 + indexPath.section
        
        stockStepper.tag = 700 + indexPath.section
    }
}

// MARK: - StepperDelegate
extension StockItemCell: StepperDelegate {
    
    func reachedToLimit(_ value: Double) {
    }
    
    func leftButtonPressed(_ value: Double) {
        stockValueChanged?(Int(value))
    }
    
    func rightButtonPressed(_ value: Double) {
        stockValueChanged?(Int(value))
    }
}
