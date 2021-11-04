//
//  TagViewCell.swift
//  ATB
//
//  Created by YueXi on 4/19/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class TagViewCell: UICollectionViewCell {
    
    static let reusableIdentifier = "TagViewCell"
    
    let salesPostTagTitles = ["Brand", "Price", "Postage Cost", "Item", "Size", "Location", "Condition", "Payment"]
    let servicePostTagTitles = ["Price from", "Area Covered", "Deposit Required", "Payment Option"]
    
    var tapOnLocationBlock: (() -> Void)? = nil

    @IBOutlet var vRowItems: [UIView]!
    @IBOutlet var vTagItems: [UIView]!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .colorGray7
    }
    
    private func hideTags(_ index: Int) {
        for i in 0 ..< 4 {
            vRowItems[i].isHidden = (index == i)
        }
    }
    
    private func showAllTags(_ show: Bool = false) {
        for i in 0 ..< 4 {
            vRowItems[i].isHidden = !show
        }
    }
    
    func configureCell(_ post: PostModel) {
        if post.Post_Type == "Advice" {
            showAllTags(false)

        } else if post.Post_Type == "Sales" {
            showAllTags(true)

            for tagItem in self.vTagItems {
                let titleLabel = tagItem.subviews[0] as! UILabel
                let valueLabel = tagItem.subviews[1] as! UILabel

                let index = tagItem.tag - 100
                titleLabel.text = salesPostTagTitles[index]

                switch index {
                case 0:
                    valueLabel.text = post.Post_Brand
                    break

                case 1:
                    //valueLabel.text = "$ " + self.selectedPost.Post_Summerize.Post_Price   //Price Value
                    if post.Post_Is_Sold == "1" {
                        valueLabel.text =  "SOLD"
                        valueLabel.textColor = UIColor.red

                    } else {
                        valueLabel.text =  "£ " + post.Post_Price
                        valueLabel.textColor = UIColor(red:0.03, green:0.67, blue:0.03, alpha:1.0)
                    }
                    break

                case 2:
                    valueLabel.text = "£ " + post.deliveryCost.floatValue.priceString
                    break

                case 3:
                    valueLabel.text = post.Post_Item
                    break

                case 4:
                    valueLabel.text = post.Post_Size
                    break

                case 5:
                    let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnLocation(_:)))
                    tagItem.addGestureRecognizer(tap)

                    valueLabel.textColor = UIColor.primaryButtonColor
                    valueLabel.attributedText = NSAttributedString(string: post.Post_Location.components(separatedBy: ",").last!.trimmingCharacters(in: .whitespacesAndNewlines), attributes:
                        [.underlineStyle: NSUnderlineStyle.single.rawValue])
                    break
                case 6:
                    valueLabel.text = post.Post_Condition
                    break
                case 7:
                    valueLabel.text = post.Post_Payment_Type
                    break
                default:
                    break
                }
            }
            
        } else if post.Post_Type == "Service" {
            hideTags(2)

            for tagItem in self.vTagItems {
                let index = tagItem.tag - 100

                let titleLabel = tagItem.subviews[0] as! UILabel
                let valueLabel = tagItem.subviews[1] as! UILabel

                if index < 4 {
                    titleLabel.text = servicePostTagTitles[index]

                    switch(index) {
                    case 0:
                        valueLabel.text =  "£ " + post.Post_Price
                        break

                    case 1:
                        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnLocation(_:)))
                        tagItem.addGestureRecognizer(tap)

                        valueLabel.textColor = UIColor.primaryButtonColor
                        valueLabel.attributedText = NSAttributedString(string: post.Post_Location.components(separatedBy: ",").last!.trimmingCharacters(in: .whitespacesAndNewlines), attributes:
                            [.underlineStyle: NSUnderlineStyle.single.rawValue])
                        break

                    case 2:
                        valueLabel.text = "£ "  + post.Post_Deposit
                        break

                    case 3:
                        valueLabel.text = post.Post_Payment_Type
                        break

                    default:
                        break
                    }
                }
            }
        }
    }
    
    @objc fileprivate func tapOnLocation(_ sender: UITapGestureRecognizer) {
        print("tapOnLocation")
        tapOnLocationBlock?()
    }
}
