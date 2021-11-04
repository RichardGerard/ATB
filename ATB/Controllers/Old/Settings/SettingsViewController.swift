//
//  SettingsViewController.swift
//  ATB
//
//  Created by YueXi on 5/17/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Stripe
import Applozic

class SettingsViewController: BaseViewController {
    
    static let kStoryboardID = "SettingsViewController"
    class func instance() -> SettingsViewController {
        let storyboard = UIStoryboard(name: "OutdatedProfile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: SettingsViewController.kStoryboardID) as? SettingsViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    // navigation
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnOK: UIButton!
    
    @IBOutlet var lblMenus: [UILabel]!
    @IBOutlet var lblLines: [UILabel]!
    @IBOutlet var imvArrows: [UIImageView]!
    @IBOutlet var btnMenus: [UIButton]!
        
    let baseMenuTag = 410
    
    var viewingBusiness:Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor(red: 0.84, green: 0.91, blue: 1.00, alpha: 1.00)
        let backBarBtnItem = UIBarButtonItem()
        backBarBtnItem.title = ""
        navigationItem.backBarButtonItem = backBarBtnItem

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        self.view.backgroundColor = .colorGray7
        
        var menuTitles = [
            "Create / Amend Bio",
            "Set Post Range",
            "User Settings",
            "Account Settings",
            "Transaction History",
            "Contact Admin",
            "Log out"
        ]
        
        if viewingBusiness {
            menuTitles = ["Create / Amend Business Bio"]
        }
        
        
        lblTitle.textColor = .white
        lblTitle.font = UIFont(name: "SegoeUI-Semibold", size: 30)
        lblTitle.text = "Settings"
        
        btnOK.setTitle("OK", for: .normal)
        btnOK.setTitleColor(.white, for: .normal)
        btnOK.titleLabel?.font = UIFont(name: "SegoeUI-Semibold", size: 22)
        
        for (index, lblMenu) in lblMenus!.enumerated() {
            lblMenus[index].text = ""
            imvArrows[index].image = UIImage()
            lblLines[index].isHidden = true
        }
        
        
        for (index, menuTitle) in menuTitles.enumerated() {
            lblMenus[index].text = menuTitle
            lblMenus[index].textColor = .colorGray19
            lblMenus[index].font = UIFont(name: "SegoeUI-Light", size: 20)
            
            if #available(iOS 13.0, *) {
                imvArrows[index].image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
            } else {
                // Fallback on earlier versions
            }
            
            imvArrows[index].tintColor = .colorGray20
            
            btnMenus[index].tag = baseMenuTag + index
            lblLines[index].isHidden = false
        }
        
        //imvTellYourFridns.image = UIImage(named: "tag.advice")?.withRenderingMode(.alwaysTemplate)
        //imvTellYourFridns.tintColor = .colorPrimary
    }
    
    @IBAction func didTapMenu(_ sender: UIButton) {
        let selected = sender.tag - baseMenuTag
        
        var toVC: BaseViewController?
        
        switch selected {
        case 0:
            
//            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let setBioVC = storyboard.instantiateViewController(withIdentifier: "SettingUserBioVC") as! SettingUserBioVC
//            if viewingBusiness {
//                setBioVC.isForBusiness = true
//            }
//            self.navigationController?.pushViewController(setBioVC, animated: true)
            break
            
        case 1:
            // Set Post Range
            toVC = LocationViewController.instance()
            break
            
        case 2:
            // User Settings
            toVC = UserSettingsViewController.instance()
            break
            
        case 3:
            // Account Settings
            toVC = AccountSettingsViewController.instance()
            // pass whatever you need to send here
            // ...
            break
            
        case 4:
            // Transaction History
            toVC = TransactionHistoryViewController.instance()
            break
            
        case 5:
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let contactAdminVC = storyboard.instantiateViewController(withIdentifier: "ContactAdminVC") as! ContactAdminVC
//            self.navigationController?.pushViewController(contactAdminVC, animated: true)
            break
        case 6:
            
            let alert = UIAlertController(title: "Do you want to log out?", message: "", preferredStyle: .actionSheet)
            alert.view.tintColor = UIColor.colorPrimary
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                g_myInfo = User()
                ATB_UserDefault.clear()
                
                let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
                registerUserClientService.logout { (response, error) in
                    if(error == nil && response!.status == "success") {
                        
                    } else {
                        
                    }
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let mainNav = storyboard.instantiateViewController(withIdentifier: "LoginNav") as! UINavigationController
                
                UIApplication.shared.keyWindow?.rootViewController = mainNav
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                
            }))
            self.navigationController?.present(alert, animated: true)
            break
            
        default:
            // Tell your friend
            toVC = InviteViewController.instance()
           
        }
        
        if let toVC = toVC {
            self.navigationController?.pushViewController(toVC, animated: true)
        }
    }
    
    @IBAction func didTapOK(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
//        self.slideMenuController()?.changeMainViewController(NewProfileViewController.instance(), close: true)
    }
}
