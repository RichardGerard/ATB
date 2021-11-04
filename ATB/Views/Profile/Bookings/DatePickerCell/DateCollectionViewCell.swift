//
//  DateCollectionViewCell.swift
//  ATB
//
//  Created by YueXi on 10/20/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class BaseDateCollectionViewCell: UICollectionViewCell {
    
    struct Style {
        // highlighted & normal background colors
        let highlightColor: UIColor
        let normalColor: UIColor
        
        // text colors
        let normalDateColor: UIColor
        let normalDayColor: UIColor
        
        // fonts
        let dateLabelFont: UIFont
        let dayLabelFont: UIFont
    }
        
    // text colors
    var normalDateColor = UIColor(red: 0, green: 22.0/255.0, blue: 39.0/255.0, alpha: 1)
    var normalDayColor = UIColor(red: 0, green: 22.0/255.0, blue: 39.0/255.0, alpha: 1)
    
    // background colors
    var highlightColor = UIColor(red: 0/255.0, green: 199.0/255.0, blue: 194.0/255.0, alpha: 1)
    var normalColor = UIColor.clear
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.backgroundColor = normalColor
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
    }
}

class DateCollectionViewCell: BaseDateCollectionViewCell {
    
    static let reuseIdentifer = "DateCollectionViewCell"
    
    @IBOutlet var dateLabel: UILabel!       // date label
    @IBOutlet var dayLabel: UILabel!        // week day label

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func selectCell(_ selected: Bool) {
        contentView.backgroundColor = selected == true ? highlightColor : normalColor
        
        dayLabel.textColor = selected == true ? .white : normalDayColor
        dateLabel.textColor = selected == true ? .white : normalDateColor
    }
    
    func configureCell(date: Date, disabled: Bool, style: Style, locale: Locale) {
        highlightColor = style.highlightColor
        normalColor = style.normalColor
        
        normalDateColor = style.normalDateColor
        normalDayColor = style.normalDayColor
        
        selectCell(isSelected)
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "E" // "EEE"
        dayFormatter.locale = locale
        dayLabel.text = dayFormatter.string(from: date)
        if disabled {
            dayLabel.textColor = normalDayColor.withAlphaComponent(0.35)
            
        } else {
            dayLabel.textColor = isSelected == true ? .white : normalDayColor
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

// MARK: StepCollectionViewFlowLayout
class StepCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
        ) -> CGPoint {
        var _proposedContentOffset = CGPoint(
            x: proposedContentOffset.x, y: proposedContentOffset.y
        )
        var offSetAdjustment: CGFloat = CGFloat.greatestFiniteMagnitude
        let horizontalCenter: CGFloat = CGFloat(
            proposedContentOffset.x + (self.collectionView!.bounds.size.width / 2.0)
        )
        
        let targetRect = CGRect(
            x: proposedContentOffset.x,
            y: 0.0,
            width: self.collectionView!.bounds.size.width,
            height: self.collectionView!.bounds.size.height
        )
        
        let array: [UICollectionViewLayoutAttributes] =
            self.layoutAttributesForElements(in: targetRect)!
                as [UICollectionViewLayoutAttributes]
        for layoutAttributes: UICollectionViewLayoutAttributes in array {
            if layoutAttributes.representedElementCategory == UICollectionView.ElementCategory.cell {
                let itemHorizontalCenter: CGFloat = layoutAttributes.center.x
                if abs(itemHorizontalCenter - horizontalCenter) < abs(offSetAdjustment) {
                    offSetAdjustment = itemHorizontalCenter - horizontalCenter
                }
            }
        }
        
        var nextOffset: CGFloat = proposedContentOffset.x + offSetAdjustment
        
        repeat {
            _proposedContentOffset.x = nextOffset
            let deltaX = proposedContentOffset.x - self.collectionView!.contentOffset.x
            let velX = velocity.x
            
            if
                deltaX == 0.0 || velX == 0 || (velX > 0.0 && deltaX > 0.0) ||
                    (velX < 0.0 && deltaX < 0.0)
            {
                break
            }
            
            if velocity.x > 0.0 {
                nextOffset = nextOffset + self.snapStep()
            } else if velocity.x < 0.0 {
                nextOffset = nextOffset - self.snapStep()
            }
        } while self.isValidOffset(offset: nextOffset)
        
        _proposedContentOffset.y = 0.0
        
        return _proposedContentOffset
    }
    
    func isValidOffset(offset: CGFloat) -> Bool {
        return (offset >= CGFloat(self.minContentOffset()) &&
            offset <= CGFloat(self.maxContentOffset()))
    }
    
    func minContentOffset() -> CGFloat {
        return -CGFloat(self.collectionView!.contentInset.left)
    }
    
    func maxContentOffset() -> CGFloat {
        return CGFloat(
            self.minContentOffset() + self.collectionView!.contentSize.width - self.itemSize.width
        )
    }
    
    func snapStep() -> CGFloat {
        return self.itemSize.width + self.minimumLineSpacing
    }
}

