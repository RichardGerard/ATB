//
//  NotificationTableViewController.swift
//  ATB
//
//  Created by administrator on 18/01/2020.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class NotificationTableViewController: UITableViewController {

    var notifications:[NotificationModel] = []
    
    @IBAction func onSearchBtn(_ sender: Any) {
        let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @IBAction func onProfileBtn(_ sender: Any) {
//        let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
//        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Do any additional setup after loading the view, typically from a nib.
        let tableViewInsets:UIEdgeInsets = UIEdgeInsets(top: 18.0, left: 0.0, bottom: 12.0, right: 0.0)
        tableView.contentInset = tableViewInsets
        
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadList()
    }
    
    func loadList(){
        notifications.removeAll()
        tableView.reloadData()
        
        let user_id = g_myInfo.ID
        
        let params = [
            "token" : g_myToken,
            "user_id":user_id
        ]
        
        _ = ATB_Alamofire.POST(GET_NOTIFICATIONS, parameters: params as [String : AnyObject],showLoading: false,showSuccess: false,showError: false){
            (result, responseObject) in
            
            let postDicts = responseObject.object(forKey: "msg")  as? [NSDictionary] ?? []
            
            for postDict in postDicts
            {
                
                let notification = NotificationModel(info: postDict)
                
                if (notification.user_id == g_myInfo.ID || notification.isVisible) {
                    if(notification.type == "signup") {
                        
                        self.notifications.append(notification)
                        self.tableView.reloadData()
                    } else if(notification.type == "report") {
                        
                        self.notifications.append(notification)
                        self.tableView.reloadData()
                    } else if(notification.type == "comment"){
                        
                        self.notifications.append(notification)
                        self.tableView.reloadData()
                    } else if(notification.type == "rating"){
                        self.notifications.append(notification)
                        self.tableView.reloadData()
                        
                    } else if(notification.type == "booking"){
                        
                    } else if(notification.type == "message"){
                        
                        self.notifications.append(notification)
                        self.tableView.reloadData()
                    } else if(notification.type == "payment"){
                        
                        self.notifications.append(notification)
                        self.tableView.reloadData()
                    }
                }
                
                
                
                
                /*let params = [
                 "token" : g_myToken,
                 "user_id":postDict["follower_user_id"]
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
                 
                 self.user_list.append(followedUser)
                 self.tbl_list.reloadData()
                 }*/
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notiCell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell",
                                                     for: indexPath) as! NotificationTableViewCell
//        let notification = self.notifications[indexPath.row]
//        notiCell.configureWithData(notification: notification, index: indexPath.row)
//        notiCell.selectionStyle = .none

        return notiCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var notification = self.notifications[indexPath.row]
        
        let params = [
            "token" : g_myToken,
            "post_id" : notification.related_id
        ]
        
        _ = ATB_Alamofire.POST(GET_POST_DETAIL_API, parameters: params as [String : AnyObject],showLoading: false
        ,showSuccess: false,showError: false){
            (result, responseObject) in
            print(responseObject)
            
            if(result)
            {
                let postdetailmodel = PostDetailModel()
                
                let postDetailDict = responseObject.object(forKey: "extra") as! NSDictionary
                
                let post = PostModel(info: postDetailDict)
                
                postdetailmodel.Post_Summerize = post
                
                let posterInfo:UserModel = UserModel()
                
                var strUserId = postDetailDict.object(forKey: "user_id") as? String ?? ""
                if(strUserId == "")
                {
                    let nUserId = postDetailDict.object(forKey: "user_id") as? Int ?? 0
                    strUserId = String(nUserId)
                }
                
                let userDetailArray = postDetailDict.object(forKey: "user") as! NSArray
                let userDetailDict = userDetailArray[0] as! NSDictionary
                
                posterInfo.ID = strUserId
                posterInfo.profile_image = userDetailDict.object(forKey: "pic_url") as? String ?? ""
                posterInfo.user_name = userDetailDict.object(forKey: "user_name") as? String ?? ""
                posterInfo.account_name = userDetailDict.object(forKey: "user_name") as? String ?? ""
                posterInfo.firstName = userDetailDict.object(forKey: "first_name") as? String ?? ""
                posterInfo.lastName = userDetailDict.object(forKey: "last_name") as? String ?? ""
                posterInfo.description = userDetailDict.object(forKey: "description") as? String ?? ""
                postdetailmodel.Poster_Info = posterInfo
                
                if (post.Poster_Account_Type == "Business") {
                    let businessDict =  userDetailDict.object(forKey: "business_info") as! NSDictionary
                    let business = BusinessModel(info: businessDict)
                    
                    posterInfo.business_profile = business
                }
                
                let commentDicts = postDetailDict.object(forKey: "comments") as? [NSDictionary] ?? []
                
                var commentArray:[CommentModel] = []
                for commentDict in commentDicts
                {
                    let newComment = CommentModel(info: commentDict)
                    commentArray.append(newComment)
                }
                postdetailmodel.Comments = commentArray
                
//                let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "PostDetailViewController") as! PostDetailViewController
                let toVC = PostDetailViewController()
                toVC.selectedPost = postdetailmodel
                self.navigationController?.pushViewController(toVC, animated: true)
            }
        }
        
    }

}
