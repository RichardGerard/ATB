//
//  AppDelegate.swift
//  ATB
//
//  Created by mobdev on 2019/5/8.
//  Copyright © 2019 mobdev. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import DropDown
import Stripe
import UserNotifications
import Applozic
import FacebookCore
import Braintree
import BraintreeDropIn
import NotificationBannerSwift
import Mixpanel
import Branch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, ApplozicUpdatesDelegate {

    var window: UIWindow?

    public var applozicClient = ApplozicClient()
    
    let pushAssist = ALPushAssist()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        Branch.getInstance().validateSDKIntegration()
//        Branch.getInstance().enableLogging()
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            if let deepLinkData = params as? [String: Any],
               let pid = deepLinkData["nav_here"] as? String {
                g_deepLinkId = pid
                g_deepLinkType = deepLinkData["nav_type"] as? String ?? "0"
                // to proceed opened from background
                NotificationCenter.default.post(name: .LaunchingWithDeepLink, object: nil)
            }
        }
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        AppManager.shared.setup()
        
        Mixpanel.initialize(token: "a833e64a898189b410d5861d53f3b9a4")
        
        DropDown.startListeningToKeyboard()
        
        LocationProvider.startUpdates()
        
        STPPaymentConfiguration.shared().publishableKey = STP_PK

        BTAppSwitch.setReturnURLScheme("com.atb.app.payments")
        
        applozicClient = ApplozicClient.init(applicationKey: "emtrac2ba61d90383c69a7fbc7db07725fa3e5b", with: self)
        
        if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {

            // If your app wasn’t running and the user launches it by tapping the push notification, the push notification is passed to your app in the launchOptions
           let _ = notification["aps"] as! [String: AnyObject]
           UIApplication.shared.applicationIconBadgeNumber = 0
        }
        
        // Override point for customization after application launch.
        let alApplocalNotificationHnadler : ALAppLocalNotifications =  ALAppLocalNotifications.appLocalNotificationHandler();
        alApplocalNotificationHnadler.dataConnectionNotificationHandler();
        
        if (launchOptions != nil)
        {
            let dictionary = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary
            
            if (dictionary != nil) {
                print("launched from push notification")
                let alPushNotificationService: ALPushNotificationService = ALPushNotificationService()
                if alPushNotificationService.isApplozicNotification(launchOptions) {
                    showChatScreen()
                    
                } else {
                    showNotificationScreen()
                }
                
                /*let appState: NSNumber = NSNumber(value: 0 as Int32)
                let applozicProcessed = alPushNotificationService.processPushNotification(launchOptions,updateUI:appState)
                if (!applozicProcessed)
                {
                    //Note: notification for app
                }*/
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
      // handler for Universal Links
        return Branch.getInstance().continue(userActivity)
    }

    func registerForPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] (granted, error) in
                print("Permission granted: \(granted)")

                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
//                guard granted else {
//                    print("Please enable \"Notifications\" from App Settings.")
//                    self?.showPermissionAlert()
//                    return
//                }
//
//                self?.getNotificationSettings()
            }
            
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
//
//    @available(iOS 10.0, *)
//    func getNotificationSettings() {
//
//        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
//            print("Notification settings: \(settings)")
//            guard settings.authorizationStatus == .authorized else { return }
//            DispatchQueue.main.async {
//                UIApplication.shared.registerForRemoteNotifications()
//            }
//        }
//    }
    
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
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
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
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        NotificationCenter.default.post(name: Notification.Name(rawValue: "APP_ENTER_IN_BACKGROUND"), object: nil)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        ALPushNotificationService.applicationEntersForeground()
        print("APP_ENTER_IN_FOREGROUND")
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "APP_ENTER_IN_FOREGROUND"), object: nil)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        ALDBHandler.sharedInstance().saveContext()
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let deviceTokenString = tokenParts.joined()
        
        NSLog("Device token :: \(deviceTokenString)")
        
        let params = [
            "token" : g_myToken,
            "push_token" : deviceTokenString,
        ]
       _ = ATB_Alamofire.POST(UPDATE_NOTIFCATION_TOKEN, parameters: params as [String : AnyObject],showLoading: false,showSuccess: false,showError: false){
               (result, responseObject) in
        
        }
        
        if (ALUserDefaultsHandler.getApnDeviceToken() != deviceTokenString)
        {
            let alRegisterUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
            alRegisterUserClientService.updateApnDeviceToken(withCompletion: deviceTokenString, withCompletion: { (response, error) in
                
            })
        }
    }
    
   func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
       var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
       topWindow?.rootViewController = UIViewController()
       topWindow?.windowLevel = UIWindow.Level.alert + 1
    
        let alert = UIAlertController(title: "APNS", message: error.localizedDescription, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in

                  topWindow?.isHidden = true // if you want to hide the topwindow then use this
                   topWindow = nil // if you want to hide the topwindow then use this
        })
        alert.view.tintColor = .colorPrimary
        topWindow?.makeKeyAndVisible()
        topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        let defaults = UserDefaults.standard
        
        let pushNotificationService = ALPushNotificationService()
        
        if pushNotificationService.isApplozicNotification(userInfo) {
            var currentMessages = defaults.double(forKey: "currentMessages")
            currentMessages = currentMessages + 1
            defaults.set(currentMessages, forKey: "currentMessages")
            
           pushNotificationService.notificationArrived(to: application, with: userInfo)
            return
        }
        
        var currentNotifications = defaults.double(forKey: "currentNotifications")
        currentNotifications = currentNotifications + 1
        defaults.set(currentNotifications, forKey: "currentNotifications")
        
        let state = UIApplication.shared.applicationState
        if state == .active {

            var alertString = ""
            
            if let aps = userInfo["aps"] as? NSDictionary {
                if let alert = aps["alert"] as? NSDictionary {
                    if let message = alert["message"] as? NSString {
                        alertString = message as String
                    }
                } else if let alert = aps["alert"] as? NSString {
                    alertString = alert as String
                }
            }
            
            let banner = NotificationBanner(title: "Notification", subtitle: alertString, style: .info, colors: ATBBannerColors())
            banner.onTap = {
                self.showNotificationScreen()
            }
            banner.show()
            
        } else {
            showNotificationScreen()
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let defaults = UserDefaults.standard
        let pushNotificationService = ALPushNotificationService()
        
        if pushNotificationService.isApplozicNotification(userInfo) {
            var currentMessages = defaults.double(forKey: "currentMessages")
            currentMessages = currentMessages + 1
            defaults.set(currentMessages, forKey: "currentMessages")
            pushNotificationService.notificationArrived(to: application, with: userInfo)
            
        } else {
            var currentNotifications = defaults.double(forKey: "currentNotifications")
            currentNotifications = currentNotifications + 1
            defaults.set(currentNotifications, forKey: "currentNotifications")
            
            let state = UIApplication.shared.applicationState
            if state == .active {
                
                var alertString = ""
                
                if let aps = userInfo["aps"] as? NSDictionary {
                    if let alert = aps["alert"] as? NSDictionary {
                        if let message = alert["message"] as? NSString {
                            alertString = message as String
                        }
                    } else if let alert = aps["alert"] as? NSString {
                        alertString = alert as String
                    }
                }
                
                let banner = NotificationBanner(title: "Notification", subtitle: alertString, style: .info, colors: ATBBannerColors())
                banner.onTap = {
                    self.showNotificationScreen()
                }
                banner.show()
            }
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let branchHandled = Branch.getInstance().application(app, open: url, options: options)
        
        if !branchHandled {
            if url.scheme?.localizedCaseInsensitiveCompare("com.atb.app.payments") == .orderedSame {
                return BTAppSwitch.handleOpen(url, options: options)
            }
            
          return ApplicationDelegate.shared.application(app, open: url, options: options)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if url.scheme?.localizedCaseInsensitiveCompare("com.atb.app.payments") == .orderedSame {
            return BTAppSwitch.handleOpen(url, sourceApplication: sourceApplication)
        }
        
        return false
    }

    func showNotificationScreen() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let tabBarVC = (storyboard.instantiateViewController(withIdentifier: "NotificationListViewController") as? NotificationListViewController)!
//        self.window?.rootViewController = tabBarVC
    }
    
    func showChatScreen() {        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarVC") as? MainTabBarVC
        tabBarVC?.selectedIndex = 2
        self.window?.rootViewController = tabBarVC
    }
    
    func sendLocalPush(message: ALMessage) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            let contactService = ALContactDBService()
            let channelService  = ALChannelService()
            UNUserNotificationCenter.current().delegate = self
            
            var title = String()
            
            if(message.groupId != nil && message.groupId != 0){
                let  alChannel =  channelService.getChannelByKey(message.groupId)
                
                guard let channel = alChannel,!channel.isNotificationMuted() else {
                    return
                }
                
                title =  channel.name
                
            }else{
                let  alContact = contactService.loadContact(byKey: "userId", value: message.to)
                
                guard let contact = alContact else {
                    return
                }
                title = contact.displayName != nil ? contact.displayName:contact.userId
            }
            
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = message.message
            content.sound = UNNotificationSound.default
            
            var dict: [AnyHashable: Any]
            if(message.groupId != nil && message.groupId != 0){
                dict = ["groupId":message.groupId ]
            }else{
                dict = ["userId":message.to ]
            }
            content.userInfo = dict
            
            let identifier = "ApplozicLocalNotification"            
            
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: nil
            )
            
            center.add(request, withCompletionHandler: { (error) in
                
                if error != nil {
                    // Something went wrong
                }
                
            })
            
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func onMessageReceived(_ alMessage: ALMessage!) {
        if (pushAssist.topViewController is ConversationsViewController) {
            let viewController =  pushAssist.topViewController as? ConversationsViewController
            viewController?.onMessageReceived(alMessage)
            
        } else if (pushAssist.topViewController is ConversationViewController) {
            let viewController =  pushAssist.topViewController as? ConversationViewController
            viewController?.onMessageReceived(alMessage)
        }
    }
    
    func onMessageSent(_ alMessage: ALMessage!) {
        if (pushAssist.topViewController is ConversationsViewController) {
            let viewController =  pushAssist.topViewController as? ConversationsViewController
            viewController?.onMessageSent(alMessage)
            
        } else if (pushAssist.topViewController is ConversationViewController) {
            let viewController =  pushAssist.topViewController as? ConversationViewController
            viewController?.onMessageSent(alMessage)
        }
    }
    
    func onUserDetailsUpdate(_ userDetail: ALUserDetail!) {
        if (pushAssist.topViewController is ConversationsViewController) {
            let viewController =  pushAssist.topViewController as? ConversationsViewController
            viewController?.onUserDetailsUpdate(userDetail)
            
        } else if (pushAssist.topViewController is ConversationViewController) {
            let viewController =  pushAssist.topViewController as? ConversationViewController
            viewController?.onUserDetailsUpdate(userDetail)
        }
    }
    
    func onMessageDelivered(_ message: ALMessage!) {
        if (pushAssist.topViewController is ConversationsViewController) {
            let viewController =  pushAssist.topViewController as? ConversationsViewController
            viewController?.onMessageDelivered(message)
            
        } else if (pushAssist.topViewController is ConversationViewController) {
            let viewController =  pushAssist.topViewController as? ConversationViewController
            viewController?.onMessageDelivered(message)
        }
    }
    
    func onMessageDeleted(_ messageKey: String!) {
        
        if (pushAssist.topViewController is ConversationsViewController) {
            let viewController =  pushAssist.topViewController as? ConversationsViewController
            viewController?.onMessageDeleted(messageKey)
        } else if (pushAssist.topViewController is ConversationViewController) {
            let viewController =  pushAssist.topViewController as? ConversationViewController
            viewController?.onMessageDeleted(messageKey)
        }
        
    }
    
    func onMessageDeliveredAndRead(_ message: ALMessage!, withUserId userId: String!) {
        
        if (pushAssist.topViewController is ConversationsViewController) {
            let viewController =  pushAssist.topViewController as? ConversationsViewController
            viewController?.onMessageDeliveredAndRead(message, withUserId: userId)
            
        } else if (pushAssist.topViewController is ConversationViewController) {
            let viewController =  pushAssist.topViewController as? ConversationViewController
            viewController?.onMessageDeliveredAndRead(message, withUserId: userId)
        }
    }
    
    func onConversationDelete(_ userId: String!, withGroupId groupId: NSNumber!) {
        
        if (pushAssist.topViewController is ConversationsViewController) {
            let viewController =  pushAssist.topViewController as? ConversationsViewController
            viewController?.onConversationDelete(userId, withGroupId: groupId)
            
        } else if (pushAssist.topViewController is ConversationViewController) {
            let viewController =  pushAssist.topViewController as? ConversationViewController
            viewController?.onConversationDelete(userId, withGroupId: groupId)
        }
    }
    
    func conversationRead(byCurrentUser userId: String!, withGroupId groupId: NSNumber!) {
        
        if (pushAssist.topViewController is ConversationsViewController) {
            let viewController =  pushAssist.topViewController as? ConversationsViewController
            viewController?.conversationRead(byCurrentUser: userId, withGroupId: groupId)
            
        } else if (pushAssist.topViewController is ConversationViewController) {
            let viewController =  pushAssist.topViewController as? ConversationViewController
            viewController?.conversationRead(byCurrentUser: userId, withGroupId: groupId)
        }
    }
    
    func onUpdateTypingStatus(_ userId: String!, status: Bool) {
        if (pushAssist.topViewController is ConversationsViewController) {
            let viewController =  pushAssist.topViewController as? ConversationsViewController
            viewController?.onUpdateTypingStatus(userId, status: status)
            
        } else if (pushAssist.topViewController is ConversationViewController) {
            let viewController =  pushAssist.topViewController as? ConversationViewController
            viewController?.onUpdateTypingStatus(userId, status: status)
        }
    }
    
    func onChannelMute(_ channelKey: NSNumber!) {
        
    }
    
    func onUpdateLastSeen(atStatus alUserDetail: ALUserDetail!) {
        if (pushAssist.topViewController is ConversationsViewController) {
            let viewController =  pushAssist.topViewController as? ConversationsViewController
            viewController?.onUpdateLastSeen(atStatus: alUserDetail)
            
        } else if (pushAssist.topViewController is ConversationViewController) {
            let viewController =  pushAssist.topViewController as? ConversationViewController
            viewController?.onUpdateLastSeen(atStatus: alUserDetail)
        }
    }
    
    func onUserBlockedOrUnBlocked(_ userId: String!, andBlockFlag flag: Bool) {
        if (pushAssist.topViewController is ConversationsViewController) {
            let viewController =  pushAssist.topViewController as? ConversationsViewController
            viewController?.onUserBlockedOrUnBlocked(userId, andBlockFlag: flag)
            
        } else if (pushAssist.topViewController is ConversationViewController) {
            let viewController =  pushAssist.topViewController as? ConversationViewController
            viewController?.onUserBlockedOrUnBlocked(userId, andBlockFlag: flag)
        }
    }
    
    func onChannelUpdated(_ channel: ALChannel!) {
        if (pushAssist.topViewController is ConversationsViewController) {
            let viewController =  pushAssist.topViewController as? ConversationsViewController
            viewController?.onChannelUpdated(channel)
            
        } else if (pushAssist.topViewController is ConversationViewController) {
            let viewController =  pushAssist.topViewController as? ConversationViewController
            viewController?.onChannelUpdated(channel)
        }
    }
    
    func onAllMessagesRead(_ userId: String!) {
        if (pushAssist.topViewController is ConversationsViewController) {
            let viewController =  pushAssist.topViewController as? ConversationsViewController
            viewController?.onAllMessagesRead(userId)
            
        } else if (pushAssist.topViewController is ConversationViewController) {
            let viewController =  pushAssist.topViewController as? ConversationViewController
            viewController?.onAllMessagesRead(userId)
        }
    }
    
    func onMqttConnectionClosed() {
        applozicClient.subscribeToConversation()
        
    }
    
    func onMqttConnected() {
        
    }
    
    func onUserMuteStatus(_ userDetail: ALUserDetail!) {
        
    }
    
    func openChatView(dic: [AnyHashable : Any] )  {
        let alPushAssist = ALPushAssist()
        let type = dic["AL_KEY"] as? String
        let alValueJson = dic["AL_VALUE"] as? String
        
        let data: Data? = alValueJson?.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        var theMessageDict: [AnyHashable : Any]? = nil
        if let aData = data {
            theMessageDict = try! JSONSerialization.jsonObject(with: aData, options: []) as? [AnyHashable : Any]
        }
        
        let notificationMsg = theMessageDict?["message"] as? String
        
        if(type != nil){
            
            let myArray = notificationMsg!.components(separatedBy: CharacterSet(charactersIn: ":"))
            
            var channelKey : NSNumber = 0
            
            if myArray.count > 2 {
                if let key = Int( myArray[1]) {
                    channelKey = NSNumber(value:key)
                }
                
            } else {
                channelKey = 0
            }
            
            
            if((alPushAssist.topViewController is ConversationViewController)){
                var json  = [String: Any]()
                
                if(channelKey != 0) {
                    json["groupId"] = channelKey
                    
                } else {
                    json["userId"] = notificationMsg
                    json["groupId"] = 0
                    
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: "reloadData"), object: json)
                
            } else {
                let viewController = ConversationViewController()
                
                if(channelKey != 0) {
                    viewController.groupId = channelKey
                    
                } else {
                    viewController.userId = notificationMsg
                }
                
                alPushAssist.topViewController.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
}

class ATBBannerColors: BannerColorsProtocol {
    internal func color(for style: BannerStyle) -> UIColor {
        switch style {
        case .danger: return UIColor.colorPrimary
        case .info:  return UIColor.colorPrimary
        case .customView: return UIColor.colorPrimary
        case .success: return UIColor.colorPrimary
        case .warning: return UIColor.colorPrimary
        }
    }
}
