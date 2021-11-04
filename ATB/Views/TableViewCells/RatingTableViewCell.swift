//
//  RatingTableViewCell.swift
//  ATB
//
//  Created by mobdev on 2019/5/27.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import ReadMoreTextView
import Cosmos

class RatingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: RoundImageView!
    @IBOutlet weak var lblRaterName: UILabel!
    @IBOutlet weak var lblRatingTime: UILabel!
    @IBOutlet weak var txtRating: ReadMoreTextView!
    @IBOutlet weak var ratingStars: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureWithData(model:RatingDetailModel, index:Int)
    {
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        txtRating.onSizeChange = { _ in }
        txtRating.shouldTrim = true
    }
}
