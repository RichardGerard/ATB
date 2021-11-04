//
//  SlotDateCollectionViewCell.swift
//  ATB
//
//  Created by YueXi on 10/20/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class SlotDateCollectionViewCell: BaseDateCollectionViewCell {
    
    static let reuseIdentifer = "SlotDateCollectionViewCell"
    
    @IBOutlet weak var slotCountLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!       // date label
    @IBOutlet var dayLabel: UILabel!        // week day label

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        slotCountLabel.layer.borderWidth = 2
        slotCountLabel.layer.cornerRadius = 15
        slotCountLabel.layer.masksToBounds = true
        
        slotCountLabel.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        slotCountLabel.textAlignment = .center
        slotCountLabel.backgroundColor = .colorPrimary
        slotCountLabel.textColor = .white
    }
    
    // selected or deselected appearance
    func selectCell(_ selected: Bool, circleFilled: Bool = true) {
        contentView.backgroundColor = selected == true ? highlightColor : normalColor
        
        dayLabel.textColor = selected == true ? .white : normalDayColor
        dateLabel.textColor = selected == true ? .white : normalDateColor
        
        slotCountLabel.layer.borderColor = selected == true ? UIColor.white.cgColor : UIColor.colorPrimary.cgColor
        
        if circleFilled {
            slotCountLabel.textColor = selected == true ? .colorPrimary : .white
            slotCountLabel.backgroundColor = selected == true ? .white : .colorPrimary
            
        } else {
            slotCountLabel.textColor = selected == true ? .white : .colorPrimary
            slotCountLabel.backgroundColor = .clear
        }
    }
    
    func configureCell(date: Date, slotCount: Int, disabled: Bool, style: Style, locale: Locale, circleFilled: Bool = true) {
        highlightColor = style.highlightColor
        normalColor = style.normalColor
        
        normalDateColor = style.normalDateColor
        normalDayColor = style.normalDayColor
        
        selectCell(isSelected, circleFilled: circleFilled)
        
        slotCountLabel.isHidden = disabled
        
        slotCountLabel.text = "\(slotCount)"
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "E" // "EEE"
        dayFormatter.locale = locale
        dayLabel.text = dayFormatter.string(from: date)
        if disabled {
            dayLabel.textColor = normalDayColor.withAlphaComponent(0.35)
            
        } else {
            dayLabel.textColor = isSelected ? .white : normalDayColor
        }
        dayLabel.font = style.dayLabelFont

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        dateFormatter.locale = locale
        dateLabel.text = dateFormatter.string(from: date)
        
        if disabled {
            dateLabel.textColor = normalDateColor.withAlphaComponent(0.35)
            
        } else {
            dateLabel.textColor = isSelected == true ? .white : normalDateColor
        }
        dateLabel.font = style.dateLabelFont
    }
}
