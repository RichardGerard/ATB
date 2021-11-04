//
//  SaleInfoViewCell.swift
//  ATB
//
//  Created by YueXi on 9/11/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

// MARK: SaleInfoViewDelegate
protocol SaleInfoViewDelegate {
    
    func didTapLocation()
}

class SaleInfoViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "SaleInfoViewCell"
    
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 23)
        lblTitle.textColor = .colorGray5
        lblTitle.numberOfLines = 0
        }}
    @IBOutlet weak var lblCategory: UILabel! { didSet {
        lblCategory.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblCategory.textColor = .colorPrimary
        }}
    @IBOutlet weak var lblDescription: UILabel! { didSet {
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray5
        lblDescription.numberOfLines = 0
        }}

    @IBOutlet var attributeContainers: [UIView]!

    @IBOutlet weak var lblBrandTitle: UILabel! { didSet {
        lblBrandTitle.text = "Brand"
        lblBrandTitle.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblBrandTitle.textColor = .colorGray21
        }}
    @IBOutlet weak var lblBrand: UILabel! { didSet {
        lblBrand.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblBrand.textColor = .colorGray5
        }}

    @IBOutlet weak var lblPriceTitle: UILabel! { didSet {
        lblPriceTitle.text = "Price"
        lblPriceTitle.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblPriceTitle.textColor = .colorGray21
        }}
    @IBOutlet weak var lblPrice: UILabel! { didSet {
        lblPrice.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblPrice.textColor = .colorGray5
        }}

    @IBOutlet weak var lblPostageTitle: UILabel! { didSet {
        lblPostageTitle.text = "Postage Cost"
        lblPostageTitle.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblPostageTitle.textColor = .colorGray21
        }}
    @IBOutlet weak var lblPostage: UILabel! { didSet {
        lblPostage.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblPostage.textColor = .colorGray5
        }}

    @IBOutlet weak var lblLocationTitle: UILabel! { didSet {
        lblLocationTitle.text = "Location"
        lblLocationTitle.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblLocationTitle.textColor = .colorGray21
        }}
    @IBOutlet weak var lblLocation: UILabel! { didSet {
        lblLocation.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblLocation.textColor = .colorPrimary
        lblLocation.textAlignment = .right
        }}
    
    var delegate: SaleInfoViewDelegate? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        for view in attributeContainers {
            view.backgroundColor = .colorGray4
            view.layer.cornerRadius = 7
            view.layer.masksToBounds = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureCell(_ post: PostModel) {
        lblTitle.text = post.Post_Title.capitalizingFirstLetter
        lblDescription.text = post.Post_Text
        lblBrand.text = post.Post_Brand.capitalizingFirstLetter
        if post.isSoldOut {
            lblPrice.text = "SOLD"
            lblPrice.textColor = .colorRed1
            
        } else {
            lblPrice.text = "£" + post.Post_Price
            lblPrice.textColor = .colorGray5
        }
        lblPostage.text = "£" + post.deliveryCost.floatValue.priceString
        lblLocation.attributedText = NSAttributedString(string: post.Post_Location.components(separatedBy: ",").last!.trimmingCharacters(in: .whitespacesAndNewlines), attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
//        lblLocation.text = post.Post_Location.components(separatedBy: ",").last!.trimmingCharacters(in: .whitespacesAndNewlines)
        lblCategory.text = post.Post_Category
        
        let arrowAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            arrowAttachment.image = UIImage(systemName: "chevron.right")?.withTintColor(.colorPrimary)
            arrowAttachment.setImageHeight(height: 12, verticalOffset: -2)
        } else {
            // Fallback on earlier versions
        }
        
        let attributedCategory = NSMutableAttributedString(string: post.Post_Category + " ")
        attributedCategory.append(NSAttributedString(attachment: arrowAttachment))
        lblCategory.attributedText = attributedCategory
    }
    
    @IBAction func didTapLocation(_ sender: Any) {
        delegate?.didTapLocation()
    }
    
//    @IBAction func didTapBuy(_ sender: Any) {
//        delegate?.didTapBuy()
//    }
//    
//    @IBAction func didTapAddCart(_ sender: Any) {
//        delegate?.didTapAddCart()
//    }
    
    class func sizeForItem(_ post: PostModel) -> CGSize {
        let preferredWidth = SCREEN_WIDTH - 32
        // top padding
        var height: CGFloat = 10
        // title label height - 1 line height
        height += post.Post_Title.heightForString(preferredWidth, font: UIFont(name: Font.SegoeUISemibold, size: 23)).height
        
        // category label height
        height += post.Post_Category.heightForString(preferredWidth, font: UIFont(name: Font.SegoeUISemibold, size: 15)).height
    
        // description label height
        // description top padding
        height += 4
        height += post.Post_Text.heightForString(preferredWidth, font: UIFont(name: Font.SegoeUILight, size: 15)).height
        // bottom padding
        height += 8
        
        // attributes
        height += 90
        
        // separator
        height += 11
        
        height += 4 // an experienced value
        
        return CGSize(width: SCREEN_WIDTH, height: height)
    }
}
