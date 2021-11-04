//
//  ProfileMenuViewController.swift
//  ATB
//
//  Created by YueXi on 4/22/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Applozic

class ProfileMenuViewController: BaseViewController {
    
    enum ProfileMenu: Int {
        case notifications = 0
        case updateMyBusiness   // Business Profile - update
        case boostMyBusiness
        case businessBookings
        case myBookings
        case purchases
        case itemsSold
        case savedPost
        case invite
        case createBio
        case setPostRange
        case userSettings
        case transactionHistory
        case contactAdmin
        case logout
    }
    
    static let kStoryboardID = "ProfileMenuViewController"
    class func instance() -> ProfileMenuViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: ProfileMenuViewController.kStoryboardID) as? ProfileMenuViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.text = "Settings"
        lblTitle.font = UIFont(name: "SegoeUI-Semibold", size: 27)!
        lblTitle.textColor = .colorGray1
        }}
    
    // Menu Options
    @IBOutlet var menuOptionContainers: [UIView]!
    @IBOutlet var imvMenuOptions: [UIImageView]!
    @IBOutlet var lblMenuOptions: [UILabel]!
        
    @IBOutlet weak var vUpgradeBusinessContainer: UIView!
    @IBOutlet weak var lblUpgradeBusiness: UILabel!
    @IBOutlet weak var imvUpgradeBusiness: UIImageView! { didSet {
        imvUpgradeBusiness.contentMode = .center
        }}
    
    var isViewingOwnBusiness = false
    
    // represent whether show 'Business' or 'Normal' profile
    var isBusiness: Bool = false
    
    // represent whether the user is 'Business' or 'Normal' user
    var isBusinessUser: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupSubviews()
    }
    
    private func setupSubviews() {
        let menuOptions = isBusiness ? [
                ("Update My Business", "briefcase.fill"),
                ("Boost My Business", "rocket.launch"),
                ("Bookings", "book.fill"),
                ("Items Sold", "star.circle.fill"),
                ("Create / Amend Bio", "pencil"),
                ("User Settings", "person.fill"),
                ("Transaction History", "clock"),
                ("Contact Admin", "hand.raised.fill"),
                ("Saved Posts", "bookmark.fill"),
                ("Log out", "arrow.right.circle")
            ] : [
                ("My Bookings", "book.fill"),
                ("Purchases", "cart.fill"),
                ("Items Sold", "star.circle.fill"),
                ("Tell your friends", "star.fill"),
                ("Create / Amend Bio", "pencil"),
                ("Location & Radius", "mappin.and.ellipse"),
                ("User Settings", "person.fill"),
                ("Transaction History", "clock"),
                ("Contact Admin", "hand.raised.fill"),
                ("Saved Posts", "bookmark.fill"),
                ("Log out", "arrow.right.circle")
            ]
        
        for i in 0 ..< 11 {
            if i < menuOptions.count {
                menuOptionContainers[i].isHidden = false
                
                lblMenuOptions[i].text = menuOptions[i].0
                lblMenuOptions[i].font = UIFont(name: Font.SegoeUILight, size: 20)
                
                if i == 1 && isBusiness {
                    imvMenuOptions[i].image = UIImage(named: menuOptions[i].1)
                    imvMenuOptions[i].tintColor = .white
                    
                    lblMenuOptions[i].textColor = .white
                    
                    menuOptionContainers[1].addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 0, alphaValue: 1.0)
                    
                } else {
                    if #available(iOS 13.0, *) {
                        imvMenuOptions[i].image = UIImage(systemName: menuOptions[i].1)
                    } else {
                        // Fallback on earlier versions
                    }
                    imvMenuOptions[i].tintColor = .colorPrimary
                    
                    lblMenuOptions[i].textColor = .colorGray1
                }
                
                imvMenuOptions[i].contentMode = .scaleAspectFit
                
            } else {
                menuOptionContainers[i].isHidden = true
            }
        }
        
        if isBusinessUser {
            vUpgradeBusinessContainer.isHidden = true
            
        } else {            
            if #available(iOS 13.0, *) {
                imvUpgradeBusiness.image = UIImage(systemName: "briefcase.fill")
            } else {
                // Fallback on earlier versions
            }
            imvUpgradeBusiness.tintColor = .white
            imvUpgradeBusiness.contentMode = .scaleAspectFit
            
            lblUpgradeBusiness.font = UIFont(name: Font.SegoeUILight, size: 20)
            lblUpgradeBusiness.textColor = .white
            
            let boldAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: Font.SegoeUISemibold, size: 20)!
            ]
            
            let upgrade = "Upgrade to a\nBusiness Account"
            let attributedUpgrade = NSMutableAttributedString(string: upgrade)
            let businessRange = (upgrade as NSString).range(of: "Business Account")
            attributedUpgrade.addAttributes(boldAttrs, range: businessRange)
            lblUpgradeBusiness.numberOfLines = 2
            lblUpgradeBusiness.attributedText = attributedUpgrade
            lblUpgradeBusiness.setLineSpacing(lineHeightMultiple: 0.75)
            
            vUpgradeBusinessContainer.addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 0, alphaValue: 1.0)
        }
    }
    
    // current design is little awkward
    // slide menu is a kind of root to switch views like iOS tab
    // However, the light hamburger is not on all screens
    private func changeViewControler(_ selected: ProfileMenu) {
        var toVC: BaseViewController?
        
        switch selected {
        case .notifications: toVC = NotificationsViewController.instance()
            
        case .updateMyBusiness:
            toVC = BusinessDetailsViewController.instance()
            (toVC as! BusinessDetailsViewController).isUpdating = true
            break
            
        case .boostMyBusiness: toVC = BoostSelectViewController.instance()
            
        case .businessBookings: toVC = BusinessBookingsViewController.instance()
            
        case .myBookings: toVC = MyBookingsViewController.instance()
            
        case .purchases: toVC = PurchasesViewController.instance()
            
        case .itemsSold:
            toVC = SoldItemsViewController.instance()
            (toVC as! SoldItemsViewController).isBusiness = isBusiness
            break
            
        case .invite: toVC = InviteViewController.instance()
            
        case .createBio:
            toVC = CreateBioViewController.instance()
            (toVC as? CreateBioViewController)?.isForBusiness = isBusiness
            break
            
        case .setPostRange:
            toVC = LocationViewController.instance()
            (toVC as! LocationViewController).selectedAddress = g_myInfo.address
            break
            
        case .userSettings: toVC = UserSettingsViewController.instance()
            
        case .transactionHistory: toVC = TransactionHistoryViewController.instance()
            
        case .contactAdmin: toVC = ContactViewController.instance()
            
        case .savedPost: toVC = BookmarksViewController.instance()
            
        default: return
        }
        
        guard let vc = toVC,
              let nav = self.slideMenuController()?.mainViewController?.navigationController else { return }
        
        // default swtich should be like this
        // self.slideMenuController()?.changeMainViewController(vc, close: true)
        vc.hidesBottomBarWhenPushed = true
        
        // manual switch
        nav.pushViewController(vc, animated: true)
        
        // close the menu
        self.slideMenuController()?.closeRight()
    }
    
    @IBAction func optionSelected(_ sender: UIButton) {
        let selected = sender.tag - 220
        
        switch selected {
        case 0:
            changeViewControler(isBusiness ? .updateMyBusiness : .myBookings)
            break
            
        case 1:
            changeViewControler(isBusiness ? .boostMyBusiness : .purchases)
            break
            
        case 2:
            changeViewControler(isBusiness ? .businessBookings: .itemsSold)
            break
            
        case 3: changeViewControler(isBusiness ? .itemsSold : .invite)
            
        case 4: changeViewControler(.createBio)
            
        case 5: changeViewControler(isBusiness ? .userSettings : .setPostRange)
            
        case 6: changeViewControler(isBusiness ? .transactionHistory : .userSettings)
            
        case 7: changeViewControler(isBusiness ? .contactAdmin : .transactionHistory)
            
        case 8: changeViewControler(isBusiness ? .savedPost : .contactAdmin)
            
        case 9:
            if isBusiness {
                logout()
                
            } else {
                changeViewControler(.savedPost)
            }
            
        case 10:
            guard !isBusiness else { return }
            logout()
                
        case 11:
            guard !isBusiness else { return }            
            upgradeBusiness()
                
        default: break
        }
    }
    
    func logout() {
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
    }
    
    func upgradeBusiness() {
        guard let slideMenuController = self.slideMenuController(),
              let mainViewController = slideMenuController.mainViewController,
              let navigationController = mainViewController.navigationController else { return }
        
        slideMenuController.closeRight()
        
        let businessVC = BusinessSignViewController.instance()
        let nvc = UINavigationController(rootViewController: businessVC)
        nvc.modalPresentationStyle = .overFullScreen
        nvc.isNavigationBarHidden = true
        
        navigationController.present(nvc, animated: true, completion: nil)
    }
}
