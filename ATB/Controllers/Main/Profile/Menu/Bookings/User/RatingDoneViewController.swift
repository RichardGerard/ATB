//
//  RatingDoneViewController.swift
//  ATB
//
//  Created by YueXi on 11/2/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class RatingDoneViewController: BaseViewController {
    
    @IBOutlet weak var imvStar: UIImageView!
    @IBOutlet weak var imvCheck: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var imvClose: UIImageView!
    
    @IBOutlet weak var btnBack: UIButton!
    
    var backBlock: (() -> Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        if #available(iOS 13.0, *) {
            imvStar.image = UIImage(systemName: "star.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvStar.tintColor = .colorPrimary
        
        if #available(iOS 13.0, *) {
            imvCheck.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvCheck.tintColor = .colorGreen
        
        if #available(iOS 13.0, *) {
            imvClose.image = UIImage(systemName: "xmark")
        } else {
            // Fallback on earlier versions
        }
        imvClose.tintColor = .colorGray2
        
        lblTitle.text = "Done!"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 34)
        lblTitle.textColor = .colorPrimary
        
        lblDescription.text = "You have sent your Rating!"
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 23)
        lblDescription.textColor = .colorGray5
        
        btnBack.setTitle(" Go to back to My Bookings", for: .normal)
        btnBack.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        btnBack.setTitleColor(.white, for: .normal)
        if #available(iOS 13.0, *) {
            btnBack.setImage(UIImage(systemName: "book.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnBack.tintColor = .white
        btnBack.backgroundColor = .colorPrimary
        btnBack.layer.cornerRadius = 5
        btnBack.layer.masksToBounds = true
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapGoToBookings(_ sender: Any) {
        dismiss(animated: true) {
            self.backBlock?()
        }
    }
}
