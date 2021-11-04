//
//  MainTabBarVC.swift
//  ATB
//
//  Created by mobdev on 2019/5/16.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import RAMAnimatedTabBarController
import Applozic

// MARK: - @Protocol PostCreateDelegate
protocol PostCreateDelegate {
    func newPostCreated(selectedCategory:FeedModel)
    func newPostCancelled()
}

class MainTabBarVC: RAMAnimatedTabBarController, UITabBarControllerDelegate {
    
    var currentViewControllerIndex:Int = 0
    var feedView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var shadowBackView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    var screenHeight:CGFloat = 0.0
    var screenWidth:CGFloat = 0.0
//    var feedSelectorVC: FeedSelectionMenuVC!
    var selectedFeed:FeedModel = FeedModel()
    var feedChangeDelegate:FeedSelectChangeDelegate!
    
    let circleTransition = CircularTransition()
    var centerPostBtn:CGPoint = CGPoint(x: 0.0, y: 0.0)
	
    var myTimer = Timer()
    
    var reload = false	
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.selectedFeed.ID = "My ATB"
        self.selectedFeed.Title = "My ATB"
        
        setupShadow()
    }
    
    private func setupShadow() {
        // remove default 1px top border
        if #available(iOS 13, *) {
            // iOS 13:
            let appearance = tabBar.standardAppearance
            appearance.configureWithOpaqueBackground()
            appearance.shadowImage = nil
            appearance.shadowColor = nil
            tabBar.standardAppearance = appearance
            
        } else {
            // iOS 12 and below:
            tabBar.shadowImage = UIImage()
            tabBar.backgroundImage = UIImage()
        }
        
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 5.0
        tabBar.layer.shadowColor = UIColor.gray.cgColor
        tabBar.layer.shadowOpacity = 0.4
    }
    
    @objc func refresh() {
        if let tabItems = tabBar.items {
            let defaults = UserDefaults.standard
            let currentMessages = defaults.double(forKey: "currentMessages")
            let currentNotifications = defaults.double(forKey: "currentNotifications")
            
            guard tabItems.count > 2 else { return }
            
            let chat = tabItems[2]
            if (currentMessages > 0) {
                chat.badgeValue = String(format: "%.0f", currentMessages)
            } else {
                chat.badgeValue = nil
            }
            
            guard tabItems.count > 3 else { return }
            
            let notifications = tabItems[3]
            if (currentNotifications > 0) {
                notifications.badgeValue = String(format: "%.0f", currentNotifications)
            } else {
                notifications.badgeValue = nil
            }
        }
    }
    
    @objc func messageView(){
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let tabItems = tabBar.items {
            for tabBarItem in tabItems {
                if #available(iOS 13.0, *)
                {
                    // Fix iOS 13 misalignment tab bar images. Some titles are nil and other empty strings. Nil title behaves as if a non-empty title was set.
                    // Note: However no need to modify imageInsets property on iOS 13.
                    tabBarItem.title = "";
                }
                else
                {
                    tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0);
                }
            }
        }
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            if let presentedViewController = topController.presentedViewController {
//                print(presentedViewController.title)
                return
            }
        }
        
        myTimer = Timer(timeInterval: 10.0, target: self, selector: #selector(MainTabBarVC.refresh), userInfo: nil, repeats: true)
        RunLoop.main.add(myTimer, forMode: RunLoop.Mode.default)
    }

    override func viewWillDisappear(_ animated: Bool) {
        myTimer.invalidate()
        reload = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.tabBar.tintColor = UIColor(displayP3Red: 165/255, green: 190/255, blue: 220/255, alpha: 1.0)
        self.changeSelectedColor(UIColor(displayP3Red: 165/255, green: 190/255, blue: 220/255, alpha: 1.0), iconSelectedColor: UIColor(displayP3Red: 165/255, green: 190/255, blue: 220/255, alpha: 1.0))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var bottomPadding:CGFloat! = 0.0
        let window = UIApplication.shared.keyWindow
        
        if #available(iOS 11.0, *) {
            bottomPadding = window?.safeAreaInsets.bottom
        }
        
        let centerXPost = UIScreen.main.bounds.width / 2
        let centerYPost = UIScreen.main.bounds.height - bottomPadding - 35
        self.centerPostBtn = CGPoint(x: centerXPost, y: centerYPost)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        print(tabBarController.selectedIndex)
        
        if(tabBarController.selectedIndex == 0) {
            if(self.currentViewControllerIndex == tabBarController.selectedIndex) {
                let vcNav = viewController as! UINavigationController
                
                let feedVC = vcNav.viewControllers.first as! FeedViewController
                
                if(feedVC.isDisplayed) {
                    self.showFeedSelector()
                }
                
            } else {
                if (reload) {
                    reload = false
                    
                    let mainNav = self.storyboard?.instantiateViewController(withIdentifier: "MainNav") as! UINavigationController
                    UIApplication.shared.keyWindow?.rootViewController = mainNav
                }
            }
        }
        
        self.currentViewControllerIndex = tabBarController.selectedIndex
    }
    
    func showFeedSelector()
    {
        var FeedItems:[FeedModel] = []
        
        for i in 0..<11
        {
            let newATBModel = FeedModel()
            newATBModel.Title = g_StrFeeds[i]
            if(i == 0)
            {
                newATBModel.ID = "My ATB"
            }
            else
            {
                newATBModel.ID = String(i + 1)
            }
            
            newATBModel.Checked = false
            
            FeedItems.append(newATBModel)
        }
        
        let feedSelectVC = SelectFeedViewController.instance()
        feedSelectVC.atbDelegate = self
        self.present(feedSelectVC, animated: true, completion: nil)
    }
    
    func hideFeedSelector(type:Int)
    {
            if(type == 1)
            {
                self.feedChangeDelegate.feedSelectChanged(feedModel: self.selectedFeed)
            }
    }
    
    @objc func tapOnShadowBack(_ sender: UITapGestureRecognizer) {
        hideFeedSelector(type: 0)
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard viewController.restorationIdentifier == "NewPostNav" else { return true }
        
        let postSelectVC = PostSelectViewController.instance()
        let navigationController = UINavigationController(rootViewController: postSelectVC)
        navigationController.isNavigationBarHidden = true
        navigationController.transitioningDelegate = self
        navigationController.modalPresentationStyle = .custom
        
        self.present(navigationController, animated: true, completion: nil)
        return false
    }
}

// MARK: - PostCreateDelegate
extension MainTabBarVC: PostCreateDelegate {
    
    func newPostCreated(selectedCategory:FeedModel) {
        //print(selectedCategory.Title)
        self.selectedFeed = selectedCategory
        self.feedChangeDelegate.feedSelectChanged(feedModel: self.selectedFeed)
        
        let currentIndex : Int = self.selectedIndex
        if(currentIndex > 0)
        {
            self.setSelectIndex(from: currentIndex, to: 0)
        }
    }
    
    func newPostCancelled() {
        
    }
}

// MARK: - ATBChooseDelegate
extension MainTabBarVC: ATBChooseDelegate {
    
    func ATBSelected(feed: FeedModel) {
        self.selectedFeed = feed
        hideFeedSelector(type: 1)
    }
    
    func ATBDialogClosed() {
        hideFeedSelector(type: 0)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension MainTabBarVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        circleTransition.transitionMode = .present
        circleTransition.startingPoint = centerPostBtn
        circleTransition.circleColor = UIColor.blurColor.withAlphaComponent(0.7)
        
        return circleTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        circleTransition.transitionMode = .dismiss
        circleTransition.startingPoint = centerPostBtn
        circleTransition.circleColor = UIColor.blurColor.withAlphaComponent(0.7)
        
        return circleTransition
    }
}
