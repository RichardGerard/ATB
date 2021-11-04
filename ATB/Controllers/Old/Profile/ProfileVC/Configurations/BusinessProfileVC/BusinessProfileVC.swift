//
//  BusinessProfileVC.swift
//  ATB
//
//  Created by mobdev on 13/8/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import Kingfisher
import Applozic

class BusinessProfileVC: UIViewController {
    
    @IBOutlet weak var imgProfile: RoundImageView!
    @IBOutlet weak var starView: CosmosView!
    
    @IBOutlet weak var avgRating: UILabel!
    @IBOutlet weak var reviewAcount: UILabel!
    
    
    @IBOutlet weak var viewRating: UIView!
    @IBOutlet weak var trianglePointer: UIImageView!
    @IBOutlet weak var btnFirst: UIImageView!
    @IBOutlet weak var btnSecond: UILabel!
    @IBOutlet weak var btnThird: UIImageView!
    @IBOutlet weak var btnLast: UIImageView!
    @IBOutlet weak var viewContent: UIView!
    
    @IBOutlet weak var btnFirstView: UIView!
    @IBOutlet weak var afterBtnLine1: UIView!
    @IBOutlet weak var btnSecondView: UIView!
    @IBOutlet weak var afterBtnLine2: UIView!
    @IBOutlet weak var btnThirdView: UIView!
    @IBOutlet weak var afterBtnLine3: UIView!
    @IBOutlet weak var btnLastView: UIView!
    
    @IBOutlet weak var firstViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var lastViewWidthConstraint: NSLayoutConstraint!
    
    var selectedIndex:Int = 1
    var selectedViewController:UIViewController?
    
    @IBOutlet weak var lblFirstName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserDescription: UILabel!
    
    var viewingUser:UserModel = UserModel()
    
    var ratings:[RatingDetailModel] = []
    var selectedUserId = ""
    
    var ownProfile = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initProfile()
    {
        if (viewingUser.business_profile.ID != "") {
            self.selectedIndex = 1
            ownProfile = false
            lblFirstName.text = viewingUser.business_profile.businessProfileName
            lblUserName.text = "@" + viewingUser.business_profile.businessName
            lblUserDescription.text = viewingUser.business_profile.businessWebsite
            selectedUserId = viewingUser.ID
            if(viewingUser.business_profile.businessPicUrl != "")
            {
                let url = URL(string: DOMAIN_URL + viewingUser.business_profile.businessPicUrl)
                self.imgProfile.kf.setImage(with: url)
            }
            
        } else {
            ownProfile = true
            self.selectedIndex = 2
            lblFirstName.text = g_myInfo.business_profile.businessName
            lblUserName.text = "@" + g_myInfo.business_profile.businessProfileName
            lblUserDescription.text = g_myInfo.business_profile.businessBio
            selectedUserId = g_myInfo.business_profile.ID
            if(g_myInfo.business_profile.businessPicUrl != "")
            {
                let url = URL(string: DOMAIN_URL + g_myInfo.business_profile.businessPicUrl)
                self.imgProfile.kf.setImage(with: url)
            }
            
           
        }
        
        
        if (ownProfile){
            self.btnLast.image = UIImage(named: "setting")
        } else {
            self.btnLast.image = UIImage(named: "MessageIcon")
        }
        self.btnThird.image = UIImage(named: "bookmark")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initProfile()
        getRatings()
        getFollowCount(user_id: selectedUserId)
        
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.SelectButton(index: self.selectedIndex)
    }
    
    func getRatings() {
        ratings.removeAll()
        
        let params = [
            "token" : g_myToken,
            "business_id":viewingUser.ID
        ]
        
        _ = ATB_Alamofire.POST(GET_BUSINESS_REVIEWS, parameters: params as [String : AnyObject],showLoading: false,showSuccess: false,showError: false){
            (result, responseObject) in
            
            let postDicts = responseObject.object(forKey: "msg")  as? [NSDictionary] ?? []
            
            var ratingCount = 0
            var totalRating = 0
            
            for postDict in postDicts
            {
                ratingCount+=1
                
                let stringRating = postDict.object(forKey: "rating") as? String ?? ""
                totalRating += Int(stringRating)!
                
                let review = RatingDetailModel()
                
                let unixTimestamp = postDict.object(forKey: "created_at") as? String ?? ""
                let date = Date(timeIntervalSince1970: Double(unixTimestamp)!)
                
                review.created = date.timeAgoSinceDate()
                
                review.Rating_Value = postDict.object(forKey: "rating") as? String ?? ""
                review.Rating_Text = postDict.object(forKey: "review") as? String ?? ""
                
                let params = [
                    "token" : g_myToken,
                    "user_id":postDict["user_id"]
                ]
                
                _ = ATB_Alamofire.POST(GET_PROFILE_API, parameters: params as [String : AnyObject],showLoading: false,showSuccess: false,showError: false){
                    (result, responseObject) in
                    
                    let postDicts = responseObject.object(forKey: "msg")  as! NSDictionary
                    let profile = postDicts["profile"] as! NSDictionary
                    
                    let followedUser = UserModel()
                    
                    followedUser.ID = profile.object(forKey: "id") as? String ?? ""
                    followedUser.profile_image = profile.object(forKey: "pic_url") as? String ?? ""
                    followedUser.user_name = profile.object(forKey: "user_name") as? String ?? ""
                    followedUser.account_name = profile["first_name"] as! String + " " + (profile["last_name"] as! String)
                    followedUser.firstName = profile.object(forKey: "first_name") as? String ?? ""
                    followedUser.lastName = profile.object(forKey: "last_name") as? String ?? ""
                    followedUser.description = profile.object(forKey: "description") as? String ?? ""
                    
                    review.Rater_Info = followedUser
                    
                    self.ratings.append(review)
                }
            }
            
            if (ratingCount > 0 ) {
                
                var avgRating = Double(totalRating)/Double(ratingCount)
                self.starView.rating = avgRating/5
                self.avgRating.text = String(format: "%.1f", avgRating)
                
                self.reviewAcount.text = String(ratingCount) + " reviews"
            } else {
                self.starView.rating = 0
                
                self.avgRating.text = "0"
                self.reviewAcount.text = String(ratingCount) + " reviews"
            }
            
        }
    }
    
    func getFollowCount(user_id:String){
        let params = [
                   "token" : g_myToken,
                   "user_id":user_id,
                   "is_business": "1"
               ]
                      
               _ = ATB_Alamofire.POST(GET_FOLLOW_COUNT, parameters: params as [String : AnyObject],showLoading: false,showSuccess: false,showError: false){
                   (result, responseObject) in
                   
                   let followCount = responseObject.object(forKey: "msg") as? NSNumber
                   self.btnSecond.text = followCount?.stringValue
                   
               }
    }
    
    func DeselectButton()
    {
        switch(self.selectedIndex)
        {
        case 1:
            self.btnFirst.image = UIImage(named: "Service1")
            break
        case 2:
            self.btnSecond.textColor = UIColor.lightGray
            break
        case 3:
            self.btnThird.image = UIImage(named: "bookmark")
            break
        case 4:
            if (ownProfile){
                self.btnLast.image = UIImage(named: "setting")
            } else {
                self.btnLast.image = UIImage(named: "MessageIcon")
            }
            break
        default:
            break
        }
        
        self.hideVC(index: self.selectedIndex)
    }
    
    func SelectButton(index:Int)
    {
        self.DeselectButton()
        switch(index)
        {
        case 1:
            self.btnFirst.image = UIImage(named: "Service")
            self.trianglePointer.center.x = btnFirstView.center.x
            break
        case 2:
            self.btnSecond.textColor = UIColor.primaryButtonColor
            self.trianglePointer.center.x = btnSecondView.center.x
            break
        case 3:
            self.btnThird.image = UIImage(named: "bookmark1")
            self.trianglePointer.center.x = btnThirdView.center.x
            break
        case 4:
            if (ownProfile){
                self.btnLast.image = UIImage(named: "setting1")
            } else {
                self.btnLast.image = UIImage(named: "MessageIcon")
            }
            self.trianglePointer.center.x = btnLastView.center.x
            break
        default:
            break
        }
        
        self.showVC(index: index)
        self.selectedIndex = index
    }
    
    func hideVC(index:Int)
    {
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveLinear, animations: {
            self.viewContent.alpha = 0
        }) { (isCompleted) in
            if(self.selectedViewController != nil)
            {
                self.selectedViewController!.willMove(toParent: nil)
                self.selectedViewController!.view.removeFromSuperview()
                self.selectedViewController!.removeFromParent()
            }
        }
    }
    
    func showVC(index:Int)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch index {
        case 1:
            let serviceListVC = storyboard.instantiateViewController(withIdentifier: "ServiceListViewController") as! ServiceListViewController
            if (ownProfile) {
                serviceListVC.service_list = g_myInfo.business_profile.businessServices
            } else {
                serviceListVC.service_list = viewingUser.business_profile.businessServices
            }
            self.addChild(serviceListVC)
            
            // Add the child's View as a subview
            self.viewContent.addSubview(serviceListVC.view)
            serviceListVC.view.frame = CGRect(x: 0, y: 0, width: viewContent.frame.width, height: viewContent.frame.height)
            serviceListVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            // tell the childviewcontroller it's contained in it's parent
            serviceListVC.didMove(toParent: self)
            
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                self.viewContent.alpha = 1.0
            }) { (isCompleted) in
                self.selectedViewController = serviceListVC
            }
            break
        case 2:
//            let likesListVC = storyboard.instantiateViewController(withIdentifier: "LikesListViewController") as! LikesListViewController
            let likesListVC = LikesListViewController.instance()
            self.addChild(likesListVC)
            
            // Add the child's View as a subview
            self.viewContent.addSubview(likesListVC.view)
            likesListVC.view.frame = CGRect(x: 0, y: 0, width: viewContent.frame.width, height: viewContent.frame.height)
            likesListVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            likesListVC.isFollowers = false
            // tell the childviewcontroller it's contained in it's parent
            likesListVC.didMove(toParent: self)
            if (!ownProfile) {
                likesListVC.viewingUser = self.viewingUser
            }
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                self.viewContent.alpha = 1.0
            }) { (isCompleted) in
                self.selectedViewController = likesListVC
            }
            break
        case 3:
            /*let bookmarkListVC = storyboard.instantiateViewController(withIdentifier: "BookMarkListViewController") as! BookMarkListViewController
            self.addChild(bookmarkListVC)
            
            // Add the child's View as a subview
            self.viewContent.addSubview(bookmarkListVC.view)
            bookmarkListVC.view.frame = CGRect(x: 0, y: 0, width: viewContent.frame.width, height: viewContent.frame.height)
            bookmarkListVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            // tell the childviewcontroller it's contained in it's parent
            bookmarkListVC.didMove(toParent: self)
            bookmarkListVC.viewingUser = self.viewingUser
            
            bookmarkListVC.ownProfile = false
            bookmarkListVC.business = true
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
                self.viewContent.alpha = 1.0
            }) { (isCompleted) in
                self.selectedViewController = bookmarkListVC
            }*/
            
            break
        default:
            break
        }
    }
    
    @IBAction func OnBtnOptions(_ sender: UIButton) {
        let index = sender.tag - 99
        
        if(index == 4)
        {
            if (ownProfile) {
                let configMnuVC = self.storyboard?.instantiateViewController(withIdentifier: "BusinessConfigurationMnuVC") as! BusinessConfigurationMnuVC
                self.navigationController?.pushViewController(configMnuVC, animated: true)
            } else {
               /* let alUser : ALUser =  ALUser()
                alUser.userId = g_myInfo.ID
                alUser.email = g_myInfo.emailAddress
                alUser.imageLink = DOMAIN_URL + g_myInfo.profileImage
                alUser.displayName = g_myInfo.userName
                alUser.password = g_myInfo.ID
                
                ALUserDefaultsHandler.setUserId(alUser.userId)
                ALUserDefaultsHandler.setEmailId(alUser.email)
                ALUserDefaultsHandler.setDisplayName(alUser.displayName)
                
                ATB_Alamofire.showIndicator()
                
                let chatManager = ALChatManager(applicationKey: "emtrac2ba61d90383c69a7fbc7db07725fa3e5b")
                
                chatManager.connectUserWithCompletion(alUser, completion: {response, error in
                    ATB_Alamofire.hideIndicator()
                    if error == nil {
                        let oppositeUserId = self.viewingUser.ID
                        chatManager.launchChatForUser(oppositeUserId, fromViewController: self)
                    } else {
                        self.showErrorVC(msg: "You can't chat with this user.")
                    }
                })*/
                
                let viewController = ConversationViewController()
                
                viewController.userId = self.viewingUser.ID
                
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        else
        {
            //self.trianglePointer.center.x = (sender.superview?.center.x)!
            SelectButton(index:index)
        }
    }
    
    @IBAction func OnClickBtnRating(_ sender: UIButton) {
//        let ratingListVC = self.storyboard?.instantiateViewController(withIdentifier: "RatingDetailViewController") as! RatingDetailViewController
//        ratingListVC.ratings_array = self.ratings
//        ratingListVC.viewingUser = self.viewingUser
//        self.navigationController?.pushViewController(ratingListVC, animated: true)
    }
    
    @IBAction func OnBtnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

