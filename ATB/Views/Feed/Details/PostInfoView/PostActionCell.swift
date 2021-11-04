//
//  PostActionCell.swift
//  ATB
//
//  Created by YueXi on 11/13/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

protocol ActionInPostDelegate {
    
    func didTapLeft()
    func didTapRight()
}

// purchase or book
// add to cart or chat with provider
class PostActionCell: UICollectionViewCell {
    
    static let reuseIdentifier = "PostActionCell"
    
    @IBOutlet weak var leftButton: UIButton! { didSet {
        leftButton.backgroundColor = .colorPrimary
        leftButton.layer.cornerRadius = 5
        leftButton.layer.masksToBounds = true
        }}
    
    @IBOutlet weak var rightContainer: UIView! { didSet {
        rightContainer.backgroundColor = .white
        rightContainer.layer.cornerRadius = 5
        rightContainer.layer.borderWidth = 1
        rightContainer.layer.borderColor = UIColor.colorGray4.cgColor
        rightContainer.layer.masksToBounds = true
        }}
    @IBOutlet weak var rightIcon: UIImageView! { didSet {
        rightIcon.contentMode = .scaleAspectFit
        rightIcon.tintColor = .colorPrimary
        }}
    
    var delegate: ActionInPostDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(_ post: PostModel) {
        if post.isService {
            leftButton.setTitle("Book this Service", for: .normal)
            leftButton.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 20)
            leftButton.setTitleColor(.white, for: .normal)
            
            // chat
            rightContainer.isHidden = false
            if #available(iOS 13.0, *) {
                rightIcon.image = UIImage(systemName: "quote.bubble.fill")?.withRenderingMode(.alwaysTemplate)
            } else {
                // Fallback on earlier versions
            }
            
        } else {
            leftButton.setTitle("Buy Now", for: .normal)
            leftButton.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 20)
            leftButton.setTitleColor(post.isSoldOut ? UIColor.white.withAlphaComponent(0.22) : .white, for: .normal)
//            let normalAttrs: [NSAttributedString.Key: Any] = [
//                .font: UIFont(name: Font.SegoeUISemibold, size: 20)!,
//                .foregroundColor: UIColor.white
//            ]
//
//            let boldAttrs: [NSAttributedString.Key: Any] = [
//                .font: UIFont(name: Font.SegoeUIBold, size: 20)!
//            ]
//
//            let buyTitle = "Buy Now £" + post.Post_Price
//            let attributedTitle = NSMutableAttributedString(string: buyTitle, attributes: normalAttrs)
//
//            let priceRange = (buyTitle as NSString).range(of: "£" + post.Post_Price)
//            attributedTitle.addAttributes(boldAttrs, range: priceRange)
//            leftButton.setAttributedTitle(attributedTitle, for: .normal)
            
            // sale cart
            rightContainer.isHidden = true
            if #available(iOS 13.0, *) {
                rightIcon.image = UIImage(systemName: "cart.fill.badge.plus")?.withRenderingMode(.alwaysTemplate)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    @IBAction func didTapLeft(_ sender: Any) {
        delegate?.didTapLeft()
    }
    
    @IBAction func didTapRight(_ sender: Any) {
        delegate?.didTapRight()
    }

}
