//
//  RequestRatingViewController.swift
//  ATB
//
//  Created by YueXi on 11/2/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Cosmos

class RequestRatingViewController: BaseViewController {
    
    @IBOutlet weak var imvProfile: ProfileView!
    
    @IBOutlet weak var vSendContainer: UIView! { didSet {
        vSendContainer.backgroundColor = .colorGreen
    }}
    @IBOutlet weak var imvSend: UIImageView!
    
    @IBOutlet weak var vRating: CosmosView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
     
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        imvProfile.image = UIImage(named: "girl6")
        
        if #available(iOS 13.0, *) {
            imvSend.image = UIImage(systemName: "paperplane.fill")
        } else {
            // Fallback on earlier versions
        }
        imvSend.contentMode = .center
        imvSend.tintColor = .white
        
        vRating.settings.totalStars = 5
        vRating.settings.updateOnTouch = false
        vRating.settings.filledImage = UIImage(named: "star.rating.fill")
        vRating.settings.emptyImage = UIImage(named: "star.rating.empty")
        vRating.settings.fillMode = .precise
        vRating.settings.starSize = 32
        vRating.rating = 0
        
        lblTitle.text = "We have sent a\nnotification"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 28)
        lblTitle.textColor = .colorPrimary
        lblTitle.numberOfLines = 2
        lblTitle.setLineSpacing(lineHeightMultiple: 0.85)
        
        lblDescription.text = "The user will be notified, and will be requests for providing a rating."
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblDescription.textColor = .colorGray2
        lblDescription.numberOfLines = 0
        lblDescription.setLineSpacing(lineHeightMultiple: 0.75)
    }
}
