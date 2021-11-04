//
//  NotificationListViewController.swift
//  ATB
//
//  Created by mobdev on 2019/5/23.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class NotificationsViewController: BaseViewController {
    
    static let kStoryboardID = "NotificationsViewController"
    class func instance() -> NotificationsViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: NotificationsViewController.kStoryboardID) as? NotificationsViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvBack: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var tbl_list: UITableView!
    
    var notifications: [NotificationModel] = []
 
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupViews()
        
        let defaults = UserDefaults.standard
        defaults.set(0, forKey: "currentNotifications")
        
        loadNotifications()
    }
    
    private func setupViews() {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        
        imvBack.tintColor = .white
        imvBack.contentMode = .scaleAspectFit
                
        lblTitle.text = "Notifications"
        lblTitle.font = UIFont(name: "SegoeUI-Semibold", size:27)
        lblTitle.textColor = .white
        
        let tableViewInsets:UIEdgeInsets = UIEdgeInsets(top: 18.0, left: 0.0, bottom: 12.0, right: 0.0)
        tbl_list.contentInset = tableViewInsets
    }
    
    func loadNotifications() {
        let params = [
            "token" : g_myToken
        ]
               
        showIndicator()
        _ = ATB_Alamofire.POST(GET_NOTIFICATIONS, parameters: params as [String : AnyObject]) { (result, response) in
            self.hideIndicator()
            
            guard result,
                  let postDicts = response.object(forKey: "msg")  as? [NSDictionary] else { return }
            
            self.notifications.removeAll()
            
            for postDict in postDicts {
                let notification = NotificationModel(info: postDict)
                if notification.isVisible {
                    self.notifications.append(notification)
                }
            }
            
            var unreadNotificationsCount = 0
            for notification in self.notifications {
                if !notification.isRead {
                    unreadNotificationsCount += 1
                }
            }
            
            ATB_UserDefault.setInt(key: NOTIFICATION_COUNT, value: unreadNotificationsCount)
            NotificationCenter.default.post(name: .DiDLoadNotification, object: nil)
            
            self.tbl_list.reloadData()
        }
    }
    
    private func readNotification(_ notification: NotificationModel) {
        APIManager.shared.readNotification(g_myToken, notificationId: notification.ID) { result in
            switch result {
            case .success(_):
                self.didReadNotification(notification)
                
            case .failure(_): break
            }
        }
    }
    
    private func didReadNotification(_ notification: NotificationModel) {
        guard let index = notifications.firstIndex(where: { $0.ID == notification.ID }) else { return }
        
        notifications[index].isRead = true
        
        var unreadNotificationsCount = ATB_UserDefault.getInt(key: NOTIFICATION_COUNT, defaultValue: 0)
        
        unreadNotificationsCount -= 1
        if unreadNotificationsCount < 0 {
            unreadNotificationsCount = 0
        }
        
        ATB_UserDefault.setInt(key: NOTIFICATION_COUNT, value: unreadNotificationsCount)
        
        NotificationCenter.default.post(name: .DidReadNotification, object: nil)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        // configure the cell
        cell.configureCell(notifications[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        if !notification.isRead {
            readNotification(notification)
        }
        
        guard !notification.related_id.isEmpty else {
            showErrorVC(msg: "The request is invalid!")
            return
        }
        
        if notification.type == "rating_requested" {
            getBookingDetail(forBooking: notification.related_id, whereTo: 0)
            
        } else if notification.type == "payment_requested" {
            getBookingDetail(forBooking: notification.related_id, whereTo: 1)
            
        } else if notification.type == "comment" {
            getPostDetail(notification.related_id)
            
        } else if notification.type == "payment" {
            gotoSoldItems()
            
        } else if notification.type == "booking" {
            gotoBusinessBookings()
//            getBookingDetail(forBooking: notification.related_id, whereTo: 2)
        }
    }
    
    // where
    // 0: rate the business
    // 1: go to user booking details
    // 2: go to business booking details
    private func getBookingDetail(forBooking bid: String, whereTo: Int) {
        showIndicator()
        
        APIManager.shared.getBooking(g_myToken, bid: bid) { result in
            self.hideIndicator()
            
            switch result {
            case .success(let booking):
                switch whereTo {
                case 0:
                    self.rateService(onBooking: booking)
                    
                case 1:
                    self.paymentRequested(onBooking: booking)
                    
                case 2:
                    self.gotoBookingDetails(booking)
                    
                default:
                    break
                }
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private func rateService(onBooking booking: BookingModel) {
        let rateVC = RateServiceViewController.instance()
        rateVC.selectedBooking = booking
        
        navigationController?.pushViewController(rateVC, animated: true)
    }
    
    private func paymentRequested(onBooking booking: BookingModel) {
        let detailsVC = BookingDetailsViewController.instance()
        detailsVC.selectedBooking = booking
        
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    private func gotoBookingDetails(_ booking: BookingModel) {
        let toVC = BusinessBookingDetailsViewController.instance()
        toVC.selectedBooking = booking
        
        navigationController?.pushViewController(toVC, animated: true)
    }
    
    private func gotoSoldItems() {
        let toVC = SoldItemsViewController.instance()
        toVC.isBusiness = g_myInfo.isBusiness
        
        navigationController?.pushViewController(toVC, animated: true)
    }
    
    private func gotoBusinessBookings() {
        let toVC = BusinessBookingsViewController.instance()
        navigationController?.pushViewController(toVC, animated: true)
    }
    
    private func getPostDetail(_ postId: String) {
        let params = [
            "token" : g_myToken,
            "post_id" : postId
        ]
        
        let selectedPost = PostDetailModel()
        
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
            
            let post = PostModel(info: postDetailDict)
            selectedPost.Post_Summerize = post
            
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
            let isOwnPost = (g_myInfo.ID == post.Post_User_ID)
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
            
            self.getComments(selectedPost, isOwnPost: isOwnPost, isLiked: isLiked)
        }
    }
}
