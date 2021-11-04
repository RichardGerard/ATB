//
//  ProfileSelectViewController.swift
//  ATB
//
//  Created by YueXi on 10/14/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

protocol ProfileSelectDelegate {
    
    func profileSelected(_ selectedIndex: Int)
}

class ProfileSelectViewController: BaseViewController {
    
    static let kStoryboardID = "ProfileSelectViewController"
    class func instance() -> ProfileSelectViewController {
        let storyboard = UIStoryboard(name: "Sheet", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: ProfileSelectViewController.kStoryboardID) as? ProfileSelectViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var vContainer: UIView!
    
    @IBOutlet weak var lblOptionTitle: UILabel!
    @IBOutlet var userProfileViews: [UIImageView]!
    @IBOutlet var usernameLabels: [UILabel]!
    @IBOutlet var checkmarkViews: [UIImageView]!
    
    var users = [UserModel]()
    var selectedIndex = 0
    
    var delegate: ProfileSelectDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        vContainer.roundCorners(corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 24)
    }
    
    private func setupViews() {
        lblOptionTitle.text = "Select a Profile"
        lblOptionTitle.font = UIFont(name: Font.SegoeUISemibold, size: 23)
        lblOptionTitle.textColor = .colorPrimary
        
        for i in 0 ..< 2 {
            userProfileViews[i].layer.cornerRadius = 24
            userProfileViews[i].layer.masksToBounds = true
            userProfileViews[i].contentMode = .scaleAspectFill
            
            userProfileViews[i].loadImageFromUrl(users[i].profile_image, placeholder: "profile.placeholder")
            
            usernameLabels[i].text = users[i].user_name
            usernameLabels[i].font = UIFont(name: Font.SegoeUILight, size: 18)
            usernameLabels[i].textColor = .colorGray1
            
            if #available(iOS 13.0, *) {
                checkmarkViews[i].image = UIImage(systemName: "checkmark")
            } else {
                // Fallback on earlier versions
            }
            checkmarkViews[i].tintColor = .colorPrimary
        }
        
        updateSelection(selectedIndex)
    }
    
    private func updateSelection(_ index: Int) {
        for i in 0 ..< 2 {
            checkmarkViews[i].isHidden = (index != i)
        }
    }
    
    @IBAction func didSelectNormalProfile(_ sender: Any) {
        guard selectedIndex != 0 else {
            dismiss(animated: true)
            return
        }
        
        updateSelection(0)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.22) {
            self.dismiss(animated: true) {
                self.delegate?.profileSelected(0)
            }
        }
    }
    
    @IBAction func didSelectBusinessProfile(_ sender: Any) {
        guard selectedIndex != 1 else {
            dismiss(animated: true)
            return
        }
        
        updateSelection(1)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.22) {
            self.dismiss(animated: true) {
                self.delegate?.profileSelected(1)
            }
        }
    }
}
