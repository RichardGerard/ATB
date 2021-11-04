//
//  LikesListViewController.swift
//  ATB
//
//  Created by mobdev on 2019/5/23.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class LikesListViewController: BaseViewController {
    
    static let kStoryboardID = "LikesListViewController"
    class func instance() -> LikesListViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: LikesListViewController.kStoryboardID) as? LikesListViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvBack.tintColor = .colorPrimary
        imvBack.contentMode = .scaleAspectFit
        }}
    
    @IBOutlet weak var imvProfile: UIImageView! { didSet {
        imvProfile.layer.cornerRadius = 24
        imvProfile.layer.masksToBounds = true
        imvProfile.contentMode = .scaleAspectFill
        imvProfile.image = UIImage(named: "new_profile_user")
        }}
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblFollowers: InsetLabel!
    @IBOutlet weak var lblFollowings: InsetLabel!
    
    private let boldAttrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "SegoeUI-Bold", size: 14)!
    ]
        
    @IBOutlet weak var tbl_list: UITableView!
    
    // represents whether follewers page has been opened or not
    var isFollowers = true
    
    // repsents whether you are seeing business's profile or normal
    var isBusiness = false
    // represents whether you are on your followers & followings page or not
    var isOwnProfile: Bool = false
    // the user who you are visiting now
    // will be nil when you are seeing your own profile
    var viewingUser: UserModel? = nil
    
    // Your followings ID list
    var myFollowings = [String]()
    
    // followers or followings list
    var userList: [UserModel] = []
    
    // (Followers, Followings, Posts)
    var likeDetails: (Int, Int, Int) = (0, 0, 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        isOwnProfile = (viewingUser == nil)
        
        setupViews()
        
        loadProfile()
        
        loadList()
    }
    
    private func setupViews() {
        if isBusiness {
            lblName.font = UIFont(name: "SegoeUI-Semibold", size: 24)
            
            lblUsername.font = UIFont(name: "SegoeUI-Light", size: 16)
            lblUsername.textColor = .colorPrimary
            
        } else {
            lblName.font = UIFont(name: "SegoeUI-Semibold", size: 26)
            
            lblUsername.font = UIFont(name: "SegoeUI-Light", size: 20)
            lblUsername.textColor = .colorGray11
        }
        
        lblName.textColor = .colorGray2
        
        lblFollowers.layer.cornerRadius = 12
        lblFollowers.layer.masksToBounds = true
        lblFollowers.contentInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        lblFollowers.font = UIFont(name: "SegoeUI-Light", size: 13)
        lblFollowers.textAlignment = .center

        lblFollowings.layer.cornerRadius = 12
        lblFollowings.layer.masksToBounds = true
        lblFollowings.contentInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        lblFollowings.font = UIFont(name: "SegoeUI-Light", size: 13)
        lblFollowings.textAlignment = .center
        
        tbl_list.contentInset = UIEdgeInsets(top: 12.0, left: 0.0, bottom: 12.0, right: 0.0)
        
        let follwerGesture = UITapGestureRecognizer(target: self, action: #selector(follwerTapped(_:)))
        follwerGesture.numberOfTapsRequired = 1
        follwerGesture.numberOfTouchesRequired = 1
        lblFollowers.addGestureRecognizer(follwerGesture)
        lblFollowers.isUserInteractionEnabled = true
        
        let followingGesture = UITapGestureRecognizer(target: self, action: #selector(followingTapped(_:)))
        followingGesture.numberOfTapsRequired = 1
        followingGesture.numberOfTouchesRequired = 1
        lblFollowings.addGestureRecognizer(followingGesture)
        lblFollowings.isUserInteractionEnabled = true
    }
    
    private func loadProfile() {
        var url = ""
        
        if isBusiness {
            let businessProfile = isOwnProfile ? g_myInfo.business_profile : viewingUser!.business_profile
            
            lblName.text = businessProfile.businessName
            lblUsername.text = businessProfile.businessWebsite
            
            url = businessProfile.businessPicUrl
            
        } else {
            if let viewingUser = viewingUser {
                lblName.text = viewingUser.firstName + " " + viewingUser.lastName
                lblUsername.text = "@" + viewingUser.user_name // or account_name
                
                url = viewingUser.profile_image
                
            } else {
                let ownUser = g_myInfo
                
                lblName.text = ownUser.firstName + " " + ownUser.lastName
                lblUsername.text = "@" + ownUser.userName
                
                url = ownUser.profileImage
            }
        }
        
        imvProfile.loadImageFromUrl(url, placeholder: "profile.placeholder")
        
        updateFollowView()
    }
    
    func updateFollowView() {
        if isFollowers {
            lblFollowers.backgroundColor = .colorPrimary
            lblFollowers.textColor = .white
            
            lblFollowings.backgroundColor = .colorGray7
            lblFollowings.textColor = .colorGray5
            
        } else {
            lblFollowers.backgroundColor = .colorGray7
            lblFollowers.textColor = .colorGray5
            
            lblFollowings.backgroundColor = .colorPrimary
            lblFollowings.textColor = .white
        }
        
        let followerSuffix = likeDetails.0 > 1 ? " followers" :  " follower"
        let followerStr = "\(likeDetails.0) " + followerSuffix
        let followerRange = (followerStr as NSString).range(of: "\(likeDetails.0)")
        let followerAttr = NSMutableAttributedString(string: followerStr)
        followerAttr.addAttributes(boldAttrs, range: followerRange)
        lblFollowers.attributedText = followerAttr
        
        let followingSuffix = likeDetails.1 > 1 ? " followings" :  " following"
        let followingStr = "\(likeDetails.1) " + followingSuffix
        let followingRange = (followingStr as NSString).range(of: "\(likeDetails.1)")
        let followingAttr = NSMutableAttributedString(string: followingStr)
        followingAttr.addAttributes(boldAttrs, range: followingRange)
        lblFollowings.attributedText = followingAttr
    }
    
    @objc func follwerTapped(_ sender: UITapGestureRecognizer) {
        guard !isFollowers else { return }
        
        // make sure to flag on before you update follow view for selection
        isFollowers = true
        updateFollowView()
        
        userList.removeAll()
        tbl_list.reloadData()
        
        loadList()
    }
    
    @objc func followingTapped(_ sender: UITapGestureRecognizer) {
        guard isFollowers else { return }
        
        // make sure to flag on before you update follow view for selection
        isFollowers = false
        updateFollowView()
        
        userList.removeAll()
        tbl_list.reloadData()
        
        loadList()
    }
    
    private func loadList() {
        let id = isOwnProfile ? g_myInfo.ID : viewingUser!.ID
        
        var params = [
            "token": g_myToken
        ]
        
        if isFollowers {
            params["follower_user_id"] = id
            params["follower_business_id"] = "0"
            
        } else {
            params["follow_user_id"] = id
            params["follow_business_id"] = "0"
        }
        
        let url = isFollowers ? GET_FOLLOWER : GET_FOLLOW
        
        showIndicator()
        _ = ATB_Alamofire.POST(url, parameters: params as [String : AnyObject]) { (result, response) in
            guard result,
                  let postDicts = response.object(forKey: "msg")  as? [NSDictionary] else {
                self.hideIndicator()
                self.showErrorVC(msg: "Failed to load \(self.isFollowers ? "Followers" : "Followings")")
                return
            }
            
            let totalCount = postDicts.count
            
            guard totalCount > 0 else {
                self.showInfoVC("ATB", msg: self.isFollowers ? "You don't have any followers yet" : "You are not following anyone yet")
                self.hideIndicator()
                return
            }
            
            for (index, postDict) in postDicts.enumerated() {
                let follow_user_id = postDict["follow_user_id"] as? String ?? ""
                let follower_user_id = postDict["follower_user_id"] as? String ?? ""
                
                let params = [
                    "token" : g_myToken,
                    "user_id": self.isFollowers ? follow_user_id : follower_user_id
                ]
                       
                _ = ATB_Alamofire.POST(GET_PROFILE_API, parameters: params as [String : AnyObject]) { (result, response) in
                    if result,
                          let postDict = response.object(forKey: "msg") as? NSDictionary,
                          let profileDict = postDict["profile"] as? NSDictionary {
                        
                        let businessDict = profileDict.object(forKey: "business_info") as? NSDictionary ?? [:]
                        let user = UserModel(info: profileDict)
                        if user.isBusiness {
                            user.business_profile = BusinessModel(info: businessDict)
                        }
                        
                        self.userList.append(user)
                    }
                    
                    if index >= totalCount - 1 {
                        if self.isOwnProfile {
                            self.hideIndicator()
                            self.tbl_list.reloadData()
                            
                        } else {
                            self.getMyFollowings()
                        }
                    }
                }
            }
        }
    }
    
    private func getMyFollowings() {
        let params = [
            "token": g_myToken,
            "follow_user_id": g_myInfo.ID,
            "follow_business_id": "0"
        ]
        
        _ = ATB_Alamofire.POST(GET_FOLLOW, parameters: params as [String: AnyObject], completionHandler: { (result, response) in
            self.hideIndicator()
            
            guard result,
                  let dicts = response.object(forKey: "msg")  as? [NSDictionary] else {
                self.showErrorVC(msg: "Failed to load \(self.isFollowers ? "Followers" : "Followings")")
                return
            }
            
            self.myFollowings.removeAll()
            for dict in dicts {
                self.myFollowings.append(dict["follower_user_id"] as? String ?? "")
            }
            
            self.tbl_list.reloadData()
        })
    }
    
    override func openMyProfile(forBusiness business: Bool) {
        // get rid of profile & likes view controller from navigation stack
        guard var viewControllers = navigationController?.viewControllers,
              viewControllers.count > 2 else { return }
        viewControllers.removeLast() // LikesViewController
        viewControllers.removeLast() // ProfileViewController
        
        SlideMenuOptions.contentViewScale = 1.0
        SlideMenuOptions.leftViewWidth = SCREEN_WIDTH - 104
        // profile controller
        let profileVC = ProfileViewController.instance()
        profileVC.isBusiness = business
        profileVC.isBusinessUser = g_myInfo.isBusiness
        
        // menu controller
        let menuVC = ProfileMenuViewController.instance()
        menuVC.isBusiness = isBusiness
        menuVC.isBusinessUser = g_myInfo.isBusiness

        let slideController = ExSlideMenuController(mainViewController: profileVC, rightMenuViewController: menuVC)
        viewControllers.append(slideController)
        
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
    override func openProfile(forUser user: UserModel, forBusiness business: Bool) {
        // get rid of profile & likes view controller from navigation stack
        guard var viewControllers = navigationController?.viewControllers,
              viewControllers.count > 2 else { return }
        viewControllers.removeLast() // LikesViewController
        viewControllers.removeLast() // ProfileViewController
        
        // profile controller
        let profileVC = ProfileViewController.instance()
        profileVC.viewingUser = user
        profileVC.isBusiness = business
        profileVC.isBusinessUser = user.isBusiness
        // isOwnProfile is not required actually, as viewingUser is nil
        // use this flag/boolean value to make logic and code simple
        profileVC.isOwnProfile = false
        
        viewControllers.append(profileVC)
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
    private func isFollowing(_ userID: String) -> Bool {
        guard let _ = myFollowings.first(where: { $0 == userID }) else {
            return false
        }
        
        return true
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - Action Handlers
extension LikesListViewController {
    
    // delete follower or follow on the user's own profile (me)
    private func deleteFollow(_ delete: UserModel) {
        var params = ["token": g_myToken]
        
        if isFollowers {
            params["follow_user_id"] = delete.ID
            params["follower_user_id"] = g_myInfo.ID
            
        } else {
            params["follow_user_id"] = g_myInfo.ID
            params["follower_user_id"] = delete.ID
        }
        
        showIndicator()
        _ = ATB_Alamofire.POST(DELETE_FOLLOWER, parameters: params as [String: AnyObject], completionHandler: { (result, response) in
            self.hideIndicator()
            
            guard result else {
                self.showErrorVC(msg: "Failed to \(self.isFollowers ? "remove the follower" : "unfollow the user"), please try again later!")
                return }
            guard let deletedIndex = self.userList.firstIndex(where: { $0.ID == delete.ID }) else { return }
            
            self.didDeleteFollow(deletedIndex)
        })
    }
    
    private func didDeleteFollow(_ deleted: Int) {
        // delete and reload the table view
        userList.remove(at: deleted)
        tbl_list.reloadData()
        
        // update like details
        if isFollowers {
            likeDetails.0 = ((likeDetails.0 - 1) > 0 ? (likeDetails.0 - 1) : 0)
            g_myInfo.followerCount = ((g_myInfo.followerCount - 1) > 0 ? (g_myInfo.followerCount - 1) : 0)

        } else {
            likeDetails.1 = ((likeDetails.1 - 1) > 0 ? (likeDetails.1 - 1) : 0)
            g_myInfo.followCount = ((g_myInfo.followCount - 1) > 0 ? (g_myInfo.followCount - 1) : 0)
        }
        
        updateFollowView()
        
        NotificationCenter.default.post(name: .FollowUpdated, object: nil)
    }
    
    private func followUser(_ follower: UserModel, isFollowing: Bool) {
        var params = [
            "token": g_myToken,
            "follow_user_id": g_myInfo.ID,
            "follower_user_id": follower.ID
        ]
        
        let url = isFollowing ? DELETE_FOLLOWER : ADD_FOLLOW
        
        if !isFollowing {
            params["follow_business_id"] = "0"
            params["follower_business_id"] = "0"
        }
        
        showIndicator()
        _ = ATB_Alamofire.POST(url, parameters: params as [String: AnyObject], completionHandler: { (result, response) in
            self.hideIndicator()
            
            guard result else {
                self.showErrorVC(msg: "Failed to \(isFollowing ? "unfollow" : "follow") the user, please try again later!")
                return }
            
            guard let followerIndex = self.userList.firstIndex(where: { $0.ID == follower.ID }) else { return }
        
            self.didFollowUser(follower.ID, followedIndex: followerIndex, isFollowing: isFollowing)
        })
    }
    
    private func didFollowUser(_ follower: String, followedIndex: Int, isFollowing: Bool) {
        if isFollowing {
            if let index = myFollowings.firstIndex(where: { $0 == follower }) {
                myFollowings.remove(at: index)
                g_myInfo.followCount = ((g_myInfo.followCount - 1) > 0 ? (g_myInfo.followCount - 1) : 0)
            }
            
        } else {
            myFollowings.append(follower)
            g_myInfo.followCount += 1
        }
        
        tbl_list.reloadRows(at: [IndexPath(row: followedIndex, section: 0)], with: .automatic)
        
        NotificationCenter.default.post(name: .FollowUpdated, object: nil)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension LikesListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let selected = userList[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikesTableViewCell", for: indexPath) as! LikesTableViewCell
        // configure the cell
        cell.configure(withUser: selected, isOwnProfile: isOwnProfile, isFollowers: isFollowers, isFollowing: isOwnProfile ? false : isFollowing(selected.ID))
        
        cell.actionBlock = {
            if self.isOwnProfile {
                self.deleteFollow(selected)
                
            } else {
                self.followUser(selected, isFollowing: self.isFollowing(selected.ID))
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = userList[indexPath.row]
        let isMe = selected.ID == g_myInfo.ID
        
        if isFollowers {
            if isMe {
                openMyProfile(forBusiness: false)
                
            } else {
                openProfile(forUser: selected, forBusiness: false)
            }
            
        } else {
            if selected.isBusiness {
                if isMe {
                    openMyProfile(forBusiness: true)
                    
                } else {
                    openProfile(forUser: selected, forBusiness: true)
                }
                
            } else {
                if isMe {
                    openMyProfile(forBusiness: false)
                    
                } else {
                    openProfile(forUser: selected, forBusiness: false)
                }
            }
        }
    }
}
