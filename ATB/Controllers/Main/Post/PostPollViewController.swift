//
//  PostPollViewController.swift
//  ATB
//
//  Created by YueXi on 5/1/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import NBBottomSheet
import ActionSheetPicker_3_0

fileprivate let kHeightWithoutImage: CGFloat = 72.0
fileprivate let kHeightWithImage: CGFloat = 156.0

class PostPollViewController: BaseViewController {
    
    static let kStoryboardID = "PostPollViewController"
    class func instance() -> PostPollViewController {
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: PostPollViewController.kStoryboardID) as? PostPollViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    private let DEFAULT_OPTIONS_COUNT = 2     // you can change this how many options you want to show users
    private let MAX_OPTIONS_COUNT = 5 // do not change this, this is fixed in the UI
    
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        
        imvBack.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imvProfile: RoundImageView!
    @IBOutlet weak var profileSelectContainer: UIView!
    @IBOutlet weak var imvSelectArrow: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // IB variables
    @IBOutlet weak var heightForImageContainer: NSLayoutConstraint!
    @IBOutlet weak var clvMedia: UICollectionView!
    
    @IBOutlet weak var btnAddImage: UIButton!
    
    let attrsPlaceholder: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "SegoeUI-Light", size: 18)!,
        .foregroundColor: UIColor.colorGray16
    ]
    @IBOutlet weak var txtQuestion: RoundRectTextField!
    
    // poll options
    @IBOutlet weak var lblOptions: UILabel!
    
    // option input fields
    @IBOutlet var vOptions: [UIView]!
    @IBOutlet var txtOptions: [RoundRectTextField]!
    @IBOutlet var btnOptions: [UIButton]!
    
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var imvDuration: UIImageView!
    
    private let accessoryView: UIView = {
        let accessoryView = UIView(frame: .zero)
        accessoryView.backgroundColor = .colorPrimary
        return accessoryView
    }()
    
    private let postButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Complete the poll to post", for: .normal)
        button.addTarget(self, action: #selector(didTapPost), for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: "SegoeUI-Light", size: 20)
        return button
    }()
    
    @IBOutlet weak var optionCategory: RoundDropDown!
    
    // User select
    var users = [UserModel]()
    var selectedUser: UserModel = UserModel()
        
    private let MAX_POLL_IMAGES_CNT = 3
    var pollImages = [UIImage]()
    
    private var defaultPollDuration = 1
    private var maxPollDuration = 7
    private var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
        lblTitle.text = "Poll/Voting"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 26)
        lblTitle.textColor = .colorGray2
        
        initUserOption()
        imvSelectArrow.layer.cornerRadius = 11
        imvSelectArrow.layer.masksToBounds = true
        if #available(iOS 13.0, *) {
            imvSelectArrow.image = UIImage(systemName: "arrow.up.arrow.down.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvSelectArrow.tintColor = .colorPrimary
        profileSelectContainer.isHidden = !g_myInfo.isBusiness
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        scrollView.contentInset.bottom = 60             // inputview height
        
        setupMediaCollectionView()
        clvMedia.isHidden = true
        
        btnAddImage.backgroundColor = .colorGray17
        btnAddImage.layer.cornerRadius = 5
        btnAddImage.setImage(UIImage(named: "add.new.image")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnAddImage.setTitle("  Add a picture", for: .normal)
        btnAddImage.tintColor = .colorGray18
        btnAddImage.setTitleColor(.colorGray18, for: .normal)
        btnAddImage.contentHorizontalAlignment = .left
        btnAddImage.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        
        setupInputField(txtQuestion, placeholder: "Make a question...")
        txtQuestion.tag = 300
        
        lblOptions.text = "Options"
        lblOptions.textColor = .colorGray2
        lblOptions.font = UIFont(name: "SegoeUI-Semibold", size: 18)
        
        setupOptionsView(withDefaultCount: DEFAULT_OPTIONS_COUNT)
        
        if #available(iOS 13.0, *) {
            imvDuration.image = UIImage(systemName: "slider.horizontal.3")
        } else {
            // Fallback on earlier versions
        }
        imvDuration.tintColor = .white
        
        lblDuration.textColor = .white
        lblDuration.font = UIFont(name: Font.SegoeUILight, size: 18)
        updatePollDuration(with: selectedDate)
        
        let categoryOptions = g_StrFeeds.filter{$0 != "My ATB"}
        optionCategory.dataStr = categoryOptions
        optionCategory.dropdownDelegate = self
        
        setupInputAccessoryView()
    }
    
    private func initUserOption() {
        users.removeAll()
        
        let normalUser = UserModel()
        normalUser.user_type = "User"
        normalUser.ID = g_myInfo.ID
        normalUser.user_name = g_myInfo.userName
        normalUser.profile_image = g_myInfo.profileImage
        users.append(normalUser)
        
        // check for account type - business
        if (g_myInfo.isBusiness) {
            let businessUser = UserModel()
            businessUser.user_type = "Business"
            businessUser.ID = g_myInfo.business_profile.ID
            businessUser.user_name = g_myInfo.business_profile.businessProfileName
            businessUser.profile_image = g_myInfo.business_profile.businessPicUrl
            users.append(businessUser)
        }
        
        selectedUser = normalUser
        
        imvProfile.loadImageFromUrl(selectedUser.profile_image, placeholder: "profile.placeholder")
        imvProfile.contentMode = .scaleAspectFill
    }
    
    private func setupMediaCollectionView() {
        clvMedia.backgroundColor = .clear
        
        clvMedia.showsVerticalScrollIndicator = false
        clvMedia.showsHorizontalScrollIndicator = false
        clvMedia.dataSource = self
        clvMedia.delegate = self
        clvMedia.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        // customize collectionviewlayout
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .horizontal
        clvMedia.collectionViewLayout = layout
    }
    
    private func setupInputField(_ textField: RoundRectTextField, placeholder: String) {
        textField.backgroundColor = .white
        textField.borderColor = .colorGray17
        textField.borderWidth = 1

        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attrsPlaceholder)
        textField.tintColor = .colorGray2
        textField.textColor = .colorGray2
        textField.font = UIFont(name: Font.SegoeUILight, size: 18)
        textField.inputPadding = 16

        textField.autocapitalizationType = .sentences
        textField.delegate = self
    }
    
    private let baseTagForOptionButtons = 400
    private let baseTagForOptionInputFields = 420
    private func setupOptionsView(withDefaultCount defaultCount: Int) {
        guard defaultCount <= MAX_OPTIONS_COUNT else { return }
        
        for i in 0 ..< MAX_OPTIONS_COUNT {
            vOptions[i].isHidden = (i > defaultCount - 1)
            
            setupInputField(txtOptions[i], placeholder: "Option \(i+1)")
            txtOptions[i].tag = baseTagForOptionInputFields + i
            txtOptions[i].addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            txtOptions[i].delegate = self
            
            btnOptions[i].setImage(i < defaultCount - 1 ? #imageLiteral(resourceName: "circle.cross.fill") : #imageLiteral(resourceName: "rect.plus.fill"), for: .normal)
            btnOptions[i].isHidden = txtOptions[i].isEmpty()
            btnOptions[i].tag = baseTagForOptionButtons + i
            
            btnOptions[i].addTarget(self, action: #selector(didTapOptionButton(_:)), for: .touchUpInside)
        }
    }
    
    private func updatePollDuration(with selected: Date?) {
        var pollDuration = ""
        var durationInDays = ""
        if let selected = selected {
            guard let differenceInHours = Calendar.current.dateComponents([.hour], from: Date(), to: selected).hour else { return }
            
            let differenceInDays = differenceInHours / 24
            let hoursBalance = differenceInHours % 24
            durationInDays = "\(differenceInDays)\(differenceInDays > 1 ? " days" : " day")"
            if hoursBalance > 0 {
                durationInDays += " \(hoursBalance)\(hoursBalance > 1 ? " hours" : " hour")"
            }
            
        } else {
            durationInDays = "\(defaultPollDuration)\(defaultPollDuration > 1 ? " days" : " day")"
        }
        
        pollDuration = "Poll duration " + durationInDays
        let attributedDuration = NSMutableAttributedString(string: pollDuration)
        attributedDuration.addAttributes(
            [.font: UIFont(name: Font.SegoeUISemibold, size: 18)!],
            range: (pollDuration as NSString).range(of: durationInDays))
        lblDuration.attributedText = attributedDuration
    }
    
    // setup input accessory view
    private func setupInputAccessoryView() {
        accessoryView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60)
        
        accessoryView.translatesAutoresizingMaskIntoConstraints = false
        postButton.translatesAutoresizingMaskIntoConstraints = false
        
        accessoryView.addSubview(postButton)
        updatePostButton(false)
        
        accessoryView.addConstraintWithFormat("H:|[v0]|", views: postButton)
        accessoryView.addConstraintWithFormat("V:|[v0]|", views: postButton)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {
        return accessoryView
    }
    
    private func updateMediaContainer(_ hasMedia: Bool = false) {
        clvMedia.isHidden = !hasMedia
        btnAddImage.isHidden = hasMedia
        
        if hasMedia {
            UIView.animate(withDuration: 0.6, animations: {
                self.heightForImageContainer.constant = kHeightWithImage
                self.view.layoutIfNeeded()
            })
            
        } else {
            UIView.animate(withDuration: 0.6, animations: {
                self.heightForImageContainer.constant = kHeightWithoutImage
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // this will represent the current options count & their option values
    private var pollOptions: [String] = ["", "", "", "", ""]
    private func reloadOptionsView(_ count: Int) {
        guard count <= MAX_OPTIONS_COUNT else { return }
        
        for i in 0 ..< MAX_OPTIONS_COUNT {
            vOptions[i].isHidden = ((i > DEFAULT_OPTIONS_COUNT - 1) && (i > count - 1) && pollOptions[i].isEmpty)
            
            txtOptions[i].text = pollOptions[i]
            
            btnOptions[i].setImage((i < count - 1 || i < DEFAULT_OPTIONS_COUNT - 1) ? #imageLiteral(resourceName: "circle.cross.fill") : #imageLiteral(resourceName: "rect.plus.fill"), for: .normal)
            
            btnOptions[i].isHidden = txtOptions[i].isEmpty()
        }
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
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapAddImage(_ sender: Any) {
        authorizationStatus(.photoLibrary) { status in
            if status {
                DispatchQueue.main.async {
                    self.openImagePicker()
                }
            }
        }
    }
    
    private func openImagePicker() {
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
        
        let controller = ImagePickerSheetController(mediaType: .image)
        controller.maximumSelection = 1
        controller.delegate = self
        
        controller.addAction(ImagePickerAction(title: "Photo Library", handler: { _ in
            presentImagePickerController(.photoLibrary)
        }))
        
        controller.addAction(ImagePickerAction(title: "Take a picture", handler: { _ in
            self.authorizationStatus(.camera) { status in
                if status {
                    DispatchQueue.main.async {
                        presentImagePickerController(.camera)
                    }
                }
            }
        }))
        
        controller.addAction(ImagePickerAction(cancelTitle: "Cancel"))
        present(controller, animated: true, completion: nil)
    }

    fileprivate func fetchAssets(_ asset: PHAsset) {
        let selected = getAssetThumbnail(asset, size: 120)
        
        pollImages.append(selected)
        
        // the first poll image has been selected
        if pollImages.count == 1 {
            updateMediaContainer(true)
        }
        
        clvMedia.reloadData()
    }
    
    private func checkValidation() {
        guard !txtQuestion.isEmpty() else {
            updatePostButton(false)
            return
        }
        
        guard currentOptionsCount >= DEFAULT_OPTIONS_COUNT else {
            updatePostButton(false)
            return
        }
        
        guard let _ = optionCategory.getValue() else {
            updatePostButton(false)
            return
        }
        
        // User is ready to post this poll
        // enable Post Button if all forms are validated
        updatePostButton(true)
    }
    
    private func updatePostButton(_ enabled: Bool) {
        let title = enabled ? "Post this Poll" : "Complete the poll to Post"
        postButton.setTitleColor(enabled ? .white : UIColor.white.withAlphaComponent(0.22), for: .normal)
        postButton.setTitle(title, for: .normal)
    }
    
    @objc internal func textFieldDidChange(_ textField: UITextField) {
        guard let inputOption = textField.text else { return }
        
        let index = textField.tag - baseTagForOptionInputFields
        // update option value, show or hide option action button
        pollOptions[index] = inputOption
        btnOptions[index].isHidden = (inputOption.isEmpty || index == MAX_OPTIONS_COUNT - 1)
    }
    
    @IBAction func didTapDuration(_ sender: UIButton) {
        let now = Date()
        let minimumDate = now.addingTimeInterval(TimeInterval(1*24*60*60))
        let maximumDate = now.addingTimeInterval(TimeInterval(7*24*60*60))
        let datePicker = ActionSheetDatePicker(title: "Poll Duration", datePickerMode: .dateAndTime, selectedDate: now, minimumDate: minimumDate, maximumDate: maximumDate, target: self, action: #selector(dateSelected(_:)), origin: sender)
        
        if #available(iOS 13.4, *) {
            datePicker?.datePickerStyle = .wheels
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        datePicker?.pickerTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: Font.SegoeUILight, size: 17)!,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: UIColor.colorGray1
        ]

        datePicker?.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: Font.SegoeUISemibold, size: 19)!,
            NSAttributedString.Key.foregroundColor: UIColor.colorPrimary
        ]
        datePicker?.pickerBackgroundColor = .colorGray23
        datePicker?.toolbarBackgroundColor = .white
        
        // custom done button
        let doneButton = UIButton()
        doneButton.setTitle("Select", for: .normal)
        doneButton.titleLabel?.font
            = UIFont(name: Font.SegoeUILight, size: 17)
        doneButton.setTitleColor(.colorPrimary, for: .normal)
        let customDoneButton = UIBarButtonItem.init(customView: doneButton)
        datePicker?.setDoneButton(customDoneButton)

        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font
            = UIFont(name: Font.SegoeUISemibold, size: 17)
        cancelButton.setTitleColor(.colorRed1, for: .normal)
        let customCancelButton = UIBarButtonItem.init(customView: cancelButton)
        datePicker?.setCancelButton(customCancelButton)
        
        datePicker?.show()
    }
    
    @objc private func dateSelected(_ date: Date) {
        selectedDate = date
        
        updatePollDuration(with: date)
    }
    
    var currentOptionsCount: Int {
        var cnt = 0
        for i in 0 ..< 5 {
            if !pollOptions[i].isEmpty {
                cnt += 1
            }
        }
        
        return cnt > DEFAULT_OPTIONS_COUNT ? cnt : DEFAULT_OPTIONS_COUNT
    }
    
    @objc private func didTapOptionButton(_ sender: UIButton) {
        let index = sender.tag - baseTagForOptionButtons
        
        // will never happened
        guard index < MAX_OPTIONS_COUNT - 1 else { return }
        
        if vOptions[index + 1].isHidden {
            // user is adding a new option
            // check all above options are valid
            guard isOptionsValid(byIndex: index) else {
                self.view.endEditing(true)
                
                showErrorVC(msg: "Please fill out above options before adding a new one.")
                return
            }
            // reload options with 1 increased count
            reloadOptionsView(currentOptionsCount + 1)
            
        } else {
            // delete the current option
            
            // delete the option
            pollOptions[index] = ""
                        
            // check the later options that already entered by user
            for i in index + 1 ..< 5 {
                if !pollOptions[i].isEmpty {
                    pollOptions[i-1] = pollOptions[i]
                    pollOptions[i] = ""
                }
            }

            // reload option views
            reloadOptionsView(currentOptionsCount)
        }
    }
    
    // check options are valid by index
    private func isOptionsValid(byIndex index: Int) -> Bool {
        for i in 0 ... index {
            if  pollOptions[i].isEmpty {
                return false
            }
        }
        
        return true
    }
    
    // check option is unique
    private func isOptionValid(_ option: String) -> Bool {
        var existCnt = 0
        for exist in pollOptions {
            if !exist.isEmpty,
               exist == option {
                existCnt += 1
            }
        }
        
        if existCnt > 1 {
            return false
        }
        
        return true
    }
    
    private func isValid() -> Bool {
        guard !txtQuestion.isEmpty() else {
            showErrorVC(msg: "Please input the question.")
            return false
        }
        
        guard let _ = optionCategory.getValue() else {
            showErrorVC(msg: "Please select a category.")
            return false
        }
        
        // option validation
        // every option should be unique, at least two options
        var optionsCount = 0
        for option in pollOptions {
            if !option.isEmpty {
                if !isOptionValid(option) {
                    showErrorVC(msg: "Options should be unique.")
                    return false
                }
                
                optionsCount += 1
            }
        }
        
        guard optionsCount > 1 else {
            showErrorVC(msg: "A poll should have two options at least.")
            return false
        }
        
        return true
    }
    
    @objc private func didTapPost(_ sender: Any) {
        self.view.endEditing(true)
        
        guard isValid() else { return }
        
        // media type for the poll
        let media_type = pollImages.count > 0 ? "1" : "0"
        let posterType = selectedUser.isBusiness ? "1" : "0"
        
        // make poll options
        var poll_options = ""
        for option in pollOptions {
            if option.count > 0 {
                poll_options += (option + "|")
            }
        }
        poll_options.removeLast()
        
        var expireDate = Date().addingTimeInterval(24*60*60)
        if let selected = selectedDate {
            expireDate = selected
        }
        
        let params = [
            "token" : g_myToken,
            "type" : "4",
            "media_type" : media_type,
            "profile_type" : posterType,
            "title" : self.txtQuestion.text!,
            "description" : "",
            "brand" : "",
            "price" : "",
            "category_title" : self.optionCategory.text!,
            "item_title" : "",
            "payment_options" : "0",
            "location_id" : "",
            "delivery_option" : "0",
            "delivery_cost" : "0",
            "poll_day" : "\(Int64(expireDate.timeIntervalSince1970))",
            "poll_options" : poll_options
        ]
        
        showIndicator()
        ATB_Alamofire.shareInstance.upload(multipartFormData: { (multipartFormData) in
            if(media_type == "1") {
                for (index, pollImage) in self.pollImages.enumerated() {
                    guard let attachment = pollImage.jpegData(compressionQuality: 1.0) else { return }
                    multipartFormData.append(attachment, withName: "post_imgs[\(index)]", fileName: "\(index + 1).jpg", mimeType: "image/jpeg")
                }
            }
            
            let contentDict = params
            for (key, value) in contentDict {
                multipartFormData.append((value.data(using: .utf8)!), withName: key)
            }
        },
        to: CREATE_POST_API,
        usingThreshold: multipartFormDataEncodingMemoryThreshold,
        method: .post,
        headers: nil,
        interceptor: nil,
        fileManager: FileManager.default).responseJSON { (response) in
            self.hideIndicator()
            
            switch response.result {
            case .success(let JSON):
                let res = JSON as! NSDictionary
                
                if let ok = res["result"] as? Bool,
                   ok {
                    self.didCompletePost()
                    
                } else {
                    let msg = res["msg"] as? String ?? ""
                    
                    if(msg == "")  {
                        self.showErrorVC(msg: "Creating Post Failed.")
                        
                    } else   {
                        self.showErrorVC(msg: msg)
                    }
                }
                
            case .failure(let error):
                print(error)
                self.showErrorVC(msg: "Creating Post Failed.")
            }
        }
    }
    
    private func didCompletePost() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainNav = storyboard.instantiateViewController(withIdentifier: "MainNav") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = mainNav
    }
}

// MARK: -
extension PostPollViewController: DropdownDelegate {
    
    func dropdownValueChanged(dropDown: RoundDropDown) {
        checkValidation()
    }
}

// MARK: - TextFieldDelegate
extension PostPollViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkValidation()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtQuestion {
            txtOptions[0].becomeFirstResponder()
            
        } else if textField == txtOptions[0] {
            txtOptions[1].becomeFirstResponder()
            
        } else if textField == txtOptions[1] {
            if !vOptions[2].isHidden {
                txtOptions[2].becomeFirstResponder()
            }
            
        } else if textField == txtOptions[2] {
            if !vOptions[3].isHidden {
                txtOptions[3].becomeFirstResponder()
            }
            
        } else if textField == txtOptions[3] {
            if !vOptions[4].isHidden {
                txtOptions[4].becomeFirstResponder()
            }
        }
        
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: ProfileSelectDelegate
extension PostPollViewController: ProfileSelectDelegate {
    
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
        
        imvProfile.loadImageFromUrl(selectedUser.profile_image, placeholder: "profile.placeholder")
    }
    
    private func alertToSubscribeBusiness() {
        let title = "You didn't subscribe for your business account yet!\nWould you like to subscribe now?"
        let alert = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            // subscribe
            self.gotoSubscribe()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        alert.view.tintColor = .colorPrimary
        self.navigationController?.present(alert, animated: true)
    }
    
    private func gotoSubscribe() {
        let subscribeVC = SubscribeBusinessViewController.instance()
        subscribeVC.modalPresentationStyle = .overFullScreen
        subscribeVC.delegate = self
        
        self.present(subscribeVC, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension PostPollViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selected = info[.editedImage] as? UIImage else { return }
        self.pollImages.append(selected)
        
        // the first poll image has been selected
        if self.pollImages.count == 1 {
            self.updateMediaContainer(true)
        }
        
        self.clvMedia.reloadData()
        
        self.checkValidation()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - ImagePickerSheetControllerDelegate
extension PostPollViewController: ImagePickerSheetControllerDelegate {
    
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
        
        controller.dismiss(animated: true) {
            self.fetchAssets(asset)
        }
    }
    
    func controller(_ controller: ImagePickerSheetController, willDeselectAsset asset: PHAsset) {
        debugPrint("Will deselect an asset")
    }
    
    func controller(_ controller: ImagePickerSheetController, didDeselectAsset asset: PHAsset) {
        debugPrint("Did deselect an asset")
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PostPollViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pollImages.count + 1 <= MAX_POLL_IMAGES_CNT ? pollImages.count + 1 : MAX_POLL_IMAGES_CNT
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < pollImages.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PollMediaCell.reusableIdentifier, for: indexPath) as! PollMediaCell
            cell.imvMedia.image = pollImages[indexPath.row]
            
            cell.deleteBlock = {
                self.pollImages.remove(at: indexPath.row)
                
                self.clvMedia.reloadData()
                
                if (self.pollImages.count == 0) {
                    self.updateMediaContainer(false)
                }
            }
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddPollMediaCell.reusableIdentifier, for: indexPath)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = kHeightWithImage
        let width = indexPath.row == pollImages.count ? height * 0.75 : height * 1.2
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row >= pollImages.count,
            pollImages.count < MAX_POLL_IMAGES_CNT else {
            return
        }
        
        openImagePicker()
    }
}

// MARK: - SubscriptionDelegate
extension PostPollViewController: SubscriptionDelegate {
    
    func didCompleteSubscription() {
        selectUser(1)
    }
    
    func didIncompleteSubscription() {
        
    }
}

// MARK: - PollOptionsView
@IBDesignable class PollOptionsView: UIView {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
