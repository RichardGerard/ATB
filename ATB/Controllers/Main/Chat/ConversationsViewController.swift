//
//  ConversationsViewController.swift
//  ATB
//
//  Created by administrator on 22/03/2020.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import MapKit
import Applozic
import NBBottomSheet
import BadgeHub

class ConversationsViewController: BaseViewController {
    
    @IBOutlet weak var titleContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    private var notificationHub: BadgeHub?
    @IBOutlet weak var imvNotification: UIImageView!
    
    @IBOutlet weak var imvProfile: ProfileView!
    
    @IBOutlet weak var lblViewingAs: UILabel! { didSet {
        lblViewingAs.text = "You are viewing\nthe conversation as"
        lblViewingAs.font = UIFont(name: Font.SegoeUILight, size: 16)
        lblViewingAs.textColor = .colorGray2
        lblViewingAs.numberOfLines = 2
        lblViewingAs.setLineSpacing(lineSpacing: 0, lineHeightMultiple: 0.75)
    }}
    
    @IBOutlet weak var lblName: UILabel! { didSet {
        lblName.text = ""
        lblName.font = UIFont(name: Font.SegoeUISemibold, size: 17)
        lblName.textColor = .colorPrimary
        lblName.textAlignment = .right
        lblName.lineBreakMode = .byTruncatingMiddle
    }}
    
    @IBOutlet weak var imvViewingUserProfile: ProfileView! { didSet {
        imvViewingUserProfile.borderColor = .colorPrimary
        imvViewingUserProfile.borderWidth = 2
    }}
    
    @IBOutlet weak var imvSelectArrow: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvSelectArrow.image = UIImage(systemName: "chevron.right")
        } else {
            // Fallback on earlier versions
        }
        imvSelectArrow.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var chatList: UITableView!
    
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    
    var allMessages = [ALMessage]()

    private var users = [UserModel]()
    private var selectedUser: UserModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        initUserOption()
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(refreshNotificationHub), name: .DiDLoadNotification, object: nil)
        defaultCenter.addObserver(self, selector: #selector(refreshNotificationHub), name: .DidReadNotification, object: nil)
    }
    
    private func setupViews() {
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
    }
    
    private func initUserOption() {
        users.removeAll()
        
        let me = g_myInfo
        
        let normalUser = UserModel()
        normalUser.user_type = "User"
        normalUser.ID = me.ID
        normalUser.user_name = me.userName
        normalUser.profile_image = me.profileImage
        
        if me.isBusiness {
            let business = me.business_profile
            
            let businessUser = UserModel()
            businessUser.user_type = "Business"
            businessUser.ID = business.ID
            businessUser.user_name = business.businessProfileName
            businessUser.profile_image = business.businessPicUrl
            
            users.append(businessUser)
        }
        
        users.append(normalUser)
        
        if var loggedinUserId = ALUserDefaultsHandler.getUserId() {
            if loggedinUserId.contains("_") {
                loggedinUserId = String(loggedinUserId.split(separator: "_")[0])
            }
            
            for user in users {
                if user.ID == loggedinUserId {
                    selectedUser = user
                }
            }
        }
        
        lblName.text = selectedUser.user_name
        imvViewingUserProfile.loadImageFromUrl(selectedUser.profile_image, placeholder: "profile.placeholder")
    }
    
    @objc private func refreshNotificationHub() {
        let unreadNotificationsCount = ATB_UserDefault.getInt(key: NOTIFICATION_COUNT, defaultValue: 0)
        DispatchQueue.main.async {
            unreadNotificationsCount > 0 ? self.notificationHub?.show() : self.notificationHub?.hide()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadMessages(loading: true)
        
        appDelegate?.applozicClient.subscribeToConversation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        appDelegate?.applozicClient.unsubscribeToConversation()
    }
    
    private func didSelectUser() {
        lblName.text = selectedUser.user_name
        imvViewingUserProfile.loadImageFromUrl(selectedUser.profile_image, placeholder: "profile.placeholder")
        
        let alUser : ALUser =  ALUser()
        if selectedUser.isBusiness {
            let business = g_myInfo.business_profile
            
            let userId = business.ID + "_" + g_myInfo.ID
            alUser.userId = userId
            alUser.imageLink = business.businessPicUrl
            alUser.displayName = business.businessProfileName
            alUser.password = userId
            
        } else {
            alUser.userId = g_myInfo.ID
            alUser.imageLink = g_myInfo.profileImage
            alUser.displayName = g_myInfo.userName
            alUser.password = g_myInfo.ID
        }
        
        alUser.email = g_myInfo.emailAddress

        // Saving these details
        ALUserDefaultsHandler.setUserId(alUser.userId)
        ALUserDefaultsHandler.setEmailId(alUser.email)
        ALUserDefaultsHandler.setDisplayName(alUser.displayName)
        
        if allMessages.count > 0 {
            allMessages.removeAll()
            chatList.reloadData()
        }
        
        showIndicator()
        
        let registerUserClinetService = ALRegisterUserClientService()
        registerUserClinetService.logout { (response, error) in
            guard error == nil,
                  let response = response,
                  response.status == "success" else {
                self.hideIndicator()
                self.showErrorVC(msg: "Failed to load the conversation, please try again!")
                return
            }
            
            // Registering or Login in the User
            let chatManager = ALChatManager(applicationKey: "emtrac2ba61d90383c69a7fbc7db07725fa3e5b")
            chatManager.connectUserWithCompletion(alUser, completion: {response, error in
                guard error == nil else {
                    self.hideIndicator()
                    self.showErrorVC(msg: "Failed to load the conversation, please try again!")
                    return
                }
                
                self.loadMessages()
            })
        }
    }
    
    func loadMessages(loading: Bool = false)  {
        if loading {
            showIndicator()
        }
        
        /// The latest message list is used to display the messages to the logged in user based on the communication time. This list contains only the latest messages for each user and group that the logged in user has interacted with, sorted in descending order of the communication time.
        appDelegate?.applozicClient.getLatestMessages(false, withCompletionHandler: { messageList, error in
            self.hideIndicator()
            self.allMessages.removeAll()
            
            if error == nil,
               let messages = messageList as? [ALMessage] {
                self.allMessages.append(contentsOf: messages)
            }
            
            self.chatList.reloadData()
        })
    }
    
    // transitioningDelgegate is a weak property
    // for dismissed protocol, we need to make it a class variable
    let sheetTransitioningDelegate = NBBottomSheetTransitioningDelegate()
    
    @IBAction func didTapViewingAs(_ sender: Any) {
        guard users.count > 1,
              let selectedIndex = users.firstIndex(where: { $0.ID == selectedUser.ID }) else { return }
        
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35
        configuruation.sheetDirection = .top
        
        let heightForOptionSheet: CGFloat =  243 // (233 + 10 - cornerRaidus addition value)
        
        configuruation.sheetSize = .fixed(heightForOptionSheet)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        
        let topSheetController = NBBottomSheetController(configuration: configuruation, transitioningDelegate: sheetTransitioningDelegate)
        
        let selectVC = SelectConversationViewController.instance()
        selectVC.users = users
        selectVC.selectedIndex = selectedIndex
        selectVC.delegate = self
        
        topSheetController.present(selectVC, on: self)
    }
    
    public func onMessageReceived(_ alMessage: ALMessage!) {
        self.addMessage(alMessage)
    }
    
    public func onMessageSent(_ alMessage: ALMessage!) {
        self.addMessage(alMessage)
    }
    
    public func onUserDetailsUpdate(_ userDetail: ALUserDetail!) {
        
    }
    
    public func onMessageDelivered(_ message: ALMessage!) {
    }
    
    public func onMessageDeleted(_ messageKey: String!) {
        
    }
    
    public func onMessageDeliveredAndRead(_ message: ALMessage!, withUserId userId: String!) {
        
    }
    
    public func onConversationDelete(_ userId: String!, withGroupId groupId: NSNumber!) {
        
    }
    
    public func conversationRead(byCurrentUser userId: String!, withGroupId groupId: NSNumber!) {
        
    }
    
    public func onUpdateTypingStatus(_ userId: String!, status: Bool) {
        
    }
    
    public func onUpdateLastSeen(atStatus alUserDetail: ALUserDetail!) {
        
    }
    
    public func onUserBlockedOrUnBlocked(_ userId: String!, andBlockFlag flag: Bool) {
        
    }
    
    public func onChannelUpdated(_ channel: ALChannel!) {
        
    }
    
    public func onAllMessagesRead(_ userId: String!) {
        
    }
    
    public func onMqttConnectionClosed() {
        appDelegate?.applozicClient.subscribeToConversation()
    }
    
    public func onMqttConnected() {
        
    }
    
    public func addMessage(_ alMessage: ALMessage) {
        
        if(alMessage.type != nil && alMessage.type  != AL_OUT_BOX && !alMessage.isMsgHidden()){
            appDelegate?.sendLocalPush(message: alMessage)
        }
        
        var messagePresent = [ALMessage]()
        
        if let _ = alMessage.groupId {
            messagePresent = allMessages.filter { ($0.groupId != nil) ? $0.groupId == alMessage.groupId:false }
            
        } else {
            messagePresent = allMessages.filter {
                $0.groupId == nil ? (($0.contactIds != nil) ? $0.contactIds == alMessage.contactIds:false) : false
            }
        }
        
        if let firstElement = messagePresent.first, let index = allMessages.index(of: firstElement) {
            allMessages[index] = alMessage
            self.allMessages[index] = alMessage
            
        } else {
            allMessages.append(alMessage)
            self.allMessages.append(alMessage)
        }
        
        if (self.allMessages.count) > 1 {
            self.allMessages = allMessages.sorted { ($0.createdAtTime != nil && $1.createdAtTime != nil) ? Int(truncating: $0.createdAtTime) > Int(truncating: $1.createdAtTime): false }
        }
        
        self.chatList.reloadData()
    }
    
    @IBAction func didTapNotification(_ sender: Any) {
        let toVC = NotificationsViewController.instance()        
        toVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(toVC, animated: true)
    }
    
    @IBAction func didTapLogo(_ sender: Any) {
        
    }

    @IBAction func didTapProfile(_ sender: Any) {
        openMyProfile(forBusiness: g_myInfo.isBusiness)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMessages.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = MessageCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MessageCell")
        
        guard let alMessage = allMessages[indexPath.row] as? ALMessage  else {
            return UITableViewCell()
        }
        
        cell.update(viewModel: alMessage)
        return cell;
    }
    
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alMessage = allMessages[indexPath.row]
        
        let viewController = ConversationViewController()
        
        if(alMessage.groupId != nil && alMessage.groupId != 0) {
            viewController.groupId = alMessage.groupId
            
        } else {
            viewController.userId = alMessage.to
        }
        
        viewController.createdAtTime = alMessage.createdAtTime
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - ConversationSelectDelegate
extension ConversationsViewController: ConversationSelectDelegate {
    
    func profileSelected(_ selectedIndex: Int) {
        let newSelected = users[selectedIndex]
        
        guard newSelected.ID != selectedUser.ID else { return }
        
        selectedUser = newSelected
        
        didSelectUser()
    }
}
