//
//  EditServiceViewController.swift
//  ATB
//
//  Created by YueXi on 3/12/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import DropDown
import BMPlayer
import Braintree
import BraintreeDropIn
import OpalImagePicker
import Photos

class EditServiceViewController: BaseViewController {
    
    static let kStoryboardID = "EditServiceViewController"
    class func instance() -> EditServiceViewController {
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: EditServiceViewController.kStoryboardID) as? EditServiceViewController {
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
    
    @IBOutlet weak var imvProfile: UIImageView!
    
    /// Midia Type
    @IBOutlet weak var lblMediaType: UILabel! { didSet {
        lblMediaType.text = "Media Type"
        lblMediaType.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblMediaType.textColor = .colorGray22
        }}
    @IBOutlet weak var optionMedia: RoundDropDown!
    
    @IBOutlet weak var mediaContainer: UIView!
    @IBOutlet weak var imgMedia: UIImageView!
    @IBOutlet weak var imgAddMark: UIImageView!
    @IBOutlet weak var list_media: UITableView!
    
    @IBOutlet weak var mediaContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var mediaWidth: NSLayoutConstraint!
    
    /// Service Name
    @IBOutlet weak var titleLabel: UILabel! { didSet {
        titleLabel.font = UIFont(name: Font.SegoeUILight, size: 18)
        titleLabel.textColor = .colorGray22
    }}
    @IBOutlet weak var txtTitle: FocusTextField! { didSet {
        txtTitle.placeholder = "Add a Title"
        txtTitle.font = UIFont(name: Font.SegoeUILight, size: 17)
        txtTitle.textColor = .colorGray21
        }}
    
    /// Service Description
    @IBOutlet weak var descriptionLabel: UILabel! { didSet {
        descriptionLabel.font = UIFont(name: Font.SegoeUILight, size: 18)
        descriptionLabel.textColor = .colorGray22
    }}
    @IBOutlet weak var txtDescription: RoundShadowTextView! { didSet {
        txtDescription.textViewTextColor = .colorGray21
    }}
    
    /// Price
    @IBOutlet weak var lblPriceFrom: UILabel! { didSet {
            lblPriceFrom.text = "Price from"
            lblPriceFrom.font = UIFont(name: Font.SegoeUILight, size: 18)
            lblPriceFrom.textColor = .colorGray22
        }}
    @IBOutlet weak var txtPrice: FocusTextField! { didSet {
        txtPrice.textColor = .colorGray21
        txtPrice.font = UIFont(name: Font.SegoeUILight, size: 17)
        txtPrice.textAlignment = .right
        txtPrice.placeholder = "0,00"
        }}
    
    /// Deposit
    @IBOutlet weak var lblDepositRequired: UILabel! { didSet {
        lblDepositRequired.text = "Deposit Required NO/YES"
        lblDepositRequired.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblDepositRequired.textColor = .colorGray21
        }}
    @IBOutlet weak var depositSwitch: UISwitch! { didSet {
        depositSwitch.onTintColor = .colorPrimary
        depositSwitch.tintColor = .colorGray17
        }}
    @IBOutlet weak var vDepositAmountContainer: UIView!
    @IBOutlet weak var lblDeposit: UILabel! { didSet {
        lblDeposit.text = "Deposit"
        lblDeposit.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblDeposit.textColor = .colorGray22
        }}
    @IBOutlet weak var txtDeposit: FocusTextField! { didSet {
        txtDeposit.textColor = .colorGray21
        txtDeposit.font = UIFont(name: Font.SegoeUILight, size: 17)
        txtDeposit.textAlignment = .right
        txtDeposit.placeholder = "0,00"
        }}
    
    /// Cancellations
    @IBOutlet weak var lblCancellations: UILabel! { didSet {
        lblCancellations.text = "Cancellations\nWithin Day(s)"
        lblCancellations.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblCancellations.textColor = .colorGray22
        lblCancellations.numberOfLines = 2
        }}
    @IBOutlet weak var cancelStepper: GMStepper! { didSet {
        cancelStepper.minimumValue = 1
        cancelStepper.maximumValue = 30
        cancelStepper.stepValue = 1
        cancelStepper.autorepeat = false
        cancelStepper.buttonsTextColor = .white
        cancelStepper.buttonsFont = UIFont(name: Font.SegoeUISemibold, size: 20)!
        cancelStepper.buttonsBackgroundColor = .colorPrimary
        cancelStepper.labelTextColor = .colorPrimary
        cancelStepper.labelFont = UIFont(name: Font.SegoeUIBold, size: 20)!
        cancelStepper.labelBackgroundColor = .white
        cancelStepper.cornerRadius = 5
        cancelStepper.borderWidth = 1
        cancelStepper.borderColor = .colorGray17
        cancelStepper.limitHitAnimationColor = .white
        }}
    
    /// Post-in category
    @IBOutlet weak var lblPostIn: UILabel! { didSet {
        lblPostIn.text = "Post In"
        lblPostIn.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblPostIn.textColor = .colorGray22
        }}
    @IBOutlet weak var optionCategory: RoundDropDown!
    
    /// Area Covered
    @IBOutlet weak var txtLocation: FocusTextField! { didSet {
        txtLocation.placeholder = "Area Covered"
        }}
    
    /// Insurance
    var selectedInsurance: Int? = nil       // we can get this value, however, if same value exists, we might get a wrong index
    var insuranceDropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.direction = .any
        dropDown.cellNib = UINib(nibName: "InsuranceCell", bundle: nil)
        
        return dropDown
    }()
    
    @IBOutlet weak var lblInsuranceRequired: UILabel!
    @IBOutlet weak var insuranceSwitch: UISwitch!
    
    // dropdown anchor view
    @IBOutlet weak var vAllInsuranceContainer: UIView!
    
    @IBOutlet weak var vNoInsuranceContainer: UIView!
    @IBOutlet weak var lblNoInsurance: UILabel!
    
    @IBOutlet weak var vInsuranceContainer: UIView!
    
    @IBOutlet weak var vInsuranceLeftContainer: UIView!
    @IBOutlet weak var imvDeleteInsurance: UIImageView!
    
    @IBOutlet weak var lblInsuranceName: UILabel!
    @IBOutlet weak var lblInsuranceExpiry: UILabel!
    
    @IBOutlet weak var vInsuranceRightContainer: UIView!
    @IBOutlet weak var imvAddInsurance: UIImageView!
    
    /// Qualification
    var selectedQualification: Int? = nil
    var qualificationDropDown: DropDown = {
        let dropDown = DropDown()
        dropDown.direction = .any
        dropDown.cellNib = UINib(nibName: "InsuranceCell", bundle: nil)
        
        return dropDown
    }()
    
    @IBOutlet weak var lblCertificateRequired: UILabel!
    @IBOutlet weak var certificateSwitch: UISwitch!
    
    // dropdown anchor view
    @IBOutlet weak var vAllCertificateContainer: UIView!
    
    @IBOutlet weak var vNoCertificateContainer: UIView!
    @IBOutlet weak var lblNoCertificate: UILabel!
    
    @IBOutlet weak var vCertificateContainer: UIView!
    
    @IBOutlet weak var vCertificateLeftContainer: UIView!
    @IBOutlet weak var imvDeleteCertificate: UIImageView!
    
    @IBOutlet weak var lblQualificationName: UILabel!
    @IBOutlet weak var lblQualifiedSince: UILabel!
    
    @IBOutlet weak var vCertificateRightContainer: UIView!
    @IBOutlet weak var imvAddCertificate: UIImageView!
    
    /// Payment Options
    @IBOutlet weak var lblPaymentOptions: UILabel! { didSet {
        lblPaymentOptions.text = "Payment Options"
        lblPaymentOptions.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblPaymentOptions.textColor = .colorPrimary
        }}
    @IBOutlet weak var lblPaymentOptionsDescription: UILabel! { didSet {
        lblPaymentOptionsDescription.text = "Please select the options you'd like to be paid with"
        lblPaymentOptionsDescription.font = UIFont(name: Font.SegoeUILight, size: 14)
        lblPaymentOptionsDescription.textColor = .colorGray22
        }}
    @IBOutlet weak var lblCashOnCollection: UILabel! { didSet {
        lblCashOnCollection.text = "Cash on collection"
        lblCashOnCollection.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblCashOnCollection.textColor = .colorGray22
        }}
    @IBOutlet weak var switchCashOnCollection: BorderedSwitch!
    
    @IBOutlet weak var lblPayPal: UILabel! { didSet {
        lblPayPal.text = "PayPal"
        lblPayPal.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblPayPal.textColor = .colorGray22
        }}
    @IBOutlet weak var switchPayPal: BorderedSwitch!
    
    @IBOutlet weak var btnUpdate: RoundedShadowButton!
    
    // used for camera action
    lazy var photoPicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        return picker
    }()
    
    // 0 - none selected, 1 - Cash on Colleciton, 2 - PayPal, 3 - both Cash and PayPal
    var paymentOption:Int = 0
    
    // editing image index
    var editingImageIndex: Int = 0
    // selected photos for the post
    var selectedPhotos: [Any] = []
    
    // selected video for the post
    var selectedVideo: Any? = nil
    var selectedVideoURL: URL? = nil
    
    private var postLatitude: String = ""
    private var postLongitude: String = ""
    
    var insurances: [ServiceFileModel] = []
    var qualifications: [ServiceFileModel] = []
    
    var editingService: PostModel!
    var isEditingPost: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
                
        lblTitle.text = isEditingPost ? "Edit a\nService Post" : "Edit a Service"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 26)
        lblTitle.textColor = .colorGray2
        lblTitle.numberOfLines = 2
        lblTitle.setLineSpacing(lineHeightMultiple: 0.75)

        let businessProfile = g_myInfo.business_profile
        imvProfile.loadImageFromUrl(businessProfile.businessPicUrl, placeholder: "profile.placeholder")
        imvProfile.contentMode = .scaleAspectFill
        
        initDropDownOptions()
        
        mediaContainer.layer.cornerRadius = 8
        mediaContainer.layer.masksToBounds = true
        
//        mediaContainerHeight.constant = 0
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action:  #selector(longPressed(_:)))
        longPressRecognizer.cancelsTouchesInView = false
        mediaContainer.addGestureRecognizer(longPressRecognizer)
        
        let mediaType = editingService.isVideoPost ? 1 : 0
        
        optionMedia.dropDown.selectRow(mediaType)
        optionMedia.text = editingService.Post_Media_Type
        
        if editingService.Post_Media_Urls.count > 0 {
            if editingService.isVideoPost {
                let videoURL = editingService.Post_Media_Urls[0]
                selectedVideo = videoURL
                selectedVideoURL = URL(string: videoURL)
                
            } else {
                for mediaUrl in editingService.Post_Media_Urls {
                    selectedPhotos.append(mediaUrl)
                }
            }
        }
        
        initMediaView(withMediaType: mediaType)
        
        txtTitle.text = editingService.Post_Title
        
        txtDescription.placeHolderText = "Add a description"
        txtDescription.setText(text: editingService.Post_Text)
                
        let currencyImage = UIImage(named: "ico_paymentblue")
        // Price InputField
        txtPrice.isLeftEnabled = true
        let currencyImageView = UIImageView(frame: CGRect(x:  0, y: 0, width: self.txtPrice.frame.height * 0.6, height: self.txtPrice.frame.height * 0.6))
        currencyImageView.image = currencyImage
        
        let priceViewLeftPadding = UIView(frame: CGRect(x: self.txtPrice.frame.height * 0.2, y: 0, width: self.txtPrice.frame.height * 0.6, height: self.txtPrice.frame.height * 0.6))
        currencyImageView.center = priceViewLeftPadding.center
        priceViewLeftPadding.addSubview(currencyImageView)
        
        txtPrice.leftView = priceViewLeftPadding
        txtPrice.leftViewMode = .always
        txtPrice.isNumInput = true
        
        txtPrice.text = editingService.Post_Price.floatValue.priceString
        
        // Hide deposit amount view as default, switch off
        if !editingService.isDepositRequired {
            vDepositAmountContainer.isHidden = true
            vDepositAmountContainer.alpha = 0
        }
        
        depositSwitch.isOn = editingService.isDepositRequired
        
        // Deposit InputField
        txtDeposit.isLeftEnabled = true
        let depositCurrencyImageView = UIImageView(frame: CGRect(x:  0, y: 0, width: self.txtDeposit.frame.height * 0.6, height: self.txtDeposit.frame.height * 0.6))
        depositCurrencyImageView.image = currencyImage
        let depositViewLeftPadding = UIView(frame: CGRect(x: self.txtDeposit.frame.height * 0.2, y: 0, width: self.txtDeposit.frame.height * 0.6, height: self.txtDeposit.frame.height * 0.6))
        depositCurrencyImageView.center = depositViewLeftPadding.center
        depositViewLeftPadding.addSubview(depositCurrencyImageView)
        
        txtDeposit.leftView = depositViewLeftPadding
        txtDeposit.leftViewMode = .always
        txtDeposit.isNumInput = true
        
        txtDeposit.text = editingService.Post_Deposit.floatValue.priceString
        
        // cancellation days
        cancelStepper.value = editingService.cancellations.doubleValue
        
        // category
        optionCategory.text = editingService.Post_Category
        let categoryOptions = g_StrFeeds.filter{ $0 != "My ATB" }
        if let index = categoryOptions.firstIndex(where: { $0 == editingService.Post_Category }) {
            optionCategory.dropDown.selectRow(index)
        }
        
        // Location Field
        let textFieldHeight = txtLocation.bounds.height
        let circleHeight = textFieldHeight - 20
        
        let rightButtonView = UIView(frame: CGRect(x: -10, y: 0, width: textFieldHeight, height: textFieldHeight))
        rightButtonView.layer.cornerRadius = 5
        rightButtonView.backgroundColor = UIColor.clear
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "location_arrow"), for: .normal)
        button.backgroundColor = UIColor.primaryButtonColor
        button.imageEdgeInsets = UIEdgeInsets(top: circleHeight/3.5, left: circleHeight/3.5, bottom: circleHeight/3.5, right: circleHeight/3.5)
        button.frame = CGRect(x: 10, y: CGFloat(10), width: circleHeight, height: circleHeight)
        button.layer.cornerRadius = 5
        
        rightButtonView.addSubview(button)
        
        txtLocation.isRightEnabled = true
        txtLocation.rightView = rightButtonView
        txtLocation.rightViewMode = .always
        txtLocation.delegate = self
        
        txtLocation.text = editingService.Post_Location
        
        let dropDownAppearance = DropDown.appearance()
        dropDownAppearance.textFont = UIFont(name: Font.SegoeUILight, size: 18)!
        dropDownAppearance.textColor = .colorGray1
        dropDownAppearance.cellHeight = 56
        dropDownAppearance.separatorColor = .colorGray14
        
        // set-up insurance select dropdown
        setupInsuranceView()
        
        // set-up qualification select dropdown
        setupQualificationView()
        
        // get insurances and qualifications
        getServiceFiles()
        
        // Payment Options
        switchCashOnCollection.setOn(editingService.isCashEnabled, animated: false)
        enableCashOption(editingService.isCashEnabled)
        
        switchPayPal.setOn(editingService.isPayPalEnabled, animated: false)
        enablePayPalOption(editingService.isPayPalEnabled)
        
        btnUpdate.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 19)
        btnUpdate.setTitle("UPDATE", for: .normal)
    }
    
    private func initDropDownOptions() {
        optionMedia.dataStr = ["Image", "Video"]
        optionMedia.isSearchEnabled = false
        optionMedia.dropdownDelegate = self
        
        let categoryOptions = g_StrFeeds.filter{$0 != "My ATB"}
        optionCategory.dataStr = categoryOptions
        optionCategory.dropdownDelegate = self
    }
    
    private func initMediaView(withMediaType mediaType: Int) {
        let viewWidth = SCREEN_WIDTH - 40
        let cellHeight = (viewWidth - 30) / 4
        let imgHeight = viewWidth - 10 - cellHeight
        
        switch mediaType {
        case 0:
            removeVideoPlayer()
            
            mediaContainerHeight.constant = imgHeight
            mediaWidth.constant = imgHeight
            
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
            
            if let selected = selectedVideoURL {
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
        if let videoView = mediaContainer.viewWithTag(1000) {
            videoView.removeFromSuperview()
        }
    }
    
    @objc func longPressed(_ sender: UILongPressGestureRecognizer) {
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
    
    private func addPostImage(at index: Int) {
        let maximumAllowed = 9
        
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
            imgAddMark.isHidden = false
        }
    }
    
    private func addPostVideo() {
        let alertController = UIAlertController(title: "", message: "What would you like to do?", preferredStyle: .actionSheet)
        
        if let _ = selectedVideo {
            // add an option to delete if a video was already added
            let deleteTitle = "Remove this video from the post."
            let deleteAction = UIAlertAction(title: deleteTitle, style: .destructive) { _ in
                let alert = UIAlertController(title: "Alert", message: "Do you want to remove this video from the post?", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    self.removePostVideo()
                }))
                alert.addAction(UIAlertAction(title: "No", style: .default))
                alert.view.tintColor = .colorPrimary
                self.present(alert, animated: true)
            }
            
            alertController.addAction(deleteAction)
            
        }  else {
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
    
    private func removePostVideo() {
        removeVideoPlayer()
        selectedVideo = nil
        
        initVideoMediaView()
    }
        
    @IBAction func didTapDepositRequired(_ sender: UISwitch) {
        let show = sender.isOn
        UIView.animate(withDuration: 0.5) {
            self.vDepositAmountContainer.isHidden = !show
            
            if show {
                self.vDepositAmountContainer.alpha = 1
                
            } else {
                self.vDepositAmountContainer.alpha = 0
            }
        }
    }
    
    @IBAction func OnSwitchChanged(_ sender: BorderedSwitch) {
        switch(sender) {
        case switchCashOnCollection:
            enableCashOption(sender.isOn)
            break
            
        case switchPayPal:
            enablePayPalOption(sender.isOn)
            break
            
        default:
            break
        }
    }
    
    private func enableCashOption(_ enabled: Bool) {
        lblCashOnCollection.font = enabled ? UIFont(name: Font.SegoeUIBold, size: 18.0) : UIFont(name: Font.SegoeUILight, size: 18.0)
        lblCashOnCollection.textColor = enabled ? .colorGray21 : .colorGray22
    }
    
    private func enablePayPalOption(_ enabled: Bool) {
        lblPayPal.font = enabled ? UIFont(name: Font.SegoeUIBold, size: 18.0): UIFont(name: Font.SegoeUILight, size: 18.0)
        lblPayPal.textColor = enabled ? .colorGray21 : .colorGray22
    }
    
    func isValid() -> Bool {
        guard let optionValue = optionMedia.getValue() else {
            showErrorVC(msg: "Please add an image or a video for your service.")
            return false
        }
        
        if optionValue == 0 {
            if selectedPhotos.count == 0 {
                showErrorVC(msg: "Please add images for your service.")
                return false
            }
            
        } else {
            if selectedVideo == nil {
                showErrorVC(msg: "Please add a video for your service.")
                return false
            }
        }
        
        if txtTitle.isEmpty() {
            showErrorVC(msg: "Please add the service title.")
            return false
        }
        
        if txtDescription.isEmpty() {
            showErrorVC(msg: "Please input the description.")
            return false
        }
        
        if txtPrice.isEmpty() {
            showErrorVC(msg: "Please input the price.")
            return false
            
        } else {
            let price = self.txtPrice.text!.doubleValue
            
            if price <= 0.0 {
                showErrorVC(msg: "Please input a valid price.")
                return false
            }
        }
        
        if depositSwitch.isOn {
            if txtDeposit.isEmpty() {
                showErrorVC(msg: "Please input the deposit amount.")
                return false
                
            } else {
                let deposit = txtDeposit.text!.doubleValue
                
                if deposit <= 0.0 {
                    showErrorVC(msg: "Please input a valid demposit amount.")
                    return false
                }
            }
        }
        
        guard let _ = optionCategory.getValue() else {
            showErrorVC(msg: "Please select a category.")
            return false
        }
        
        if txtLocation.isEmpty() {
            showErrorVC(msg: "Please input the location.")
            return false
        }
        
        paymentOption = 0
        if switchCashOnCollection.isOn {
            paymentOption += 1
        }
        
        if switchPayPal.isOn {
            paymentOption += 2
        }
        
        guard paymentOption > 0 else {
            showErrorVC(msg: "Please select payment options.")
            return false
        }
        
        // check deposit enabled and PayPal enabled
        // PayPal option should be enabled for a service that requires a deposit
        if depositSwitch.isOn && paymentOption < 2 {
            showErrorVC(msg: "You have to enable the PayPal option in order to let customers can pay deposit at the time of booking.")
            return false
        }
        
        if isEditingPost {
            guard let sid = editingService.sid,
                  !sid.isEmpty else {
                return false
            }
        }
        
        return true
    }
    
    @IBAction func didTapUpdate(_ sender: Any) {
        guard isValid() else { return }
        
        if switchPayPal.isOn && g_myInfo.bt_paypal_account.isEmpty {
            showAlert("Setup PayPal Account", message: "To be able to use the PayPal payment method and take payment for your service directly in the app you will need to add your PayPal.", positive: "Add PayPal", positiveAction: { _ in
                self.getClientToken()
                
            }, negative: "Cancel", negativeAction: nil, preferredStyle: .actionSheet)
            
            return
        }
        
        updateService(showLoading: true)
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
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
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
    
    private func retrievePayPal(withNonce nonce: String) {
        let params = [
            "token" : g_myToken,
            "customerId" : g_myInfo.bt_customer_id,
            "paymentMethodNonce" : nonce
        ]
        
        showIndicator()
        _ = ATB_Alamofire.POST(GET_PP_ADDRESS, parameters: params as [String : AnyObject]) { (result, response) in
            if result {
                let paypal = response.object(forKey: "msg") as? String ?? ""
                g_myInfo.bt_paypal_account = paypal
                
                self.updateService(showLoading: false)
                
            } else {
                self.hideIndicator()
                self.showErrorVC(msg: "Failed to link your PayPal account, please try again!")
            }
        }
    }
    
    func updateService(showLoading: Bool) {
        let sid = isEditingPost ? editingService.sid! : editingService.Post_ID
        let media_type = (optionMedia.getValue() ?? 0) + 1
        
        let isDepositRequired = depositSwitch.isOn
        let depositRequired = isDepositRequired ? "1" : "0"
        let depositAmount = isDepositRequired ? txtDeposit.text! : "0.00"
        
        let cancellations = Int(cancelStepper.value)

        let insurance = (insuranceSwitch.isOn && selectedInsurance != nil) ? insurances[selectedInsurance!].id : ""
        let qualification = (certificateSwitch.isOn && selectedQualification != nil) ? qualifications[selectedQualification!].id : ""
        
        var params = [
            "id": sid,
            "token" : g_myToken,
            "poster_profile_type": "1",
            "media_type": String(media_type),
            "title": txtTitle.text!,
            "brand": "",
            "description": self.txtDescription.text!,
            "price": self.txtPrice.text!,
            "is_deposit_required": depositRequired,
            "deposit_amount": depositAmount,
            "cancellations": "\(cancellations)",
            "category_title": self.optionCategory.text!,
            "location_id": self.txtLocation.text!,
            "lat": postLatitude,
            "lng": postLongitude,
            "insurance_id": insurance,
            "qualification_id": qualification,
            "payment_options": String(self.paymentOption),
            "post_tags": "",
            "delivery_option": "0",
            "delivery_cost" : "0",
            "item_title": "",
            "post_condition": ""]
        
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

                } else {
                    if self.selectedVideo is Data,
                       let videoData = self.selectedVideo as? Data {
                        multipartFormData.append(videoData, withName: "post_imgs[0]", fileName: "vid0.mp4", mimeType: "video/mp4")
                    
                    }
                }
                
                for (key, value) in params  {
                    multipartFormData.append((value.data(using: .utf8)!), withName: key)
                }
            },
            to: UPDATE_SERVICE,
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
                    let serviceDict = res["extra"] as? NSDictionary {
                    let updatedService = PostModel(info: serviceDict)
                    self.didCompleteUpdateService(with: updatedService)
                    
                } else {
                    self.showErrorVC(msg: "Failed to update \(self.isEditingPost ? "the post" : "the service"), please try again!")
                }
                
            case .failure(_):
                self.showErrorVC(msg: "Failed to update \(self.isEditingPost ? "the post" : "the service"), please try again!")
            }
        }
    }
    
    func didCompleteUpdateService(with updated: PostModel) {
        editingService.update(withService: updated)
        
        let object = [
            "updated": updated
        ]
        
        NotificationCenter.default.post(name: .DidUpdatePost, object: object)
        
        showAlert("ATB", message: "The service \(isEditingPost ? "post " : "")details has been updated successfully!", positive: "Ok", positiveAction: { _ in
            self.navigationController?.popViewController(animated: true)
            
        }, preferredStyle: .actionSheet)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension EditServiceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // maximum attachments count for business users - in case of image
        return 9
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mediaCell = tableView.dequeueReusableCell(withIdentifier: "MediaTableViewCell",
                                                      for: indexPath) as! MediaTableViewCell
        
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

// MARK: - Insurances & Qualification
extension EditServiceViewController {
    
    private func setupInsuranceView() {
        lblInsuranceRequired.text = "Does This Service\nRequire Insurance?"
        lblInsuranceRequired.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblInsuranceRequired.textColor = .colorGray21
        lblInsuranceRequired.numberOfLines = 0
        lblInsuranceRequired.setLineSpacing(lineHeightMultiple: 0.75)
        
        insuranceSwitch.onTintColor = .colorPrimary
        insuranceSwitch.tintColor = .colorGray17
        insuranceSwitch.setOn(false, animated: false)
        
        // No Insurance View
        vNoInsuranceContainer.backgroundColor = .colorGray7  // #EFEFEF
        vNoInsuranceContainer.layer.cornerRadius = 5
        vNoInsuranceContainer.layer.masksToBounds = true
        
        lblNoInsurance.text = "No Insurances Added"
        lblNoInsurance.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblNoInsurance.textColor = .colorGray22
        
        // shadow to the container view
        vInsuranceContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
        vInsuranceContainer.layer.shadowRadius = 3.0
        vInsuranceContainer.layer.shadowColor = UIColor.gray.cgColor
        vInsuranceContainer.layer.shadowOpacity = 0.4
        
        // make corner radius to content views
        vInsuranceLeftContainer.backgroundColor = .white
        vInsuranceLeftContainer.layer.cornerRadius = 5
        vInsuranceLeftContainer.layer.masksToBounds = true
        
        if #available(iOS 13.0, *) {
            imvDeleteInsurance.image = UIImage(systemName: "minus.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvDeleteInsurance.tintColor = .colorRed1
        imvDeleteInsurance.contentMode = .scaleAspectFill
        
        lblInsuranceName.text = ""
        lblInsuranceName.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblInsuranceName.textColor = .colorGray1
        
        lblInsuranceExpiry.text = ""
        lblInsuranceExpiry.font = UIFont(name: Font.SegoeUILight, size: 16)
        lblInsuranceExpiry.textColor = .colorPrimary
        
        // make corner radius to content views
        vInsuranceRightContainer.addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 73, alphaValue: 1.0)
        vInsuranceRightContainer.layer.cornerRadius = 5
        vInsuranceRightContainer.layer.masksToBounds = true
        
        if #available(iOS 13.0, *) {
            imvAddInsurance.image = UIImage(systemName: "plus.circle")
        } else {
            // Fallback on earlier versions
        }
        imvAddInsurance.tintColor = .white
        imvAddInsurance.contentMode = .scaleAspectFill
        
        // This will be insurance IDs or names
        insuranceDropDown.dataSource = []
        insuranceDropDown.anchorView = vAllInsuranceContainer
        
        //(Index, String, DropDownCell)
        insuranceDropDown.customCellConfiguration = { index, item, cell in
            guard let cell = cell as? InsuranceCell else { return }
            
            let formattedExpiry = self.insurances[index].expiry.toDateString(fromFormat: "d MMM yyyy", toFormat: "dd/MM/YYYY")
            cell.lblExpiry.text = "Expires\n\(formattedExpiry)"
        }
        
        insuranceDropDown.selectionAction = { [weak self] (index, item) in
            self?.updateInsuranceView(true, selectedIndex: index)
        }
        
        insuranceDropDown.cancelAction = {
            self.updateInsuranceView(false)
        }
        
        if editingService.isInsured {
            let insurance = editingService.insurance!
            lblInsuranceName.text = insurance.name + " " + insurance.reference
            let formattedExpiry = insurance.expiry.toDateString(fromFormat: "d MMM yyyy", toFormat: "dd/MM/YYYY")
            lblInsuranceExpiry.text = "Expires \(formattedExpiry)"
            
            vInsuranceContainer.isHidden = false
            vNoInsuranceContainer.isHidden = true
            
            insuranceSwitch.setOn(true, animated: false)
            
        } else {
            updateInsuranceView(false, animated: false)
        }
    }
    
    @IBAction func didTapDeleteInsurance(_ sender: Any) {
        updateInsuranceView(false, animated: true)
    }
    
    @IBAction func didTapAddInsurance(_ sender: Any) {
        insuranceDropDown.show()
    }
    
    @IBAction func didTapInsurance(_ sender: Any) {
        insuranceDropDown.show()
    }
    
    @IBAction func didTapInsuranceSwitch(_ sender: UISwitch) {
        guard sender.isOn else {
            updateInsuranceView(false, animated: true)
            return
        }
        
        guard insurances.count > 0 else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                sender.isOn = false
                if self.editingService.isInsured {
                    self.showErrorVC(msg: "We were not able to load your insurance files, please try again later!")
                    
                } else {
                    self.showErrorVC(msg: "You don't have any insurance to add.")
                }
            }
            
            return
        }
        
        insuranceDropDown.show()
    }
    
    private func updateInsuranceView(_ added: Bool, selectedIndex: Int? = nil, animated: Bool = true) {
        selectedInsurance = selectedIndex
        
        if let selectedIndex = selectedIndex {
            let insurance = insurances[selectedIndex]
            lblInsuranceName.text = insurance.name + " " + insurance.reference
            let formattedExpiry = insurance.expiry.toDateString(fromFormat: "d MMM yyyy", toFormat: "dd/MM/YYYY")
            lblInsuranceExpiry.text = "Expires \(formattedExpiry)"
            
        } else {
            lblInsuranceName.text = ""
            lblInsuranceExpiry.text = ""
        }
        
        if animated {
            UIView.transition(with: vInsuranceContainer, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.vInsuranceContainer.isHidden = !added
                self.vNoInsuranceContainer.isHidden = added
                
            }, completion: { _ in
                self.insuranceSwitch.setOn(added, animated: true)
            })
            
        } else {
            vInsuranceContainer.isHidden = !added
            insuranceSwitch.setOn(added, animated: false)
        }
    }
    
    private func setupQualificationView() {
        lblCertificateRequired.text = "Does This Service\nRequire Qualitifications?"
        lblCertificateRequired.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblCertificateRequired.textColor = .colorGray21
        lblCertificateRequired.numberOfLines = 0
        lblCertificateRequired.setLineSpacing(lineHeightMultiple: 0.75)
        
        certificateSwitch.onTintColor = .colorPrimary
        certificateSwitch.tintColor = .colorGray17
        certificateSwitch.setOn(false, animated: false)
        
        // No Insurance View
        vNoCertificateContainer.backgroundColor = .colorGray7  // #EFEFEF
        vNoCertificateContainer.layer.cornerRadius = 5
        vNoCertificateContainer.layer.masksToBounds = true
        
        lblNoCertificate.text = "No Qualitifications Added"
        lblNoCertificate.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblNoCertificate.textColor = .colorGray22
        
        // shadow to the container view
        vCertificateContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
        vCertificateContainer.layer.shadowRadius = 3.0
        vCertificateContainer.layer.shadowColor = UIColor.gray.cgColor
        vCertificateContainer.layer.shadowOpacity = 0.4
        
        // make corner radius to content views
        vCertificateLeftContainer.backgroundColor = .white
        vCertificateLeftContainer.layer.cornerRadius = 5
        vCertificateLeftContainer.layer.masksToBounds = true
        
        if #available(iOS 13.0, *) {
            imvDeleteCertificate.image = UIImage(systemName: "minus.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvDeleteCertificate.tintColor = .colorRed1
        imvDeleteCertificate.contentMode = .scaleAspectFill
        
        lblQualificationName.text = ""
        lblQualificationName.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblQualificationName.textColor = .colorGray1
        
        // make corner radius to container views
        lblQualifiedSince.text = ""
        lblQualifiedSince.font = UIFont(name: Font.SegoeUILight, size: 16)
        lblQualifiedSince.textColor = .colorPrimary
        
        // make corner radius to content views
        vCertificateRightContainer.addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 73, alphaValue: 1.0)
        vCertificateRightContainer.layer.cornerRadius = 5
        vCertificateRightContainer.layer.masksToBounds = true
        
        if #available(iOS 13.0, *) {
            imvAddCertificate.image = UIImage(systemName: "plus.circle")
        } else {
            // Fallback on earlier versions
        }
        imvAddCertificate.tintColor = .white
        imvAddCertificate.contentMode = .scaleAspectFill
        
        // This will be insurance IDs or names
        qualificationDropDown.dataSource = []
        qualificationDropDown.anchorView = vAllCertificateContainer
        
        //(Index, String, DropDownCell)
        qualificationDropDown.customCellConfiguration = { index, item, cell in
            guard let cell = cell as? InsuranceCell else { return }
            
            let formattedExpiry = self.qualifications[index].expiry.toDateString(fromFormat: "d MMM yyyy", toFormat: "dd/MM/YYYY")
            cell.lblExpiry.text = "Qualified Since\n\(formattedExpiry)"
        }
        
        qualificationDropDown.selectionAction = { [weak self] (index, item) in
            self?.updateQualificationView(true, selectedIndex: index)
        }
        
        qualificationDropDown.cancelAction = {
            self.updateQualificationView(false, animated: true)
        }
        
        if editingService.isQualified {
            let qualification = editingService.qualification!
            lblQualificationName.text = qualification.name + " " + qualification.reference
            let formattedExpiry = qualification.expiry.toDateString(fromFormat: "d MMM yyyy", toFormat: "dd/MM/YYYY")
            lblQualifiedSince.text = "Qualified Since \(formattedExpiry)"
            
            vCertificateContainer.isHidden = false
            vNoCertificateContainer.isHidden = true
            
            certificateSwitch.setOn(true, animated: false)
            
        } else {
            updateQualificationView(false, animated: false)
        }
    }
    
    @IBAction func didTapDeleteCertificate(_ sender: Any) {
        updateQualificationView(false, animated: true)
    }
    
    @IBAction func didTapAddCertificate(_ sender: Any) {
        qualificationDropDown.show()
    }
    
    @IBAction func didTapCertificate(_ sender: Any) {
        qualificationDropDown.show()
    }
    
    @IBAction func didTapCertificateSwitch(_ sender: UISwitch) {
        guard sender.isOn else {
            updateQualificationView(false, animated: true)
            return
        }
        
        guard qualifications.count > 0 else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                sender.isOn = false
                if self.editingService.isQualified {
                    self.showErrorVC(msg: "We were not able to load your qualification files, please try again later!")
                    
                } else {
                    self.showErrorVC(msg: "You don't have any qualification to add.")
                }
            }
            
            return
        }
        
        qualificationDropDown.show()
    }
    
    private func updateQualificationView(_ added: Bool, selectedIndex: Int? = nil, animated: Bool = true) {
        selectedQualification = selectedIndex
        
        if let selectedIndex = selectedIndex {
            let qualification = qualifications[selectedIndex]
            lblQualificationName.text = qualification.name + " " + qualification.reference
            let formattedExpiry = qualification.expiry.toDateString(fromFormat: "d MMM yyyy", toFormat: "dd/MM/YYYY")
            lblQualifiedSince.text = "Qualified Since \(formattedExpiry)"
            
        } else {
            lblQualificationName.text = ""
            lblQualifiedSince.text = ""
        }
        
        if animated {
            UIView.transition(with: vInsuranceContainer, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.vCertificateContainer.isHidden = !added
                self.vNoCertificateContainer.isHidden = added
                
            }, completion: { _ in
                self.certificateSwitch.setOn(added, animated: true)
            })
            
        } else {
            vCertificateContainer.isHidden = !added
            certificateSwitch.setOn(added, animated: false)
        }
    }
    
    private func getServiceFiles() {
        insurances.removeAll()
        qualifications.removeAll()
        
        showIndicator()
        
        APIManager.shared.getServiceFiles(g_myToken) { (result, message, serviceFiles) in
            self.hideIndicator()
            
            if result,
                let serviceFiles = serviceFiles {
                for serviceFile in serviceFiles {
                    if serviceFile.isInsurance {
                        self.insurances.append(serviceFile)
                        
                    } else {
                        self.qualifications.append(serviceFile)
                    }
                }
                
                self.updateServiceFiles()
            }
        }
    }
    
    // update dropdown data source and set default selection if an insurance and a qualification are added
    private func updateServiceFiles() {
        var insuranceDataSource = [String]()
        for insurance in insurances {
            insuranceDataSource.append(insurance.name + " " + insurance.reference)
        }
        
        // update insurance dropdown datasource
        insuranceDropDown.dataSource = insuranceDataSource
        
        if editingService.isInsured,
           let selected = insurances.firstIndex(where: { $0.id == editingService.insuranceID }) {
            selectedInsurance = selected
            insuranceDropDown.selectRow(selected)
        }
        
        var qualificationDataSource = [String]()
        for qualification in qualifications {
            qualificationDataSource.append(qualification.name + " " + qualification.reference)
        }
        
        // update qualification dropdown datasource
        qualificationDropDown.dataSource = qualificationDataSource
        
        if editingService.isQualified,
           let selected = qualifications.firstIndex(where: { $0.id == editingService.qualificationID }) {
            selectedQualification = selected
            qualificationDropDown.selectRow(selected)
        }
    }
}

// MARK: - DropDownDelegate
extension EditServiceViewController: DropdownDelegate {
    
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
extension EditServiceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            let data = try? Data(contentsOf: videoURL) else { return }
            
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
extension EditServiceViewController: LocationInputDelegate {
    
    func locationSelected(address: String, latitude: String, longitude: String, radius: Float) {
        txtLocation.text = address
        
        postLatitude = latitude
        postLongitude = longitude
        
        txtLocation.layer.shadowOffset = CGSize(width: 1, height: 5)
        txtLocation.layer.shadowColor = UIColor.lightGray.cgColor
        txtLocation.layer.shadowOpacity = 0.5
        txtLocation.layer.shadowRadius = 5.0
    }
}

// MARK: - UITextFieldDelegate
extension EditServiceViewController: UITextFieldDelegate {
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField == self.txtLocation) {
            let toVC = PostRangeViewController.instance()
            toVC.locationInputDelegate = self
            navigationController?.pushViewController(toVC, animated: true)
            return false
        }
        
        return true
    }
}
