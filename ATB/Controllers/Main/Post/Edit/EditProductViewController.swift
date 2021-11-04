//
//  EditProductViewController.swift
//  ATB
//
//  Created by YueXi on 3/12/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import Photos
import OpalImagePicker
import BMPlayer
import Braintree
import BraintreeDropIn
import PopupDialog
import NBBottomSheet

class EditProductViewController: BaseViewController {
    
    static let kStoryboardID = "EditProductViewController"
    class func instance() -> EditProductViewController {
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: EditProductViewController.kStoryboardID) as? EditProductViewController {
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
    
    @IBOutlet weak var imvProfile: ProfileView! { didSet {
        imvProfile.borderWidth = 2
        imvProfile.borderColor = .colorPrimary
    }}
    
    // media type
    @IBOutlet weak var optionMedia: RoundDropDown!
    
    // media view
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var imgMedia: UIImageView!
    @IBOutlet weak var imgAddMark: UIImageView!
    
    @IBOutlet weak var list_media: UITableView! { didSet {
        list_media.separatorStyle = .none
        }}
    @IBOutlet weak var mediaContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var mediaWidth: NSLayoutConstraint!
    
    // form fields
    @IBOutlet weak var txtTitle: FocusTextField!
    @IBOutlet weak var txtDescription: RoundShadowTextView!
    
    @IBOutlet weak var txtBrand: FocusTextField!
    @IBOutlet weak var txtPrice: FocusTextField!
    @IBOutlet weak var optionCategory: RoundDropDown!
    @IBOutlet weak var optionCondition: RoundDropDown!
    @IBOutlet weak var noVariantStockContainer: UIView!
    @IBOutlet weak var txtStockLevel: FocusTextField! { didSet {
        txtStockLevel.placeholder = "Quantity"
    }}
    
    /// Variations
    @IBOutlet weak var variationContainer: UIView!
    @IBOutlet weak var imvVariationInfo: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvVariationInfo.image = UIImage(systemName: "questionmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvVariationInfo.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var tblVariations: IntrinsicTableView!
    @IBOutlet weak var btnAddVariation: UIButton!
    
    // Stock
    @IBOutlet weak var stockContainer: UIView!
    @IBOutlet weak var imvStockEnabled: UIImageView! { didSet {
        imvStockEnabled.tintColor = .colorPrimary
    }}
    @IBOutlet weak var lblManageStockTitle: UILabel! { didSet {
        lblManageStockTitle.text = "Manage Stock"
        lblManageStockTitle.font = UIFont(name: Font.SegoeUIBold, size: 17)
    }}
    @IBOutlet weak var lblStockErrorMessage: UILabel! { didSet {
        let exclamation = NSTextAttachment()
        if #available(iOS 13.0, *) {
            exclamation.image = UIImage(systemName: "exclamationmark.bubble.fill")?.withTintColor(.colorRed1)
        } else {
            // Fallback on earlier versions
        }
        exclamation.setImageHeight(height: 16, verticalOffset: -2)
        let attributedMessage = NSMutableAttributedString(string: " Your product has variations")
        attributedMessage.insert(NSAttributedString(attachment: exclamation), at: 0)
        lblStockErrorMessage.font = UIFont(name: Font.SegoeUISemibold, size: 16)
        lblStockErrorMessage.textColor = .colorRed1
        
        lblStockErrorMessage.attributedText = attributedMessage
    }}
    @IBOutlet weak var lblStockDescription: UILabel! { didSet {
        lblStockDescription.text = "A complete list of variations an options has been listed here based on the variations selected"
        lblStockDescription.font = UIFont(name: Font.SegoeUILight, size: 14)
        lblStockDescription.textColor = .mediumGray
        lblStockDescription.numberOfLines = 0
    }}
    
    @IBOutlet weak var tblStock: IntrinsicTableView!

    // payment options
    var paymentType: Int = 0
    @IBOutlet weak var lblCashOnCollection: UILabel!
    @IBOutlet weak var switchCashOnCollection: BorderedSwitch!
    @IBOutlet weak var lblPayPal: UILabel!
    @IBOutlet weak var switchPayPal: BorderedSwitch!
    
    // location
    @IBOutlet weak var txtLocation: FocusTextField!
    private var postLatitude: String = ""
    private var postLongitude: String = ""
    
    // delivery options
    var deliverType:Int = 0
    @IBOutlet weak var lblFreePostage: UILabel!
    @IBOutlet weak var switchFreePostage: BorderedSwitch!
    @IBOutlet weak var lblBuyerCollects: UILabel!
    @IBOutlet weak var switchBuyerCollects: BorderedSwitch!
    @IBOutlet weak var lblDeliver: UILabel!
    @IBOutlet weak var switchDeliver: BorderedSwitch!
    // delivery cost
    @IBOutlet weak var viewHeightDeliverCost: NSLayoutConstraint!
    @IBOutlet weak var viewDeliverCost: UIView!
    @IBOutlet weak var txtDeliverCost: FocusTextField!
    
    @IBOutlet weak var btnUpdate: RoundedShadowButton!
    
    // used for camera action
    lazy var photoPicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        return picker
    }()
    
    // editing image index
    var editingImageIndex: Int = 0
    // selected photos for the post
    var selectedPhotos: [Any] = []
    
    // selected video for the post
    var selectedVideo: Any? = nil
    var selectedVideoURL: URL? = nil
        
    var variants: [[String:String]] = []
    var productVariants = [ProductVariant]()
    
    var isEditingPost: Bool = false
    var editingProduct: PostModel!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
        lblTitle.text = isEditingPost ? "Edit a\nProduct Post" : "Edit a Product"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 26)
        lblTitle.textColor = .colorGray2
        lblTitle.numberOfLines = 2
        lblTitle.setLineSpacing(lineHeightMultiple: 0.75)
        
        let profileUrl = editingProduct.isBusinessPost ? g_myInfo.business_profile.businessPicUrl : g_myInfo.profileImage
        imvProfile.loadImageFromUrl(profileUrl, placeholder: "profile.placeholder")
                
        initDropDownOptions()
        
        // media view
        mediaContainer.layer.cornerRadius = 8
        mediaContainer.layer.masksToBounds = true
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action:  #selector(self.longPressed))
        longPressRecognizer.cancelsTouchesInView = false
        mediaContainer.addGestureRecognizer(longPressRecognizer)
        
        let mediaType = editingProduct.isVideoPost ? 1 : 0
        optionMedia.dropDown.selectRow(mediaType)
        optionMedia.text = editingProduct.Post_Media_Type
        
        if editingProduct.Post_Media_Urls.count > 0 {
            if editingProduct.isVideoPost {
                let videoURL = editingProduct.Post_Media_Urls[0]
                selectedVideo = videoURL
                selectedVideoURL = URL(string: videoURL)
                
            } else {
                for mediaUrl in editingProduct.Post_Media_Urls {
                    selectedPhotos.append(mediaUrl)
                }
            }
        }
        
        initMediaView(withMediaType: mediaType)
        
        txtTitle.text = editingProduct.Post_Title
        
        txtDescription.placeHolderText = "Add a description"
        txtDescription.setText(text: editingProduct.Post_Text)
        
        txtBrand.text = editingProduct.Post_Brand
        
        // Price
        let currencyImageView = UIImageView(frame: CGRect(x:  0, y: 0, width: self.txtPrice.frame.height * 0.6, height: self.txtPrice.frame.height * 0.6))
        let currencyImage = UIImage(named: "ico_paymentblue")
        currencyImageView.image = currencyImage;
        
        let costCurrencyImageView = UIImageView(frame: CGRect(x:  0, y: 0, width: self.txtDeliverCost.frame.height * 0.6, height: self.txtDeliverCost.frame.height * 0.6))
        costCurrencyImageView.image = currencyImage;
        
        let priceViewLeftPadding = UIView(frame: CGRect(x: self.txtPrice.frame.height * 0.2, y: 0, width: self.txtPrice.frame.height * 0.6, height: self.txtPrice.frame.height * 0.6))
        currencyImageView.center = priceViewLeftPadding.center
        priceViewLeftPadding.addSubview(currencyImageView)
        
        txtPrice.isLeftEnabled = true
        txtPrice.leftView = priceViewLeftPadding
        txtPrice.leftViewMode = .always
        txtPrice.isNumInput = true
        
        txtPrice.text = editingProduct.Post_Price.floatValue.priceString
        
        // category
        optionCategory.text = editingProduct.Post_Category
        let categoryOptions = g_StrFeeds.filter{ $0 != "My ATB" }
        if let index = categoryOptions.firstIndex(where: { $0 == editingProduct.Post_Category }) {
            optionCategory.dropDown.selectRow(index)
        }
        
        // condition
        optionCondition.text = editingProduct.Post_Condition
        if let index = conditions.firstIndex(where: { $0 == editingProduct.Post_Condition }) {
            optionCondition.dropDown.selectRow(index)
        }
        
        // Stock
        txtStockLevel.text = editingProduct.stock_level
        
        // Variations
        initVariation()
        
        tblVariations.separatorStyle = .none
        tblVariations.backgroundColor = .clear
        tblVariations.showsVerticalScrollIndicator = false
        tblVariations.bounces = false
        
        tblVariations.dataSource = self
        tblVariations.delegate = self
        
        btnAddVariation.setTitle(" Add a new Variation", for: .normal)
        btnAddVariation.setTitleColor(.white, for: .normal)
        btnAddVariation.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        if #available(iOS 13.0, *) {
            btnAddVariation.setImage(UIImage(systemName: "plus"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnAddVariation.tintColor = .white
        btnAddVariation.layer.cornerRadius = 5.0
        btnAddVariation.backgroundColor = .colorPrimary
        
        variationContainer.isHidden = !editingProduct.isBusinessPost
        
        noVariantStockContainer.isHidden = editingProduct.productVariants.count > 0
        
        // Stock
        tblStock.separatorStyle = .none
        tblStock.backgroundColor = .clear
        tblStock.showsVerticalScrollIndicator = false
        tblStock.bounces = false
        tblStock.allowsMultipleSelection = true
        tblStock.dataSource = self
        tblStock.delegate = self
        
        manageStockEnabled(true)
        
        lblStockErrorMessage.isHidden = true
                
        stockContainer.isHidden = editingProduct.productVariants.count <= 0
        
        // Location Field
        let textFieldHeight = txtLocation.bounds.height
        let circleHeight = textFieldHeight - 20
        
        let rightButtonView = UIView(frame: CGRect(x: -10, y: 0, width: textFieldHeight, height: textFieldHeight))
        rightButtonView.layer.cornerRadius = 5
        rightButtonView.backgroundColor = UIColor.clear
        
        let arrowButton = UIButton(type: .custom)
        arrowButton.setImage(UIImage(named: "location_arrow"), for: .normal)
        arrowButton.backgroundColor = .colorPrimary
        arrowButton.imageEdgeInsets = UIEdgeInsets(top: circleHeight/3.5, left: circleHeight/3.5, bottom: circleHeight/3.5, right: circleHeight/3.5)
        arrowButton.frame = CGRect(x: 10, y: CGFloat(10), width: circleHeight, height: circleHeight)
        arrowButton.layer.cornerRadius = 5
        rightButtonView.addSubview(arrowButton)
        
        txtLocation.isRightEnabled = true
        txtLocation.rightView = rightButtonView
        txtLocation.rightViewMode = .always
        txtLocation.delegate = self
        
        txtLocation.text = editingProduct.Post_Location
        
        // Payment Options
        switchCashOnCollection.setOn(editingProduct.isCashEnabled, animated: false)
        enableCashOption(editingProduct.isCashEnabled)
        
        switchPayPal.setOn(editingProduct.isPayPalEnabled, animated: false)
        enablePayPalOption(editingProduct.isPayPalEnabled)
        
        // Delivery Options
        switchFreePostage.setOn(editingProduct.isFreeEnabled, animated: false)
        enableFreePostage(editingProduct.isFreeEnabled)
        switchBuyerCollects.setOn(editingProduct.isCollectEnabled, animated: false)
        enableBuyerCollect(editingProduct.isCollectEnabled)
        switchDeliver.setOn(editingProduct.isDeliverEnabled, animated: false)
        enableWillDeliver(editingProduct.isDeliverEnabled)
        
        // Delivery Cost
        let costDeliverViewLeftPadding = UIView(frame: CGRect(x: self.txtDeliverCost.frame.height * 0.2, y: 0, width: self.txtDeliverCost.frame.height * 0.6, height: self.txtDeliverCost.frame.height * 0.6))
        costCurrencyImageView.center = costDeliverViewLeftPadding.center
        costDeliverViewLeftPadding.addSubview(costCurrencyImageView)
        
        txtDeliverCost.isLeftEnabled = true
        txtDeliverCost.leftView = costDeliverViewLeftPadding
        txtDeliverCost.leftViewMode = .always
        txtDeliverCost.isNumInput = true
        
        txtDeliverCost.text = editingProduct.deliveryCost.floatValue.priceString
        
        showDeliverCostView(editingProduct.isDeliverEnabled, animated: false)
        
        btnUpdate.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 19)
        btnUpdate.setTitle("UPDATE", for: .normal)
    }
    
    private let conditions = ["New", "Nearly New", "Used", "Damaged", "Broke"]
    private func initDropDownOptions() {
        optionMedia.dataStr = ["Image", "Video"]
        optionMedia.isSearchEnabled = false
        optionMedia.dropdownDelegate = self
        
        let categoryOptions = g_StrFeeds.filter{$0 != "My ATB"}
        optionCategory.dataStr = categoryOptions
        optionCategory.dropdownDelegate = self
        
        optionCondition.dataStr = conditions
        optionCondition.dropdownDelegate = self
    }
    
    private func initVariation() {
        guard editingProduct.productVariants.count > 0 else { return }
        
        let attributes = editingProduct.productVariants[0].attributes
        for attribute in attributes {
            var variant: [String: String] = [:]
            let name = attribute.name
            variant["attribute_name"] = name
            
            var values = [String]()
            
            for productVariant in editingProduct.productVariants {
                for variantAttribute in productVariant.attributes {
                    if variantAttribute.name == name,
                       values.firstIndex(of: variantAttribute.value) == nil {
                        values.append(variantAttribute.value)
                    }
                }
            }
            
            var attributeValues = ""
            for value in values {
                attributeValues += "," + value
            }
            
            variant["values"] = String(attributeValues.dropFirst())
            variants.append(variant)
        }
        
        // instead of assigning, append to avoid momory copy
        productVariants.removeAll()
        productVariants.append(contentsOf: editingProduct.productVariants)
    }
    
    func enableVariation(_ enabled: Bool) {
        variationContainer.isHidden = !enabled
        UIView.animate(withDuration: 0.35, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func initMediaView(withMediaType mediaType: Int) {
        let viewWidth = SCREEN_WIDTH - 40
        let cellHeight = (viewWidth - 30) / 4
        let imgHeight = viewWidth - 10 - cellHeight
        
        switch mediaType {
        case 0:
            mediaContainerHeight.constant = imgHeight
            mediaWidth.constant = imgHeight
            
            removeVideoPlayer()
            
            initImageMediaView()
            break
            
        case 1:
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
    
    private func initImageMediaView() {
        imgAddMark.image = UIImage(named: "addimage")
        
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
    
    private func initVideoMediaView() {
        imgAddMark.image = UIImage(named: "videoadd")
        imgMedia.image = nil
        
        if let _ = selectedVideo {
            imgAddMark.isHidden = true
            
            let screenWidth = UIScreen.main.bounds.width
            let viewWidth = screenWidth - 40
            let cellHeight = (viewWidth - 30) / 4
            let viewHeight = viewWidth - 10 - cellHeight
            
            let player = BMPlayer(customControlView: BMPlayerCustomControlView())
            player.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
            
            if let selected = selectedVideoURL{
                let videoAsset = BMPlayerResource(url: selected, name: "")
                player.setVideo(resource: videoAsset)
            }
            
            let playerView = UIView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight))
            playerView.tag = 1000
            mediaContainer.addSubview(playerView)
            
            playerView.addSubview(player)
            
        } else {
            self.imgAddMark.isHidden = false
        }
    }
    
    private func removeVideoPlayer() {
        if let videoView = self.mediaContainer.viewWithTag(1000) {
            videoView.removeFromSuperview()
        }
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        guard let selectedOption = optionMedia.getValue(),
            selectedOption == 1 else { return }

        addPostVideo()
    }
    
    @IBAction func didTapAdd(_ sender: UIButton) {
        guard let optionMediaValue = optionMedia.getValue() else { return }
        
        if optionMediaValue == 0 {
            addPostImage(at: 0)
            
        } else {
            addPostVideo()
        }
    }
    
    func addPostImage(at index: Int) {
        let maximumAllowed = editingProduct.isBusinessPost ? 9 : 3
        
        if selectedPhotos.count >= maximumAllowed,
           index >= maximumAllowed {
            showInfoVC("ATB", msg: "You can only add upto \(maximumAllowed) images.")
            return
        }
        
        editingImageIndex = index > selectedPhotos.count ? selectedPhotos.count : index
        
        let alertController = UIAlertController(title: "", message: "What would you like to do?", preferredStyle: .actionSheet)
        
        // camera action
        let cameraTitle = "Take a photo from Camera."
        let cameraAction = UIAlertAction(title: cameraTitle, style: .default) { _ in
            self.photoPicker.sourceType = .camera
            self.photoPicker.cameraCaptureMode = .photo
            self.photoPicker.mediaTypes = ["public.image"]
            
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
        self.present(alertController, animated: true)
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
            imgAddMark.isHidden = false
        }
    }
    
    private func addPostVideo() {
        guard editingProduct.isBusinessPost else {
            showInfoVC("ATB", msg: "You can't not add a video on the product \(isEditingPost ? "posted": "added") using normal profile!")
            return
        }
        
        // adding a sale item(s) will not check selected user
        // this is already a businesses, getting straight to add a post video
        let alertController = UIAlertController(title: "", message: "What would you like to do?", preferredStyle: .actionSheet)
        
        if let _ = self.selectedVideo {
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
        self.present(alertController, animated: true)
    }
    
    private func removePostVideo() {
        removeVideoPlayer()
        selectedVideo = nil
        
        initVideoMediaView()
    }
    
    @IBAction func OnSwitchChanged(_ sender: BorderedSwitch) {
        switch sender {
        case switchCashOnCollection:
            enableCashOption(sender.isOn)
            
        case switchPayPal:
            enablePayPalOption(sender.isOn)
            
        case switchFreePostage:
            enableFreePostage(sender.isOn)
            
        case switchBuyerCollects:
            enableBuyerCollect(sender.isOn)
            
        case switchDeliver:
            enableWillDeliver(sender.isOn)
            showDeliverCostView(sender.isOn, animated: true)
        
        default:
            break
        }
    }
    
    private func enableCashOption(_ enabled: Bool) {
        lblCashOnCollection.textColor = enabled ? .darkGray : .mediumGray
    }
    
    private func enablePayPalOption(_ enabled: Bool) {
        lblPayPal.textColor = enabled ? .darkGray : .mediumGray
    }
    
    private func enableFreePostage(_ enabled: Bool) {
        lblFreePostage.textColor =  enabled ? .darkGray : .mediumGray
    }
    
    private func enableBuyerCollect(_ enabled: Bool) {
        lblBuyerCollects.textColor =  enabled ? .darkGray : .mediumGray
    }
    
    private func enableWillDeliver(_ enabled: Bool) {
        lblDeliver.textColor =  enabled ? .darkGray : .mediumGray
    }
    
    private func showDeliverCostView(_ show: Bool, animated: Bool) {
        txtDeliverCost.text = show ? editingProduct.deliveryCost : ""
        viewDeliverCost.isHidden = !show
        
        viewHeightDeliverCost.constant = show ? 56 + 15 : 0
        
        if animated {
            UIView.animate(withDuration: 0.5) {
                self.viewDeliverCost.alpha = show ? 1 : 0
                self.view.layoutIfNeeded()
            }
            
        } else {
            self.viewDeliverCost.alpha = show ? 1 : 0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func didTapVariationInfo(_ sender: Any) {
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius = 5
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color = .colorPrimary
        overlayAppearance.alpha = 0.75
        overlayAppearance.blurRadius = 8
        
        let variationVC = VariationSettingViewController(nibName: "VariationSettingViewController", bundle: nil)
        
        let variationDialogVC = PopupDialog(viewController: variationVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: true, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(variationDialogVC, animated: true, completion: nil)
    }
    
    @IBAction func didTapAddVariation(_ sender: Any) {
        guard variants.count < 3 else {
            showErrorVC(msg: "You can add upto 3 variantions on a product.")
            return
        }

        openVariation(forEditing: false)
    }
    
    private func openVariation(forEditing editing: Bool, variantToUpdate: [String: String] = [:]) {
        showInfoVC("ATB", msg: "Coming soon!")
        return
        
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35
        
        // sum static values
        // 32 - UILabel(font size: 18) + 12 + UITextField(height: 56) + 24 + UILabel(font size: 18) + 12 + Options TableView + 10 + UIButton/UILabel(22) + 30 + UIButton(60) + 34
        var heightForVariation: CGFloat = 34 + 60 + 30 + 22 + 10 + 12 + 24 + 56 + 12 + 32 + 4 // experienced value
        heightForVariation += UIFont(name: Font.SegoeUISemibold, size: 18)!.lineHeight * 2
        // variation options
        if editing {
            guard let values = variantToUpdate["values"] else { return }
            let variantOptions = values.components(separatedBy: ",")
            
            heightForVariation += 66.0 * CGFloat(variantOptions.count < 4 ? variantOptions.count : 4)
            
        } else {
            heightForVariation += 66.0 * 3
        }        
        
        configuruation.sheetSize = .fixed(heightForVariation)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        
        let sheetController = NBBottomSheetController(configuration: configuruation)
        
        // presented controller
        let variationVC = VariationViewController.instance()
        variationVC.configuration = configuruation
        variationVC.isAdding = !editing
        variationVC.variantToUpdate = variantToUpdate
        
        variationVC.delegate = self
        
        sheetController.present(variationVC, on: self)
    }
    
    private var isStockEnabled: Bool = true
    @IBAction func didTapManageStock(_ sender: Any) {
        isStockEnabled = !isStockEnabled
       
        manageStockEnabled(isStockEnabled)
        
        lblStockErrorMessage.isHidden = isStockEnabled
        UIView.animate(withDuration: 0.35, delay: 0.12, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    private func manageStockEnabled(_ enabled: Bool) {
        if #available(iOS 13.0, *) {
            imvStockEnabled.image = UIImage(systemName: enabled ? "checkmark.square.fill" : "square")
        } else {
            // Fallback on earlier versions
        }
        
        lblManageStockTitle.textColor = enabled ? .darkGray : .mediumGray
        
        // select all row or deselect all rows
        for variant in productVariants {
            variant.isSelected = enabled
        }
        
        tblStock.reloadData()
    }
  
    private func isValid() -> Bool {
        if let optionValue = optionMedia.getValue() {
            if optionValue == 0 {
                if selectedPhotos.count == 0 {
                    self.showErrorVC(msg: "Please add images for your post.")
                    return false
                }
                
            } else {
                if selectedVideo == nil {
                    showErrorVC(msg: "Please add a video for your post.")
                    return false
                }
            }
            
        } else {
            self.showErrorVC(msg: "Please add an image or a video for your post.")
            return false
        }
        
        if(self.txtTitle.isEmpty()) {
            self.showErrorVC(msg: "Please input the post title.")
            return false
        }
        
        if(self.txtDescription.isEmpty()) {
            self.showErrorVC(msg: "Please input the description.")
            return false
        }
        
        if(self.txtBrand.isEmpty()) {
            self.showErrorVC(msg: "Please input the brand.")
            return false
        }
        
        if(self.txtPrice.isEmpty())  {
            self.showErrorVC(msg: "Please input the price.")
            return false
            
        } else {
            let price = txtPrice.text!.doubleValue
            
            if price <= 0.0 {
                self.showErrorVC(msg: "Please input the price.")
                return false
            }
        }
        
        if(self.optionCategory.getValue() == nil) {
            self.showErrorVC(msg: "Please select a category.")
            return false
        }
        
        if(self.optionCondition.getValue() == nil) {
            self.showErrorVC(msg: "Please select a condition.")
            return false
        }
        
        self.paymentType = 0
        if self.switchCashOnCollection.isOn {
            self.paymentType += 1
        }
        
        if self.switchPayPal.isOn {
            self.paymentType += 2
        }
        
        if paymentType == 0 {
            self.showErrorVC(msg: "Please select payment options.")
            return false
        }
        
        if(self.txtLocation.isEmpty()) {
            self.showErrorVC(msg: "Please input the location.")
            return false
        }
        
        self.deliverType = 0
        if self.switchFreePostage.isOn  {
            self.deliverType += 1
        }
        
        if self.switchBuyerCollects.isOn {
            self.deliverType += 3
        }
        
        if self.switchDeliver.isOn {
            self.deliverType += 5
            
            if self.txtDeliverCost.isEmpty(){
                self.showErrorVC(msg: "Please input the cost for delivery.")
                return false
                
            } else {
                let deliveryCost = txtDeliverCost.text!.doubleValue
                if deliveryCost <= 0.0 {
                    self.showErrorVC(msg: "Please input the cost for delivery.")
                    return false
                }
            }
        }
        
        if self.deliverType == 0 {
            self.showErrorVC(msg: "Please select a delivery option.")
            return false
        }
        
        if variants.count > 0 {
            if isStockEnabled {
                var selectedExist = false
                for productVariant in productVariants {
                    if productVariant.isSelected {
                        selectedExist = true
                        break
                    }
                }
                
                if !selectedExist {
                    showErrorVC(msg: "Your product has variants.")
                    return false
                }
                
            } else {
                showErrorVC(msg: "Your product has variants.")
                return false
            }
            
        } else {
            // no variant, stock leve no set
            if txtStockLevel.isEmpty() {
                showErrorVC(msg: "Please input the quantity.")
                return false
            }
        }
        
        if isEditingPost {
            guard let pid = editingProduct.pid,
                  !pid.isEmpty else {
                return false
            }
        }
        
        return true
    }
    
    @IBAction func didTapUpdate(_ sender: Any) {
        guard isValid() else { return }
        
        if g_myInfo.bt_paypal_account.isEmpty && switchPayPal.isOn {
            let alert = UIAlertController(title: "Setup Paypal Account", message: "To be able to use the PayPal payment method and take payment for your item directly in the app you will need to add your PayPal.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Add Paypal", style: .default, handler: { _ in
                self.getClientToken()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.view.tintColor = .colorPrimary
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        if productVariants.count > 0 {
            uploadProductVariants()
            
        } else {
            updateProduct(showLoading: true)
        }
        
    }
    
    private func getClientToken() {
        showIndicator()
        ATBBraintreeManager.shared.getBraintreeClientToken(g_myToken) { (result, message) in
            self.hideIndicator()
            
            guard result else {
                self.showErrorVC(msg: "Server returned the error message: " + message)
                return
            }
            
            let clientToken = message
            self.showDropIn(clientTokenOrTokenizationKey: clientToken)
        }
    }
    
    private func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        request.cardDisabled = true
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            controller.dismiss(animated: true, completion: nil)
            
            guard error == nil,
                  let result = result else {
                // show error
                self.showErrorVC(msg: "Failed to link your PayPal account, please try again!")
                return
            }
            
            guard !result.isCancelled,
                  let paymentMethod = result.paymentMethod else {
                // Payment has been cancelled by the user
                return }
            
            let nonce = paymentMethod.nonce
            self.showAlert("Payment Method Confirmation", message: "Would you like to receive payment through this PayPal?", positive: "Yes", positiveAction: { _ in
                if result.paymentOptionType == .payPal {
                    self.retrievePayPal(withNonce: nonce)
                    
                } else {
                    self.showErrorVC(msg: "You can not use this card to receive payments.\nPlease set up a PayPal account.")
                }
                
            }, negative: "No", negativeAction: nil, preferredStyle: .actionSheet)
        }
        
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    private func retrievePayPal(withNonce paymentNonce: String) {
        let params = [
            "token" : g_myToken,
            "customerId" : g_myInfo.bt_customer_id,
            "paymentMethodNonce" : paymentNonce
        ]
        
        showIndicator()
        _ = ATB_Alamofire.POST(GET_PP_ADDRESS, parameters: params as [String : AnyObject]) { (result, response) in
            if result {
                let paypal = response.object(forKey: "msg") as? String ?? ""
                g_myInfo.bt_paypal_account = paypal
                
                self.updateProduct(showLoading: false)
                
            } else {
                self.hideIndicator()
                self.showErrorVC(msg: "Failed to link your PayPal account, please try again!")
            }
        }
    }
            
    private func updateProduct(showLoading: Bool) {
        let pid = isEditingPost ? editingProduct.pid! : editingProduct.Post_ID
        let media_type = (optionMedia.getValue() ?? 0) + 1 // Image - 1, Video - 2
        let posterType = editingProduct.isBusinessPost ? "1" : "0"
        
        let deliveryCost = switchDeliver.isOn ? txtDeliverCost.text! : ""
        
        var stock_level = txtStockLevel.text!
        if stock_level.isEmpty {
            stock_level = "0"
        }
        
        var params : [String : String] = [
            "id": pid,
            "token" : g_myToken,
            "poster_profile_type" : posterType,
            "media_type" : "\(media_type)",
            "title" : self.txtTitle.text!,
            "brand" : self.txtBrand.text!,
            "price" : self.txtPrice.text!,
            "description" : self.txtDescription.text!,
            "category_title" : self.optionCategory.text!,
            "post_tags" : "",
            "lat" : postLatitude,
            "lng" : postLongitude,
            "item_title" : "",
            "payment_options" : "\(paymentType)",
            "location_id" : txtLocation.text!,
            "delivery_option" : "\(deliverType)",
            "delivery_cost": deliveryCost,
            "post_condition": optionCondition.text!,
            "stock_level" : stock_level
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
            
        } else {
            if let url = selectedVideo as? String {
                params["post_img_uris"] = url
                
            } else {
                params["post_img_uris"] = "data"
            }
        }
        
        if showLoading {
            showIndicator()
        }
        
        let upload = ATB_Alamofire.shareInstance.upload(
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

                } else {
                    if self.selectedVideo is Data,
                       let videoData = self.selectedVideo as? Data {
                        multipartFormData.append(videoData, withName: "post_imgs[0]", fileName: "vid0.mp4", mimeType: "video/mp4")
                    
                    }
                }
                
                for (key, value) in params {
                    multipartFormData.append((value.data(using: .utf8)!), withName: key)
                }
            },
            to: UPDATE_PRODUCT,
            usingThreshold: multipartFormDataEncodingMemoryThreshold,
            method: .post,
            headers: nil,
            interceptor: nil,
            fileManager: FileManager.default)
        
        upload.responseJSON { (response) in
            self.hideIndicator()
            
            switch response.result {
            case .success(let JSON):
                let res = JSON as! NSDictionary
                
                if let ok = res["result"] as? Bool,
                    ok,
                    let productDict = res["extra"] as? NSDictionary {
                    let updatedProduct = PostModel(info: productDict)
                    
                    self.didCompleteUpdateProduct(with: updatedProduct)
                    
                } else {
                    self.showErrorVC(msg: "Failed to update \(self.isEditingPost ? "the post" : "the product"), please try again!")
                }
                
            case .failure(_):
                self.showErrorVC(msg: "Failed to update \(self.isEditingPost ? "the post" : "the product"), please try again!")
            }
        }
    }
    
    // upload prices & stockes for variants
    private func uploadProductVariants() {
        showIndicator()
        
        var uploadCount = 0
        for productVariant in productVariants {
            if productVariant.isUpdated {
                uploadCount += 1
            }
        }
        
        guard uploadCount > 0 else {
            updateProduct(showLoading: false)
            return
        }
        
        var uploadedCount = 0
        for productVariant in productVariants {
            guard productVariant.isUpdated else {
                if uploadedCount >= uploadCount { return }
                
                continue
            }
            
            let params = [
                "token" : g_myToken,
                "id" : productVariant.id,
                "stock_level" : productVariant.stock_level,
                "price" : productVariant.price
            ]
            
            _ = ATB_Alamofire.POST(UPDATE_PRODUCT_VARIANT, parameters: params as [String : AnyObject]) { _, _ in
                uploadedCount += 1
                if uploadedCount >= uploadCount {
                    self.updateProduct(showLoading: false)
                }
            }
        }
    }
    
    private func didCompleteUpdateProduct(with updated: PostModel) {
        editingProduct.update(withProduct: updated)
        
        let object = [
            "updated": updated
        ]
        
        NotificationCenter.default.post(name: .DidUpdatePost, object: object)
        
        showAlert("ATB", message: "The product \(isEditingPost ? "post " : "")details has been updated successfully!", positive: "Ok", positiveAction: { _ in
            self.navigationController?.popViewController(animated: true)
            
        }, preferredStyle: .actionSheet)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - DropDownDelegate
extension EditProductViewController: DropdownDelegate {
   
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

// MARK: - UITableViewDataSource, UITableViewDelegate
extension EditProductViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == list_media {
            return editingProduct.isBusinessPost ? 9 : 3
            
        } else if tableView == tblVariations {
            return variants.count
            
        } else {
            return productVariants.count
        }
    }
    
    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == list_media {
            let mediaCell = tableView.dequeueReusableCell(withIdentifier: "MediaTableViewCell",
                                                          for: indexPath) as! MediaTableViewCell
            // configure the cell
            let index = indexPath.section + 1
            mediaCell.configureCell(with: selectedPhotos.count > index ? selectedPhotos[index] : nil)
            
            return mediaCell
            
        } else if tblVariations == tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: VariationItemCell.reuseIdentifier, for: indexPath) as! VariationItemCell
            // configure the cell
            let variantDict = variants[indexPath.section]
            if let name = variantDict["attribute_name"] {
                if let options = variantDict["values"] {
                    cell.configureCell(name, options: options)
                }
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: StockItemCell.reuseIdentifier, for: indexPath) as! StockItemCell
            // configure the cell
            cell.configureCell(withProductVariant: productVariants[indexPath.section])
            cell.stockValueChanged = { updated in
                self.productVariants[indexPath.section].isUpdated = true
                self.productVariants[indexPath.section].stock_level = "\(updated)"
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case tblVariations:
            openVariation(forEditing: true, variantToUpdate: variants[indexPath.section])
            break
            
        case tblStock:
            showInfoVC("ATB", msg: "Coming soon!")
//            productVariants[indexPath.section].isSelected = !productVariants[indexPath.section].isSelected
//            tblStock.reloadSections([indexPath.section], with: .none)
            break
            
        case list_media:
            addPostImage(at: indexPath.section + 1)
            break
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let stockItemCelll = cell as? StockItemCell {
            stockItemCelll.setTextFieldDelegate(self, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == list_media {
            let screenWidth = UIScreen.main.bounds.width
            let viewWidth = screenWidth - 40
            let cellHeight = (viewWidth - 30) / 4
            
            return cellHeight
            
        } else if tableView == tblVariations {
            return 68
            
        } else {
            if productVariants[indexPath.section].attributes.count > 2 {
                return 102
                
            } else {
                return 68
            }
        }
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard tableView != tblStock else { return 0 }
        
        if section == 0 {
            return 0
        }
        
        return 10
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
    }
}

// MARK: - UIImagePickerControllerDelegate
extension EditProductViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let optionMediaValue = optionMedia.getValue() else { return }
        
        if optionMediaValue == 0 {
            guard let pickedImage = info[.originalImage] as? UIImage,
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
            
        } else {
            guard let videoURL = info[.mediaURL] as? URL,
                let data = try? Data(contentsOf: videoURL as URL) else { return }
            
            selectedVideoURL = videoURL
            selectedVideo = data
            
            initVideoMediaView()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - LocationInputDelegate
extension EditProductViewController: LocationInputDelegate {
    
    func locationSelected(address: String, latitude: String, longitude: String, radius: Float) {
        txtLocation.text = address
        
        postLatitude = latitude
        postLongitude = longitude
        
        txtLocation.layer.shadowOffset = CGSize(width: 1, height: 5)
        txtLocation.layer.shadowColor = UIColor.lightGray.cgColor
        txtLocation.layer.shadowOpacity = 0.5
        txtLocation.layer.shadowRadius = 5.0
        txtLocation.layer.borderColor = UIColor.primaryButtonColor.cgColor
        txtLocation.layer.borderWidth = 1.0
    }
}

// MARK: - UITextFieldDelegate
extension EditProductViewController: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtLocation {
            let toVC = PostRangeViewController.instance()
            toVC.locationInputDelegate = self
            navigationController?.pushViewController(toVC, animated: true)
            return false
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let currentText = textField.text ?? "0.00"
        textField.text = currentText.doubleValue.priceString
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let value = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        let index = textField.tag - 500
        guard index >= 0,
              index < productVariants.count else { return true }
        
        let priceString = value.doubleValue.priceString
        
        productVariants[index].price = priceString
        productVariants[index].isUpdated = true
        
        return true
    }
}

// MARK: - VariationUpdateDelegate
extension EditProductViewController: VariationUpdateDelegate {
    
    func variationAdded(name: String, options: String) {
        var variant: [String: String] = [:]
        variant["attribute_name"] = name
        variant["values"] = options
        
        variants.append(variant)
        
        var price = "0.00"
        if let priceText = txtPrice.text,
           !priceText.isEmpty {
            price = priceText.doubleValue.priceString
        }
        
        // make possible combinations
        var variantAttributes = [[VariantAttribute]]()
        for variant in variants {
            if let name = variant["attribute_name"],
                let values = variant["values"] {
                let options = values.components(separatedBy: ",")
                
                var attributes = [VariantAttribute]()
                for option in options {
                    let variantAttribute = VariantAttribute()
                    variantAttribute.name = name
                    variantAttribute.value = option
                    
                    attributes.append(variantAttribute)
                }
                
                variantAttributes.append(attributes)
            }
        }
        
        let possibleCombinations = cartesianProduct(variantAttributes)
        productVariants.removeAll()
        for attributes in possibleCombinations {
            let productVariant = ProductVariant(attributes: attributes)
            productVariant.price = price
            productVariant.stock_level = "1"
            
            productVariants.append(productVariant)
        }
        
        tblVariations.reloadData()
        noVariantStockContainer.isHidden = true
        
        stockContainer.isHidden = !(productVariants.count > 0 )
        tblStock.reloadData()
        
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
        }
    }
    
    func variationUpdated(name: String, updatedName: String, options: String) {
        var variant: [String:String] = [:]
        variant["attribute_name"] = updatedName
        variant["values"] = options
        
        // remove old one
        variants.removeAll(where: { $0["attribute_name"] == name })
        // add updated variant
        variants.append(variant)
        
        var price = "0.00"
        if let priceText = txtPrice.text,
           !priceText.isEmpty {
            price = priceText.doubleValue.priceString
        }
        
        // make possible combinations
        var variantAttributes = [[VariantAttribute]]()
        for variant in variants {
            if let name = variant["attribute_name"],
                let values = variant["values"] {
                let options = values.components(separatedBy: ",")
                
                var attributes = [VariantAttribute]()
                for option in options {
                    let variantAttribute = VariantAttribute()
                    variantAttribute.name = name
                    variantAttribute.value = option
                    
                    attributes.append(variantAttribute)
                }
                
                variantAttributes.append(attributes)
            }
        }
        
        let possibleCombinations = cartesianProduct(variantAttributes)
        productVariants.removeAll()
        for attributes in possibleCombinations {
            let productVariant = ProductVariant(attributes: attributes)
            productVariant.price = price
            productVariant.stock_level = "1"
            
            productVariants.append(productVariant)
        }
        
        tblVariations.reloadData()
        
        tblStock.reloadData()
        
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
        }
    }
    
    func variationDeleted(name: String) {
        variants.removeAll(where: { $0["attribute_name"] == name })
        noVariantStockContainer.isHidden = (variants.count > 0)
        
        var price = "0.00"
        if let priceText = txtPrice.text,
           !priceText.isEmpty {
            price = priceText.doubleValue.priceString
        }
        
        // make possible combinations
        var variantAttributes = [[VariantAttribute]]()
        for variant in variants {
            if let name = variant["attribute_name"],
                let values = variant["values"] {
                let options = values.components(separatedBy: ",")
                
                var attributes = [VariantAttribute]()
                for option in options {
                    let variantAttribute = VariantAttribute()
                    variantAttribute.name = name
                    variantAttribute.value = option
                    
                    attributes.append(variantAttribute)
                }
                
                variantAttributes.append(attributes)
            }
        }
        
        let possibleCombinations = cartesianProduct(variantAttributes)
        productVariants.removeAll()
        for attributes in possibleCombinations {
            let productVariant = ProductVariant(attributes: attributes)
            productVariant.price = price
            productVariant.stock_level = "1"
            
            productVariants.append(productVariant)
        }
        
        tblVariations.reloadData()
        
        stockContainer.isHidden = !(productVariants.count > 0 )
        tblStock.reloadData()
        
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
        }
    }
}
