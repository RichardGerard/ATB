//
//  VariationSelectCell.swift
//  ATB
//
//  Created by YueXi on 11/14/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import DropDown

class VariationSelectCell: UITableViewCell {
    
    static let reuseIdentifier = "VariationSelectCell"
    
    @IBOutlet weak var lblName: UILabel! { didSet {
        lblName.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        lblName.textColor = .colorGray5
    }}
    
    @IBOutlet weak var fieldContainer: FieldContainerView!
    
    @IBOutlet weak var lblSelected: UILabel! { didSet {
        lblSelected.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblSelected.textColor = .colorGray2
    }}
    @IBOutlet weak var imvSelectedAccessory: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvSelectedAccessory.image = UIImage(systemName: "chevron.down")
        } else {
            // Fallback on earlier versions
        }
        imvSelectedAccessory.tintColor = .colorPrimary
    }}
    
    private let attributesDropDown: DropDown = {
        let dropdown = DropDown()
        return dropdown
    }()
    
    var attributeOptionSelected: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        backgroundColor = .clear
        
        let appearance = DropDown.appearance()
        appearance.textFont = UIFont(name: Font.SegoeUILight, size: 18)!
        appearance.textColor = .colorGray2
        appearance.selectedTextColor = .white
        appearance.backgroundColor = .white
        appearance.selectionBackgroundColor = UIColor.colorPrimary.withAlphaComponent(0.9)
        appearance.cellHeight = 56
        appearance.cornerRadius = 5
        
        lblSelected.text = "- select an option -"
        
        attributesDropDown.anchorView = fieldContainer
        attributesDropDown.selectionAction = { [weak self] (index, item) in
            self?.lblSelected.text = item
            self?.attributeOptionSelected?(Int(index))
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(withVariation variation: VariationModel) {
        lblName.text = variation.name
        
        attributesDropDown.dataSource = variation.values
        
        if let selectedVariation = variation.selected {
            attributesDropDown.selectRow(selectedVariation)
            lblSelected.text = variation.values[selectedVariation]
        }
    }
        
    @IBAction func didTapDropdown(_ sender: Any) {
        attributesDropDown.show()
    }
}
