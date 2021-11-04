//
//  SearchCategoryCollectionViewCell.swift
//  ATB
//
//  Created by mobdev on 2019/6/3.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

protocol SearchCategoryCellDelegate {
    func OnClickSearchCategory(index:Int)
}

class SearchCategoryCollectionViewCell: UICollectionViewCell {
    
    var categoryID:String = ""
    var index:Int = 0
    var cellDelegate:SearchCategoryCellDelegate!
    
    @IBOutlet weak var lblCategoryTitle: UILabel! { didSet {
        lblCategoryTitle.adjustsFontSizeToFitWidth = true
        lblCategoryTitle.minimumScaleFactor = 0.8
    }}
    @IBOutlet weak var imgCheckMark: UIImageView!
    @IBOutlet weak var outterView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @IBAction func OnClickCell(_ sender: UIButton) {
        self.cellDelegate.OnClickSearchCategory(index: index)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func configureWithData(categoryData:FeedGroup, index:Int, search:Bool) {
        self.outterView.layer.cornerRadius = 5.0
        
        self.lblCategoryTitle.text = categoryData.name
        lblCategoryTitle.numberOfLines = categoryData.name == "Health & Well-Being" ? 2 : 1
        
        self.index = index
        imgCheckMark.image = UIImage(named: categoryData.icon)?.withRenderingMode(.alwaysTemplate)
        if categoryData.isSelected {
            outterView.backgroundColor = .white
            
            imgCheckMark.tintColor = .colorPrimary
            lblCategoryTitle.textColor = .colorPrimary
            
        } else {
            if (search) {
                 outterView.backgroundColor = UIColor(red: 0.50, green: 0.56, blue: 0.64, alpha: 1.00)
            } else {
//                outterView.backgroundColor = UIColor(red: 0.70, green: 0.77, blue: 0.87, alpha: 1.00)
                outterView.backgroundColor = .colorPrimary


            }
           

            imgCheckMark.tintColor = .white
            lblCategoryTitle.textColor = .white
        }
    }
}
