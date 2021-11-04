//  PostDetailCollectionViewController.swift
//  ATB
//
//  Created by YueXi on 4/19/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import Foundation
import UIKit
import InputBarAccessoryView
import ImageSlideshow
import Applozic
import Photos
import IQKeyboardManagerSwift
import NBBottomSheet
import PopupDialog
import TTGTagCollectionView
import Branch
import Braintree
import BraintreeDropIn

class PostDetailViewController: InputBarViewController {
    
    private var nameView: ReplyNameView!
    
    // true when you post a reply
    private var isReply: Bool = false
    // comment id to reply
    var forCommentID: String? = nil
    // it will be used only when you reply to reply to scroll to the indexPath you replied to
    var replyIndexPath: IndexPath? = nil
    
    /// The object that manages attachments
    open lazy var attachmentManager: AttachmentManager = { [unowned self] in
        let manager = AttachmentManager()
        manager.delegate = self
        return manager
    }()
    
    var selectedPost: PostDetailModel = PostDetailModel()
    
    private var isOwnPost = false
    // this will be required if the selected post is not the user's post
    // flags represents that you are following, bookmarked, liked the selected post
    // This represents whether the user is currently following this post or not
    var isFollowing = false
    // This represents whether the user already liked this post or not
    var isLiked: Bool = false
    // This represents whether the user already saved this post or not
    var isSaved: Bool = false
    
    var comments = [CommentViewModel]()
    private var commentList = [Any]()
    
    /********* none use variables from old version *********/
    var comment_array:[CommentModel] = []
        
    private let MAXIMUM_SELECTION_COUNT = 3
    
    let readMoreTextFont = UIFont(name: "SegoeUI-Light", size: 18.0)!
    var isMoreShow: Bool = true
    var isFirstLoad: Bool = true
    
    let COMMENT_PREFERRED_WIDTH = SCREEN_WIDTH * 0.75
    let REPLY_PREFERRED_WIDTH   = SCREEN_WIDTH * 0.75 - 62
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .colorGray7
        
        isOwnPost = (g_myInfo.ID == selectedPost.Poster_Info.ID)
        
        setupNavigation()
        
        getVariations()
        
        configureCollectionView()
        configureInputBar()
        configureInputBarItems()
        
        updateCommentList()
        
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius = 5
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color = .colorPrimary
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(didSelectVariant(_:)), name: .DidSelectVariant, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didUpdatePost(_:)), name: .DidUpdatePost, object: nil)
    }
    
    private var variations = [VariationModel]()
    private func getVariations() {
        let post = selectedPost.Post_Summerize
        guard post.isSale,
              post.productVariants.count > 0 else { return }
        
        let variantAttributes = post.productVariants[0].attributes
        for variantAttribute in variantAttributes {
            let variation = VariationModel()
            let name = variantAttribute.name
            variation.name = name
            
            var values = [String]()
            
            for productVariant in post.productVariants {
                for attribute in productVariant.attributes {
                    if attribute.name == name,
                       values.firstIndex(of: attribute.value) == nil {
                        values.append(attribute.value)
                    }
                }
            }
            
            variation.values = values
            
            variations.append(variation)
        }
    }
    
    private let navigationView: NavigationView = {
        let view = NavigationView.instantiate()
        view.backgroundColor = .white
        return view
    }()
    
    private func setupNavigation() {
        view.addSubview(navigationView)
        navigationView.delegate = self
        
        let navigationHeight = 82 + UIApplication.safeAreaTop() // 44
        // constraint
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraintWithFormat("H:|[v0]|", views: navigationView)
        view.addConstraintWithFormat("V:|[v0(\(navigationHeight))]", views: navigationView)
        
        navigationView.layer.shadowOffset = CGSize(width: 0, height: -2)
        navigationView.layer.shadowRadius = 4.0
        navigationView.layer.shadowColor = UIColor.gray.cgColor
        navigationView.layer.shadowOpacity = 0.4
        
        updateNavigation()
    }
    
    // setup poster info
    private func updateNavigation() {
        if selectedPost.Post_Summerize.isBusinessPost {
            let business = selectedPost.Poster_Info.business_profile
            navigationView.imvPoster.loadImageFromUrl(business.businessPicUrl, placeholder: "profile.placeholder")
            navigationView.lblName.text = business.businessProfileName
            navigationView.lblUsername.text = "@" + business.businessName
            
        } else {
            let normal = selectedPost.Poster_Info
            navigationView.imvPoster.loadImageFromUrl(normal.profile_image, placeholder: "profile.placeholder")
            navigationView.lblName.text = normal.firstName + " " + normal.lastName
            navigationView.lblUsername.text = "@" + normal.account_name
        }
    }
    
    private func configureCollectionView() {
        commentCollectionView.backgroundColor = .clear
        commentCollectionView.showsVerticalScrollIndicator = false
        
        maintainPositionOnKeyboardFrameChanged = true   // default false
        
        commentCollectionView.dataSource = self
        commentCollectionView.delegate = self
        
        // register collectionview cells
        commentCollectionView.register(UINib(nibName: "TextPollInPostViewCell", bundle: nil), forCellWithReuseIdentifier: TextPollInPostViewCell.reuseIdentifier)
        commentCollectionView.register(UINib(nibName: "MediaPollInPostViewCell", bundle: nil), forCellWithReuseIdentifier: MediaPollInPostViewCell.reuseIdentifier)
        commentCollectionView.register(UINib(nibName: "TextInPostViewCell", bundle: nil), forCellWithReuseIdentifier: TextInPostViewCell.reuseIdentifier)
        commentCollectionView.register(UINib(nibName: "MediaInPostViewCell", bundle: nil), forCellWithReuseIdentifier: MediaInPostViewCell.reuseIdentifier)
        commentCollectionView.register(UINib(nibName: "LikesInfoViewCell", bundle: nil), forCellWithReuseIdentifier: LikesInfoViewCell.reuseIdentifier)
        commentCollectionView.register(UINib(nibName: "SaleInfoViewCell", bundle: nil), forCellWithReuseIdentifier: SaleInfoViewCell.reuseIdentifier)
        commentCollectionView.register(UINib(nibName: "ServiceInfoViewCell", bundle: nil), forCellWithReuseIdentifier: ServiceInfoViewCell.reuseIdentifier)
        commentCollectionView.register(UINib(nibName: "AdviceInfoViewCell", bundle: nil), forCellWithReuseIdentifier: AdviceInfoViewCell.reuseIdentifier)
        commentCollectionView.register(UINib(nibName: "VariationTagsCell", bundle: nil), forCellWithReuseIdentifier: VariationTagsCell.reuseIdentifier)
        commentCollectionView.register(UINib(nibName: "PostActionCell", bundle: nil), forCellWithReuseIdentifier: PostActionCell.reuseIdentifier)
        commentCollectionView.register(CommentCell.self, forCellWithReuseIdentifier: CommentCell.reusableIdentifier)
        commentCollectionView.register(ReplyCell.self, forCellWithReuseIdentifier: ReplyCell.reusableIdentifier)
        
//        commentCollectionView.addSubview(refreshControl)
//        refreshControl.addTarget(self, action: #selector(loadMoreComments), for: .valueChanged)
    }
    
    private func configureInputBar() {
        inputBar.separatorLine.isHidden = true
        inputBar.backgroundColor = .white

        inputBar.inputTextView.backgroundColor = .white
        inputBar.inputTextView.tintColor = .colorPrimary
        inputBar.inputTextView.placeholder = "Write a comment"
        inputBar.inputTextView.placeholderTextColor = UIColor.colorGray1.withAlphaComponent(0.32)
        inputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 42)
        inputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 42)
        inputBar.inputTextView.layer.borderColor = UIColor.colorGray3.cgColor
        inputBar.inputTextView.layer.borderWidth = 1.0
        inputBar.inputTextView.layer.cornerRadius = 20.0
        inputBar.inputTextView.layer.masksToBounds = true
        inputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        inputBar.shouldAutoUpdateMaxTextViewHeight = false
        inputBar.maxTextViewHeight = 80

        inputBar.delegate = self

        //   Set plugins
        inputBar.inputPlugins = [attachmentManager]
    }

    private func configureInputBarItems() {
        inputBar.sendButton.image = #imageLiteral(resourceName: "ic_send")
        inputBar.sendButton.title = nil
        inputBar.sendButton.tintColor = .colorPrimary
        inputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)

        let cameraButton = InputBarButtonItem()
            .configure {
                $0.setSize(CGSize(width: 36, height: 36), animated: false)
                $0.setImage(#imageLiteral(resourceName: "ic_camera").withRenderingMode(.alwaysTemplate), for: .normal)
                $0.imageView?.contentMode = .scaleAspectFit
                $0.tintColor = .colorGray2
        }
        
        cameraButton.onTouchUpInside { _ in
            self.didTapCamera()
        }

        inputBar.setStackViewItems([cameraButton, InputBarButtonItem.fixedSpace(20), inputBar.sendButton], forStack: .right, animated: false)
        inputBar.setRightStackViewWidthConstant(to: 92, animated: false)
        inputBar.middleContentViewPadding.right = -46
        
        nameView = ReplyNameView.instantiate()
        if #available(iOS 13.0, *) {
            nameView.backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
            nameView.backgroundColor = .white
        }
        nameView.translatesAutoresizingMaskIntoConstraints = false
        nameView.delegate = self
        inputBar.topStackView.addArrangedSubview(nameView)
        nameView.isHidden = true
        
        isReply = false
    }
    
    private func updateCommentList(_ hiddenID: String = "") {
        commentList.removeAll()
        
        for comment in comments.reversed() {
            if  comment.id == hiddenID {
                comment.hidden = true
                continue
                
            } else {
                if  let hidden = comment.hidden,
                    hidden {
                    continue
                }
                
                commentList.append(comment)
                
                for reply in comment.replies.reversed() {
                    if  reply.id == hiddenID {
                        reply.hidden = true
                        continue
                        
                    } else {
                        if  let hidden = comment.hidden,
                            hidden {
                            continue
                        }
                        
                        commentList.append(reply)
                    }
                }
            }
        }
        
        commentCollectionView.reloadData()
    }
    
    @objc func loadMoreComments() {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
//            SampleData.shared.getMessages(count: 20) { messages in
                DispatchQueue.main.async {
//                    self.messageList.insert(contentsOf: messages, at: 0)
//                    self.messagesCollectionView.reloadDataAndKeepOffset()
//                    self.refreshControl.endRefreshing()
                }
//            }
        }
    }
    
    private func updateInputBarForReply(_ selected: Any, indexPath: IndexPath) {
        // check for commenter ID
        let commenterID = (selected is CommentViewModel) ? (selected as! CommentViewModel).commentUserId : (selected as! ReplyModel).replyUserId
        
        // check for commenter
        guard commenterID != g_myInfo.ID else {
            self.showErrorVC(msg: "You can not reply to your own comments.")
            return
        }
        
        forCommentID = (selected is CommentViewModel) ? (selected as! CommentViewModel).id : (selected as! ReplyModel).commentID
        
        replyIndexPath = indexPath
        
        let toName = (selected is CommentViewModel) ? (selected as! CommentViewModel).userNameDisplay : (selected as! ReplyModel).userNameDisplay
        
        let prefix = "Replying to "
        let boldFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: boldFont
        ]

        let attributedName = NSMutableAttributedString(string: prefix + toName)
        attributedName.addAttributes(boldAttributes, range: NSRange(location: prefix.count, length: toName.count))
        
        isReply = true
        nameView.isHidden = false
        nameView.lblUserName.attributedText = attributedName

        inputBar.inputTextView.becomeFirstResponder()
    }
    
    // This will be called after a new comment has been added to
    private func didPostNewComment() {
        selectedPost.Post_Summerize.Post_Comments = "\(selectedPost.Post_Summerize.Post_Comments.intValue + 1)"
        commentCollectionView.reloadSections([1])
        
        let objectToPost = [
            "postID": selectedPost.Post_Summerize.Post_ID
        ]
        
        // post a notificaiton to get feed updated
        NotificationCenter.default.post(name: .PostNewCommentAdded, object: objectToPost)
    }
    
    private func fetchAssets(_ selectedAssets: [PHAsset], isDirectSend: Bool) {
        if !isDirectSend {
            inputBar.inputTextView.becomeFirstResponder()
        }
        
        guard selectedAssets.count > 0 else { return }
        
        var selectedImages = [UIImage]()
        for selected in selectedAssets {
            let image = getAssetThumbnail(selected, size: 420)
            if isDirectSend {
                selectedImages.append(getAssetThumbnail(selected, size: 420))
                
            } else {
                attachmentManager.handleInput(of: image)
            }
        }
        
        if isDirectSend {
            let comment = inputBar.inputTextView.text!
            for attachment in attachmentManager.attachments {
                if case AttachmentManager.Attachment.image(let image) = attachment {
                    selectedImages.append(image)
                }
            }
            
            startPost(withComment: comment, attachments: selectedImages)
        }
    }
    
    private func startPost(withComment comment: String, attachments: [UIImage]) {
//        inputBar.inputTextView.text = String()
        
        // Send button activity animation
        inputBar.sendButton.startAnimating()
//        inputBar.inputTextView.placeholder = "Sending..."
        
        isReply ? postReply(comment.trimmingCharacters(in: .whitespacesAndNewlines), attachments: attachments) : postComment(comment.trimmingCharacters(in: .whitespacesAndNewlines), attachments: attachments)
    }
    
    private func finishPost() {
        if isReply {
            isReply = false
            nameView.isHidden = true
        }
        
        inputBar.sendButton.stopAnimating()
        inputBar.inputTextView.placeholder = "Write a comment"
        
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        
        inputBar.inputTextView.resignFirstResponder()
        inputBar.inputTextViewDidChange()
    }
    
    private func didTapCamera() {
        guard attachmentManager.attachments.count < 3 else {
            showAlertVC(msg: "You can only post 3 images at the same time.")
            return
        }
        
        let presentImagePickerController: (UIImagePickerController.SourceType) -> () = { source in
            let controller = UIImagePickerController()
            controller.delegate = self
            
            var sourceType = source
            
            if !UIImagePickerController.isSourceTypeAvailable(sourceType) {
                sourceType = .photoLibrary
                
                print("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
            }
            
            controller.sourceType = sourceType
            controller.allowsEditing = true
            
            self.present(controller, animated: true, completion: nil)
        }
        
        let controller = ImagePickerSheetController(mediaType: .imageAndVideo)
        controller.maximumSelection = MAXIMUM_SELECTION_COUNT - attachmentManager.attachments.count
        controller.delegate = self
        
        controller.addAction(ImagePickerAction(title: "Camera", secondaryTitle: "Add comment", handler: { _ in
            presentImagePickerController(.camera)
        }, secondaryHandler: {_ , numberOfPhotos in
            self.fetchAssets(controller.selectedAssets, isDirectSend: false)
        }))
        
        controller.addAction(ImagePickerAction(title: "Photo Library", secondaryTitle: "Send Photo", handler: { _ in
            presentImagePickerController(.photoLibrary)
        }, secondaryHandler: { _, numberOfPhotos in
            self.fetchAssets(controller.selectedAssets, isDirectSend: true)
        }))
        
        controller.addAction(ImagePickerAction(cancelTitle: "Cancel"))
        
        present(controller, animated: true, completion: nil)
    }
    
    private func tapOnLocation(_ post: PostModel) {
        guard let postLocationVC = PostLocationViewController.instance() else { return }
        
        postLocationVC.postLocation = CLLocation(latitude: post.Post_Position.latitude, longitude: post.Post_Position.longitude)
        postLocationVC.postAddress = post.Post_Location
        
        if post.Post_Type == "Service" {
            postLocationVC.strTitle = "Area Covered"
            
        } else {
            postLocationVC.strTitle = "Location"
        }
        
        self.navigationController?.pushViewController(postLocationVC, animated: true)
    }
    
    fileprivate func showImages(_ selectedIndex: Int, urls: [String]) {
        let imageSlide = ImageSlideshow()
        
        var imageSources = [KingfisherSource]()
        for url in urls {
            if  url != "" ,
                let newkingsource = KingfisherSource(urlString: url) {
                imageSources.append(newkingsource)
            }
        }
        
        guard imageSources.count > 0 else { return }
        
        imageSlide.setImageInputs(imageSources)
        imageSlide.setCurrentPage(selectedIndex, animated: false)
        
        let fullScreenController = imageSlide.presentFullScreenController(from: self)
        if #available(iOS 13.0, *) {
            fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .medium, color: .white)
        } else {
            // Fallback on earlier versions
            fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
        }
    }
    
    fileprivate func showMenuOptions(_ selected: Any, indexPath: IndexPath) {
        let alert = UIAlertController()
        
        alert.addAction(UIAlertAction(title: "Reply", style: .destructive) { action in
            self.updateInputBarForReply(selected, indexPath: indexPath)
        })
        alert.addAction(UIAlertAction(title: "Find support or Report comment", style: .default) { action in
            self.reportSelected(selected)
        })
        alert.addAction(UIAlertAction(title: "Copy", style: .default) { action in
            self.copySelected(selected)
        })
        alert.addAction(UIAlertAction(title: "Hide", style: .default) { action in
            self.hideSelected(selected, indexPath: indexPath)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    fileprivate func replySelected(_ selected: Any, indexPath: IndexPath) {
        updateInputBarForReply(selected, indexPath: indexPath)
    }
    
    fileprivate func reportSelected(_ selected: Any) {
        let reportId = (selected is CommentViewModel) ? (selected as! CommentViewModel).id : (selected as! ReplyModel).id
        submitReport(.COMMENT, reportId: reportId)
    }
    
    fileprivate func copySelected(_ selected: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = (selected is CommentViewModel) ? (selected as! CommentViewModel).comment : (selected as! ReplyModel).reply
    }
    
    @objc private func didUpdatePost(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let _ = object["updated"] as? PostModel else { return }
        
        let selected = selectedPost.Post_Summerize
        
        DispatchQueue.main.async {
            if selected.isAdvice {
                self.updateNavigation()
            }
            
            self.commentCollectionView.reloadSections([0, 1, 2])
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: API handlers
extension PostDetailViewController {
    
    // Get followings to see if the user is already following this poster/user
    // the way to check this
    // get my followings, compare both follower_user_id and follower_business_id with this poster user_id and business_id
    private func getFollowings() {
        let myUserID = g_myInfo.ID
//        let myBusinessID = g_myInfo.isBusiness ? g_myInfo.business_profile.ID : "0"
        let myBusinessID = "0"
        
        let posterUserID = selectedPost.Poster_Info.ID
        let posterBusinessID = selectedPost.Post_Summerize.Poster_Account_Type == "Business" ? selectedPost.Poster_Info.business_profile.ID : "0"
        
        showIndicator()
        
        let params = [
            "token": g_myToken,
            "follow_user_id": myUserID,
            "follow_business_id": myBusinessID
        ]
        
        _ = ATB_Alamofire.POST(GET_FOLLOW, parameters: params as [String: AnyObject], showLoading: false, showSuccess: false, showError: false, completionHandler: { (result, responseObject) in
            self.hideIndicator()
            
            let responseDicts = (responseObject.object(forKey: "msg") as? [NSDictionary]) ?? []
            
            for responseDict in responseDicts {
                if let followingUserID = responseDict["follower_user_id"] as? String,
                let followingBusinessID = responseDict["follower_business_id"] as? String,
                followingUserID == posterUserID,
                    followingBusinessID == posterBusinessID {
                    self.isFollowing = true
                    
                    return
                }
            }
        })
    }
    
    private func postComment(_ comment: String, attachments: [UIImage]) {
        showIndicator()
        
        let forPostID = selectedPost.Post_Summerize.Post_ID
        var attachmentsInfo = [(Data, String, String, String)]()
        for (index, attachment) in attachments.enumerated() {
            if let imageData = attachment.jpegData(compressionQuality: 0.5) {
                let withName = "comment_imgs[\(index)]"
                let fileName = "for_\(forPostID)_comment_img\(index)"
                attachmentsInfo.append((imageData, withName, fileName, "image/jpeg"))
            }
        }
        
        let comment = comment.encodedString
        APIManager.shared.postComment(forPost: forPostID, token: g_myToken, withID: selectedPost.Poster_Info.ID, withComment: comment, attachments: attachmentsInfo) { (result, message, addedComment) in
            self.hideIndicator()
            self.finishPost()
            
            guard result else {
                if let message = message,
                    message != "" {
                    self.showErrorVC(msg: "Server returned the error message: " + message)
                    
                } else {
                    self.showErrorVC(msg: "Failed to post the comment, please try again later")
                }
                
                return
            }
            
            if let addedComment = addedComment {
                self.commentList.append(addedComment)
                
                let indexPath = IndexPath(row: (self.commentList.count > 0 ? self.commentList.count : 1) - 1, section: 3)
                self.commentCollectionView.performBatchUpdates({
                    self.commentCollectionView.insertItems(at: [indexPath])
                    
                }, completion: { _ in
                    self.commentCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
                })
                
                self.didPostNewComment()
            }
        }
    }
        
    private func postReply(_ reply: String, attachments: [UIImage]) {
        showIndicator()
        
        guard let commentID = forCommentID else {
            return
        }
        
        var attachmentsInfo = [(Data, String, String, String)]()
        for (index, attachment) in attachments.enumerated() {
            if let imageData = attachment.jpegData(compressionQuality: 0.5) {
                let withName = "reply_imgs[\(index)]"
                let fileName = "for_\(commentID)_reply_img\(index)"
                attachmentsInfo.append((imageData, withName, fileName, "image/jpeg"))
            }
        }
           
        let reply = reply.encodedString
        APIManager.shared.postReply(forComment: commentID, token: g_myToken, withID: selectedPost.Poster_Info.ID, withReply: reply, attachments: attachmentsInfo) { (result, message, addedReply) in
            self.hideIndicator()
            self.finishPost()
            
            guard result else {
                if let message = message,
                    message != "" {
                    self.showErrorVC(msg: "Server returned the error message: " + message)

                } else {
                    self.showErrorVC(msg: "Failed to post the reply, please try again later")
                }
                
                return
            }
            
            if let reply = addedReply {
                DispatchQueue.main.async { [weak self] in
                    guard let weakSelf = self,
                          let indexPath = weakSelf.replyIndexPath else { return }
                    // add new comment to data
                    reply.userName = g_myInfo.userName
                    
                    var toIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
                    
                    if toIndexPath.row == weakSelf.commentList.count {
                        weakSelf.commentList.append(reply)
                        
                    } else {
                        while weakSelf.commentList[toIndexPath.row] is ReplyModel {
                            toIndexPath.row += 1
                            
                            if toIndexPath.row == weakSelf.commentList.count { break }
                        }
                        
                        weakSelf.commentList.insert(reply, at: toIndexPath.row)
                    }
                    
                    weakSelf.commentCollectionView.performBatchUpdates({
                        weakSelf.commentCollectionView.insertItems(at: [toIndexPath])
                        
                    }, completion: { _ in
                        weakSelf.commentCollectionView.scrollToItem(at: toIndexPath, at: .bottom, animated: true)
                    })
                    
                    weakSelf.didPostNewComment()
                }
            }
        }
    }
    
    fileprivate func addLike(forComment selected: Any, isComment: Bool = true) {
        let commenterID = isComment ? (selected as! CommentViewModel).commentUserId : (selected as! ReplyModel).replyUserId
        
        // check for commenter
        guard commenterID != g_myInfo.ID else {
            self.showErrorVC(msg: "You can not like your own comments.")
            return
        }
        
        showIndicator()
        
        let id = isComment ? (selected as! CommentViewModel).id : (selected as! ReplyModel).id
        
        APIManager.shared.addLike(forComment: id, token: g_myToken, isComment: isComment) { result, message in
            self.hideIndicator()
            
            guard result else {
                let message = message ?? "Failed to like this comment."
                self.showErrorVC(msg: "Server returned the error message: " + message)
                
                return
            }
            
            if isComment {
                let comment = selected as! CommentViewModel
                comment.liked = comment.liked != nil ? !comment.liked! : true
                
            } else {
                let reply = selected as! ReplyModel
                reply.liked = reply.liked != nil ? !reply.liked! : true
            }
            
            self.commentCollectionView.reloadData()
        }
    }
    
    fileprivate func hideSelected(_ selected: Any, indexPath: IndexPath) {
        let id = (selected is CommentViewModel) ? (selected as! CommentViewModel).id : (selected as! ReplyModel).id
        
        showIndicator()
        APIManager.shared.hideComment(forComment: id, token: g_myToken) { (result, message) in
            self.hideIndicator()
            
            guard result else {
                let message = message ?? "Failed to hide selected comment"
                self.showErrorVC(msg: "Server returned the error message: " + message)
                
                return
            }
            
            DispatchQueue.main.async {
                self.updateCommentList(id)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PostDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // the 1st two sections will have one item in the section
    // section - 0: media info
    // section - 1: likes, comments & save post
    
    // the 2nd section will be varied
    // section - 2: service & sale info (only vailable for service & sale post)
        
    // section - 3: comments section
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) ->  Int {
        let post = selectedPost.Post_Summerize
        switch section {
        case 0, 1:
            return 1
            
        case 2:
            if post.isPoll {
                return 0
                
            } else if post.isAdvice {
                // advice
                return post.isTextPost ? 0 : 1
                
            } else if post.isSale {
                // sales info
                // variations
                // buy (if the selected post is own post, get rid of the 'Buy' button)
                return isOwnPost ? variations.count+1 : variations.count+2
                
            } else {
                // service
                return isOwnPost ? 1 : 2
            }
            
        default:
            return commentList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = selectedPost.Post_Summerize
        
        switch indexPath.section {
        case 0:
            if post.isPoll {
                // poll
                if post.isTextPost {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextPollInPostViewCell.reuseIdentifier, for: indexPath) as! TextPollInPostViewCell
                    // configure the cell
                    cell.configureCell(post)
                    cell.delegate = self
                    
                    return cell
                    
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaPollInPostViewCell.reuseIdentifier, for: indexPath) as! MediaPollInPostViewCell
                    // configure the cell
                    cell.configureCell(post)
                    cell.delegate = self
                    
                    return cell
                }
                
            } else {
                if post.isTextPost {
                    // advice without media
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextInPostViewCell.reuseIdentifier, for: indexPath) as! TextInPostViewCell
                    // configure the cell
                    cell.configureCell(post)
                    
                    return cell
                    
                } else {
                    // advice with media, sale, and service
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaInPostViewCell.reuseIdentifier, for: indexPath) as! MediaInPostViewCell
                    // configure the cell
                    cell.configureCell(post, isApproved: post.isBusinessPost)
                    
                    // tap on video
                    cell.tapOnVideo = {
                        guard post.Post_Media_Urls.count > 0,
                            let videoURL = URL(string: post.Post_Media_Urls[0]) else {
                                self.showErrorVC(msg: "The video URL is invalid.")
                                return
                        }

                        let avPlayer = AVPlayer(url: videoURL)

                        let playerViewController = AVPlayerViewController()
                        playerViewController.player = avPlayer

                        self.present(playerViewController, animated: true) {
                            playerViewController.player?.play()
                        }
                    }
                    
                    // tap on image
                    cell.tapOnImage = { gesture in
                        guard let imageSlide = gesture.view as? ImageSlideshow else { return }

                        let fullScreenController = imageSlide.presentFullScreenController(from: self)
                        // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
                        if #available(iOS 13.0, *) {
                            fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .medium, color: .white)
                        } else {
                            // Fallback on earlier versions
                            fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
                        }
                    }
                    
                    return cell
                }
            }
            
        case 1:
            // Likes & Comments, Save Post
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LikesInfoViewCell.reuseIdentifier, for: indexPath) as! LikesInfoViewCell
            // configure the cell
            cell.configureCell(post, isOwnPost: isOwnPost, isLiked: isLiked, isSaved: isSaved)
            cell.delegate = self
            
            return cell
            
        case 2:
            // poll will not get here
            // service, sales, and advice with media
            if post.isSale {
                // sale
                if indexPath.row == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SaleInfoViewCell.reuseIdentifier, for: indexPath) as! SaleInfoViewCell
                    // configure the cell
                    cell.configureCell(post)
                    cell.delegate = self

                    return cell
                    
                } else if indexPath.row <= variations.count {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VariationTagsCell.reuseIdentifier, for: indexPath) as! VariationTagsCell
                    // configure the cell
                    cell.configureCell(withVariation: variations[indexPath.row - 1])
                    cell.setDelegate(self, forRow: indexPath.row-1)
                    
                    return cell
                    
                } else {
                    // post action (buy & add)
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostActionCell.reuseIdentifier, for: indexPath) as! PostActionCell
                    // configure the cell
                    cell.configureCell(post)
                    cell.delegate = self
                    
                    return cell
                }
                
            } else if post.isService {
                if indexPath.row == 0 {
                    // service info
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ServiceInfoViewCell.reuseIdentifier, for: indexPath) as! ServiceInfoViewCell
                    // configure the cell
                    cell.configureCell(post)
                    cell.delegate = self

                    return cell
                    
                } else {
                    // post action (book service & chat with provider)
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostActionCell.reuseIdentifier, for: indexPath) as! PostActionCell
                    // configure the cell
                    cell.configureCell(post)
                    cell.delegate = self
                    
                    return cell
                }
                
            } else {
                // advice with media
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdviceInfoViewCell.reuseIdentifier, for: indexPath) as! AdviceInfoViewCell
                // configure the cell
                cell.configureCell(post)
                
                return cell
            }
                    
        default:
            // return comment cell
            let anyComment = commentList[indexPath.row]
                    
            if anyComment is CommentViewModel {
                let comment = anyComment as! CommentViewModel
                let estimatedFrame = (comment.userNameDisplay + " " + comment.commentDisplay).heightForString(COMMENT_PREFERRED_WIDTH)
                
                let messageWidth = (comment.comment == "") ? 0 : estimatedFrame.width + 16    //  16 is compentisive value
                let messageHeight = (comment.comment == "") ? 0 : estimatedFrame.height + 20  //  20 is compentisive value
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCell.reusableIdentifier, for: indexPath) as! CommentCell
                
                // 16(left padding) + 36 (profile) + 6 (imageview - margin(6)) = 58
                if comment.comment != "" {
                    cell.messageTextView.frame = CGRect(x: 58 + 8, y: 0, width: messageWidth, height:  messageHeight)
                    cell.bubbleView.frame = CGRect(x: 58, y: 0, width: messageWidth + 8, height:  messageHeight)
                    
                } else {
                    cell.messageTextView.frame = .zero
                    cell.bubbleView.frame = .zero
                }
                
                
                if comment.mediaUrls.count > 0 {
                    cell.mediaStackView.isHidden = false
                    let originYForMediaStack = (comment.comment == "") ? CGFloat(0) : CGFloat(8)
                    
                    cell.mediaStackView.frame = CGRect(x: 58 , y: messageHeight + originYForMediaStack, width: 138, height: 126 * CGFloat(comment.mediaUrls.count)  + 8 * CGFloat(comment.mediaUrls.count - 1))
                    
                } else {
                    cell.mediaStackView.isHidden = true
                    cell.mediaStackView.frame = .zero
                }
                
                cell.configureCell(comment)
                
                cell.likeBlock = {
                    self.addLike(forComment: comment)
                }

                cell.replyBlock = {
                    self.updateInputBarForReply(comment, indexPath: indexPath)
                }
                
                // image tapped
                cell.imageTapBlock = { selected in
                    var urls = [String]()
                    for url in comment.mediaUrls {
                        urls.append(url)
                    }
                    
                    self.showImages(selected, urls: urls)
                }
                
                cell.longPressBlock = {
                    self.showMenuOptions(comment, indexPath: indexPath)
                }
                
                return cell
                
            } else {
                let reply = anyComment as! ReplyModel
                let estimatedFrame = (reply.userNameDisplay + " " + reply.commentDisplay).heightForString(REPLY_PREFERRED_WIDTH)
                
                let messageWidth = (reply.reply == "") ? 0 : estimatedFrame.width + 16    //  16 is compentisive value
                let messageHeight = (reply.reply == "") ? 0 : estimatedFrame.height + 20  //  20 is compentisive value
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  ReplyCell.reusableIdentifier, for: indexPath) as! ReplyCell
                
                if reply.reply != "" {
                    // 62(left padding) + 25(profile) + 6 (imageview - margin(6)) = 93
                    cell.messageTextView.frame = CGRect(x: 93 + 8, y: 0, width: messageWidth, height:  messageHeight)
                    cell.bubbleView.frame = CGRect(x: 93, y: 0, width: messageWidth + 8, height:  messageHeight)
                    
                } else {
                    cell.messageTextView.frame = .zero
                    cell.bubbleView.frame = .zero
                }
                
                if reply.mediaUrls.count > 0 {
                    cell.mediaStackView.isHidden = false
                    let originYForMediaStack = (reply.reply == "") ? CGFloat(0) : CGFloat(8)
                    
                    cell.mediaStackView.isHidden = false
                    cell.mediaStackView.frame = CGRect(x: 93 , y: messageHeight + originYForMediaStack, width: 138, height: 126 * CGFloat(reply.mediaUrls.count)  + 8 * CGFloat(reply.mediaUrls.count - 1))
                    
                } else {
                    cell.mediaStackView.isHidden = true
                    cell.mediaStackView.frame = .zero
                }
                
                cell.configureCell(reply)
                
                cell.likeBlock = {
                    self.addLike(forComment: reply, isComment: false)
                }
                
                cell.replyBlock = {
                    self.updateInputBarForReply(reply, indexPath: indexPath)
                }
                
                // image tapped
                cell.imageTapBlock = { selected in
                    var urls = [String]()
                    for url in reply.mediaUrls {
                        urls.append(url)
                    }
                    
                    self.showImages(selected, urls: urls)
                }
                
                cell.longPressBlock = {
                    self.showMenuOptions(reply, indexPath: indexPath)
                }
                
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let post = selectedPost.Post_Summerize
        switch indexPath.section {
        case 0:
            if post.isPoll {
                if post.isTextPost {
                    return TextPollInPostViewCell.sizeForItem(post)
                    
                } else {
                    return MediaPollInPostViewCell.sizeForItem(post)
                }
                
            } else {
                if post.isTextPost {
                    return TextInPostViewCell.sizeForItem(post)
                    
                } else {
                    return MediaInPostViewCell.sizeForItem()
                }
            }
            
        case 1: return CGSize(width: SCREEN_WIDTH, height: 50)
            
        case 2:
            if post.isAdvice {
                // advice
                return AdviceInfoViewCell.sizeForItem(post)
                
            } else if post.isSale {
                // sale
                if indexPath.row == 0 {
                    return SaleInfoViewCell.sizeForItem(post)
                    
                } else if indexPath.row <= variations.count {
                    return VariationTagsCell.sizeForItem()
                    
                } else {
                    // buy & add
                    return CGSize(width: SCREEN_WIDTH, height: 88)
                }
            } else {
                // service
                if indexPath.row == 0 {
                    return ServiceInfoViewCell.sizeForItem(post)
                    
                } else {
                    // book & chat
                    return CGSize(width: SCREEN_WIDTH, height: 88)
                }
            }
            
        default:
            let anyComment = commentList[indexPath.item]
            if anyComment is CommentViewModel {
                let comment = anyComment as! CommentViewModel
                let estimatedFrame = (comment.userNameDisplay + " " + comment.commentDisplay).heightForString(COMMENT_PREFERRED_WIDTH)
                var height = (comment.comment == "") ? CGFloat(comment.mediaUrls.count) * 126.0 : estimatedFrame.height + 20 + CGFloat(comment.mediaUrls.count) * 126.0
                let originYForMediaStack = (comment.comment == "") ? CGFloat(0) : CGFloat(8)

                if comment.mediaUrls.count > 0 {
                    height += CGFloat(comment.mediaUrls.count - 1) * 8 + originYForMediaStack // top margin and space between imageviews
                }

                return CGSize(width: SCREEN_WIDTH, height: height + 32) // final time & action buttons

            } else {
                let reply = anyComment as! ReplyModel
                let estimatedFrame = (reply.userNameDisplay + " " + reply.commentDisplay).heightForString(REPLY_PREFERRED_WIDTH)
                var height = (reply.reply == "") ? CGFloat(reply.mediaUrls.count) * 126.0 : estimatedFrame.height + 20 + CGFloat(reply.mediaUrls.count) * 126.0
                let originYForMediaStack = (reply.reply == "") ? CGFloat(0) : CGFloat(8)

                if reply.mediaUrls.count > 0 {
                    height += CGFloat(reply.mediaUrls.count - 1) * 8 + originYForMediaStack // top margin and space between imageviews
                }

                return CGSize(width: SCREEN_WIDTH, height: height + 32) // time & action buttons
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        // safeArea - 20 - Navigation(52) - 10
        case 0: return UIEdgeInsets(top: 82 + UIApplication.safeAreaTop(), left: 0, bottom: 0, right: 0)
        case 1, 2: return UIEdgeInsets.zero
        default: return UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        }
    }
}

// MARK: - TTGTextTagCollectionViewDelegate
extension PostDetailViewController: TTGTextTagCollectionViewDelegate {
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTapTag tagText: String!, at index: UInt, selected: Bool, tagConfig config: TTGTextTagConfig!) {
        let indexForTagsView = textTagCollectionView.tag
        guard indexForTagsView >= 0,
              variations.count > indexForTagsView else { return }
        
        if let lastSelected = variations[indexForTagsView].selected,
           lastSelected != index {
            textTagCollectionView.setTagAt(UInt(lastSelected), selected: false)
        }
        
        variations[indexForTagsView].selected = selected ? Int(index) : nil
    }
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, canTapTag tagText: String!, at index: UInt, currentSelected: Bool) -> Bool {
        return !isOwnPost
    }
}

// MARK: - ReplyNameViewDelegate
extension PostDetailViewController: ReplyNameViewDelegate {
    
    func didTapClose() {
        finishPost()
    }
}

// MARK: - ImagePickerControllerDelegate
extension PostDetailViewController: ImagePickerSheetControllerDelegate {
    
    func controllerWillEnlargePreview(_ controller: ImagePickerSheetController) {
        debugPrint("Will enlarge the preview")
    }
    
    func controllerDidEnlargePreview(_ controller: ImagePickerSheetController) {
        debugPrint("Did enlarge the preview")
    }
    
    func controller(_ controller: ImagePickerSheetController, willSelectAsset asset: PHAsset) {
        debugPrint("Will select an asset")
    }
    
    func controller(_ controller: ImagePickerSheetController, didSelectAsset asset: PHAsset) {
        debugPrint("Did select an asset")
    }
    
    func controller(_ controller: ImagePickerSheetController, willDeselectAsset asset: PHAsset) {
        debugPrint("Will deselect an asset")
    }
    
    func controller(_ controller: ImagePickerSheetController, didDeselectAsset asset: PHAsset) {
        debugPrint("Did deselect an asset")
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension PostDetailViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let comment = inputBar.inputTextView.text!
        
        var attachments = [UIImage]()
        for attachment in attachmentManager.attachments {
            if case AttachmentManager.Attachment.image(let image) = attachment {
                attachments.append(image)
            }
        }
        
        startPost(withComment: comment, attachments: attachments)
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        // Adjust content insets
//        tableView.contentInset.bottom = size.height + 300 // keyboard size estimate
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
    }
}

// MARK: - AttachmentManagerDelegate
extension PostDetailViewController: AttachmentManagerDelegate {
    
    func attachmentManager(_ manager: AttachmentManager, shouldBecomeVisible: Bool) {
        setAttachmentManager(active: shouldBecomeVisible)
    }
    
    func attachmentManager(_ manager: AttachmentManager, didReloadTo attachments: [AttachmentManager.Attachment]) {
        let attachedCount = manager.attachments.count
        inputBar.sendButton.isEnabled = attachedCount > 0
        
        if attachedCount < 3 {
            attachmentManager.showAddAttachmentCell = true
            
        } else {
            attachmentManager.showAddAttachmentCell = false
        }
    }
    
    func attachmentManager(_ manager: AttachmentManager, didInsert attachment: AttachmentManager.Attachment, at index: Int) {
        let attachedCount = manager.attachments.count
        inputBar.sendButton.isEnabled = attachedCount > 0
        
        if attachedCount < 3 {
            attachmentManager.showAddAttachmentCell = true
            
        } else {
            attachmentManager.showAddAttachmentCell = false
        }
    }
    
    func attachmentManager(_ manager: AttachmentManager, didRemove attachment: AttachmentManager.Attachment, at index: Int) {
        let attachedCount = manager.attachments.count
        inputBar.sendButton.isEnabled = attachedCount > 0
        
        if attachedCount < 3 {
            attachmentManager.showAddAttachmentCell = true
            
        } else {
            attachmentManager.showAddAttachmentCell = false
        }
        
        if attachmentManager.attachments.count == 0 {
            // require to redraw contrainer
            // library issue - case add attachment, then input multiline text then delete attachments
            // it will stick container height
            self.inputBar.inputTextView.text = self.inputBar.inputTextView.text
        }
    }
    
    func attachmentManager(_ manager: AttachmentManager, didSelectAddAttachmentAt index: Int) {
        didTapCamera()
    }
    
    // MARK: - AttachmentManagerDelegate Helper
    func setAttachmentManager(active: Bool) {
        let topStackView = inputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.removeArrangedSubview(attachmentManager.attachmentView)
            topStackView.layoutIfNeeded()
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension PostDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: {
            guard let picked = info[.editedImage] as? UIImage else {
                return
            }
            
            self.attachmentManager.handleInput(of: picked)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - NavigationViewDelegate
extension PostDetailViewController: NavigationViewDelegate {
    
    func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func didTapProfile() {
        // get rid of the post detail page
        guard var viewControllers = navigationController?.viewControllers,
            viewControllers.count > 1 else { return }
        viewControllers.removeLast()
        
        if let lastVC = viewControllers.last,
            lastVC is ExSlideMenuController {
            // The post detail page is from profile so user is trying to open the same profile always
            self.navigationController?.popViewController(animated: true)
            
        } else {
            let isBusiness = selectedPost.Post_Summerize.isBusinessPost
            
            if isOwnPost {
                SlideMenuOptions.contentViewScale = 1.0
                SlideMenuOptions.leftViewWidth = SCREEN_WIDTH - 104
                
                // profile controller
                let profileVC = ProfileViewController.instance()
                profileVC.isBusiness = isBusiness
                profileVC.isBusinessUser = g_myInfo.isBusiness
                profileVC.isOwnProfile = true
                
                // menu controller
                let menuVC = ProfileMenuViewController.instance()
                // uncomment this if the account is business user
                menuVC.isBusiness = isBusiness
                menuVC.isBusinessUser = g_myInfo.isBusiness                
                
                let slideController = ExSlideMenuController(mainViewController: profileVC, rightMenuViewController: menuVC)
                
                viewControllers.append(slideController)
                
            } else {
                let viewingUser = selectedPost.Poster_Info
                
                // profile controller
                let profileVC = ProfileViewController.instance()
                profileVC.viewingUser = viewingUser
                profileVC.isBusiness = isBusiness
                profileVC.isBusinessUser = viewingUser.isBusiness
                profileVC.isOwnProfile = false

                viewControllers.append(profileVC)
            }
            
            self.navigationController?.setViewControllers(viewControllers, animated: true)
        }
    }
    
    func didTapInfo() {
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35
        
        let post = selectedPost.Post_Summerize
        var heightForOptionSheet: CGFloat = 0
        if isOwnPost {
            if post.isPoll {
                // edit disabled for poll
                heightForOptionSheet = 60*3 + 32
                
            } else if post.isSale {
                heightForOptionSheet = 60*5 + 32
                
            } else {
                // sold-out or re-list disabled for others
                heightForOptionSheet = 60*4 + 32
            }
            
        } else {
            heightForOptionSheet = 60*5 + 32
        }
        
        configuruation.sheetSize = .fixed(heightForOptionSheet)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        let bottomSheetController = NBBottomSheetController(configuration: configuruation)
        
        /// show action sheet with options (Edit or Delete)
        let optionSheet = OptionSheetViewController.instance()
        optionSheet.isOwnPost = isOwnPost
        
        optionSheet.isPoll = post.isPoll
        
        optionSheet.isSale = post.isSale
        optionSheet.isSoldOut = post.isSoldOut
        
        optionSheet.isFollowing = isFollowing
        
        optionSheet.delegate = self
        
        bottomSheetController.present(optionSheet, on: self)
    }
}

// MARK: - PollVoteDelegate
extension PostDetailViewController: PollVoteDelegate {
    
    func vote(forOption index: Int, completion: @escaping (Bool, PostModel?) -> Void) {
        // check if user already voted
        let ownID = g_myInfo.ID
        
        let postToVote = selectedPost.Post_Summerize
        
        var voted = false
        for option in postToVote.Post_PollOptions {
            if let _ = option.votes.firstIndex(of: ownID) {
                voted = true
                break
            }
        }
        
        guard !voted else {
            showErrorVC(msg: "You've already voted on this poll!")
            return
        }
        
        let value = postToVote.Post_PollOptions[index].value

        let params = [
            "token": g_myToken,
            "post_id": postToVote.Post_ID,
            "poll_value": value
        ]
        
        showIndicator()
        _ = ATB_Alamofire.POST(ADD_VOTE, parameters: params as [String : AnyObject], showLoading: false, showSuccess: false, showError: false) { (result, responseObject) in
            self.hideIndicator()

            if result {
                // add the new vote made
                self.selectedPost.Post_Summerize.Post_PollOptions[index].votes.append(ownID)
                
                let postObject = [
                    "postID": postToVote.Post_ID
                ]
                
                NotificationCenter.default.post(name: .PollVoted, object: postObject)
                
                completion(true, self.selectedPost.Post_Summerize)
            }
        }
    }
}

// MARK: - LikesInfoDelegate
extension PostDetailViewController: LikesInfoDelegate {
    
    func didTapLike() {
        guard !isOwnPost else {
            showErrorVC(msg: "You can not like your own post.")
            return
        }
        
        let postID = selectedPost.Post_Summerize.Post_ID
        let params = [
            "token" : g_myToken,
            "post_id" : postID
        ]
        
        var likeCount = selectedPost.Post_Summerize.Post_Likes.intValue
        if isLiked {
            likeCount -= 1
            
            // this is not required but for any wrong displayed
            if likeCount < 0 {
                likeCount = 0
            }
            
        } else {
            likeCount += 1
        }
        
        _ = ATB_Alamofire.POST(POST_LIKE_API, parameters: params as [String : AnyObject], showLoading: true, showSuccess: false, showError: false) { (result, responseObject) in
            print(responseObject)
            guard result else {
                self.showErrorVC(msg: "Something went wrong.\nPlease try again later")
                return
            }
            
            if result {
                self.selectedPost.Post_Summerize.Post_Likes = "\(likeCount)"
                self.isLiked = !self.isLiked
                
                DispatchQueue.main.async {
                    self.commentCollectionView.reloadItems(at: [IndexPath(row: 0, section: 1)])
                }
                
                let objectToPost = [
                    "postID": postID
                ]
                
                NotificationCenter.default.post(name: .PostLiked, object: objectToPost)
                
            } else {
                self.showErrorVC(msg: "Something went wrong.\nPlease try again later")
            }
        }
    }
    
    func didTapSave() {
        let params = [
            "token" : g_myToken,
            "post_id" : selectedPost.Post_Summerize.Post_ID
        ]
        
        _ = ATB_Alamofire.POST(ADD_USER_BOOKMARK, parameters: params as [String : AnyObject], showLoading: true, showSuccess: false, showError: false) { (result, responseObject) in
            guard result else {
                self.showErrorVC(msg: "Something went wrong.\nPlease try again later")
                return
            }

            self.isSaved = !self.isSaved
            
            let object = [
                "post": self.selectedPost.Post_Summerize
            ]
            
            NotificationCenter.default.post(name: self.isSaved ? .DidSavePost : .DiDDeleteSavedPost, object: object)

            DispatchQueue.main.async {
                self.commentCollectionView.reloadItems(at: [IndexPath(row: 0, section: 1)])
            }
        }
    }
}

// MARK: - ServiceInfoViewDelegate
extension PostDetailViewController: ServiceInfoViewDelegate {
    
    func didTapDeposit() {
        let dialogVC = ServiceInfoPopupViewController(nibName: "ServiceInfoPopupViewController", bundle: nil)
        dialogVC.isDeposit = true
        dialogVC.depositAmount = selectedPost.Post_Summerize.Post_Deposit.floatValue
        
        let popupDialog = PopupDialog(viewController: dialogVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: true, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(popupDialog, animated: true, completion: nil)
    }
    
    func didTapCancellations() {
        let dialogVC = ServiceInfoPopupViewController(nibName: "ServiceInfoPopupViewController", bundle: nil)
        dialogVC.isDeposit = false
        
        let popupDialog = PopupDialog(viewController: dialogVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: true, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(popupDialog, animated: true, completion: nil)
    }
    
    func didTapArea() {
        showLocationInMap()
    }
    
    func didTapInsurance() {
        guard !selectedPost.Post_Summerize.insuranceID.isEmpty,
              let insurance = selectedPost.Post_Summerize.insurance else { return }
        
        let dialogVC = InsurancePopupViewController(nibName: "InsurancePopupViewController", bundle: nil)
        dialogVC.isInsurance = true
        dialogVC.urlString = insurance.file
        
        let popupDialog = PopupDialog(viewController: dialogVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: true, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(popupDialog, animated: true, completion: nil)
    }
    
    func didTapQualification() {
        guard !selectedPost.Post_Summerize.qualificationID.isEmpty,
              let qualification = selectedPost.Post_Summerize.qualification else { return }
        
        let dialogVC = InsurancePopupViewController(nibName: "InsurancePopupViewController", bundle: nil)
        dialogVC.isInsurance = false
        dialogVC.urlString = qualification.file
        
        let popupDialog = PopupDialog(viewController: dialogVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: true, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(popupDialog, animated: true, completion: nil)
    }
}

// MARK: - SaleInfoViewDelegate
extension PostDetailViewController: SaleInfoViewDelegate {
    
    func didTapLocation() {
        showLocationInMap()
    }
    
    private func showLocationInMap() {
        guard let locationVC = PostLocationViewController.instance() else { return }
        let post = selectedPost.Post_Summerize
        
        locationVC.postLocation = CLLocation(latitude: post.Post_Position.latitude, longitude: post.Post_Position.longitude)
        locationVC.postAddress = post.Post_Location
        
        if post.Post_Type == "Service" {
            locationVC.strTitle = "Area Covered"
            
        } else {
            locationVC.strTitle = "Location"
        }
        
        self.navigationController?.pushViewController(locationVC, animated: true)
    }
}

// MARK: - ActionInPostDelegate
extension PostDetailViewController: ActionInPostDelegate {
    
    // buy a product or book a service
    func didTapLeft() {
        let selected = selectedPost.Post_Summerize
        
        guard isValidMakeTransaction() else { return }
        
        if selected.isSale {
            guard !selected.isSoldOut else {
                showInfoVC("ATB", msg: "The product is out of stock")
                return
            }
            
            if variations.count > 0 {
                // check only when a variant is selected
                if isVariantSelected() {
                    let vid = getSelectedVariant()
                    guard !vid.isEmpty else {
                        showInfoVC("ATB", msg: "The product variant is invalid!")
                        return
                    }
                    
                    guard isStockValid(forVariant: vid) else { return }
                    
                    selectDeliveryOption(forProduct: selected, vid: vid, quantity: 1)
                    return
                }
                
                // select variation
                selectVariation(forProduct: selected)
                
            } else {
                // select delivery option
                // with no variant, quantity 1
                selectDeliveryOption(forProduct: selected, vid: "", quantity: 1)
            }
            
        } else {
            // just to make sure that
            // The service is not posted by the user own
            // They have business profile
            let me = g_myInfo
            guard me.ID != selectedPost.Poster_Info.ID,
                  selectedPost.Poster_Info.isBusiness  else { return }

            let appointmentVC = AppointmentViewController.instance()
            appointmentVC.selectedService = selectedPost.Post_Summerize
            appointmentVC.business = selectedPost.Poster_Info.business_profile

            navigationController?.pushViewController(appointmentVC, animated: true)
        }
    }
    
    // add product to cart or chat with provider
    func didTapRight() {
        let selected = selectedPost.Post_Summerize
        
        if selected.isSale {
            guard isValidMakeTransaction() else { return }
            
            guard !selected.isSoldOut else {
                showInfoVC("ATB", msg: "The product is out of stock")
                return
            }
            
            if variations.count > 0 {
                // check only when a variant is selected
                if isVariantSelected() {
                    let vid = getSelectedVariant()
                    guard !vid.isEmpty else {
                        showErrorVC(msg: "The variant is invalid!")
                        return
                    }
                    
                    guard isStockValid(forVariant: vid) else { return }
                    
                    addItemToCart(selected, vid: vid)
                    return
                }
                
                selectVariation(forProduct: selected)
                
            } else {
                // add the product to cart
                // no variant
                addItemToCart(selected, vid: "")
            }
                        
        } else {
            chatWithSeller()
        }
    }
    
    private func chatWithSeller() {
        let conversationVC = ConversationViewController()
        
        let chatUser = selectedPost.Poster_Info
        if selectedPost.Post_Summerize.isBusinessPost && chatUser.isBusiness {
            conversationVC.userId = chatUser.business_profile.ID + "_" + chatUser.ID
            
        } else {
            conversationVC.userId = chatUser.ID
        }
        
        self.navigationController?.pushViewController(conversationVC, animated: true)
    }
    
    // when all variations is selected, returns true
    // otherwise, returns false
    private func isVariantSelected() -> Bool {
        for variation in variations {
            if let _ = variation.selected {
                continue
                
            } else {
                return false
            }
        }
        return true
    }
    
    // get the selected variant and return it's id
    private func getSelectedVariant() -> String {
        // get selected variation
        var attributes = [VariantAttribute]()
        for variation in variations {
            if let selected = variation.selected,
               variation.values.count > selected {
                let attribute = VariantAttribute()
                attribute.name = variation.name
                attribute.value = variation.values[selected]
                
                attributes.append(attribute)
            }
        }
        
        let sortedAttributes = attributes.sorted { $0.value.localizedCaseInsensitiveCompare($1.value) == .orderedAscending }
        
        var selectedAttributes = ""
        for attribute in sortedAttributes {
            selectedAttributes += attribute.value
        }
        
        let selectedProduct = selectedPost.Post_Summerize
        for productVariant in selectedProduct.productVariants {
            guard !productVariant.id.isEmpty else { continue }
            
            let sortedProductAttributes = productVariant.attributes.sorted {
                $0.value.localizedCaseInsensitiveCompare($1.value) == .orderedAscending
            }
            
            var allProductAttributes = ""
            for productAttribute in sortedProductAttributes {
                allProductAttributes += productAttribute.value
            }
            
            if allProductAttributes == selectedAttributes {
                return productVariant.id
            }
        }
        
        return ""
    }
    
    private func isStockValid(forVariant vid: String) -> Bool {
        let selectedProduct = selectedPost.Post_Summerize
        let productVariants = selectedProduct.productVariants
        guard let selectedVariant = productVariants.first(where: { $0.id == vid }),
              selectedVariant.stock_level.intValue > 0 else {
            showAlert("ATB", message: "The product is out of stock!", positive: "Ok", positiveAction: nil, preferredStyle: .actionSheet)
            return false
        }
        
        return true
    }
    
    // no need to be checked, however, the business was approved and made a post using their business account
    // later admin disable the business
    // It'd be better to handle in the backend by removing their business posts
    private func isValidMakeTransaction() -> Bool {
        let selected = selectedPost.Post_Summerize
        guard selected.isBusinessPost else { return true }
        
        let poster = selectedPost.Poster_Info
        guard poster.isBusinessApproved else {
            showAlert("ATB", message: "Admin is currently reviewing the business!\nPlease wait until they get approved, we always value your experience on ATB.", positive: "Ok", positiveAction: nil, preferredStyle: .actionSheet)
            return false
        }
        
        return true
    }
    
    private func selectVariation(forProduct product: PostModel) {
        // check product id is valid
        guard let pid = product.pid,
              !pid.isEmpty else {
            showErrorVC(msg: "The product is invalid!")
            return
        }
        
        // calculate the height
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35
        
        // 24 + 100 + 20 + 1 + 20 + 16*2 + 60 + 34
        var height: CGFloat = 291
        height += "Before you continue....".heightForString(SCREEN_WIDTH-40, font: UIFont(name: Font.SegoeUISemibold, size: 22)).height
        height += "Please select the following variations to complete your order".heightForString(SCREEN_WIDTH-40, font: UIFont(name: Font.SegoeUILight, size: 15)).height
        height += 4 // add an experienced value
        height -= UIApplication.safeAreaBottom()
        
        height += 91*CGFloat(variations.count)
        height += 10*CGFloat(variations.count-1)
        
        if height > (SCREEN_HEIGHT - 44) {
            height = SCREEN_HEIGHT - 44
        }
        
        configuruation.sheetSize = .fixed(height)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        let sheetController = NBBottomSheetController(configuration: configuruation)
        
        let variationVC = SelectVariationViewController.instance()
        
        variationVC.selectedProduct = product
        variationVC.variations = variations
        variationVC.delegate = self
        
        sheetController.present(variationVC, on: self)
    }
    
    // add item to cart
    private func addItemToCart(_ item: PostModel, vid: String) {
        // check product id is valid
        guard let pid = item.pid,
              !pid.isEmpty else {
            showErrorVC(msg: "The product is invalid!")
            return
        }
        
        showIndicator()
        APIManager.shared.addItemInCart(g_myToken, pid: pid, vid: vid.isEmpty ? "0" : vid) { (result, message, cartInfo) in
            self.hideIndicator()

            guard result,
                  let cartInfo = cartInfo else {
                self.showErrorVC(msg: "It's been failed to add the product to your cart!")
                return
            }
            
            let quantity = cartInfo.1
            self.showInstantCart(withProduct: item, vid: vid, quantity: quantity)
        }
    }
    
    // shows instant cart
    private func showInstantCart(withProduct product: PostModel, vid: String, quantity: Int) {
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35
        
        configuruation.sheetSize = .fixed(200)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        let sheetController = NBBottomSheetController(configuration: configuruation)
        
        let instantCart = InstantCartViewController.instance()
        
        instantCart.cartItem = product
        instantCart.vid = vid
        instantCart.quantity = quantity
        instantCart.delegate = self
        
        sheetController.present(instantCart, on: self)
    }
}

// MARK: - InstantCartDelegate
extension PostDetailViewController: InstantCartDelegate {
    
    func buyProduct(_ product: PostModel, vid: String, quantity: Int) {
        // select delivery option
        selectDeliveryOption(forProduct: product, vid: vid, quantity: quantity)
    }
    
    // select delivery option
    private func selectDeliveryOption(forProduct product: PostModel, vid: String, quantity: Int) {
        // check product id is valid
        guard let pid = product.pid,
              !pid.isEmpty else {
            showErrorVC(msg: "The product is invalid!")
            return
        }
        
        // calculate the height
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35
       
        let height: CGFloat = 380 - UIApplication.safeAreaBottom()
        
        configuruation.sheetSize = .fixed(height)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        let sheetController = NBBottomSheetController(configuration: configuruation)
        
        let deliveryVC = SelectDeliveryViewController.instance()
        // sheet configuration for UI
        deliveryVC.configuration = configuruation
        
        deliveryVC.selectedProduct = product
        deliveryVC.vid = vid
        deliveryVC.quantity = quantity
        
        // set the delegate
        deliveryVC.delegate = self
        
        sheetController.present(deliveryVC, on: self)
    }
}

// MARK: SelectVariationDelegate
extension PostDetailViewController: SelectVariationDelegate {
    
    func didAddItemToCart(_ product: PostModel, vid: String, quantity: Int) {
        showInstantCart(withProduct: product, vid: vid, quantity: quantity)
    }
    
    func willBuyProduct(_ product: PostModel, vid: String, quantity: Int) {
        selectDeliveryOption(forProduct: product, vid: vid, quantity: quantity)
    }
    
    @objc private func didSelectVariant(_ notification: Notification) {
        DispatchQueue.main.async {
            // reload variation with new selected
            self.commentCollectionView.reloadSections([2])
        }
    }
}
                
// MARK: - SelectDeliveryDelegate
extension PostDetailViewController: SelectDeliveryDelegate {
    
    func purchaseProduct(_ product: PostModel, vid: String, quantity: Int, deliveryOption: Int) {
        let paymentVC = SelectPaymentViewController(nibName: "SelectPaymentViewController", bundle: nil)
        // send over payment parameters
        paymentVC.selectedProduct = product
        paymentVC.vid = vid
        paymentVC.quantity = quantity
        paymentVC.deliveryOption = deliveryOption
        
        paymentVC.delegate = self
        
        let popupDialog = PopupDialog(viewController: paymentVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(popupDialog, animated: true, completion: nil)
    }
}

// MARK: - SelectPaymentDelegate
extension PostDetailViewController: SelectPaymentDelegate {
    
    // paymentOption: 1 - PayPal, 2 - Cash
    func proceedPayment(forProduct product: PostModel, paymentOption: Int, vid: String, quantity: Int, deliveryOption: Int) {
        if paymentOption == 1 {
            payByPayPal(forProduct: product, vid: vid, quantity: quantity, deliveryOption: deliveryOption)
            
        } else {
            payWithCash(forProduct: product, vid: vid, quantity: quantity, deliveryOption: deliveryOption)
        }
    }
    
    private func payByPayPal(forProduct product: PostModel, vid: String, quantity: Int, deliveryOption: Int) {
        showIndicator()
        ATBBraintreeManager.shared.getBraintreeClientToken(g_myToken) { (result, message) in
            self.hideIndicator()
            
            guard result else {
                self.showErrorVC(msg: "Server returned the error message: " + message)
                return
            }
            
            let clientToken = message
            self.showDropIn(clientTokenOrTokenizationKey: clientToken, product: product, vid: vid, quantity: quantity, deliveryOption: deliveryOption)
        }
    }
    
    private func payWithCash(forProduct product: PostModel, vid: String, quantity: Int, deliveryOption: Int) {
        guard let productId = product.pid,
              !productId.isEmpty else { return }
        
        let isBusiness = product.isBusinessPost ? "1" : "0"
        let toUserId = selectedPost.Poster_Info.ID
        
        showIndicator()
        APIManager.shared.makeCashPayment(g_myToken, productId: productId, variantId: vid, deliveryOption: deliveryOption, quantity: quantity, toUserId: toUserId, isBusiness: isBusiness) { result in
            self.hideIndicator()
            
            switch result {
            case .success(let message):
                self.updateStock(vid: vid, quantity: quantity, paymentMethod: 1, showMessage: message)
                
            case .failure(let error):                
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    func contactSeller() {
        chatWithSeller()
    }
    
    private func showDropIn(clientTokenOrTokenizationKey: String, product: PostModel, vid: String, quantity: Int, deliveryOption: Int) {
        let request = BTDropInRequest()
        request.vaultManager = true
        request.cardDisabled = true
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request) { (controller, result, error) in
            controller.dismiss(animated: true, completion: nil)
            guard error == nil,
                  let result = result else {
                // show error
                self.showErrorVC(msg: "Failed to proceed your payment.\nPlease try again later!")
                
                return
            }
            
            guard !result.isCancelled,
                  let paymentMethod = result.paymentMethod else {
                // Payment has been cancelled by the user
                return
            }
            
            let nonce = paymentMethod.nonce
            self.showAlert("Payment Confirmation", message: "Would you like to proceed the payment?", positive: "Yes", positiveAction: { _ in
                switch result.paymentOptionType {
                case .payPal:
                    self.makePayment(forProduct: product, vid: vid, quantity: quantity, deliveryOption: deliveryOption, method: "Paypal", nonce: nonce)
                    
                case .masterCard,
                     .AMEX,
                     .dinersClub,
                     .JCB,
                     .maestro,
                     .visa:
//                    self.showErrorVC(msg: "You cannot use your card to pay for goods.")
                    self.makePayment(forProduct: product, vid: vid, quantity: quantity, deliveryOption: deliveryOption, method: "Card", nonce: nonce)
                    
                default: break
                }
                
            }, negative: "No", negativeAction: nil, preferredStyle: .actionSheet)
        }
        
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    private func makePayment(forProduct product: PostModel, vid: String, quantity: Int, deliveryOption: Int, method: String, nonce: String) {
        guard let pid = product.pid,
              !pid.isEmpty else { return }
        
        let isBusiness = product.isBusinessPost ? "1" : "0"
        let seller = selectedPost.Poster_Info.ID
        
        var params = [
            "token" : g_myToken,
            "customerId" : g_myInfo.bt_customer_id,
            "paymentMethod" : method,
            "paymentNonce" : nonce,
            "toUserId" : seller,
            "amount" : product.Post_Price,
            "quantity": "\(quantity)",
            "is_business": isBusiness,
            "delivery_option": "\(deliveryOption)"
        ]
        
        if !vid.isEmpty {
            params["variation_id"] = vid
            
        } else {
            params["product_id"] = pid
        }
        
        showIndicator()
        _ = ATB_Alamofire.POST(MAKE_PP_PAYMENT, parameters: params as [String: AnyObject], completionHandler: { (result, response) in
            self.hideIndicator()
            if result {
//                self.deletePurchasedItems(product, vid: vid)
                self.updateStock(vid: vid, quantity: quantity)
                
            } else {
                let msg = response.object(forKey: "msg") as? String ?? "Failed to proceed your payment, please try again!"
                self.showErrorVC(msg: msg)
            }
        })
    }
    
    // paymentMethod: 1 - pay with cash, 2 - pay by PayPal
    private func updateStock(vid: String, quantity: Int, paymentMethod: Int = 2, showMessage: String = "") {
        if vid.isEmpty {
            var stockLevel = selectedPost.Post_Summerize.stock_level.intValue
            stockLevel = stockLevel - quantity >= 0 ? stockLevel - quantity : 0
            
            selectedPost.Post_Summerize.stock_level = "\(stockLevel)"
            
            if stockLevel <= 0 {
                selectedPost.Post_Summerize.Post_Is_Sold = "1"
            }
            
        } else {
            guard let index = selectedPost.Post_Summerize.productVariants.firstIndex(where: { $0.id == vid }) else {
                return
            }
            
            var stockLevel = selectedPost.Post_Summerize.productVariants[index].stock_level.intValue
            stockLevel = stockLevel - quantity >= 0 ? stockLevel - quantity : 0
            
            selectedPost.Post_Summerize.productVariants[index].stock_level = "\(stockLevel)"
            
            var totalStocks = 0
            for variant in selectedPost.Post_Summerize.productVariants {
                totalStocks += variant.stock_level.intValue
            }
            
            if totalStocks <= 0 {
                selectedPost.Post_Summerize.Post_Is_Sold = "1"
            }
        }
        
        DispatchQueue.main.async {
            self.commentCollectionView.reloadSections([2])
        }
        
        guard let productId = selectedPost.Post_Summerize.pid,
              !productId.isEmpty else { return }
        
        let objectToPost: [String: Any] = [
            "product_id": productId,                // send product id seperately
            "updated": selectedPost.Post_Summerize  // use only post details to update product or post
        ]
        
        NotificationCenter.default.post(name: .ProductStockChanged, object: objectToPost)
        
        if paymentMethod == 2 {
            self.didCompletePurchase(forProduct: selectedPost.Post_Summerize)
            
        } else {
            // Pay with 'Cash'
            self.showAlert("ATB", message: showMessage, positive: "Contact Now", positiveAction: { _ in
                self.chatWithSeller()
                
            }, negative: "No, later", negativeAction: nil, preferredStyle: .actionSheet)
        }
    }
    
    private func deletePurchasedItems(_ item: PostModel, vid: String) {
        guard let pid = item.pid,
              !pid.isEmpty else { return }
        
        APIManager.shared.deleteItemInCart(g_myToken, pid: pid, vid: vid.isEmpty ? "0" : vid, isAll: true) { (result, message) in
            self.hideIndicator()
            
            self.didCompletePurchase(forProduct: item)
        }
    }
    
    private func didCompletePurchase(forProduct product: PostModel) {
        let completedVC = PurchaseCompletedViewController(nibName: "PurchaseCompletedViewController", bundle: nil)
        completedVC.purchasedItem = product
        completedVC.delegate = self
        
        let popupDialog = PopupDialog(viewController: completedVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(popupDialog, animated: true, completion: nil)
    }
}
                
// MARK: - PurchaseCompleteDelegate
extension PostDetailViewController: PurchaseCompleteDelegate {
    
    func viewPurchases() {
        // redirect to PurchasesViewController
        let purchasesVC = PurchasesViewController.instance()
        purchasesVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(purchasesVC, animated: true)
    }
    
    func keepBuying() {
        // Do any additional things if redirection is required
    }
}

// MARK: OptionSheetDelegate
extension PostDetailViewController: OptionSheetDelegate {
    
    func didTapReport() {
        submitReport(.POST, reportId: selectedPost.Post_Summerize.Post_ID)
    }
    
    func didTapBlock() {
        
    }
    
    func didTapFollow() {
        let url = isFollowing ? DELETE_FOLLOWER : ADD_FOLLOW
        
        // follow - always me, follower - always others
        let followUserID = g_myInfo.ID
//        let followBusinessID = g_myInfo.isBusiness ? g_myInfo.business_profile.ID : "0"
        // follow others with only my user account - this will always be '0'
        // no mean, no effect to filter
//        let followBusinessID = "0"
        
        let followerUserID = selectedPost.Poster_Info.ID
//        let isBusiness = selectedPost.Post_Summerize.Poster_Account_Type == "Business"
//        let followerBusinessID = isBusiness ? selectedPost.Poster_Info.business_profile.ID : "0"
        
        var params = [
            "token": g_myToken,
            "follow_user_id": followUserID,
            "follower_user_id": followerUserID
        ]
        
        if !isFollowing {
//            params["follow_business_id"] = followBusinessID
            params["follow_business_id"] = "0"
//            params["follower_business_id"] = followerBusinessID
            params["follower_business_id"] = "0"
        }
        
        showIndicator()
        _ = ATB_Alamofire.POST(url, parameters: params as [String: AnyObject], showLoading: false, showSuccess: false, showError: false, completionHandler: { (result, responseObject) in
            self.hideIndicator()
            
            if self.isFollowing {
                if result {
                    self.showSuccessVC(msg: "You removed this follow!")
                    self.isFollowing = false
                    g_myInfo.followCount = ((g_myInfo.followCount - 1) > 0 ? (g_myInfo.followCount - 1) : 0)
                    
                } else {
                    self.showErrorVC(msg: "Failed to remove follow, please try again later.")
                }
                
            } else {
                if result {
                    self.showSuccessVC(msg: "You are following this user!")
                    self.isFollowing = true
                    
                    g_myInfo.followCount += 1
                    
                } else {
                    self.showErrorVC(msg: "Failed to add follow, please try again later.")
                }
            }
        })
    }
    
    func didTapSold() {
        guard let productId = selectedPost.Post_Summerize.pid,
              !productId.isEmpty else { return }
        
        let params = [
            "token" : g_myToken,
            "product_id" : productId
        ]
        
        let isSoldOut = selectedPost.Post_Summerize.isSoldOut
        let url = isSoldOut ? RELIST : SET_SOLD
        
        _ = ATB_Alamofire.POST(url, parameters: params as [String : AnyObject], showLoading: true) { (result, response) in
            if result {
                self.showSuccessVC(msg: isSoldOut ? "Item re-listed." : "Item sold.")
                self.didSetItemSold(!isSoldOut)
                
            } else {
                let message = response.object(forKey: "msg") as? String ?? (isSoldOut ? "It's been failed to re-list the item.": "It's been failed to set item as sold, please try again.")
                self.showErrorVC(msg: message)
            }
        }
    }
    
    private func didSetItemSold(_ isSoldOut: Bool) {
        guard let productId = selectedPost.Post_Summerize.pid,
              !productId.isEmpty else { return }
        
        selectedPost.Post_Summerize.Post_Is_Sold = isSoldOut ? "1" : "0"
        if isSoldOut {
            if selectedPost.Post_Summerize.productVariants.count > 0 {
                for i in 0 ..< selectedPost.Post_Summerize.productVariants.count {
                    selectedPost.Post_Summerize.productVariants[i].stock_level = "0"
                }
                
            } else {
                selectedPost.Post_Summerize.stock_level = "0"
            }
            
        } else {
            if selectedPost.Post_Summerize.productVariants.count > 0 {
                for i in 0 ..< selectedPost.Post_Summerize.productVariants.count {
                    selectedPost.Post_Summerize.productVariants[i].stock_level = "1"
                }
                
            } else {
                selectedPost.Post_Summerize.stock_level = "1"
            }
        }
        
        DispatchQueue.main.async {
            self.commentCollectionView.reloadItems(at: [IndexPath(row: 0, section: 2)])
        }
        
        let objectToPost: [String: Any] = [
            "product_id": productId,                // send product id seperately
            "updated": selectedPost.Post_Summerize  // use only post details to update product or post
        ]
        
        NotificationCenter.default.post(name: .ProductStockChanged, object: objectToPost)
    }
    
    func didTapDelete() {
        let alert = UIAlertController(title: "Delete Post", message: "Would you like to remove this post?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
            self.deletePost()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.view.tintColor = .colorPrimary
        self.present(alert, animated: true, completion: nil)
    }
    
    func didTapEdit() {
        let post = selectedPost.Post_Summerize
        if post.isAdvice {
            let editAdvice = EditAdviceViewController.instance()
            editAdvice.editingPost = selectedPost.Post_Summerize
            
            self.navigationController?.pushViewController(editAdvice, animated: true)
            
        } else if post.isSale {
            let editProduct = EditProductViewController.instance()
            editProduct.isEditingPost = true
            editProduct.editingProduct = selectedPost.Post_Summerize
            
            self.navigationController?.pushViewController(editProduct, animated: true)
            
        } else if post.isService {
            let editService = EditServiceViewController.instance()
            editService.isEditingPost = true
            editService.editingService = selectedPost.Post_Summerize
            
            self.navigationController?.pushViewController(editService, animated: true)
        }
    }
    
    func didTapCopyLink() {
        
    }
    
    func didTapShare() {
        let lp = BranchLinkProperties()
        lp.addControlParam("$ios_url", withValue: "https://itunes.apple.com/app/id1501095031")
        lp.addControlParam("nav_here", withValue: selectedPost.Post_Summerize.Post_ID)
        lp.addControlParam("nav_type", withValue: "0")
        
        let identifier = selectedPost.Post_Summerize.Post_ID
        let buo = BranchUniversalObject(canonicalIdentifier: "content/\(identifier))")
        buo.title = selectedPost.Post_Summerize.Post_Title.capitalizingFirstLetter
        buo.contentDescription = selectedPost.Post_Summerize.Post_Text
        if selectedPost.Post_Summerize.Post_Media_Urls.count > 0 {
            buo.imageUrl = selectedPost.Post_Summerize.Post_Media_Urls[0]
        }
        buo.publiclyIndex = true
        buo.locallyIndex = true
                
        buo.getShortUrl(with: lp) { (url, error) in
            guard let url = url,
                  let deepLink = URL(string: url) else { return }

            print(url)
            let items: [Any] = [deepLink]

            let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self.present(avc, animated: true)
        }
    }
    
    private func submitReport(_ type: REPORT_TYPE, reportId: String) {
        let reportVC = ReportViewController.instance()
        reportVC.reportType = type
        reportVC.reportId = reportId
        
        self.present(reportVC, animated: true, completion: nil)
    }
    
    private func deletePost() {
        let params = [
            "token" : g_myToken,
            "post_id" : selectedPost.Post_Summerize.Post_ID
        ]

        showIndicator()
        _ = ATB_Alamofire.POST(DELETE_POST, parameters: params as [String : AnyObject]) { (result, responseObject) in
            self.hideIndicator()

            if result {
                self.navigationController?.popViewController(animated: true)
                
                // Post notification
                NotificationCenter.default.post(name: .DidDeletePost, object: nil, userInfo: ["post_id" : self.selectedPost.Post_Summerize.Post_ID])
                
            } else {
                self.showErrorVC(msg: "Failed to delete post, please try again later.")
            }
        }
    }
}
