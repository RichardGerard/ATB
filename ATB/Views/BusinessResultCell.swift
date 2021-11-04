//
//  BusinessResultCell.swift
//  ATB
//
//  Created by YueXi on 3/31/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import Cosmos

class BusinessResultCell: UITableViewCell {
    
    static let reuseIdentifier = "BusinessResultCell"
    
    @IBOutlet weak var resultContainer: UIView!     // shadow container
    @IBOutlet weak var resultView: UIView!          // background view
    @IBOutlet weak var imvProfile: ProfileView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblBio: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var imvBadge: UIImageView!
    @IBOutlet weak var lblDistance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = .clear
        
        setupSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupSubviews() {
        resultContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        resultContainer.layer.shadowRadius = 2
        resultContainer.layer.shadowColor = UIColor.gray.cgColor
        resultContainer.layer.shadowOpacity = 0.25
        
        resultView.backgroundColor = .white
        resultView.layer.cornerRadius = 4
        resultView.layer.masksToBounds = true
        
        imvProfile.borderColor = .colorPrimary
        imvProfile.borderWidth = 1.5
        
        lblName.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblName.textColor = .colorPrimary
        
        lblBio.font = UIFont(name: Font.SegoeUILight, size: 13)
        lblBio.textColor = .colorGray2
        lblBio.numberOfLines = 2
        lblBio.setLineSpacing(lineHeightMultiple: 0.7)
        
        ratingView.settings.emptyBorderColor = .colorPrimary
        ratingView.settings.emptyColor = .clear
        ratingView.settings.emptyBorderWidth = 1
        ratingView.settings.filledColor = .colorPrimary
        ratingView.settings.filledBorderColor = .colorPrimary
        ratingView.settings.filledBorderWidth = 1
        ratingView.settings.fillMode = .precise
        ratingView.settings.totalStars = 1
        ratingView.settings.updateOnTouch = false
        ratingView.settings.filledImage = UIImage(named: "star.rating.blue.fill")
        ratingView.settings.emptyImage = UIImage(named: "star.rating.blue.empty")
                
        lblRating.font = UIFont(name: Font.SegoeUIBold, size: 15)
        lblRating.textColor = .colorPrimary
        
        lblDistance.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDistance.textColor = .colorBlue3
        
        imvBadge.image = UIImage(named: "badge.approved")?.withRenderingMode(.alwaysTemplate)
        imvBadge.tintColor = .colorGray2
    }
    
    func configureCell(_ user: UserModel) {
        let businessProfile = user.business_profile
        imvProfile.loadImageFromUrl(businessProfile.businessPicUrl, placeholder: "profile.placeholder")
        
        lblName.text = businessProfile.businessName
        lblBio.text = businessProfile.businessBio
        
        let locationAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            locationAttachment.image = UIImage(systemName: "location.fill")?.withTintColor(.colorBlue3)
        } else {
            // Fallback on earlier versions
        }
        locationAttachment.setImageHeight(height: 12)
        
        let distance = user.distance / 1000.0
        let distanceFormattedString = String(format: " %.1f", distance) + "KM"
        let attributedDistance = NSMutableAttributedString(string: distanceFormattedString)
        attributedDistance.insert(NSAttributedString(attachment: locationAttachment), at: 0)
        lblDistance.attributedText = attributedDistance
        
        ratingView.rating = Double(businessProfile.rating)
        
        let reviewCount = businessProfile.reviews
        let reviewText = reviewCount > 0 ? String(format: "%.1f", businessProfile.rating) + "/5.0" + " (\(reviewCount))" : String(format: "%.1f", businessProfile.rating) + "/5.0"
        let attributedReviewText = NSMutableAttributedString(string: reviewText)
        attributedReviewText.addAttributes(
            [.font: UIFont(name: Font.SegoeUILight, size: 14)!]
            , range: (reviewText as NSString).range(of: "(\(reviewCount))"))
        lblRating.attributedText = attributedReviewText
    }

}
