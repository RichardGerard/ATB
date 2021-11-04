//
//  VariationTagsCell.swift
//  ATB
//
//  Created by YueXi on 11/13/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import TTGTagCollectionView

class VariationTagsCell: UICollectionViewCell {
    
    static let reuseIdentifier = "VariationTagsCell"
    
    @IBOutlet weak var lblName: UILabel! { didSet {
        lblName.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblName.textColor = .colorGray21
        }}
    
    @IBOutlet weak var attributesView: TTGTextTagCollectionView! { didSet {
        attributesView.scrollDirection = .horizontal
        attributesView.numberOfLines = 1
        attributesView.horizontalSpacing = 8
        attributesView.verticalSpacing = 0
        attributesView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        attributesView.scrollView.bounces = true
        attributesView.scrollView.alwaysBounceHorizontal = true
        attributesView.scrollView.showsHorizontalScrollIndicator = false
        attributesView.enableTagSelection = true
    }}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let configuration = attributesView.defaultConfig
        configuration?.textFont = UIFont(name: Font.SegoeUILight, size: 18)
        configuration?.textColor = .colorPrimary
        configuration?.selectedTextColor = .white
        configuration?.borderColor = .colorPrimary
        configuration?.selectedBackgroundColor = .colorPrimary
        configuration?.backgroundColor = .clear
        configuration?.selectedBorderColor = .colorPrimary
        configuration?.cornerRadius = 5
        configuration?.shadowOpacity = 0
        configuration?.extraSpace = CGSize(width: 40, height: 16)
    }
    
    func configureCell(withVariation variation: VariationModel) {
        lblName.text = variation.name
        
        attributesView.removeAllTags()
        
        attributesView.addTags(variation.values)
        attributesView.reload()
        
        if let selectedIndex = variation.selected {
            attributesView.setTagAt(UInt(selectedIndex), selected: true)
        }
    }
    
    func setDelegate(_ delegate: TTGTextTagCollectionViewDelegate, forRow row: Int) {
        attributesView.tag = row
        attributesView.delegate = delegate
    }
    
    class func sizeForItem() -> CGSize {
        // top padding
        var height: CGFloat = 10
        // height for name
        height += UIFont(name: Font.SegoeUILight, size: 15)!.lineHeight
        // bottom margin
        height += 8
        
        // variation attributes list view
        height += 44
        
        return CGSize(width: SCREEN_WIDTH, height: height)
    }
}

