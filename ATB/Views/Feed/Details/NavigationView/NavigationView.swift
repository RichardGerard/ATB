//
//  NavigationView.swift
//  ATB
//
//  Created by YueXi on 4/19/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

// MARK: NavigationViewDelegate
protocol NavigationViewDelegate {
    
    func didTapBack()
    func didTapProfile()
    func didTapInfo()
}

// MARK: - NavigationView
class NavigationView: UIView {
    
    var delegate: NavigationViewDelegate? = nil
    
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        
        imvBack.tintColor = .colorPrimary
        imvBack.contentMode = .scaleAspectFit
        }}
    
    @IBOutlet weak var imvPoster: UIImageView! { didSet {
        imvPoster.layer.cornerRadius = 22
        imvPoster.layer.masksToBounds = true
        imvPoster.contentMode = .scaleAspectFill
        }}
    @IBOutlet weak var lblName: UILabel! { didSet {
        lblName.font = UIFont(name: Font.SegoeUISemibold, size: 24)
        lblName.textColor = .colorGray2
        }}
    @IBOutlet weak var lblUsername: UILabel! { didSet {
        lblUsername.font = UIFont(name: Font.SegoeUILight, size: 20)
        lblUsername.textColor = .colorGray11
        }}
    
    @IBOutlet weak var imvInfo: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvInfo.image = UIImage(systemName: "ellipsis")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        
        imvInfo.tintColor = .colorGray2
        imvInfo.contentMode = .scaleAspectFit
        }}
    
    @IBAction func didTapBack(_ sender: UIButton) {
        delegate?.didTapBack()
    }
    
    @IBAction func didTapProfileView(_ sender: UIButton) {
        delegate?.didTapProfile()
    }
    
    @IBAction func didTapInfoView(_ sender: UIButton) {
        delegate?.didTapInfo()
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
