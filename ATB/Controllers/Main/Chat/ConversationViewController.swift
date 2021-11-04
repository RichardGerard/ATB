import Foundation
import MessageKit
import UIKit
import MapKit
import Applozic
import InputBarAccessoryView
import LocationPickerViewController
import IQKeyboardManagerSwift
import NVActivityIndicatorView
import ImageSlideshow

public class ConversationViewController: MessagesViewController {
    
    let refreshControl = UIRefreshControl()
    let appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    
    public var userId: String?
    public var groupId: NSNumber?
    var createdAtTime: NSNumber?
    var contact : ALContact?
    var channel : ALChannel?
    var messageList: [Message] = []
    var isTyping = false
    
    let photoPicker = UIImagePickerController()
    
    var photoDatas:[Data] = []
    var videoData:Data = Data()
    var videoURL:URL!
    var optionMedia = 0
    
    var player = AVPlayer()
    
    private var nameView: ReplyNameView!
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .colorGray7
        messagesCollectionView.backgroundColor = .colorGray7        
        
        setupNavigation()
        
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        }
        
        activityIndicator.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        activityIndicator.color = UIColor.gray
        view.addSubview(activityIndicator)
        self.view.bringSubviewToFront(activityIndicator)
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = CGSize(width: 32, height: 32)
            
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = CGSize(width: 32, height: 32)
            
            layout.videoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.videoMessageSizeCalculator.incomingAvatarSize = CGSize(width: 32, height: 32)
        }
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        configureInputBar()
        
        photoPicker.delegate = self
        
        appDelegate?.applozicClient.subscribeToConversation()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "reloadData"), object: nil, queue: nil, using: {[weak self]
            (notification) in
            
            guard let weakSelf = self else { return }
            
            let data =  notification.object  as!  [String: Any]
            
            let groupId =  data["groupId"] as! NSNumber
            
            weakSelf.unSubscribeTypingStatus()
            
            if (groupId != 0) {
                self?.groupId = groupId
                self?.userId = nil
                
            } else {
                let userId =  data["userId"] as! String?
                self?.userId = userId
                self?.groupId = 0
            }
            
            weakSelf.messageList.removeAll()
            weakSelf.messagesCollectionView.reloadData()
            weakSelf.loadMessages()
            weakSelf.subscribeTypingStatus()
        })
        
        loadMessages()
    }
    
    private func setupNavigation() {
        let navigationView = ChatNavigationView.instantiate()
        view.addSubview(navigationView)
        navigationView.delegate = self
        navigationView.backgroundColor = .white
        
        let navigationHeight = 100 + UIApplication.safeAreaTop()
        // constraint
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraintWithFormat("H:|[v0]|", views: navigationView)
        view.addConstraintWithFormat("V:|[v0(\(navigationHeight))]", views: navigationView)
        
        if groupId != nil && groupId != 0 {
            let alChannelService = ALChannelService()
            alChannelService .getChannelInformation(byResponse: self.groupId, orClientChannelKey: nil, withCompletion: { (error, alChannel, response) in
                
                if(alChannel != nil){
                    self.channel = alChannel
                    navigationView.lblName.text = alChannel?.name
                    navigationView.imvProfile.loadImageFromUrl(alChannel!.channelImageURL, placeholder: "profile.placeholder")
                }
            })
            
        } else {
            let contactDataBase  = ALContactDBService()
            guard let contact = contactDataBase.loadContact(byKey: "userId", value: userId) else { return }
            navigationView.lblName.text = contact.displayName
            navigationView.imvProfile.loadImageFromUrl(contact.contactImageUrl ?? "", placeholder: "profile.placeholder")
        }
        
        navigationView.layer.shadowOffset = CGSize(width: 0, height: -2)
        navigationView.layer.shadowRadius = 4.0
        navigationView.layer.shadowColor = UIColor.gray.cgColor
        navigationView.layer.shadowOpacity = 0.4
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        appDelegate?.applozicClient.unsubscribeToConversation()
        self.unSubscribeTypingStatus()
    }
    
    class  func showIndicator() {
        curviewcontroller = UIApplication.topViewController()
        let curframe = curviewcontroller?.view.frame
        
        loadingView = UIView(frame: (curviewcontroller?.view.frame)!)
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        loadingAcitivity = NVActivityIndicatorView(frame: CGRect(x: (curframe?.width)!/2 - 18, y: (curframe?.height)!/2 - 18, width: 100, height: 100), type: .ballRotateChase, color: .gray, padding: CGFloat(0))
        loadingAcitivity!.startAnimating()
        loadingView.addSubview(loadingAcitivity!)
        
        KEYWINDOW?.isUserInteractionEnabled = false
        
        if loadingView.superview == nil{
            UIApplication.topViewController()?.view.addSubview(loadingView)
        }
    }
    
    class func hideIndicator(){
        if loadingView.superview != nil{
            loadingAcitivity!.stopAnimating()
            KEYWINDOW?.isUserInteractionEnabled = true
            loadingView.removeFromSuperview()
        }
    }
    
    @objc func refresh() {
        loadMessages(true)
    }
    
    func loadMessages(_ refresh: Bool = false)  {
        showFakeIndicator()
        
        if !refresh {
            activityIndicator.startAnimating()
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var chatId : String?
            let req = MessageListRequest()
            if(self.groupId  != nil && self.groupId != 0){
                req.channelKey =  self.groupId  // pass groupId
                chatId = self.groupId?.stringValue
                
            } else{
                req.userId =  self.userId  // pass userId
                chatId = self.userId
            }
            
            if ALUserDefaultsHandler.isServerCallDone(forMSGList: chatId) {
                ALMessageService.getMessageList(forContactId: req.userId, isGroup: req.channelKey != nil, channelKey: req.channelKey, conversationId: nil, start: 0, withCompletion: {
                    messages in
                    DispatchQueue.main.async {
                        self.hideFakeIndicator()
                        
                        if refresh {
                            self.refreshControl.endRefreshing()
                            
                        } else {
                            self.activityIndicator.stopAnimating()
                        }
                    }
                    
                    self.markConversationAsRead()
                    
                    guard let messages = messages else { return }
                    
                    self.messageList.removeAll()
                    for alMessage in messages {
                        self.convertMessageToMockMessage(_alMessage: alMessage as! ALMessage)
                    }
                    
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom()
                    }
                })
            } else {
                self.appDelegate?.applozicClient.getMessages(req) { (messageList, error) in
                    DispatchQueue.main.async {
                        self.hideFakeIndicator()
                        
                        if refresh {
                            self.refreshControl.endRefreshing()
                            
                        } else {
                            self.activityIndicator.stopAnimating()
                        }
                        
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom()
                    }
                    
                    guard error == nil, let newMessages = messageList as? [ALMessage] else { return }
                    
                    self.messageList.removeAll()
                    for alMessage in newMessages {
                        self.convertMessageToMockMessage(_alMessage: alMessage)
                    }
                    
                    self.messageList =  self.messageList.reversed()
                    
                    self.markConversationAsRead()
                    
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom()
                    }
                }
            }
        }
    }
      
    func configureInputBar() {
        messageInputBar.delegate = self
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundColor = .white

        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.tintColor = .colorPrimary
        messageInputBar.inputTextView.placeholder = "Write a message"
        messageInputBar.inputTextView.placeholderTextColor = UIColor.colorGray1.withAlphaComponent(0.32)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 42)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 42)
        messageInputBar.inputTextView.layer.borderColor = UIColor.colorGray3.cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 20.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        messageInputBar.shouldAutoUpdateMaxTextViewHeight = false
        messageInputBar.maxTextViewHeight = 80
        
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "ic_send")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.tintColor = .colorPrimary
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)

        let cameraButton = InputBarButtonItem()
            .configure {
                $0.setSize(CGSize(width: 36, height: 36), animated: false)
                if #available(iOS 13.0, *) {
                    $0.image = UIImage(systemName: "paperclip")?.withRenderingMode(.alwaysTemplate)
                } else {
                    // Fallback on earlier versions
                }
                $0.imageView?.contentMode = .scaleAspectFit
                $0.tintColor = .colorGray2
        }
        
        cameraButton.onTouchUpInside { _ in
            self.showMenu()
        }

        messageInputBar.setStackViewItems([cameraButton, InputBarButtonItem.fixedSpace(20), messageInputBar.sendButton], forStack: .right, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 92, animated: false)
        messageInputBar.middleContentViewPadding.right = -46
           
        messageInputBar.delegate = self
    }
    
    // MARK: - Helpers
    func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                if #available(iOS 13.0, *) {
                    $0.image = UIImage(systemName: named)?.withRenderingMode(.alwaysTemplate)
                } else {
                    // Fallback on earlier versions
                }
                $0.setSize(CGSize(width: 30, height: 30), animated: true)
            }.onSelected {
                $0.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                self.showMenu()
        }
       
    }
    
    func showMenu() {
        let alert = UIAlertController(title: "Send", message: "", preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor.colorPrimary

        alert.addAction(UIAlertAction(title: "Photo from camera", style: .default, handler: { action in
            self.optionMedia = 0
            self.photoPicker.sourceType = .camera
            self.present(self.photoPicker, animated: true, completion: nil)
        }))
        
        /*alert.addAction(UIAlertAction(title: "Video from camera", style: .default, handler: { action in
            self.photoPicker.sourceType = .camera
            self.photoPicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            self.photoPicker.cameraCaptureMode = .video
            self.optionMedia = 1
            self.present(self.photoPicker, animated: true, completion: nil)
        }))*/
        alert.addAction(UIAlertAction(title: "Photo from library", style: .default, handler: { action in
            self.optionMedia = 0
            self.photoPicker.sourceType = .photoLibrary
            self.photoPicker.mediaTypes = ["public.image"]
            self.present(self.photoPicker, animated: true, completion: nil)
        }))
        
        /*alert.addAction(UIAlertAction(title: "Video from library", style: .default, handler: { action in
            self.photoPicker.sourceType = .savedPhotosAlbum
            self.photoPicker.mediaTypes = ["public.movie"]
            self.optionMedia = 1
            self.present(self.photoPicker, animated: true, completion: nil)
        }))*/
        
        alert.addAction(UIAlertAction(title: "Audio", style: .default, handler: { action in
            let controller = AudioRecorderViewController()
            controller.audioRecorderDelegate = self
            self.present(controller, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Location", style: .default, handler: { action in
            
            //self.sendLocation(latitude: Double((location?.coordinate.latitude)!) , longitude: Double((location?.coordinate.longitude)!))
           let locationPicker = LocationPicker()
            locationPicker.pickCompletion = { (pickedLocationItem) in
                
                if let lat = pickedLocationItem.coordinate?.latitude {
                    if let lon = pickedLocationItem.coordinate?.longitude {
                        self.sendLocation(latitude: lat, longitude: lon)
                    }
                }
                
                self.showIndicator()
            }
            locationPicker.addBarButtons()
            // Call this method to add a done and a cancel button to navigation bar.
            
            let navigationController = UINavigationController(rootViewController: locationPicker)
            self.present(navigationController, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Report User", style: .default, handler: { action in
            
            let reportVC = ReportViewController.instance()
            reportVC.reportType  = .USER
            reportVC.reportId = self.userId ?? ""
            
            self.navigationController?.present(reportVC, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func openProfile(forUser user: UserModel, forBusiness business: Bool) {
        // get rid of profile & likes view controller from navigation stack
        guard let conversationsVC = navigationController?.viewControllers.first else { return }
        
        var viewControllers = [conversationsVC]
        
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
    
    private func getUserDetails(forUser uid: String, forBusiness business: Bool) {
        showIndicator()
        
        let params = [
            "token" : g_myToken,
            "user_id": uid
        ]
               
        _ = ATB_Alamofire.POST(GET_PROFILE_API, parameters: params as [String : AnyObject]) { (result, response) in
            self.hideIndicator()
            
            guard result,
                  let postDict = response.object(forKey: "msg") as? NSDictionary,
                  let profileDict = postDict["profile"] as? NSDictionary else  {
                self.showErrorVC(msg: "Failed to get user details, please try again later!")
                return
            }
                
            let businessDict = profileDict.object(forKey: "business_info") as? NSDictionary ?? [:]
            let user = UserModel(info: profileDict)
            if user.isBusiness {
                user.business_profile = BusinessModel(info: businessDict)
            }
            
            self.openProfile(forUser: user, forBusiness: business)
        }
    }
       
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadData"), object: nil)
    }
}

// MARK: - ChatNavigationViewDelegate
extension ConversationViewController: ChatNavigationViewDelegate {
    
    func didTapProfile() {
        guard var uid = userId else { return }
        
        var business = false
        if uid.contains("_") {
            business = true
            
            uid = String(uid.split(separator: "_")[1])
        }
        
        getUserDetails(forUser: uid, forBusiness: business)
    }
    
    func didTapInfo() {
        
    }
    
    func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ConversationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        if(self.optionMedia == 0)
        {
            if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                sendImage(image: pickedImage)
                
                showIndicator()
               // present(loadingAlert, animated: true, completion: nil)
            }
            else
            {
                
                
            }
        }
        else if(self.optionMedia == 1)
        {
            if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL{
                sendVideo(videoURL: videoUrl)
                showIndicator()
                //present(loadingAlert, animated: true, completion: nil)
            }
            else
            {
                
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - AudioRecorderViewControllerDelegate
extension ConversationViewController: AudioRecorderViewControllerDelegate {
    
    func audioRecorderViewControllerDismissed(withFileURL fileURL: NSURL?) {
        dismiss(animated: true, completion: nil)
        if let url = fileURL {
            sendAudio(audioURL: url)
        }
    }
}

//MARK: - ApplozicAttachmentDelegate
extension ConversationViewController: ApplozicAttachmentDelegate {
    
    public func onUpdateBytesDownloaded(_ bytesReceived: Int64, with alMessage: ALMessage!) {
        // Will get this callback on downloaded bytes in attachment and  from alMessage you can get the filePath and find that file in your doc directory to get the size of the file
        // Ignore this in case of upload a attachment
    }
    
    public func onUpdateBytesUploaded(_ bytesSent: Int64, with alMessage: ALMessage!) {
        // Will get this callback while uploading it will have bytesSent and from alMessage you can get the filePath and find that file in your doc directory to get the size of the file
    }
    
    public func onUploadFailed(_ alMessage: ALMessage!) {
        // Will get this callback in case of upload failed
    }
    
    public func onDownloadFailed(_ alMessage: ALMessage!) {
        // Will get this callback once attachment  Download failed. it will give message object the message which is failed to download
    }
    
    public func onUploadCompleted(_ alMessage: ALMessage!, withOldMessageKey oldMessageKey: String!) {
        // You can use the oldMessageKey to update the current message in UI you can replace the messsage by finding the message with oldMessageKey in your  message list
    }
    
    public func onDownloadCompleted(_ alMessage: ALMessage!) {
        var filePath = alMessage.imageFilePath!
        
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let fileURL = URL(fileURLWithPath: dirPath).appendingPathComponent(filePath)
            print(fileURL.pathExtension)
            
            switch fileURL.pathExtension {
                case "png", "jpeg":
                    if let image = UIImage(contentsOfFile: fileURL.path) {
                        var mockImageMessage = Message(image: image, sender: self.getSender(message: alMessage), messageId: alMessage.key, date: Date(timeIntervalSince1970: Double(alMessage.createdAtTime.doubleValue/1000)))
                        
                        mockImageMessage.createdAtTime = alMessage.createdAtTime
                        self.messageList.append(mockImageMessage)
                        self.messageList.sort{$0.createdAtTime.intValue < $1.createdAtTime.intValue}
                    }
                case "m4a":
                    var mockAudioMessage = Message(audioURL: fileURL, sender: self.getSender(message: alMessage), messageId: alMessage.key, date: Date(timeIntervalSince1970: Double(alMessage.createdAtTime.doubleValue/1000)))
                    mockAudioMessage.createdAtTime = alMessage.createdAtTime
                    self.messageList.append(mockAudioMessage)
                    self.messageList.sort{$0.createdAtTime.intValue < $1.createdAtTime.intValue}
                
                default:
                    return
            }
            
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
        }

    }
}

// MARK: - MessagesDataSource
extension ConversationViewController: MessagesDataSource {
    
    public func currentSender() -> SenderType {
        let contactDBService = ALContactDBService()
        let contact = contactDBService.loadContact(byKey: "userId", value: ALUserDefaultsHandler.getUserId()) as ALContact
        
        let senderContact =  Sender(id:contact.userId , displayName: contact.displayName != nil ? contact.displayName : contact.userId )
        
        return senderContact
    }
    
    public func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    public func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        
        return nil
    }
    
    public func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
    
    public func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: message.sentDate.toString("h:mm a", timeZone: .current) , attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
}

// MARK: - MessagesDisplayDelegate
extension ConversationViewController: MessagesDisplayDelegate {
    // MARK: - Text Messages
    public func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    public func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        return MessageLabel.defaultAttributes
    }
    
    public func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation]
    }
    
    // MARK: - All Messages
    public func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .colorPrimary
            : .white
    }
    
    public func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
    
    public func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if isFromCurrentSender(message: message) {
            avatarView.isHidden = true
            
        } else {
            avatarView.isHidden = false
            
            let alContactDBService = ALContactDBService()
            guard let contact = alContactDBService.loadContact(byKey: "userId", value: message.sender.senderId) else  { return }
            
            avatarView.backgroundColor = .white
            avatarView.layer.borderWidth = 2
            avatarView.layer.borderColor = UIColor.colorPrimary.cgColor
            avatarView.loadImageFromUrl(contact.contactImageUrl ?? "", placeholder: "profile.placeholder")
        }
    }
    
    // MARK: - Location Messages
    public func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "pin")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    public func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(0, 0, 0)
            view.alpha = 0.0
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
                view.alpha = 1.0
            }, completion: nil)
        }
    }
    
    public func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions()
    }
}

// MARK: - MessagesLayoutDelegate
extension ConversationViewController: MessagesLayoutDelegate {
    
    public  func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            return 20
        }
        return 0
    }
    
//    public  func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 16
//    }
    
    public func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
}

// MARK: - MessageCellDelegate
extension ConversationViewController: MessageCellDelegate {
    
    public func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
         guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        switch message.kind {
            case .audio(let audioItem):
                self.play(url :audioItem.url)
            default:
                break
        }
    }
    
    public func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        switch message.kind {
            case .photo(let photoItem):
                if let img = photoItem.image{
                    self.showImage(image: img)
                }
            default:
                break
        }
    }
    
    func play(url:URL) {
        print("playing \(url)")

        let playerItem = AVPlayerItem(url: url)
        
        self.player =  AVPlayer(playerItem:playerItem)
        player.volume = 1.0
        player.play()
    }
    
    fileprivate func showImage(image:UIImage) {
        let imageSlide = ImageSlideshow()
        
        var imageSources = [ImageSource]()
        imageSources.append(ImageSource(image: image))
        
        imageSlide.setImageInputs(imageSources)
        
        let fullScreenController = imageSlide.presentFullScreenController(from: self)
        if #available(iOS 13.0, *) {
            fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .medium, color: .white)
        } else {
            // Fallback on earlier versions
            fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
        }
    }
    
    public func didTapAvatar(in cell: MessageCollectionViewCell) {
        // open profile
        guard var uid = userId else { return }
        
        var business = false
        if uid.contains("_") {
            business = true
            
            uid = String(uid.split(separator: "_")[1])
        }
        
        getUserDetails(forUser: uid, forBusiness: business)
    }
    
    public  func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        switch message.kind {
            case .location(let location):
                let clLocation = location.location
                let coordinate = clLocation.coordinate
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
            default:
                break
        }
    }
    
    public func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    public  func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    public  func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
}

// MARK: - MessageLabelDelegate
extension ConversationViewController: MessageLabelDelegate {
    
    public func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    public  func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    public  func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    public func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    public  func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
}

// MARK: - MessageInputBarDelegate
extension ConversationViewController: InputBarAccessoryViewDelegate {
    
    public func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        // Each NSTextAttachment that contains an image will count as one empty character in the text: String
        
        for component in inputBar.inputTextView.components {
            
            if let image = component as? UIImage {
                
                let imageMessage = Message(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])
                
            } else if let text = component as? String {
                let channelService = ALChannelService()
                if (self.channel != nil && channelService.isChannelLeft(self.channel?.key)) {
                    return;
                }
                self.send(message: text, isOpenGroup: self.channel != nil && self.channel?.type != nil && self.channel?.type == 6)
                
            }
        }
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
    
    func sendImage(image: UIImage) {
        //self.activityIndicator.startAnimating()
        var alMessage = ALMessage();
        var filePath = ALImagePickerHandler.saveImage(toDocDirectory: image)
        
        alMessage = ALMessage.build({ alMessageBuilder in
            
            if(self.groupId != nil && self.groupId != 0){
                alMessageBuilder?.groupId = self.groupId
                
            }else{
                alMessageBuilder?.to = self.userId
            }
            alMessageBuilder?.imageFilePath = filePath
            alMessageBuilder?.contentType = Int16(ALMESSAGE_CONTENT_ATTACHMENT)
        })
        
        appDelegate?.applozicClient.sendMessage(withAttachment: alMessage)
        
    }
    
    func sendVideo(videoURL: NSURL) {
        var alMessage = ALMessage();
        
        alMessage = ALMessage.build({ alMessageBuilder in
            
            if(self.groupId != nil && self.groupId != 0){
                alMessageBuilder?.groupId = self.groupId
                
            }else{
                alMessageBuilder?.to = self.userId
            }
            alMessageBuilder?.imageFilePath = videoURL.absoluteString
            alMessageBuilder?.contentType = Int16(ALMESSAGE_CONTENT_ATTACHMENT)
        })
        
        appDelegate?.applozicClient.sendMessage(withAttachment: alMessage)
        
    }
    
    func sendLocation(latitude: Double, longitude: Double){
        print("Sending location")
        let lat = String(format: "%.8f", latitude) // Pass float value
        let lon = String(format: "%.8f", longitude)  // Pass float value
        
        let latLongDic = [
            "lat" : lat,
            "lon" : lon
        ]
        
        let jsonData: Data? = try? JSONSerialization.data(withJSONObject: latLongDic, options: .prettyPrinted)
        var jsonString: String? = nil
        if jsonData != nil {
            if let aData = jsonData {
                jsonString = String(data: aData, encoding: .utf8)
            }
        }
        
        
        let alMessage = ALMessage.build({ alMessageBuilder in
            if(self.groupId != nil && self.groupId != 0){
                alMessageBuilder?.groupId = self.groupId
                
            }else{
                alMessageBuilder?.to = self.userId
            }
            alMessageBuilder?.message = jsonString
            alMessageBuilder?.contentType = Int16(ALMESSAGE_CONTENT_LOCATION)
            
        })
        
        print("location built")
        appDelegate?.applozicClient.sendTextMessage(alMessage, withCompletion: { (alMessage, error) in
            
            print("location sent")
            if(error == nil){
                //update the ui once message is sent
            }
            
        })
    }
    
    func sendAudio(audioURL: NSURL){
        var alMessage = ALMessage();
        
        alMessage = ALMessage.build({ alMessageBuilder in
            
            if(self.groupId != nil && self.groupId != 0){
                alMessageBuilder?.groupId = self.groupId
                
            }else{
                alMessageBuilder?.to = self.userId
            }
            alMessageBuilder?.imageFilePath = audioURL.absoluteString
            alMessageBuilder?.contentType = Int16(ALMESSAGE_CONTENT_AUDIO)
        })
        
        appDelegate?.applozicClient.sendMessage(withAttachment: alMessage)
    }
    
    
    open func send(message: String, isOpenGroup: Bool = false) {
        
        
        let attributedText = NSAttributedString(string: message, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
        
        var alMessage = ALMessage();
        
        alMessage = ALMessage.build({ alMessageBuilder in
            
            if(self.groupId != nil && self.groupId != 0){
                alMessageBuilder?.groupId = self.groupId
                
            }else{
                alMessageBuilder?.to = self.userId
            }
            alMessageBuilder?.message = message
        })
        
        if isOpenGroup {
            let messageClientService = ALMessageClientService()
            messageClientService.sendMessage(alMessage.dictionary(), withCompletionHandler: {responseJson, error in
                guard error == nil else { return }
                NSLog("No errors while sending the message in open group")
                alMessage.status = NSNumber(integerLiteral: Int(SENT.rawValue))
                
                return
            })
        } else {
            appDelegate?.applozicClient.sendTextMessage(alMessage, withCompletion: { (alMessage, error) in
                
                if(error == nil){
                    //update the ui once message is sent
                }
                
            })
        }
        
    }
    
    @objc func backTapped() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func subscribeTypingStatus()  {
        if(self.groupId != nil && self.groupId != 0){
            appDelegate?.applozicClient.subscribeToTypingStatus(forChannel: self.groupId)
        }else{
            appDelegate?.applozicClient.subscribeToTypingStatusForOneToOne()
        }
    }
    
    func unSubscribeTypingStatus()  {
        if (self.groupId != nil && self.groupId != 0) {
            appDelegate?.applozicClient.unSubscribeToTypingStatus(forChannel: self.groupId)
        } else {
            appDelegate?.applozicClient.unSubscribeToTypingStatusForOneToOne()
        }
    }
    
    public func addMessage(_alMessage:ALMessage){
        convertMessageToMockMessage(_alMessage: _alMessage)
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    public func onMessageReceived(_ alMessage: ALMessage!) {
        
        if (alMessage.groupId != nil && alMessage.groupId != 0 && self.groupId != nil && self.groupId != 0 && alMessage.groupId.isEqual(to: self.groupId ?? 0) ) {
            self.addMessage(_alMessage: alMessage)
            self.markConversationAsRead()
            
        } else if((alMessage.groupId  == nil || alMessage.groupId == 0) && self.userId != nil && self.userId?.isEqual(alMessage.to) ?? false ){
            self.addMessage(_alMessage: alMessage)
            self.markConversationAsRead()
        } else {
            
            if( !alMessage.isMsgHidden()){
                appDelegate?.sendLocalPush(message: alMessage)
            }
        }
    }
    
    public func onMessageSent(_ alMessage: ALMessage!) {
        //self.activityIndicator.stopAnimating()
        self.hideIndicator()
        let position = self.messageList.count-1
        if (position < 0) {
            if(alMessage.groupId != nil && alMessage.groupId != 0 && self.groupId != nil && self.groupId != 0 && alMessage.groupId.isEqual(to: self.groupId ?? 0) ){
                self.addMessage(_alMessage: alMessage)
            }else if(self.userId != nil && self.userId?.isEqual(alMessage.to) ?? false ){
                self.addMessage(_alMessage: alMessage)
            }
        } else {
            let messageTest = self.messageList[position]
            if (messageTest.messageId != alMessage.key) {
                if(alMessage.groupId != nil && alMessage.groupId != 0 && self.groupId != nil && self.groupId != 0 && alMessage.groupId.isEqual(to: self.groupId ?? 0) ){
                    self.addMessage(_alMessage: alMessage)
                }else if(self.userId != nil && self.userId?.isEqual(alMessage.to) ?? false ){
                    self.addMessage(_alMessage: alMessage)
                }
            }
        }
        
       
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
        
        if (self.isShowTypingStatus(_userId: userId)) {
            
            if !status {
                
                messageInputBar.topStackView.arrangedSubviews.first?.removeFromSuperview()
                messageInputBar.topStackViewPadding = .zero
                
            } else {
                messageInputBar.topStackView.arrangedSubviews.first?.removeFromSuperview()
                messageInputBar.topStackViewPadding = .zero
                
                let label = UILabel()
                
                let contactDB = ALContactDBService()
                
                let contact =  contactDB.loadContact(byKey: "userId", value:userId) as ALContact
                
                label.text = String(format: "%@ is typing...", contact.displayName != nil ? contact.displayName:contact.userId)
                label.font = UIFont.boldSystemFont(ofSize: 16)
                messageInputBar.topStackView.addArrangedSubview(label)
                messageInputBar.topStackViewPadding.top = 6
                messageInputBar.topStackViewPadding.left = 12
                
                // The backgroundView doesn't include the topStackView. This is so things in the topStackView can have transparent backgrounds if you need it that way or another color all together
                messageInputBar.backgroundColor = messageInputBar.backgroundView.backgroundColor
                
            }
        }
        
    }
    
    func isShowTypingStatus(_userId:String) -> Bool {
        
        let channelService = ALChannelService()
        var  isMemberOfChannel : Bool = false
        if (self.groupId != nil && self.groupId != 0) {
            let array =  channelService.getListOfAllUsers(inChannel: self.groupId) as NSMutableArray
            isMemberOfChannel = array.contains(_userId)
        }
        
        return ((self.userId != nil &&  _userId == self.userId && (self.groupId == nil || self.groupId == 0)) || self.groupId != nil && self.groupId != 0 && isMemberOfChannel)
        
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
        
    }
    
    public func onMqttConnected() {
        self.subscribeTypingStatus()
    }
    
    public func markConversationAsRead() {
        
        if (self.groupId != nil && self.groupId != 0) {
            appDelegate?.applozicClient.markConversationRead(forGroup: self.groupId) { (response, error) in
                
            }
        } else {
            appDelegate?.applozicClient.markConversationRead(forOnetoOne: self.userId) { (response, error) in
                
            }
        }
    }
    
    public func convertMessageToMockMessage(_alMessage:ALMessage) {
        
        switch  Int32(_alMessage.contentType)  {
            
        case ALMESSAGE_CONTENT_DEFAULT:
            
            var mockTextMessage =  Message(text: _alMessage.message, sender: self.getSender(message: _alMessage), messageId: _alMessage.key, date:                            Date(timeIntervalSince1970: Double(_alMessage.createdAtTime.doubleValue/1000)))
            mockTextMessage.createdAtTime = _alMessage.createdAtTime
            self.messageList.append(mockTextMessage)
            
            break;
            
        case ALMESSAGE_CONTENT_ATTACHMENT:
            
            appDelegate?.applozicClient.attachmentProgressDelegate = self
            appDelegate?.applozicClient.downloadMessageAttachment(_alMessage)
            
        case ALMESSAGE_CONTENT_AUDIO:
            appDelegate?.applozicClient.attachmentProgressDelegate = self
            appDelegate?.applozicClient.downloadMessageAttachment(_alMessage)
            
        case ALMESSAGE_CONTENT_LOCATION:
            
            let objectData: Data? = _alMessage.message.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            var jsonStringDic: [AnyHashable : Any]? = nil
            
            if let aData = objectData {
                jsonStringDic = try! JSONSerialization.jsonObject(with: aData, options: .mutableContainers) as? [AnyHashable : Any]
            }
            
            if let lat =  jsonStringDic?["lat"] as? String, let aDoubleLat = Double(lat), let lon =  jsonStringDic?["lon"] as? String, let aDoubleLon = Double(lon)  {
                
                let location =  CLLocation(latitude: aDoubleLat, longitude: aDoubleLon)
                let date =  Date(timeIntervalSince1970: Double(_alMessage.createdAtTime.doubleValue/1000))
                
                var mockLocationMessage =  Message(location: location, sender: self.getSender(message: _alMessage), messageId: _alMessage.key, date: date)
                mockLocationMessage.createdAtTime = _alMessage.createdAtTime
                self.messageList.append(mockLocationMessage)
            }
            break
            
        default:
            break
        }
    }
    
    func getSender(message:ALMessage) -> Sender {
        let contactDB = ALContactDBService()
        
        var contact =   ALContact()
        if (message.isReceivedMessage()) {
            contact =  contactDB.loadContact(byKey: "userId", value: message.to)
            return  Sender(id: message.to, displayName: contact.displayName == nil ? message.to: contact.displayName)
        } else {
            contact =  contactDB.loadContact(byKey: "userId", value:ALUserDefaultsHandler.getUserId())
            return Sender(id: ALUserDefaultsHandler.getUserId(), displayName: contact.displayName == nil ? ALUserDefaultsHandler.getUserId(): contact.displayName)
        }
    }
}
