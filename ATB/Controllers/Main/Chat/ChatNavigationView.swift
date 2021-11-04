//
//  ChatNavigationView.swift
//  ATB
//
//  Created by YueXi on 1/16/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit

protocol ChatNavigationViewDelegate {
    
    func didTapProfile()
    func didTapInfo()
    func didTapBack()
}

class ChatNavigationView: UIView {
    
    var delegate: ChatNavigationViewDelegate? = nil
    
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        
        imvBack.tintColor = .colorPrimary
        imvBack.contentMode = .scaleAspectFit
    }}
    
    @IBOutlet weak var imvProfile: ProfileView! { didSet {
        imvProfile.borderWidth = 2
        imvProfile.borderColor = .colorPrimary
    }}
    
    @IBOutlet weak var lblName: UILabel! { didSet {
        lblName.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblName.textColor = .colorGray2
        }}
    
    @IBOutlet weak var imvInfo: UIImageView!
    
    @IBAction func didTapInfo(_ sender: Any) {
        delegate?.didTapInfo()
    }
    
    @IBAction func didTapProfile(_ sender: Any) {
        delegate?.didTapProfile()
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        delegate?.didTapBack()
    }
}
