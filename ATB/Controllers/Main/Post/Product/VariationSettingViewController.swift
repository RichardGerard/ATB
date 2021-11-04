//
//  VariationSettingViewController.swift
//  ATB
//
//  Created by YueXi on 11/11/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class VariationSettingViewController: BaseViewController {
    
    @IBOutlet weak var imvHexagon: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvHexagon.image = UIImage(systemName: "hexagon.fill")
        } else {
            // Fallback on earlier versions
        }
        imvHexagon.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var imvSquareLeft: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvSquareLeft.image = UIImage(systemName: "square")
        } else {
            // Fallback on earlier versions
        }
        imvSquareLeft.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var imvSquareRight: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvSquareRight.image = UIImage(systemName: "square")
        } else {
            // Fallback on earlier versions
        }
        imvSquareRight.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var imvClose: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvClose.image = UIImage(systemName: "xmark")
        } else {
            // Fallback on earlier versions
        }
        imvClose.tintColor = .colorGray2
    }}
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }

    private func setupViews() {
        lblTitle.text = "Use variations"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 23)
        lblTitle.textColor = .colorGray5
        
        lblDescription.text = "The variation button allows you to create\nbespoke descriptions for your product\ngiving you greater flexibitlity when selling\ndifferent variations of the same product."
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray2
        lblDescription.numberOfLines = 0
        lblDescription.textAlignment = .center
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
