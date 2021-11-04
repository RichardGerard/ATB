//
//  EditAdviceViewController.swift
//  ATB
//
//  Created by YueXi on 3/12/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import DropDown
import BMPlayer
import OpalImagePicker
import Photos
import NBBottomSheet

class EditAdviceViewController: BaseViewController {
    
    static let kStoryboardID = "EditAdviceViewController"
    class func instance() -> EditAdviceViewController {
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: EditAdviceViewController.kStoryboardID) as? EditAdviceViewController {
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
    }}
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var profileImgView: RoundImageView!
    
    @IBOutlet weak var profileSelectContainer: UIView!
    @IBOutlet weak var imvSelectArrow: UIImageView! { didSet {
        imvSelectArrow.layer.cornerRadius = 11
        imvSelectArrow.layer.masksToBounds = true
        if #available(iOS 13.0, *) {
            imvSelectArrow.image = UIImage(systemName: "arrow.up.arrow.down.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvSelectArrow.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var optionMedia: RoundDropDown!
    var mediaOptions = ["Text", "Image", "Video"]
    
    // media attachment
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var imgMedia: UIImageView!           // the 1st selected image display
    @IBOutlet weak var list_media: UITableView!         // selected image display
    
    @IBOutlet weak var mediaContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var mediaWidth: NSLayoutConstraint!
    
    // add mark UIImageView
    // will show different icons based on whether video or image is selected
    @IBOutlet weak var imgAddMark: UIImageView!
    
    @IBOutlet weak var txtTitle: FocusTextField!
    @IBOutlet weak var txtDescription: RoundShadowTextView!
    @IBOutlet weak var optionCategory: RoundDropDown!
    
    @IBOutlet weak var btnUpdate: RoundedShadowButton!
    
    // used for camera action
    lazy var photoPicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        return picker
    }()
    
    var users:[UserModel] = []
    var selectedUser: UserModel!
    
    // editing image index
    var editingImageIndex:Int = 0
    // selected photos for the post
    var selectedPhotos: [Any] = []
    
    // selected video for the post
    var selectedVideo: Any? = nil
    var selectedVideoURL: URL? = nil
    
    var editingPost: PostModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpgradeAccount(_:)), name: .DidUpgradeAccount, object: nil)
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
        initUserOption()

        initDropDownOptions()
        
        lblTitle.text = "Edit Advice"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 26)
        lblTitle.textColor = .colorGray2
        
        txtDescription.placeHolderText = "Add a description"
        
        mediaContainer.layer.cornerRadius = 8
        mediaContainer.layer.masksToBounds = true
        
//        mediaContainerHeight.constant = 0
        
        // add a long tap gesture on the media container
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action:  #selector(longPressed(_:)))
        longPressRecognizer.cancelsTouchesInView = false
        mediaContainer.addGestureRecognizer(longPressRecognizer)
        
        // set initital values with the editing post
        var mediaType = 0
        switch editingPost.Post_Media_Type {
        case "Image": mediaType = 1
        case "Video": mediaType = 2
        default: mediaType = 0  // "Text"
        }
        
        optionMedia.dropDown.selectRow(mediaType)
        optionMedia.text = editingPost.Post_Media_Type
        
        if editingPost.Post_Media_Urls.count > 0 {
            if editingPost.isVideoPost {
                let videoURL = editingPost.Post_Media_Urls[0]
                selectedVideo = videoURL
                selectedVideoURL = URL(string: videoURL)
                
            } else {
                for mediaUrl in editingPost.Post_Media_Urls {
                    selectedPhotos.append(mediaUrl)
                }
            }
        }
        
        initMediaView(withMediaType: mediaType)
        
        txtTitle.text = editingPost.Post_Title
        
        txtDescription.setText(text: editingPost.Post_Text)
        
        optionCategory.text = editingPost.Post_Category
        let categoryOptions = g_StrFeeds.filter{ $0 != "My ATB" }
        if let index = categoryOptions.firstIndex(where: { $0 == editingPost.Post_Category }) {
            optionCategory.dropDown.selectRow(index)
        }
        
        btnUpdate.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 19)
        btnUpdate.setTitle("UPDATE", for: .normal)
    }
    
    // init user options for account selection
    private func initUserOption() {
        users.removeAll()
        
        let normalUser = UserModel()
        normalUser.user_type = "User"
        normalUser.ID = g_myInfo.ID
        normalUser.user_name = g_myInfo.userName
        normalUser.profile_image = g_myInfo.profileImage
        users.append(normalUser)
        
        if g_myInfo.isBusiness {
            let businessUser = UserModel()
            businessUser.user_type = "Business"
            businessUser.ID = g_myInfo.business_profile.ID
            businessUser.user_name = g_myInfo.business_profile.businessProfileName
            businessUser.profile_image = g_myInfo.business_profile.businessPicUrl
            users.append(businessUser)
        }
        
        profileSelectContainer.isHidden = !g_myInfo.isBusiness
        
        if editingPost.isBusinessPost && g_myInfo.isBusiness {
            selectedUser = users[1]
            
        } else {
            selectedUser = users[0]
        }
        
        profileImgView.loadImageFromUrl(selectedUser.profile_image, placeholder: "profile.placeholder")
    }
    
    // set resource for media and category dropdowns
    private func initDropDownOptions() {
        optionMedia.dataStr = mediaOptions
        optionMedia.isSearchEnabled = false
        optionMedia.dropdownDelegate = self
        
        let categoryOptions = g_StrFeeds.filter{ $0 != "My ATB" }
        optionCategory.dataStr = categoryOptions
        optionCategory.dropdownDelegate = self
    }
        
    private func initMediaView(withMediaType mediaType: Int) {
        let screenWidth = UIScreen.main.bounds.width
        let viewWidth = screenWidth - 40
        let cellHeight = (viewWidth - 30) / 4
        let imgHeight = viewWidth - 10 - cellHeight
        
        switch mediaType {
        case 0, 1:
            removeVideoPlayer()
            
            if mediaType == 0 {
                self.mediaContainerHeight.constant = 0.0
                
            } else {
                mediaContainerHeight.constant = imgHeight
                mediaWidth.constant = imgHeight
                
                initImageMediaView()
            }
            break
            
        case 2:
            list_media.isHidden = true
            
            mediaContainerHeight.constant = imgHeight
            mediaWidth.constant = viewWidth
            
            initVideoMediaView()
            break
            
        default:
            break
        }
        
        self.view.layoutIfNeeded()
    }
     
    // init media select view for images
    private func initImageMediaView() {
        self.imgAddMark.image = UIImage(named: "addimage")
        
        if selectedPhotos.count > 0 {
            let first = selectedPhotos[0]
            if first is Data,
               let firstImgData = first as? Data {
                imgMedia.image = UIImage(data: firstImgData)
                
            } else {
                if let firstUrl = first as? String {
                    imgMedia.loadImageFromUrl(firstUrl, placeholder: "post.placeholder")
                }
            }
            
            imgAddMark.isHidden = true
            
        } else {
            imgMedia.image = nil
            imgAddMark.isHidden = false
        }
        
        list_media.isHidden = false
        
        list_media.reloadData()
        list_media.scroll(to: .top, animated: false)
    }
    
    // init media select view for video
    private func initVideoMediaView() {
        imgAddMark.image = UIImage(named: "videoadd")
        imgMedia.image = nil
        
        if let _ = selectedVideo {
            // hide add icon
            imgAddMark.isHidden = true
            
            // set up a video player
            let screenWidth = UIScreen.main.bounds.width
            let viewWidth = screenWidth - 40
            let cellHeight = (viewWidth - 30) / 4
            let viewHeight = viewWidth - 10 - cellHeight
            
            let player = BMPlayer(customControlView: BMPlayerCustomControlView())
            player.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
            
            if let selected = selectedVideoURL {
                let videoAsset = BMPlayerResource(url: selected, name: "")
                player.setVideo(resource: videoAsset)
            }

            let playerView = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight))
            playerView.tag = 1000
            mediaContainer.addSubview(playerView)
            
            playerView.addSubview(player)
            
        } else {
            // show add icon
            self.imgAddMark.isHidden = false
        }
    }
    
    private func removeVideoPlayer() {
        if let videoView = mediaContainer.viewWithTag(1000) {
            videoView.removeFromSuperview()
        }
    }
    
    @objc func longPressed(_ sender: UILongPressGestureRecognizer) {
        guard let optionMediaValue = optionMedia.getValue(),
              optionMediaValue == 2 else { return }
        
        addPostVideo()
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
        guard let optionMediaValue = optionMedia.getValue() else { return }
        
        if optionMediaValue == 1 {
            addPostImage(at: 0)
            
        } else if optionMediaValue == 2 {
            addPostVideo()
        }
    }
    
    private func addPostImage(at index: Int) {
        let maximumAllowed = selectedUser.isBusiness ? 9 : 3
        
        if selectedPhotos.count >= maximumAllowed,
           index >= maximumAllowed {
            let isBusiness = g_myInfo.isBusiness
            
            // check if the user is a business user
            if isBusiness {
                //  the user is a business user
                if selectedUser.isBusiness {
                    showInfoVC("ATB", msg: "You can only add upto \(maximumAllowed) images.")
                    
                } else {
                    alertToSwitchBusiness(forVideoPost: false)
                }
                
            } else {
                // the user is a none-business user
                alertToUpgradeBusiness(forVideoPost: false)
            }
            
            return
        }
        
        editingImageIndex = index > selectedPhotos.count ? selectedPhotos.count : index
        
        let alertController = UIAlertController(title: "", message: "What would you like to do?", preferredStyle: .actionSheet)
        
        // camera action
        let cameraTitle = "Take a photo from Camera."
        let cameraAction = UIAlertAction(title: cameraTitle, style: .default) { _ in
            self.photoPicker.sourceType = .camera
            self.photoPicker.cameraCaptureMode = .photo
            self.present(self.photoPicker, animated: true, completion: nil)
        }
        alertController.addAction(cameraAction)
        
        // Photo library action
        let libraryTitle = "Pick a photo from Photo Library"
        let libraryAction = UIAlertAction(title: libraryTitle, style: .default) { _ in
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
            
            let imagePicker = OpalImagePickerController()
            
            imagePicker.allowedMediaTypes = Set([PHAssetMediaType.image])
            // the allowed selections
            var maximumSelections = maximumAllowed - self.selectedPhotos.count
            if self.selectedPhotos.count > self.editingImageIndex {
                maximumSelections += 1 // plus 1 for replacing
            }
            // no need to check, but make sure that it's always greather than zero
            imagePicker.maximumSelectionsAllowed = maximumSelections > 0 ? maximumSelections : 1
            
            self.presentOpalImagePickerController(imagePicker, animated: true, select: { (assets) in
                imagePicker.dismiss(animated: true, completion: nil)
                
                // Select Assets
                let requestOptions = PHImageRequestOptions()
                requestOptions.isNetworkAccessAllowed = true
                requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
                requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                requestOptions.isSynchronous = true
                
                let totalSelected = assets.count
                for (assetIndex, asset) in assets.enumerated() {
                    PHImageManager.default().requestImage(for: asset , targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestOptions, resultHandler: { (pickedImage, info) in
                        guard let pickedImage = pickedImage else {
                            self.showErrorVC(msg: "The request has been failed to get the image!")
                            return
                        }
                        
                        guard let pickedImageData = pickedImage.jpegData(compressionQuality: 0.5) else {
                            // this will be exception - just return without handler
                            self.showErrorVC(msg: "JPEG conversion has been failed!")
                            return
                        }
                        
                        let editingIndex = self.editingImageIndex + assetIndex
                        if self.selectedPhotos.count > editingIndex {
                            if assetIndex == 0 {
                                // replace the 1st one with the original one
                                self.selectedPhotos[editingIndex] = pickedImageData
                                
                            } else {
                                // needs to be added
                                self.selectedPhotos.insert(pickedImageData, at: editingIndex)
                            }
                            
                        } else {
                            // just add
                            self.selectedPhotos.append(pickedImageData)
                        }
                        
                        if editingIndex == 0 {
                            DispatchQueue.main.async {
                                self.imgMedia.image = pickedImage
                                self.imgAddMark.isHidden = true
                            }
                            
                        } else {
                            if assetIndex+1 >= totalSelected {
                                DispatchQueue.main.async {
                                    self.list_media.reloadData()
                                }
                            }
                        }
                    })
                }
            }, cancel: {
                imagePicker.dismiss(animated: true, completion: nil)
            })
        }
        alertController.addAction(libraryAction)
        
        // add delete option
        if selectedPhotos.count > editingImageIndex {
            let deleteTitle = "Remove this photo from the post."
            let deleteAction = UIAlertAction(title: deleteTitle, style: .destructive) { _ in
                let alert = UIAlertController(title: "Alert", message: "Do you want to remove this photo from the post?", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    self.removePostImage(at: self.editingImageIndex)
                }))
                
                alert.addAction(UIAlertAction(title: "No", style: .default))
                alert.view.tintColor = .colorPrimary
                self.present(alert, animated: true)
            }
            
            alertController.addAction(deleteAction)
        }
        
        // cancel action
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.view.tintColor = .colorPrimary
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func removePostImage(at index: Int) {
        // index validation
        guard selectedPhotos.count > index else { return }
        
        selectedPhotos.remove(at: index)
        
        if selectedPhotos.count > 0 {
            let first = selectedPhotos[0]
            if first is Data,
               let firstImgData = first as? Data {
                imgMedia.image = UIImage(data: firstImgData)
                
            } else {
                if let firstUrl = first as? String {
                    imgMedia.loadImageFromUrl(firstUrl, placeholder: "post.placeholder")
                }
            }
            imgAddMark.isHidden = true
            
            list_media.reloadData()
            
        } else {
            imgMedia.image = nil
            imgAddMark.isHidden = true
        }
    }
    
    private func addPostVideo() {
        let isBusiness = g_myInfo.isBusiness
        
        // check user is a business
        guard isBusiness else {
            // the user is none-business user
            // show an alert to upgrade to a business account
            alertToUpgradeBusiness(forVideoPost: true)
            return
        }
        
        // check user selected their business profile
        guard selectedUser.isBusiness else {
            // show alert to switch to business profile
            alertToSwitchBusiness(forVideoPost: true)
            return
        }
        
        let alertController = UIAlertController(title: "", message: "What would you like to do?", preferredStyle: .actionSheet)
        
        if let _ = selectedVideo {
            // add an option to delete if a video was already added
            let deleteTitle = "Remove this video from the post."
            let deleteAction = UIAlertAction(title: deleteTitle, style: .destructive) { _ in
                let alert = UIAlertController(title: "Alert", message: "Do you want to remove this video from the post?", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                    self.removePostVideo()
                }))
                alert.addAction(UIAlertAction(title: "No", style: .default))
                alert.view.tintColor = .colorPrimary
                self.present(alert, animated: true)
            }
            
            alertController.addAction(deleteAction)
            
        } else {
            let cameraVideo = "Take video from your camera."
            let cameraAction = UIAlertAction(title: cameraVideo, style: .default) { _ in
                self.photoPicker.sourceType = .camera
                self.photoPicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
                self.photoPicker.cameraCaptureMode = .video
                self.present(self.photoPicker, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
            
            let libraryTitle = "Pick a video from your photo library."
            let libraryAction = UIAlertAction(title: libraryTitle, style: .default) { _ in
                self.photoPicker.sourceType = .savedPhotosAlbum
                self.photoPicker.mediaTypes = ["public.movie"]
                self.present(self.photoPicker, animated: true, completion: nil)
            }
            alertController.addAction(libraryAction)
        }
        
        // cancel action
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.view.tintColor = .colorPrimary
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func removePostVideo()  {
        removeVideoPlayer()
        selectedVideo = nil
        
        initVideoMediaView()
    }
    
    private func alertToSwitchBusiness(forVideoPost videoPost: Bool) {
        let title = (videoPost ? "To post a video, you need to use your business account!" : "You can't add more than 3 images using a normal account!") + "\nDo you want to switch to your business account?"
        
        let alert = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            // switch to business profile
            self.selectUser(1)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default))
        alert.view.tintColor = .colorPrimary
        self.present(alert, animated: true)
    }
    
    private func alertToUpgradeBusiness(forVideoPost videoPost: Bool) {
        let title = (videoPost ? "To post a video, you need to upgrade your account to business!" : "To post more than 3 images, you need to upgrade your account to business!") + "\nDo you want to upgrade now?"
        let alert = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            // upgrade
            self.gotoUpgrade()
        }))

        alert.addAction(UIAlertAction(title: "No", style: .default))
        alert.view.tintColor = .colorPrimary
        self.present(alert, animated: true)
    }
    
    private func gotoUpgrade() {
        let businessVC = BusinessSignViewController.instance()
        businessVC.isFromProfile = false
        
        let nav = UINavigationController(rootViewController: businessVC)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .overFullScreen
        
        self.present(nav, animated: true, completion: nil)
    }

    // transitioningDelgegate is a weak property
    // for dismissed protocol, we need to make it a class variable
    let sheetTransitioningDelegate = NBBottomSheetTransitioningDelegate()
    @IBAction func didTapProfile(_ sender: Any) {
        guard users.count > 1 else { return }
        
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35
        configuruation.sheetDirection = .top
        
        let heightForOptionSheet: CGFloat =  243 // (233 + 10 - cornerRaidus addition value)
        
        configuruation.sheetSize = .fixed(heightForOptionSheet)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        
        let topSheetController = NBBottomSheetController(configuration: configuruation, transitioningDelegate: sheetTransitioningDelegate)
        
        /// show action sheet with options (Edit or Delete)
        let selectVC = ProfileSelectViewController.instance()
        selectVC.users = users
        selectVC.selectedIndex = selectedUser.isBusiness ? 1 : 0
        selectVC.delegate = self
        
        topSheetController.present(selectVC, on: self)
    }
    
    private func isValid() -> Bool {
        guard let optionMediaValue = optionMedia.getValue() else {
            showErrorVC(msg: "Please select a media type")
            return false
        }

        if optionMediaValue == 1 && selectedPhotos.count <= 0 {
            showErrorVC(msg: "Please add images for your post.")
            return false
        }

        if optionMediaValue == 2 && selectedVideo == nil {
            showErrorVC(msg: "Please add a video for your post.")
            return false
        }

        if txtTitle.isEmpty() {
            showErrorVC(msg: "Please input the title.")
            return false
        }

        if txtDescription.isEmpty() {
            showErrorVC(msg: "Please input the description.")
            return false
        }

        guard let _ = optionCategory.getValue() else {
            showErrorVC(msg: "Please select a category.")
            return false
        }
        
        return true
    }
    
    @IBAction func didTapUpdate(_ sender: Any) {
        guard isValid() else { return }
        
        updateAdvice()
    }
    
    private func updateAdvice() {
        let media_type = optionMedia.getValue() ?? 0
        let posterType = selectedUser.isBusiness ? "1" : "0"
        
        var params = [
            "id": editingPost.Post_ID,
            "token" : g_myToken,
            "type" : "1",
            "media_type" : String(media_type),
            "profile_type" : posterType,
            "title" : self.txtTitle.text!,
            "description" : self.txtDescription.text!,
            "brand" : "",
            "price" : "0.00",
            "category_title" : self.optionCategory.text!,
            "item_title" : "",
            "payment_options" : "0",
            "location_id" : "",
            "delivery_option" : "0",
            "delivery_cost" : "0"
        ]
        
        if media_type == 1 {
            var post_img_uris = ""
            for selectedPhoto in selectedPhotos {
                if let url = selectedPhoto as? String {
                    post_img_uris += (url + ",")
                    
                } else {
                    post_img_uris += ("data" + ",")
                }
            }
            
            // remove the last comma
            post_img_uris = String(post_img_uris.dropLast())
            params["post_img_uris"] = post_img_uris
            
        } else if media_type == 2 {
            if let url = selectedVideo as? String {
                params["post_img_uris"] = url
                
            } else {
                params["post_img_uris"] = "data"
            }
        }
        
        showIndicator()
        ATB_Alamofire.shareInstance.upload(
            multipartFormData: { (multipartFormData) in
                var mediaFileIndex = 0
                
                if media_type == 1 {
                    for selectedPhoto in self.selectedPhotos {
                        if selectedPhoto is Data,
                           let photoData = selectedPhoto as? Data {
                            multipartFormData.append(photoData, withName: "post_imgs[\(mediaFileIndex)]", fileName: "img\(mediaFileIndex).jpg", mimeType: "image/jpeg")
                            mediaFileIndex = mediaFileIndex + 1
                        }
                    }

                } else if media_type == 2 {
                    if self.selectedVideo is Data,
                       let videoData = self.selectedVideo as? Data {
                        multipartFormData.append(videoData, withName: "post_imgs[0]", fileName: "vid0.mp4", mimeType: "video/mp4")
                    }
                }
                
                let contentDict = params
                for (key, value) in contentDict {
                    multipartFormData.append((value.data(using: .utf8)!), withName: key)
                }
            },
            to: UPDATE_POST_API,
            usingThreshold: multipartFormDataEncodingMemoryThreshold,
            method: .post,
            headers: nil,
            interceptor: nil,
            fileManager: FileManager.default
        ).responseJSON { (response) in
            self.hideIndicator()
            
            switch response.result {
            case .success(let JSON):
                let res = JSON as! NSDictionary
                if let ok = res["result"] as? Bool,
                   ok,
                   let adviceDict = res["extra"] as? NSDictionary {
                    let updatedPost = PostModel(info: adviceDict)
                    
                    self.didCompleteUpdatePost(with: updatedPost)
                    
                } else {
                    self.showErrorVC(msg: "Failed to update the post, please try again!")
                }
                
            case .failure(_):
                self.showErrorVC(msg: "Failed to update the post, please try again!")
            }
        }
    }
    
    private func didCompleteUpdatePost(with updated: PostModel) {
        // to get feed updated when the user gets to this page from profile
        // send the updated post through notification
        editingPost.update(withPost: updated)
        let object = [
            "updated": updated
        ]
        
        NotificationCenter.default.post(name: .DidUpdatePost, object: object)
        
        showAlert("ATB", message: "The post details has been updated successfully!", positive: "Ok", positiveAction: { _ in
            self.navigationController?.popViewController(animated: true)
            
        }, preferredStyle: .actionSheet)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func didUpgradeAccount(_ notification: Notification) {
        DispatchQueue.main.async {
            self.initUserOption()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - ProfileSelectDelegate
extension EditAdviceViewController: ProfileSelectDelegate {
    
    func profileSelected(_ selectedIndex: Int) {
        selectUser(selectedIndex)
    }
    
    // profile switch validation
    private func isValidToSwitchProfile(selected: UserModel) -> Bool {
        guard selected.isBusiness else { return true }
        
        // business profile has been selected
        let business = g_myInfo.business_profile
        guard business.isPaid else {
            alertToSubscribeBusiness()
            return false
        }
        
        return true
    }
    
    private func selectUser(_ selected: Int) {
        let newSelected = users[selected]
        
        guard isValidToSwitchProfile(selected: newSelected) else { return }
        
        selectedUser = newSelected
        
        profileImgView.loadImageFromUrl(selectedUser.profile_image, placeholder: "profile.placeholder")
        
        // new selected is user's normal profile - it's been changed from business profile
        // need to check selected photos, remove if it's more than 3
        if !selectedUser.isBusiness,
           selectedPhotos.count > 3 {
            for _ in 0 ..< selectedPhotos.count-3 {
                selectedPhotos.removeLast()
            }
        }
        
        // if media option is 'Image'
        // you need to reload media list tableview to change it's count
        if let mediaOptionValue = optionMedia.getValue(),
           mediaOptionValue == 1 {
            list_media.reloadData()
            list_media.scroll(to: .top, animated: false)
        }
    }
    
    private func alertToSubscribeBusiness() {
        let title = "You have not subscribed for your business account yet!\nWould you like to subscribe now?"
        let alert = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            // subscribe
            self.gotoSubscribe()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default))
        alert.view.tintColor = .colorPrimary
        self.present(alert, animated: true)
    }
    
    private func gotoSubscribe() {
        let subscribeVC = SubscribeBusinessViewController.instance()
        subscribeVC.modalPresentationStyle = .overFullScreen
        subscribeVC.delegate = self
        
        self.present(subscribeVC, animated: true, completion: nil)
    }
}

// MARK: - DropdownDelegate
extension EditAdviceViewController: DropdownDelegate {
    
    func dropdownValueChanged(dropDown: RoundDropDown) {
        switch dropDown {
        case optionMedia:
            guard let optionMediaValue = dropDown.getValue() else { return }
            
            initMediaView(withMediaType: optionMediaValue)
            break
            
        case optionCategory:
            break
            
        default:
            break
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EditAdviceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let optionMediaValue = optionMedia.getValue() else { return }
        
        if optionMediaValue == 1 {
            guard let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
                  let pickedImageData = pickedImage.jpegData(compressionQuality: 0.5) else { return }
            
            if selectedPhotos.count > editingImageIndex {
                // replace
                selectedPhotos[editingImageIndex] = pickedImageData
                
            } else {
                // add
                selectedPhotos.append(pickedImageData)
            }
            
            if editingImageIndex == 0 {
                imgMedia.image = pickedImage
                imgAddMark.isHidden = true
                
            } else {
                list_media.reloadData()
            }
            
        } else if optionMediaValue == 2  {
            guard let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL,
                  let data = try? Data(contentsOf: videoUrl) else { return }
            
            self.selectedVideoURL = videoUrl as URL
            self.selectedVideo = data as Data
            
            self.initVideoMediaView()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension EditAdviceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if selectedUser.isBusiness {
            return 9
            
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mediaCell = tableView.dequeueReusableCell(withIdentifier: "MediaTableViewCell", for: indexPath) as! MediaTableViewCell
        
        // configure the cell
        let index = indexPath.section + 1
        mediaCell.configureCell(with: selectedPhotos.count > index ? selectedPhotos[index] : nil)
        
        return mediaCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addPostImage(at: indexPath.section + 1)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let viewWidth = SCREEN_WIDTH - 40
        let cellHeight = (viewWidth - 30) / 4
        
        return cellHeight
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 10
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
    }
}

// MARK: - SubscriptionDelegate
extension EditAdviceViewController: SubscriptionDelegate {
    
    func didCompleteSubscription() {
        selectUser(1)
    }
    
    func didIncompleteSubscription() {
        
    }
}
