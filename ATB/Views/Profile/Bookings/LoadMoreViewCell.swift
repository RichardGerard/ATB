//
//  LoadMoreViewCell.swift
//  ATB
//
//  Created by YueXi on 10/18/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class LoadMoreViewCell: UITableViewCell {
    
    static let reuseIdentifier = "LoadMoreViewCell"
    
    @IBOutlet weak var imvThumbsup: UIImageView!
    @IBOutlet weak var lblNoMore: UILabel!
    
    var loadMoreBlock: (() -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        backgroundColor = .clear
        
        setupViews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func setupViews() {
        if #available(iOS 13.0, *) {
            imvThumbsup.image = UIImage(systemName: "hand.thumbsup.fill")
        } else {
            // Fallback on earlier versions
        }
        imvThumbsup.tintColor = UIColor.colorGray2.withAlphaComponent(0.34)
        
//        lblNoMore.text = "No more bookings coming up\nSee your past bookings"
//        lblNoMore.font = UIFont(name: Font.SegoeUILight, size: 20)
//        lblNoMore.textColor = .colorGray2
        
        let txtNoMore = "No more bookings coming up"
        let txtPast = "See your past bookings"
        let text = txtNoMore + "\n" + txtPast
        let attributedText = NSMutableAttributedString(string: text)
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.colorGray2,
            .font: UIFont(name: Font.SegoeUILight, size: 20)!
        ]
                
        let linkAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor : UIColor.colorPrimary,
            .font: UIFont(name: Font.SegoeUILight, size: 20)!,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.colorPrimary
        ]
        
        let noMoreRange = (text as NSString).range(of: txtNoMore)
        attributedText.addAttributes(normalAttrs, range: noMoreRange)
        
        let pastRange = (text as NSString).range(of: txtPast)
        attributedText.addAttributes(linkAttrs, range: pastRange)
        
        lblNoMore.attributedText = attributedText
        lblNoMore.numberOfLines = 0
        lblNoMore.textAlignment = .center
    }
    
    @IBAction func didTapPastBookings(_ sender: Any) {
        loadMoreBlock?()
    }
}
