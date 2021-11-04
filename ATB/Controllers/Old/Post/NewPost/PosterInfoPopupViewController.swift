//
//  PosterInfoPopupViewController.swift
//  ATB
//
//  Created by MobDev on 10/30/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import Applozic

class PosterInfoPopupViewController: BaseViewController{
    
    var selectedPost:PostDetailModel = PostDetailModel()
    
    @IBOutlet weak var imgProfile: RoundImageView!
    @IBOutlet weak var lblPosterName: UILabel!
    @IBOutlet weak var lblPosterUserName: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if (selectedPost.Post_Summerize.Poster_Account_Type == "Business") {
            if(self.selectedPost.Poster_Info.business_profile.businessPicUrl != "")
            {
                let url = URL(string: DOMAIN_URL + self.selectedPost.Poster_Info.business_profile.businessPicUrl)
                self.imgProfile.kf.setImage(with: url)
            }
            
            self.lblPosterName.text = self.selectedPost.Poster_Info.business_profile.businessName
            self.lblPosterUserName.text = "@" + self.selectedPost.Poster_Info.business_profile.businessProfileName
        } else {
            if(self.selectedPost.Poster_Info.profile_image != "")
            {
                let url = URL(string: DOMAIN_URL + self.selectedPost.Poster_Info.profile_image)
                self.imgProfile.kf.setImage(with: url)
            }
            
            self.lblPosterName.text = self.selectedPost.Poster_Info.firstName + " " + self.selectedPost.Poster_Info.lastName
            self.lblPosterUserName.text = "@" + self.selectedPost.Poster_Info.account_name
        }
        
       
        
        self.followBtn.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.view.layoutIfNeeded()
    }
    
    @IBAction func onBtnClose(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBtnViewProfile(_ sender: UIButton) {
//        if (selectedPost.Post_Summerize.Poster_Account_Type == "Business") {
//            openProfile(viewingUser: selectedPost.Poster_Info, isBusinessUser: true)
//
//        } else {
//            openProfile(viewingUser: selectedPost.Poster_Info, isBusinessUser: false)
//        }
    }
    
    @IBAction func onBtnSendMessage(_ sender: UIButton) {
        if(g_myInfo.ID == self.selectedPost.Poster_Info.ID)
        {
            return
        }
        
        /*let alUser : ALUser =  ALUser()
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
                let oppositeUserId = self.posterInfo.ID
                chatManager.launchChatForUser(oppositeUserId, fromViewController: self)
            } else {
                self.showErrorVC(msg: "You can't chat with this user.")
            }
        })*/
        
        let viewController = ConversationViewController()
        
        viewController.userId = self.selectedPost.Poster_Info.ID
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func onBtnFollow(_ sender: UIButton) {
        if(g_myInfo.ID == self.selectedPost.Poster_Info.ID)
        {
            self.showErrorVC(msg: "You can not follow yourself.")
            return
        }
        
        let follow_user_id = g_myInfo.ID
        var follower_business_id = "0"
        var follow_business_id = "0"
        var follower_user_id = "0"
        
        if (selectedPost.Post_Summerize.Poster_Account_Type == "Business") {
            follower_business_id = self.selectedPost.Poster_Info.business_profile.ID
        } else {
            follower_user_id = self.selectedPost.Poster_Info.ID
        }
        
        let params = [
                "token" : g_myToken,
                "follow_user_id":follow_user_id
        ]
               
               _ = ATB_Alamofire.POST(GET_FOLLOW, parameters: params as [String : AnyObject],showLoading: false,showSuccess: false,showError: false){
                   (result, responseObject) in
                   self.view.isUserInteractionEnabled = true
                   print(responseObject)
                   
                    let postDicts = responseObject.object(forKey: "msg")  as? [NSDictionary] ?? []
                                  
                    for postDict in postDicts
                    {
                        if (postDict["follower_user_id"] as! String == follower_user_id && postDict["follower_business_id"] as! String == follower_business_id) {
                                self.showErrorVC(msg: "Already following this user.")
                                return
                        }
                    }
                
                    let params = [
                        "token" : g_myToken,
                        "follower_business_id" : follower_business_id,
                        "follow_user_id":follow_user_id,
                        "follow_business_id":follow_business_id,
                        "follower_user_id":follower_user_id
                    ]
                    
                    _ = ATB_Alamofire.POST(ADD_FOLLOW, parameters: params as [String : AnyObject],showLoading: false,showSuccess: false,showError: false){
                        (result, responseObject) in
                        self.view.isUserInteractionEnabled = true
                        print(responseObject)
             
                        if(result)
                        {
                            self.showSuccessVC(msg: "You followed this user!")
                        }
                        else
                        {
                            let msg = responseObject.object(forKey: "msg") as? String ?? ""
                            
                            if(msg == "")
                            {
                                self.showErrorVC(msg: "Failed to add follow, please try again")
                            }
                            else
                            {
                                self.showErrorVC(msg: "Server returned the error message: " + msg)
                            }
                        }
                    }
               }
        
        
    }
}
