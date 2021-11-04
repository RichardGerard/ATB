//
//  FeedViewController.swift
//  ATB
//
//  Created by mobdev on 2019/5/16.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import Kingfisher
import BadgeHub

protocol FeedSelectChangeDelegate {
    func feedSelectChanged(feedModel:FeedModel)
}

class FeedViewController: BaseViewController {
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    private var notificationHub: BadgeHub?
    @IBOutlet weak var imvNotification: UIImageView!
    @IBOutlet weak var imvProfile: ProfileView!
    
    @IBOutlet weak var boostCollectionView: UICollectionView!
    
    @IBOutlet weak var tblFeed: UITableView!
    
    var posts: [PostModel] = []
    
    var boostList: [UserModel] = []
    
    var isDisplayed: Bool = false
    var selectedFeed: FeedModel = FeedModel()
    
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    
    // title, price, description
    private let CONTENT_PREFERRED_WIDTH = SCREEN_WIDTH - 36 - 20
    
    private var profilePins = [AuctionModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        setupViews()
        
        let defaultCenter = NotificationCenter.default
        
        defaultCenter.addObserver(self, selector: #selector(didDeletePost(_:)), name: .DidDeletePost, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didDeleteProduct(_:)), name: .DidDeleteProduct, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didDeleteService(_:)), name: .DidDeleteService, object: nil)
        
        defaultCenter.addObserver(self, selector: #selector(didReceiveItemReloadNotification(_:)), name: .PollVoted, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didReceiveItemReloadNotification(_:)), name: .PostLiked, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didReceiveItemReloadNotification(_:)), name: .PostNewCommentAdded, object: nil)
        
        defaultCenter.addObserver(self, selector: #selector(didReceiveProductStockChanged(_:)), name: .ProductStockChanged, object: nil)
        
        defaultCenter.addObserver(self, selector: #selector(appDidFinishLaunching), name: .LaunchingWithDeepLink, object: nil)
        
        // post updated
        defaultCenter.addObserver(self, selector: #selector(didUpdatePost(_:)), name: .DidUpdatePost, object: nil)
        
        
        defaultCenter.addObserver(self, selector: #selector(appEnteredFromBackground),
                                  name: UIApplication.willEnterForegroundNotification, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didUpgradeAccount(_:)), name: .DidUpgradeAccount, object: nil)
        
        defaultCenter.addObserver(self, selector: #selector(refreshNotificationHub), name: .DiDLoadNotification, object: nil)
        defaultCenter.addObserver(self, selector: #selector(refreshNotificationHub), name: .DidReadNotification, object: nil)
        
        appDelegate?.applozicClient.userService.getListOfRegisteredUsers(completion: { error in })
        
        let parentVC = self.navigationController?.parent as! MainTabBarVC
        parentVC.feedChangeDelegate = self
        selectedFeed = parentVC.selectedFeed
        
        // to mute videos
        ASVideoPlayerController.sharedVideoPlayer.mute = true
        
        getProfilePins(with: selectedFeed.Title)
        
        getFeed()
        
        getNotifications()
        
        registerForPushNotifications()
    }
    
    private func setupViews() {
        // add shadow to navigation view
        navigationView.layer.shadowOffset = CGSize(width: 0, height: -2)
        navigationView.layer.shadowRadius = 4.0
        navigationView.layer.shadowColor = UIColor.lightGray.cgColor
        navigationView.layer.shadowOpacity = 0.4
        
        titleContainer.backgroundColor = .colorGray3
        titleContainer.layer.cornerRadius = 4
        
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 19)
        lblTitle.textColor = .white
        
        if #available(iOS 13.0, *) {
            imvNotification.image = UIImage(systemName: "bell.fill")
        } else {
            // Fallback on earlier versions
        }
        imvNotification.tintColor = .colorPrimary
        imvNotification.clipsToBounds = false
        notificationHub = BadgeHub(view: imvNotification)
        notificationHub?.setCircleBorderColor(.white, borderWidth: 1.5)
        notificationHub?.setCircleColor(.colorRed1, label: .clear)
        notificationHub?.scaleCircleSize(by: 0.5)
        notificationHub?.moveCircleBy(x: -4, y: 0)
        let unreadNotificationsCount = ATB_UserDefault.getInt(key: NOTIFICATION_COUNT, defaultValue: 0)
        unreadNotificationsCount > 0 ? notificationHub?.show() : notificationHub?.hide()
        
        imvProfile.borderColor = .colorPrimary
        imvProfile.borderWidth = 1.5
        let profilePictureUrl = g_myInfo.isBusiness ? g_myInfo.business_profile.businessPicUrl : g_myInfo.profileImage
        imvProfile.loadImageFromUrl(profilePictureUrl, placeholder: "profile.placeholder")
        
        // set up boost collection view
        boostCollectionView.showsHorizontalScrollIndicator = false
        boostCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        boostCollectionView.register(AddBoostCell.self, forCellWithReuseIdentifier: AddBoostCell.reuseIdentifier)
        boostCollectionView.register(BoostListCell.self, forCellWithReuseIdentifier: BoostListCell.reuseIdentifier)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 60, height: 86)
        
        boostCollectionView.collectionViewLayout = layout
        boostCollectionView.dataSource = self
        boostCollectionView.delegate = self
        
        // setup feed table view
        tblFeed.register(UINib(nibName: "TextPostCell", bundle: nil), forCellReuseIdentifier: TextPostCell.reuseIdentifier)
        tblFeed.register(UINib(nibName: "MediaPostCell", bundle: nil), forCellReuseIdentifier: MediaPostCell.reuseIdentifier)
        tblFeed.register(UINib(nibName: "TextPollPostCell", bundle: nil), forCellReuseIdentifier: TextPollPostCell.reuseIdentifier)
        tblFeed.register(UINib(nibName: "MediaPollPostCell", bundle: nil), forCellReuseIdentifier: MediaPollPostCell.reuseIdentifier)
        tblFeed.register(UINib(nibName: "MultiplePostCell", bundle: nil), forCellReuseIdentifier: MultiplePostCell.reuseIdentifier)
        
        tblFeed.backgroundColor = .colorGray7
        tblFeed.showsVerticalScrollIndicator = false
        tblFeed.separatorStyle = .none
        tblFeed.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tblFeed.tableFooterView = UIView()
        
        tblFeed.dataSource = self
        tblFeed.delegate = self
        
        tblFeed.addPullToRefresh(actionHandler: {
            self.getProfilePins(with: self.selectedFeed.Title)
            self.getFeed(refresh: true)
            
        }, position: .top)
        
        for refershView in tblFeed.pullToRefreshViews {
            if let pullToRefreshView = refershView as? SVPullToRefreshView {
                pullToRefreshView.setTitle("", for: .all)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        pausePlayVideos()
        
        isDisplayed = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ASVideoPlayerController.sharedVideoPlayer.removePlayer(in: tblFeed)
        
        isDisplayed = false
    }
    
    @objc private func didUpgradeAccount(_ notification: Notification) {
        DispatchQueue.main.async {
            let profilePictureUrl = g_myInfo.isBusiness ? g_myInfo.business_profile.businessPicUrl : g_myInfo.profileImage
            self.imvProfile.loadImageFromUrl(profilePictureUrl, placeholder: "profile.placeholder")
        }
    }
    
    @objc func appDidFinishLaunching() {
        guard !g_deepLinkId.isEmpty else { return }
        
        if g_deepLinkType == "0",
            posts.count > 0,
           let _ = posts.firstIndex(where: { $0.Post_ID == g_deepLinkId}) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.handleDeepLink(withID: g_deepLinkId)
            }
        }
    }
    
    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] (granted, error) in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                guard granted else {
                    self?.showPermissionAlert()
                    return
                }
                self?.getNotificationSettings()
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
            }
        }
    
    func showPermissionAlert() {
        let alert = UIAlertController(title: "WARNING", message: "Please enable access to Notifications in the Settings app.", preferredStyle: .actionSheet)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) {[weak self] (alertAction) in
            self?.gotoAppSettings()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        alert.view.tintColor = .colorPrimary
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
       }
    }
    
    private func gotoAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.openURL(settingsUrl)
        }
    }

    @available(iOS 10.0, *)
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            }
    }
    
    private func getNotifications() {
        let params = ["token" : g_myToken]
        
        _ = ATB_Alamofire.POST(GET_NOTIFICATIONS, parameters: params as [String : AnyObject]) { (result, response) in
            self.hideIndicator()
            
            guard result,
                  let postDicts = response.object(forKey: "msg")  as? [NSDictionary] else { return }
            
            var notifications = [NotificationModel]()
            for postDict in postDicts {
                let notification = NotificationModel(info: postDict)
                if notification.isVisible {
                    notifications.append(notification)
                }
            }
            
            var unreadNotificationsCount = 0
            for notification in notifications {
                if !notification.isRead {
                    unreadNotificationsCount += 1
                }
            }
            
            ATB_UserDefault.setInt(key: NOTIFICATION_COUNT, value: unreadNotificationsCount)
            NotificationCenter.default.post(name: .DiDLoadNotification, object: nil)
        }
    }
    
    @objc private func refreshNotificationHub() {
        let unreadNotificationsCount = ATB_UserDefault.getInt(key: NOTIFICATION_COUNT, defaultValue: 0)
        DispatchQueue.main.async {
            unreadNotificationsCount > 0 ? self.notificationHub?.show() : self.notificationHub?.hide()
        }
    }
    
    @IBAction func didTapNotification(_ sender: Any) {
        let toVC = NotificationsViewController.instance()
        toVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(toVC, animated: true)
    }
    
    @IBAction func didTapProfile(_ sender: Any) {
        openMyProfile(forBusiness: g_myInfo.isBusiness)
    }

    @IBAction func didTapLogo(_ sender: Any) {
        tblFeed.scroll(to: .top, animated: true)
    }
    
    private func handleDeepLink(withID id: String) {
        if g_deepLinkType == "1" {
            openProduct(id)
            
        } else if g_deepLinkType == "2" {
            openService(id)
            
        } else {
            guard let index = posts.firstIndex(where: { $0.Post_ID == id }) else { return }
            
            let selectedPost = posts[index]
            getPostDetail(selectedPost)
        }
        
        g_deepLinkId = ""
    }
    
    private func openProduct(_ productId: String) {
        showIndicator()
        
        let params = [
            "token": g_myToken,
            "product_id": productId
        ]
        
        let url = API_BASE_URL + "profile/get_product"
        _ = ATB_Alamofire.POST(url, parameters: params as [String: AnyObject], completionHandler: { (result, response) in
            self.hideIndicator()
            
            guard result,
                  let extraDict = response.object(forKey: "extra") as? NSDictionary,
                  let userDicts = extraDict.object(forKey: "user") as? NSArray,
                  userDicts.count > 0,
                  let userDict = userDicts[0] as? NSDictionary else {
                return
            }
            
            let product = PostModel(info: extraDict)
            let viewingUser = UserModel(info: userDict)
            
            guard product.isBusinessPost,
                  viewingUser.isBusiness else { return }
            
            let toVC = BusinessStoreItemViewController()
            toVC.selectedItem = product
            if viewingUser.ID != g_myInfo.ID {
                toVC.viewingUser = viewingUser
            }
            toVC.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(toVC, animated: true)
        })
    }
    
    private func openService(_ serviceId: String) {
        showIndicator()
        
        let params = [
            "token": g_myToken,
            "service_id": serviceId
        ]
        
        let url = API_BASE_URL + "profile/get_service"
        _ = ATB_Alamofire.POST(url, parameters: params as [String: AnyObject], completionHandler: { (result, response) in
            self.hideIndicator()
            
            guard result,
                  let extraDict = response.object(forKey: "extra") as? NSDictionary,
                  let userDicts = extraDict.object(forKey: "user") as? NSArray,
                  userDicts.count > 0,
                  let userDict = userDicts[0] as? NSDictionary else {
                return
            }
            
            let service = PostModel(info: extraDict)
            let viewingUser = UserModel(info: userDict)
            
            guard service.isBusinessPost,
                  viewingUser.isBusiness else { return }
            
            let toVC = BusinessStoreItemViewController()
            toVC.selectedItem = service
            if viewingUser.ID != g_myInfo.ID {
                toVC.viewingUser = viewingUser
            }
            toVC.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(toVC, animated: true)
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // [(country, 2), (county 1), (region, 1), (country, 1), (region, 2), (county, 2)]
    private let PIN_POSITIONS = [(0, 1), (1, 0), (2, 0), (0, 0), (2, 1), (1, 1)]
}

// MARK: - FeedSelectChangeDelegate
extension FeedViewController: FeedSelectChangeDelegate {
    
    func feedSelectChanged(feedModel: FeedModel) {
        selectedFeed = feedModel
        
        getProfilePins(with: selectedFeed.Title)
        
        getFeed()
    }
}

// MARK: - API Handlers
extension FeedViewController {
    
    func getFeed(refresh: Bool = false) {
        lblTitle.text = selectedFeed.Title.uppercased()

        var params = [
            "token" : g_myToken,
            "search_key": ""
        ]
        var api_url = ""
        
        if selectedFeed.isMyATB {
            api_url = GET_ALL_FEED_API
            
        } else {
            api_url = GET_SELECTED_FEED_API
            params["category_title"] = selectedFeed.Title
        }
        
        if refresh {
            showFakeIndicator()
            
        } else {
            showIndicator()
        }
        
        _ = ATB_Alamofire.POST(api_url, parameters: params as [String : AnyObject]) { (result, responseObject) in
            if refresh {
                self.tblFeed.pullToRefreshView(at: .top)?.stopAnimating()
                self.hideFakeIndicator()
                
            } else {
                self.hideIndicator()
            }
            
            
            if result,
               let postDicts = responseObject.object(forKey: "extra")  as? [NSDictionary] {
                //get post model array and reload
                self.posts.removeAll()
                
                for postDict in postDicts {
                    let newPostModel = PostModel(info: postDict)
                    self.posts.append(newPostModel)
                }
                
                self.tblFeed.reloadData()
                // to play the first video
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.pausePlayVideos()
                }
                
                if !refresh {
                    self.tblFeed.scroll(to: .top, animated: false)
                }
            
                if !g_deepLinkId.isEmpty {
                    self.handleDeepLink(withID: g_deepLinkId)
                }
                
            } else {
                let msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if(msg == "")
                {
                    self.showErrorVC(msg: "Failed to download posts please try again")
                }
                else
                {
                    self.showErrorVC(msg: "Server returned the error message: " + msg)
                }
            }
        }
    }
    
    private func getProfilePins(with category: String) {
        APIManager.shared.getProfilePins(g_myToken, category: category) { result in
            switch result {
            case.success(let auctions):
                self.profilePins.removeAll()
                self.profilePins.append(contentsOf: auctions)
                
            case .failure(_):
                self.profilePins.removeAll()
                break
            }
            
            self.boostCollectionView.reloadData()
        }
    }
}

// MARK: - Notification Observer
extension FeedViewController {
    
    @objc func didDeletePost(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
              let postId = userInfo["post_id"] as? String,
              let index = posts.firstIndex(where: {
                if $0.isMultiplePost {
                    if let _ = $0.group_posts.firstIndex(where: { $0.Post_ID == postId }) {
                        return true
                        
                    } else {
                        return $0.Post_ID == postId
                    }
                    
                } else {
                    return $0.Post_ID == postId
                }
            }) else { return }
        
        let deleted = posts[index]
        if deleted.Post_ID == postId {
            posts.remove(at: index)
            
        } else {
            guard let indexInGroup = deleted.group_posts.firstIndex(where: {  $0.Post_ID == postId  }) else { return }
            posts[index].group_posts.remove(at: indexInGroup)
        }
        
        DispatchQueue.main.async {
            self.tblFeed.reloadData()
            
            self.showDeleteNotification()
        }
    }
    
    @objc private func didDeleteProduct(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let deletedProductId = object["product_id"] as? String else { return }
        
        // get only none-deleted posts
        var updatedPosts = [PostModel]()
        for post in posts {
            guard post.isSale else {
                updatedPosts.append(post)
                continue
            }
            
            if post.isMultiplePost {
                if let productId = post.pid,
                   productId != deletedProductId {
                    updatedPosts.append(post)
                    
                    if let updatedPost = updatedPosts.last {
                        guard let index = updatedPost.group_posts.firstIndex(where: {
                            guard let productIdInGroup = $0.pid,
                                  productIdInGroup == deletedProductId else { return false }
                            
                            return true
                            
                        }) else {
                            continue
                        }
                        
                        updatedPost.group_posts.remove(at: index)
                    }
                }
                
            } else {
                if let productId = post.pid,
                   productId != deletedProductId {
                    updatedPosts.append(post)
                }
            }
        }
        
        posts.removeAll()
        posts.append(contentsOf: updatedPosts)

        DispatchQueue.main.async {
            self.tblFeed.reloadData()
        }
    }
    
    @objc private func didDeleteService(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let deletedServiceId = object["service_id"] as? String else { return }
        
        // get only none-deleted posts
        var updatedPosts = [PostModel]()
        for post in posts {
            guard post.isService else {
                updatedPosts.append(post)
                continue
            }
            
            if post.isMultiplePost {
                if let serviceId = post.sid,
                   serviceId != deletedServiceId {
                    updatedPosts.append(post)
                    
                    if let updatedPost = updatedPosts.last {
                        guard let index = updatedPost.group_posts.firstIndex(where: {
                            guard let serviceIdInGroup = $0.sid,
                                  serviceIdInGroup == deletedServiceId else { return false }
                            
                            return true
                            
                        }) else {
                            continue
                        }
                        
                        updatedPost.group_posts.remove(at: index)
                    }
                }
                
            } else {
                if let serviceId = post.sid,
                   serviceId != deletedServiceId {
                    updatedPosts.append(post)
                }
            }
        }
        
        posts.removeAll()
        posts.append(contentsOf: updatedPosts)

        DispatchQueue.main.async {
            self.tblFeed.reloadData()
        }
    }
    
    // false - when the post is deleted
    private func showDeleteNotification() {
        let toastMessage = "The post has been deleted successfully."
        let toastFont = UIFont(name: Font.SegoeUILight, size: 16)
        let estimatedFrame = toastMessage.heightForString(SCREEN_WIDTH - 72, font: toastFont)
        
        let toastViewHeight: CGFloat = estimatedFrame.height + 20
        let toastView = TextToastView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 40, height: toastViewHeight))
        toastView.toastMessage = toastMessage
        
        // giving position with a point as we have input accessory view
        showToast(toastView)
    }
    
    @objc func didReceiveItemReloadNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let object = notification.object as? [String: Any],
                  let postID = object["postID"] as? String else {
                return
            }
            
            if let indexForPost = self.posts.firstIndex(where: { $0.Post_ID == postID }) {
                self.tblFeed.reloadRows(at: [IndexPath(row: indexForPost, section: 0)], with: .none)
            }
        }
    }
    
    @objc private func didUpdatePost(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let updated = object["updated"] as? PostModel else { return }
        
        if updated.isAdvice {
            // the updated will be a post model
            // advice does not have multiple posts
            guard let index = posts.firstIndex(where: { $0.Post_ID == updated.Post_ID }) else { return}
            
            // if the post was updated from the feed page, no need to call this
            // however, if was updated from the profile page, we need to update with the updated one
            posts[index].update(withPost: updated)
            DispatchQueue.main.async {
                self.tblFeed.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
            }
            
        } else {
            // the updated will be whether a product or a service
            // get all posts for the updated product or service
            let filtered = posts.filter({
                if $0.isMultiplePost {
                    if let _ = $0.group_posts.firstIndex(where: {
                        if updated.isSale {
                            guard let pid = $0.pid,
                                  pid == updated.Post_ID else { return false }
                            
                            return true
                            
                        } else {
                            guard let sid = $0.sid,
                                  sid == updated.Post_ID else { return false }
                            
                            return true
                        }
                    }) {
                        return true
                        
                    } else {
                        if updated.isSale {
                            guard let pid = $0.pid,
                                  pid == updated.Post_ID else { return false }
                            
                            return true
                            
                        } else {
                            guard let sid = $0.sid,
                                  sid == updated.Post_ID else { return false }
                            
                            return true
                        }
                    }
                    
                } else {
                    if updated.isSale {
                        guard let pid = $0.pid,
                              pid == updated.Post_ID else { return false }
                        
                        return true
                        
                    } else {
                        guard let sid = $0.sid,
                              sid == updated.Post_ID else { return false }
                        
                        return true
                    }
                }
            })
            
            var reloadIndexes = [IndexPath]()
            for filteredPost in filtered {
                if filteredPost.isMultiplePost {
                    if let indexInGroup = filteredPost.group_posts.firstIndex(where: {
                        if updated.isSale {
                            guard let pid = $0.pid,
                                  pid == updated.Post_ID else { return false }
                            
                            return true
                            
                        } else {
                            guard let sid = $0.sid,
                                  sid == updated.Post_ID else { return false }
                            
                            return true
                        }
                    }) {
                        if updated.isSale {
                            filteredPost.group_posts[indexInGroup].update(withProduct: updated)
                            
                        } else {
                            filteredPost.group_posts[indexInGroup].update(withService: updated)
                        }
                        
                    } else {
                        // the 1st in the group post
                        if updated.isSale {
                            filteredPost.update(withProduct: updated)
                            
                        } else {
                            filteredPost.update(withService: updated)
                        }
                    }
                    
                } else {
                    if updated.isSale {
                        filteredPost.update(withProduct: updated)
                        
                    } else {
                        filteredPost.update(withService: updated)
                    }
                }
                
                if let index = posts.firstIndex(where: { $0.Post_ID == filteredPost.Post_ID }) {
                    reloadIndexes.append(IndexPath(row: index, section: 0))
                }
            }
            
            guard reloadIndexes.count > 0 else { return }
            
            DispatchQueue.main.async {
                self.tblFeed.reloadRows(at: reloadIndexes, with: .fade)
            }
        }
    }
    
    @objc private func didReceiveProductStockChanged(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let updatedProductId = object["product_id"] as? String,
              let updated = object["updated"] as? PostModel else { return }
        
        // get all posts for the updated product
        let filtered = posts.filter({
            guard $0.isSale else { return false }
                  
            if $0.isMultiplePost {
                if let _ = $0.group_posts.firstIndex(where: {
                    guard let productId = $0.pid,
                          productId == updatedProductId else {
                        return false
                    }
                    
                    return true
                    
                }) {
                    return true
                    
                } else {
                    guard let productId = $0.pid,
                          productId == updatedProductId else {
                        return false
                    }
                    
                    return true
                }
                
            } else {
                guard let productId = $0.pid,
                      productId == updatedProductId else {
                    return false
                }
                
                return true
            }
        })
        
        var reloadIndexes = [IndexPath]()
        for filteredPost in filtered {
            if filteredPost.isMultiplePost {
                if let indexInGroup = filteredPost.group_posts.firstIndex(where: {
                    guard let productId = $0.pid,
                          productId == updatedProductId else {
                        return false
                    }
                    
                    return true
                }) {
                    filteredPost.group_posts[indexInGroup].update(withProduct: updated)
                    
                } else {
                    // the 1st in the group post
                    filteredPost.update(withProduct: updated)
                }
                
            } else {
                filteredPost.update(withProduct: updated)
            }
            
            if let index = posts.firstIndex(where: { $0.Post_ID == filteredPost.Post_ID }) {
                reloadIndexes.append(IndexPath(row: index, section: 0))
            }
        }
        
        guard reloadIndexes.count > 0 else { return }
        
        DispatchQueue.main.async {
            self.tblFeed.reloadRows(at: reloadIndexes, with: .fade)
        }
    }
}

// MARK: - PollVoteDelegate
extension FeedViewController: PollVoteDelegate {
    
    func vote(forOption index: Int, inPost post: PostModel, completion: @escaping (Bool, PostModel?) -> Void) {
        // check if user already voted
        let ownID = g_myInfo.ID
        
        var voted = false
        for option in post.Post_PollOptions {
            if let _ = option.votes.firstIndex(of: ownID) {
                voted = true
                break
            }
        }
        
        guard !voted else {
            showErrorVC(msg: "You've already voted on this poll!")
            return
        }
        
        let value = post.Post_PollOptions[index].value
        
        let params = [
            "token": g_myToken,
            "post_id": post.Post_ID,
            "poll_value": value
        ]
        
        showIndicator()
        _ = ATB_Alamofire.POST(ADD_VOTE, parameters: params as [String : AnyObject], showLoading: false, showSuccess: false, showError: false) { (result, responseObject) in
            self.hideIndicator()

            if result {                
                // add the new vote made
                // { $0.Post_ID == post.Post_ID }
                if let indexForPost = self.posts.firstIndex(where: { (item) -> Bool in item.Post_ID == post.Post_ID }) {
                    self.posts[indexForPost].Post_PollOptions[index].votes.append(ownID)
                    
                    completion(true, self.posts[indexForPost])
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource , UITableViewDelegate
extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        if post.isMultiplePost {
            let cell = tableView.dequeueReusableCell(withIdentifier: MultiplePostCell.reuseIdentifier, for: indexPath)
            
            return cell
            
        } else {
            if (post.Post_Type == "Poll") {
                if post.isTextPost {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TextPollPostCell.reuseIdentifier, for: indexPath) as! TextPollPostCell
                    // configure the cell
                    cell.configureCell(post)
                    
                    cell.profileTapBlock = {
                        let ownUser = g_myInfo
                        
                        if post.Post_User_ID == ownUser.ID {
                            self.openMyProfile(forBusiness: post.isBusinessPost)
                            
                        } else {
                            self.openPosterProfile(forPost: post)
                        }
                    }
                    
                    cell.delegate = self

                    return cell
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: MediaPollPostCell.reuseIdentifier, for: indexPath) as! MediaPollPostCell
                    // configure the cell
                    cell.configureCell(post)
                    
                    cell.profileTapBlock = {
                        let ownUser = g_myInfo
                        
                        if post.Post_User_ID == ownUser.ID {
                            self.openMyProfile(forBusiness: post.isBusinessPost)
                            
                        } else {
                            self.openPosterProfile(forPost: post)
                        }
                    }
                    
                    cell.delegate = self

                    return cell
                }
                
            } else {
                if(post.Post_Media_Type == "Text") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.reuseIdentifier, for: indexPath) as! TextPostCell
                    // configure the cell
                    cell.configureCell(post)
                    
                    cell.likeBlock = {
                        print("like tapped")
                    }
                    
                    cell.profileTapBlock = {
                        let ownUser = g_myInfo
                        
                        if post.Post_User_ID == ownUser.ID {
                            self.openMyProfile(forBusiness: post.isBusinessPost)
                            
                        } else {
                            self.openPosterProfile(forPost: post)
                        }
                    }
                    
                    return cell
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: MediaPostCell.reuseIdentifier, for: indexPath) as! MediaPostCell
                    // configure the cell
                    cell.configureCell(post)
                    
                    cell.likeBlock = {
                        print("like tapped")
                    }
                    
                    cell.profileTapBlock = {
                        let ownUser = g_myInfo
                        
                        if post.Post_User_ID == ownUser.ID {
                            self.openMyProfile(forBusiness: post.isBusinessPost)
                            
                        } else {
                            self.openPosterProfile(forPost: post)
                        }
                    }
                    
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        guard post.isMultiplePost,
              let multiplePostCell = cell as? MultiplePostCell else { return }
        multiplePostCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard posts.count > indexPath.row else { return }

        // to remove player that ends displaying
        guard let videoCell =  cell as? ASAutoPlayVideoLayerContainer else { return }
        
        if cell is MultiplePostCell {
            // multiple post cell ends displaying
            // the case
            // a video on the multiple collection cell was playing
            // the cell become unvisible by scrolling before the video is stopped
            guard let multiplePostCell = cell as? MultiplePostCell,
                  let collectionView = multiplePostCell.clvPost else { return }
            
            let endingPost = posts[indexPath.row]
            
            // the root item in the group post
            if let collectionCell = collectionView.cellForItem(at: IndexPath(row: 0, section: 0)),
               let videoCell = collectionCell as? ASAutoPlayVideoLayerContainer,
               let _ = videoCell.videoURL {
                // has a valid video url - video cell
                ASVideoPlayerController.sharedVideoPlayer.removePlayerLayer(in: videoCell)
            }
            
            for (index, _) in endingPost.group_posts.enumerated() {
                guard let collectionCell = collectionView.cellForItem(at: IndexPath(row: index + 1, section: 0)),
                      let videoCell = collectionCell as? ASAutoPlayVideoLayerContainer,
                      let _ = videoCell.videoURL else { continue }
                
                // has a valid video url - video cell
                ASVideoPlayerController.sharedVideoPlayer.removePlayerLayer(in: videoCell)
            }
            
        } else {
            // a single media cell ends displaying
            guard let _ = videoCell.videoURL else { return }
            
            // has a valid video url - video cell
            ASVideoPlayerController.sharedVideoPlayer.removePlayerLayer(in: videoCell)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if (post.isMultiplePost) {
            return MultiplePostCell.cellHeight(post)
            
        } else {
            if post.isPoll {
                if post.isTextPost {
                    return TextPollPostCell.cellHeight(post)
                    
                } else {
                    return MediaPollPostCell.cellHeight(post)
                }
                
            } else {
                if post.isTextPost {
                    return TextPostCell.cellHeight(post)
                    
                } else {
                    return MediaPostCell.cellHeight(post)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPost = posts[indexPath.row]
        
        getPostDetail(selectedPost)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension FeedViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == boostCollectionView {
            return selectedFeed.isMyATB ? 60 : 6
            
        } else {
            let post = posts[collectionView.tag - 300]
            return post.group_posts.count + 1
        }
    }
    
    private func getPinnedProfile(forCategory category: Int, bidOn: Int, position: Int) -> UserModel? {
        let groups = g_StrFeeds.filter({ $0 != "My ATB" })
        let categoryTitle = selectedFeed.isMyATB ? groups[category] : selectedFeed.Title
        guard profilePins.count > 0,
              let pinnedProfile = profilePins.first(where: {
                $0.bidOn == bidOn && $0.position == position && $0.category == categoryTitle
              }) else { return nil }
        
        return pinnedProfile.user
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == boostCollectionView {
            let category = indexPath.row / 6
            let position = indexPath.row % 6
            if let pinUser = getPinnedProfile(forCategory: category, bidOn: PIN_POSITIONS[position].0, position: PIN_POSITIONS[position].1) {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoostListCell.reuseIdentifier, for: indexPath) as! BoostListCell
                // configure the cell
                cell.configureCell(pinUser)
                
                return cell
                
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddBoostCell.reuseIdentifier, for: indexPath)
                return cell
            }
            
        } else {
            let multiplePostCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: MultiplePostCollectionCell.reuseIdentifier, for: indexPath) as! MultiplePostCollectionCell
            // configure the cell
            let post = posts[collectionView.tag - 300]
            let row = indexPath.row
            
            multiplePostCollectionCell.configureCell(row == 0 ? post : post.group_posts[row - 1])
            
            multiplePostCollectionCell.likeBlock = {
                print("like tapped")
            }
            
            multiplePostCollectionCell.profileTapBlock = {
                let ownUser = g_myInfo
                
                if post.Post_User_ID == ownUser.ID {
                    self.openMyProfile(forBusiness: post.isBusinessPost)
                    
                } else {
                    self.openPosterProfile(forPost: post)
                }
            }
            
            return multiplePostCollectionCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard collectionView != boostCollectionView else { return }
        
        let index = collectionView.tag - 300
        guard posts.count > index else { return }
        
        let post = posts[index]
        let row = indexPath.row
        
        var endingPost: PostModel!
        if row == 0 {
            endingPost = post
            
        } else {
            guard post.group_posts.count >= row else { return }
            
            endingPost = post.group_posts[row - 1]
        }
        
        guard endingPost.isVideoPost,
              let videoCell = cell as? ASAutoPlayVideoLayerContainer,
              let _ = videoCell.videoURL else { return }

        ASVideoPlayerController.sharedVideoPlayer.removePlayerLayer(in: videoCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == boostCollectionView {
            let category = indexPath.row / 6
            let position = indexPath.row % 6
            // open profile
            let ownUser = g_myInfo
            
            if let pinUser = getPinnedProfile(forCategory: category, bidOn: PIN_POSITIONS[position].0, position: PIN_POSITIONS[position].1) {
                if ownUser.ID == pinUser.ID {
                    openMyProfile(forBusiness: ownUser.isBusiness) // you are free to pass 'true'
                    
                } else {
                    openProfile(forUser: pinUser, forBusiness: pinUser.isBusiness) // you are free to pass 'true'
                }
                
            } else {
                // open boost business
                if ownUser.isBusiness {
                    let boostVC = BoostSelectViewController.instance()
                    boostVC.hidesBottomBarWhenPushed = true
                    
                    navigationController?.pushViewController(boostVC, animated: true)
                    
                } else {
                    alertToUpgradeBusiness()
                }
            }
            
        } else {
            let post = posts[collectionView.tag - 300]
            let row = indexPath.row
            
            // only sales & service has multiple post
            // so no need to check the post type
            getPostDetail(row == 0 ? post : post.group_posts[row - 1])
        }
    }
    
    private func alertToUpgradeBusiness() {
        showAlert("You need to upgrade your account to business to boost your business profile!", message: nil, positive: "Upgrade Now", positiveAction: { _ in
            self.gotoUpgrade()
            
        }, negative: "Close", negativeAction: nil, preferredStyle: .actionSheet)
    }
    
    private func gotoUpgrade() {
        let businessVC = BusinessSignViewController.instance()
        businessVC.isFromProfile = false
        
        let nav = UINavigationController(rootViewController: businessVC)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .overFullScreen
        
        self.present(nav, animated: true, completion: nil)
    }
}

// MARK: - UIScrollViewDelegate
extension FeedViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        
        pausePlayVideos()
    }
    
    // called when scroll view grinds to a halt
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pausePlayVideos()
    }
    
    func pausePlayVideos() {
        ASVideoPlayerController.sharedVideoPlayer.pausePlayVideosFor(tableView: tblFeed)
    }
    
    @objc func appEnteredFromBackground() {
        ASVideoPlayerController.sharedVideoPlayer.pausePlayVideosFor(tableView: tblFeed, appEnteredFromBackground: true)
    }
}

