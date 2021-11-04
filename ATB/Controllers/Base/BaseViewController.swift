//
//  BaseViewController.swift
//  ATB
//
//  Created by YueXi on 4/16/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

enum AttachmentType: String{
 case camera, video, photoLibrary
}

class BaseViewController: UIViewController {
    
    lazy var overlayView: UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // open my own profile
    // forBusiness - represents whether to open my 'Business' or 'Normal' profile
    func openMyProfile(forBusiness business: Bool) {
        SlideMenuOptions.contentViewScale = 1.0
        SlideMenuOptions.leftViewWidth = SCREEN_WIDTH - 104
        
        // profile controller
        let profileVC = ProfileViewController.instance()
        profileVC.isBusiness = business
        profileVC.isBusinessUser = g_myInfo.isBusiness
        profileVC.isOwnProfile = true       // default
        
        // menu controller
        let menuVC = ProfileMenuViewController.instance()
        menuVC.isBusiness = business
        menuVC.isBusinessUser = g_myInfo.isBusiness

        let slideController = ExSlideMenuController(mainViewController: profileVC, rightMenuViewController: menuVC)
        
        self.navigationController?.pushViewController(slideController, animated: true)
    }
    
    // open other's profile
    // no including slide menu controller
    // isBusiness - represents whether to open other's 'Business' or 'Normal' profile
    func openProfile(forUser user: UserModel, forBusiness business: Bool) {
        // profile controller
        let profileVC = ProfileViewController.instance()
        profileVC.viewingUser = user
        profileVC.isBusiness = business
        profileVC.isBusinessUser = user.isBusiness
        profileVC.isOwnProfile = false

        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func openPosterProfile(forPost post: PostModel) {
        let params = [
            "token" : g_myToken,
            "post_id" : post.Post_ID
        ]
        
        showIndicator()
        _ = ATB_Alamofire.POST(GET_POST_DETAIL_API, parameters: params as [String : AnyObject]) { (result, response) in
            self.hideIndicator()
            guard result,
                  let detailDict = response.object(forKey: "extra") as? NSDictionary,
                  let userDicts = detailDict.object(forKey: "user") as? NSArray,
                  userDicts.count > 0,
                  let userDict = userDicts[0] as? NSDictionary else {
                self.showErrorVC(msg: "It's been failed to get the user details, please try again later!")
                return
            }
            
            let viewingUser = UserModel(info: userDict)
            
            if post.isBusinessPost {
                let businessDict = userDict["business_info"] as! NSDictionary
                let business = BusinessModel(info: businessDict)
                
                viewingUser.business_profile = business
                viewingUser.user_type = "Business"
                
            } else {
                viewingUser.user_type = "User"
            }
            
            self.openProfile(forUser: viewingUser, forBusiness: post.isBusinessPost)
        }
    }
        
    func showAlertForSettings(_ attachmentType: AttachmentType) {
        var alertTitle: String = ""
        
        if attachmentType == .camera {
            alertTitle = Constants.alertForCameraAccessMessage
        }
        
        if attachmentType == .photoLibrary {
            alertTitle = Constants.alertForPhotoLibraryMessage
        }
        
        if attachmentType == .video {
            alertTitle = Constants.alertForVideoLibraryMessage
        }
        
        let alertController = UIAlertController (title: alertTitle , message: nil, preferredStyle: .actionSheet)
        
        let settingsAction = UIAlertAction(title: Constants.settingsBtnTitle, style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
            
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: Constants.cancelBtnTitle, style: .default, handler: nil)
        alertController .addAction(cancelAction)
        alertController .addAction(settingsAction)
        alertController.view.tintColor = .colorPrimary
        self.present(alertController , animated: true, completion: nil)
    }
    
    func authorizationStatus(_ attachmentType: AttachmentType, completion: @escaping (Bool) -> Void) {
        if attachmentType ==  .camera {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized: // The user has previously granted access to the camera.
                completion(true)
                
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    completion(granted)
                }
            //denied - The user has previously denied access.
            //restricted - The user can't grant access due to restrictions.
            case .denied, .restricted:
                self.showAlertForSettings(attachmentType)
                return
                
            default:
                break
            }
            
        } else if attachmentType == .photoLibrary || attachmentType == .video {
            let status = PHPhotoLibrary.authorizationStatus()
            
            switch status {
            case .authorized:
                if attachmentType == AttachmentType.photoLibrary {
                    completion(true)
                }
                
                if attachmentType == AttachmentType.video {
                    completion(true)
                }
                
            case .denied, .restricted:
                self.showAlertForSettings(attachmentType)
                
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ status in
                    if status == .authorized {
                        // photo library access given
                        completion(true)
                    }
                    
                    if attachmentType == AttachmentType.video{
                        completion(true)
                    }
                })
                
            default:
                break
            }
        }
    }
        
    func hideKeyboardWhenTapped() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    private let overlayViewTag = 35678
    func showOverlay() {
        overlayView.alpha = 0.0
        overlayView.tag = overlayViewTag
        view.addSubview(overlayView)
        
//        overlayView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.3) {
            self.overlayView.alpha = 1.0
//            self.overlayView.transform = .identity
        }
    }
    
    func hideOverlay() {
        if let overlayView = view.viewWithTag(overlayViewTag) {
            UIView.animate(withDuration: 0.3) {
                overlayView.alpha = 0
                
            } completion: { _ in
                overlayView.removeFromSuperview()
            }
        }
    }
    
    func gotoPostDetail(_ selectedPost: PostDetailModel, comments: [CommentViewModel], isFollowing: Bool = false, isLiked: Bool = false, isSaved: Bool = false) {
        let postDetailVC = PostDetailViewController()
        
        postDetailVC.selectedPost = selectedPost
        postDetailVC.comments = comments
        postDetailVC.isFollowing = isFollowing
        postDetailVC.isLiked = isLiked
        postDetailVC.isSaved = isSaved
        postDetailVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(postDetailVC, animated: true)
    }
}

// MARK: - Slots Handlers
extension BaseViewController {
    
    func getHourTimeSlotsBetween(start: Date, end: Date, interval: Int) -> [String] {
        var intervals = 0
        if start > end {
            intervals = Int(end.addingTimeInterval(24*60*60).timeIntervalSince(start)/(60*60))
            
        } else {
            intervals = Int(end.timeIntervalSince(start)/(60*60))
        }
        
        var timeSlots = [String]()
        
        for i in 0 ..< intervals {
            let date = start.addingTimeInterval(TimeInterval(i*interval*60*60))
            timeSlots.append(date.toString("h:mm a"))
        }
        
        return timeSlots
    }
    
    func getSlotsBetween(startTime: Date, endTime: Date, date: Date, interval: Int) -> [Date] {
        var slots = [Date]()
        
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(abbreviation: "GMT")!
        var dayComponents = gregorian.dateComponents([.year, .month, .day], from: date)
        dayComponents.hour = gregorian.component(.hour, from: startTime)
        dayComponents.minute = gregorian.component(.minute, from: startTime)
        
        guard let start = gregorian.date(from: dayComponents) else { return [] }
        
        var intervals = 0
        if startTime > endTime {
            intervals = Int(endTime.addingTimeInterval(24*60*60).timeIntervalSince(startTime)/(60*60))
        } else {
            intervals = Int(endTime.timeIntervalSince(startTime)/(60*60))
        }
        
        for i in 0 ..< intervals {
            let slot = start.addingTimeInterval(TimeInterval(i*interval*60*60))
            slots.append(slot)
        }
        
        return slots
    }
    
//    func getSlotsBetween(start: Date, end: Date, interval: Int) -> [Date] {
//        var intervals = 0
//        if start > end {
//            intervals = Int(end.addingTimeInterval(24*60*60).timeIntervalSince(start)/(60*60))
//
//        } else {
//            intervals = Int(end.timeIntervalSince(start)/(60*60))
//        }
//
//        var timeSlots = [Date]()
//
//        for i in 0 ..< intervals {
//            let date = start.addingTimeInterval(TimeInterval(i*interval*60*60))
//            timeSlots.append(date)
//        }
//
//        return timeSlots
//    }
}


// MARK: - API Handlers
extension BaseViewController {
    
    func getPostDetail(_ post: PostModel) {
        let selectedPost = PostDetailModel()
        // post summerize
        selectedPost.Post_Summerize = post
        
        let isOwnPost = (g_myInfo.ID == post.Post_User_ID)
        
        let params = [
            "token" : g_myToken,
            "post_id" : post.Post_ID
        ]
        
        showIndicator()
        _ = ATB_Alamofire.POST(GET_POST_DETAIL_API, parameters: params as [String : AnyObject]) { (result, response) in
            guard result, 
                  let postDetailDict = response.object(forKey: "extra") as? NSDictionary,
                  let userDicts = postDetailDict.object(forKey: "user") as? NSArray,
                  userDicts.count > 0,
                  let userDict = userDicts[0] as? NSDictionary else {
                self.hideIndicator()
                self.showErrorVC(msg: "Failed to download the details of this post.\nPlease try again")
                return
            }
            
            let posterInfo: UserModel = UserModel(info: userDict)
            if let businessDict = userDict["business_info"] as? NSDictionary {
                let business = BusinessModel(info: businessDict)
                posterInfo.business_profile = business
                
                posterInfo.user_type = "Business"
                
            } else {
                posterInfo.user_type = "User"
            }
            
            selectedPost.Poster_Info = posterInfo
            
            // likes
            var isLiked = false
            // This value is only meaningful for others posts
            if !isOwnPost {
                if let likes = postDetailDict.object(forKey: "likes") as? [NSDictionary] {
                    for like in likes {
                        if let likedUserID = like.object(forKey: "follower_user_id") as? String,
                            likedUserID == g_myInfo.ID {
                            isLiked = true
                            break
                        }
                    }
                }
            }
            
//            let commentDicts = postDetailDict.object(forKey: "comments") as? [NSDictionary] ?? []
//
//            var commentArray:[CommentModel] = []
//            for commentDict in commentDicts
//            {
//                let newComment = CommentModel(info: commentDict)
//                commentArray.append(newComment)
//            }
//            postDetail.Comments = commentArray
            
            self.getComments(selectedPost, isOwnPost: isOwnPost, isLiked: isLiked)
        }
    }
    
    func getComments(_ selectedPost: PostDetailModel, isOwnPost: Bool, isLiked: Bool) {
        let postID = selectedPost.Post_Summerize.Post_ID
        
        APIManager.shared.getComments(forPost: postID, token: g_myToken) { status, message, allComments in
            guard let comments = allComments else {
                self.hideIndicator()
                self.showErrorVC(msg: "Failed to download the details of this post.\nPlease try again")
                
                return
            }
            
            if isOwnPost {
                self.hideIndicator()
                
                self.gotoPostDetail(selectedPost, comments: comments)
                
            } else {
                self.getFollows(selectedPost, comments: comments, isLiked: isLiked)
            }
        }
    }
    
    // Get followings to see if I am following this poster/user
    // the way to check this
    // get my followings, compare both follower_user_id and follower_business_id with this poster user_id and business_id
    func getFollows(_ selectedPost: PostDetailModel, comments: [CommentViewModel], isLiked: Bool) {
        let myUserID = g_myInfo.ID
//        let myBusinessID = g_myInfo.isBusiness ? g_myInfo.business_profile.ID : "0"
        let myBusinessID = "0"
        
        let posterUserID = selectedPost.Poster_Info.ID
//        let posterBusinessID = (selectedPost.Post_Summerize.Poster_Account_Type == "Business") ? selectedPost.Poster_Info.business_profile.ID : "0"
                
        let params = [
            "token": g_myToken,
            "follow_user_id": myUserID,
            "follow_business_id": myBusinessID
        ]
        
        var isFollowing = false
        
        _ = ATB_Alamofire.POST(GET_FOLLOW, parameters: params as [String: AnyObject], showLoading: false, showSuccess: false, showError: false, completionHandler: { (result, responseObject) in
            guard result else {
                self.hideIndicator()
                self.showErrorVC(msg: "Failed to download the details of this post.\nPlease try again")
                return
            }
            
            let responseDicts = (responseObject.object(forKey: "msg") as? [NSDictionary]) ?? []
            for responseDict in responseDicts {
                if let followingUserID = responseDict["follower_user_id"] as? String,
//                    let followingBusinessID = responseDict["follower_business_id"] as? String,
                   followingUserID == posterUserID {
//                    followingBusinessID == posterBusinessID {
                    isFollowing = true
                    
                    break
                }
            }
            
            self.getSavedList(selectedPost, comments: comments, isLiked: isLiked, isFollowing: isFollowing)
        })
    }
    
    func getSavedList(_ selectedPost: PostDetailModel, comments: [CommentViewModel], isLiked: Bool, isFollowing: Bool) {
        var isSaved = false
        
        let selectedPostID = selectedPost.Post_Summerize.Post_ID
        
        let params = [
            "token" : g_myToken,
            "user_id":g_myInfo.ID
        ]
        
        _ = ATB_Alamofire.POST(GET_USER_BOOKMARKS, parameters: params as [String : AnyObject]) { (result, response) in
            self.hideIndicator()
            
            guard result else {
                self.showErrorVC(msg: "Failed to download the details of this post.\nPlease try again")
                return
            }
        
            let postDicts = response.object(forKey: "msg")  as? [NSDictionary] ?? []
            for postDict in postDicts  {
                if let postID = postDict["id"] as? String,
                    postID == selectedPostID {
                    isSaved = true
                    break
                }
            }
            
            self.gotoPostDetail(selectedPost, comments: comments, isFollowing: isFollowing, isLiked: isLiked, isSaved: isSaved)
        }
    }
}
