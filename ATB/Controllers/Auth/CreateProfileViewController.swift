//
//  CreateProfileViewController.swift
//  ATB
//
//  Created by YueXi on 5/29/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import MapKit
import Applozic
import PopupDialog
import Mixpanel

enum Gender: Int {
    case Male = 0
    case Female = 1
}

class CreateProfileViewController: BaseViewController {
    
    static let kStoryboardID = "CreateProfileViewController"
    class func instance() -> CreateProfileViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: CreateProfileViewController.kStoryboardID) as? CreateProfileViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvLogo: UIImageView!
    @IBOutlet weak var lblAccountCreated: UILabel!
    @IBOutlet weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var accountCreatedLabelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var vProfileInput: UIView!
    @IBOutlet weak var lblCompleteProfile: UILabel!
    
    @IBOutlet weak var vProfile: RoundView!
    @IBOutlet weak var imvProfile: UIImageView!
    @IBOutlet weak var imvCamera: UIImageView!
    @IBOutlet weak var lblProfile: UILabel!
    
    @IBOutlet weak var txfUsername: RoundRectTextField!
    @IBOutlet weak var txfFirstname: RoundRectTextField!
    @IBOutlet weak var txfLastname: RoundRectTextField!
    @IBOutlet weak var txvDescription: RoundRectTextView!
    @IBOutlet weak var txfLocation: RoundRectTextField!
    // gender selection
    var selectedGender: Gender = .Female
    @IBOutlet weak var txfMale: RoundRectTextField!
    @IBOutlet weak var txfFemale: RoundRectTextField!
    
    @IBOutlet weak var txfBirthday: RoundRectTextField!
    
    @IBOutlet weak var vInviteContainer: UIView!
    @IBOutlet weak var txfInviteCode: RoundRectTextField!
    @IBOutlet weak var vPasteBtnContainer: UIView!
    @IBOutlet weak var imvPasteIcon: UIImageView!
    @IBOutlet weak var lblPaste: UILabel!
    
    @IBOutlet weak var btnBegin: UIButton!
    
    var isInputViewShown: Bool = false
    
    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.delegate = self
        
        return imagePicker
    }()
    
    var selectedPhoto: Data? = nil
    
    private var latitude: String = ""
    private var longitude: String = ""
    private var radius: Float = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isInputViewShown {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.showCreateProfileView()
            }
        }
    }
    
    private func setupViews() {
        self.view.backgroundColor = .colorGray14
        
        self.imvLogo.contentMode = .scaleAspectFill
        self.imvLogo.image = UIImage(named: "account.logo")
        
        lblAccountCreated.text = "Your Account Has Been Created"
        lblAccountCreated.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblAccountCreated.textColor = .colorPrimary
                
        lblCompleteProfile.text = "Now please complete your profile"
        lblCompleteProfile.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblCompleteProfile.textColor = .colorGray2
        
        // profile container
        vProfile.backgroundColor = .colorGray7
        vProfile.layer.borderWidth = 1
        vProfile.layer.borderColor = UIColor.colorGray17.cgColor
        vProfile.layer.masksToBounds = true
        
        imvProfile.contentMode = .scaleAspectFill
        
        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfile(_:)))
        profileTapGesture.numberOfTapsRequired = 1
        imvProfile.isUserInteractionEnabled = true
        imvProfile.addGestureRecognizer(profileTapGesture)
        
        imvCamera.contentMode = .scaleAspectFit
        if #available(iOS 13.0, *) {
            imvCamera.image = UIImage(systemName: "camera.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvCamera.tintColor = .colorGray11
        
        lblProfile.text = "Set A Profile Picture"
        lblProfile.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblProfile.textColor = .colorGray2
        
        /// username field
        setupInputField(txfUsername, placeholder: "Username", image: "checkmark")
        txfUsername.iconTintColor = .colorGreen
        /// first name field
        setupInputField(txfFirstname, placeholder: "First Name", image: "checkmark")
        txfFirstname.autocapitalizationType = .words
        /// last name field
        setupInputField(txfLastname, placeholder: "Last Name", image: "checkmark")
        txfLastname.autocapitalizationType = .words
        /// description
        txvDescription.text = ""
        txvDescription.font = UIFont(name: Font.SegoeUILight, size: 18)
        txvDescription.textColor = .colorGray19
        txvDescription.tintColor = .colorGray19
        txvDescription.placeholder = "Write Your Biography"
        txvDescription.inputPadding = 11 // lineFragmentPadding = 5(by default)
        txvDescription.borderColor = .colorGray17
        txvDescription.borderWidth = 1
        txvDescription.delegate = self
        /// location field
        setupInputField(txfLocation, placeholder: "Location", image: "mappin.and.ellipse")
        txfLocation.iconTintColor = .colorGray11
        txfLocation.rightViewMode = .always
        
        setupInputField(txfMale, placeholder: "", image: "checkmark.circle.fill")
        txfMale.text = "Male"
        txfMale.isUserInteractionEnabled = false
                
        setupInputField(txfFemale, placeholder: "", image: "checkmark.circle.fill")
        txfFemale.text = "Female"
        txfFemale.isUserInteractionEnabled = false
        
        updateGenderSelection(selectedGender)
        
        setupInputField(txfBirthday, placeholder: "Date Of Birth", image: "calendar.badge.plus")
        txfBirthday.iconTintColor = .colorGray11
        txfBirthday.rightViewMode = .always
        
        // set date picker
        let datePicker = UIDatePicker()
        datePicker.sizeToFit()
        datePicker.datePickerMode = .date
        if #available(iOS 14, *) {
            // add conditions for iOS 14
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.backgroundColor = .colorGray7
        datePicker.setValue(UIColor.colorGray19, forKey: "textColor")
        
        // create a tool bar and assign it to inputAccessoryView
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        toolbar.barTintColor = .colorGray7
        toolbar.layer.borderWidth = 1
        toolbar.layer.borderColor = UIColor.colorGray17.cgColor
        toolbar.clipsToBounds = true
         
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nibName, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dateSelected))
        doneButton.setTitleTextAttributes(
            [.font: UIFont(name: Font.SegoeUISemibold, size: 18)!,
            .foregroundColor: UIColor.colorGray19], for: .normal)
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dateCanceled))
        cancelButton.setTitleTextAttributes(
            [.font: UIFont(name: Font.SegoeUILight, size: 18)!,
            .foregroundColor: UIColor.colorGray19], for: .normal)
        
        toolbar.setItems([cancelButton, flexible, doneButton], animated: false)
        
        txfBirthday.inputAccessoryView = toolbar
        txfBirthday.inputView = datePicker
        
        setupInviteViews()
        
        btnBegin.layer.cornerRadius = 5
        btnBegin.backgroundColor = .colorPrimary
        btnBegin.setTitle("Let's Begin", for: .normal)
        btnBegin.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        
        updateBeginButton(false)
        
        vProfileInput.alpha = 0
    }
    
    private func setupInputField(_ textField: RoundRectTextField, placeholder: String, image: String? = nil) {
        textField.backgroundColor = .white
        textField.borderColor = .colorGray17
        textField.borderWidth = 1
        textField.placeholder = placeholder
        textField.tintColor = .colorGray19
        textField.textColor = .colorGray19
        textField.font = UIFont(name: Font.SegoeUILight, size: 18)
        textField.inputPadding = 16
        
        if let image = image {
            textField.rightPadding = 12
            textField.iconTintColor = .colorPrimary
            
            if #available(iOS 13.0, *) {
                textField.rightImage = UIImage(systemName: image)
                
            } else {
                // Fallback on earlier versions
            }
        }
        
        guard textField != txfMale,
              textField != txfFemale else { return }
              
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
    }
    
    private func showCreateProfileView() {
        // logo animation
        accountCreatedLabelBottomConstraint.constant = -(SCREEN_HEIGHT / 2.0 - 145)
        logoWidthConstraint.constant = 56
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        
        // show proile view
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.vProfileInput.alpha = 1.0
        })
    }
    
    private func setupInviteViews() {
        // input field
        txfInviteCode.backgroundColor = .white
        txfInviteCode.placeholder = "Invitation Code"
        txfInviteCode.tintColor = .colorGray19
        txfInviteCode.textColor = .colorGray19
        txfInviteCode.font = UIFont(name: Font.SegoeUILight, size: 18)
        txfInviteCode.inputPadding = 16
        
        txfInviteCode.delegate = self
        
        vInviteContainer.layer.cornerRadius = 5
        vInviteContainer.layer.borderColor = UIColor.colorGray17.cgColor
        vInviteContainer.layer.borderWidth = 1
        vInviteContainer.layer.masksToBounds = true
        
        vPasteBtnContainer.backgroundColor = .colorPrimary
        
        lblPaste.text = "Paste"
        lblPaste.textColor = .white
        lblPaste.font = UIFont(name: Font.SegoeUILight, size: 18)
        if #available(iOS 13.0, *) {
            imvPasteIcon.image = UIImage(systemName: "doc.on.clipboard.fill")
        } else {
            // Fallback on earlier versions
        }
        imvPasteIcon.tintColor = .white
    }
    
    // update gender selection
    private func updateGenderSelection(_ gender: Gender)  {
        selectedGender = gender
        
        genderSelected(txfFemale, isSelected: gender == .Female)
        genderSelected(txfMale, isSelected: gender == .Male)
    }
    
    private func genderSelected(_ textField: UITextField, isSelected: Bool) {
        if isSelected {
            textField.backgroundColor = .white
            textField.textColor = .colorGray19
            textField.rightViewMode = .always
            
        } else {
            textField.backgroundColor = .colorGray7
            textField.textColor = .colorGray11
            textField.rightViewMode = .never
        }
    }
    
    @IBAction func didTapGender(_ sender: UIButton) {
        updateGenderSelection(sender.tag == 450 ? .Male : .Female)
    }
    
    @objc func didTapProfile(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: "What would you like to do?", preferredStyle: .actionSheet)
        
        if let camera = actionAction(for: .camera, title: "Take photo") {
            alertController.addAction(camera)
        }
        
        if let photoLibrary = actionAction(for: .photoLibrary, title: "Photo Library") {
            alertController.addAction(photoLibrary)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.view.tintColor = .colorPrimary
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func actionAction(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.imagePicker.sourceType = type
            
            DispatchQueue.main.async {
                // make sure to call this present explicitly on the main thread
                self.present(self.imagePicker, animated: true)
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkValidation(textField)
    }
    
    @objc func dateSelected() {
        txfBirthday.resignFirstResponder()
        
        guard let datePicker = txfBirthday.inputView as? UIDatePicker else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "d MMM yyyy"
        
        txfBirthday.text = dateFormatter.string(from: datePicker.date)
        
        // should call validation check
        checkValidation(txfBirthday)
    }
    
    @objc func dateCanceled() {
        txfBirthday.resignFirstResponder()
    }
    
    private func validateUsername(_ username: String, completion: @escaping (Bool) -> Void) {
        _ = ATB_Alamofire.POST(IS_USERNAME_USED, parameters: ["user_name": username] as [String: AnyObject], completionHandler: { (result, response) in
            completion(result)
        })
    }
    
    // check validation for UITextField
    private func checkValidation(_ textField: UITextField) {
        updateValidation()
        
        if textField == txfUsername {
            txfUsername.borderColor = .colorGray17
            textField.rightViewMode = .never
            return
        }
        
        if textField == txfFirstname || textField == txfLastname {
            guard !textField.isEmpty() else {
                textField.rightViewMode = .never
                return
            }
            
            textField.rightViewMode = .always
            return
        }
        
        if textField == txfLocation || textField == txfBirthday {
            guard let roundTextField = textField as? RoundRectTextField else { return }
            
            if textField.isEmpty() {
                roundTextField.iconTintColor = .colorGray11
                return
            }
            
            roundTextField.iconTintColor = .colorPrimary
            return
        }
    }
    
    // this will check and update 'Let's Begin' enabled/disabled
    private func updateValidation() {
        guard let _ = selectedPhoto,
              let username = txfUsername.text,
              !username.isEmpty,
              username.trimmedString.count > 2,
              !txfFirstname.isEmpty(),
              !txfLastname.isEmpty(),
              !txfLocation.isEmpty(),
              !txvDescription.isEmpty else {
                updateBeginButton(false)
            return
        }
        
        updateBeginButton(true)
    }
    
    private func updateBeginButton(_ enabled: Bool) {
        btnBegin.setTitleColor(enabled ? .white : UIColor.white.withAlphaComponent(0.22), for: .normal)
    }
    
    @IBAction func didTapPaste(_ sender: Any) {
        if let inviteCode = UIPasteboard.general.string {
            txfInviteCode.text = inviteCode
        }
    }
    
    private func isValid() -> Bool {
        guard let _ = selectedPhoto else {
            showErrorVC(msg: "Please set your profile picture.")
            return false
        }
        
        guard let username = txfUsername.text,
              !username.isEmpty else {
            showErrorVC(msg: "Please enter your username.")
            return false
        }
        
        guard username.count > 2 else {
            showErrorVC(msg: "The username should be at least 3 characters.")
            return false
        }
        
        guard let firstname = txfFirstname.text,
              !firstname.isEmpty else {
            showErrorVC(msg: "Please enter your first name.")
            return false
        }
        
        guard let lastname = txfLastname.text,
              !lastname.isEmpty else {
            showErrorVC(msg: "Please enter your last name.")
            return false
        }
        
        guard let bio = txvDescription.text,
              !bio.isEmpty else {
            showErrorVC(msg: "Please enter your bio.")
            return false }
        
        guard let location = txfLocation.text,
              !location.isEmpty else {
            showErrorVC(msg: "Please enter your location")
            return false }
        
        return true
    }
    
    @IBAction func didTapBegin(_ sender: Any) {
        guard isValid() else { return }
        
        let username = txfUsername.text!.trimmedString
        
        showIndicator()
        validateUsername(username) { valid in
            if valid {
                self.txfUsername.rightViewMode = .always
                self.txfUsername.borderColor = .colorGreen
                
                self.createProfile()
                
            } else {
                self.hideIndicator()
                
                self.txfUsername.rightViewMode = .never
                self.txfUsername.borderColor = .colorRed1
                
                self.showErrorVC(msg: "The username was already taken.")
            }
        }
    }
    
    private func createProfile() {
        let birthday = txfBirthday.text!.toDateString(fromFormat: "d MMM yyyy ", toFormat: "dd-MM-yyyy")

        let params = [
            "token" : g_myToken,
            "user_name" : txfUsername.text!.trimmedString,
            "first_name" : txfFirstname.text!,
            "last_name" : txfLastname.text!,
            "bio": txvDescription.text!.trimmedString,
            "location" : txfLocation.text!,
            "lat": latitude,
            "lng": longitude,
            "range": "\(radius)",
            "dob" : birthday,
            "gender": "\(selectedGender.rawValue)"
        ]
        
        ATB_Alamofire.shareInstance.upload(
            multipartFormData: { (multipartFormData) in
                if let photoData = self.selectedPhoto {
                    multipartFormData.append(photoData, withName: "pic", fileName: "profileimg.jpg", mimeType: "image/jpeg")
                }

                let contentDict = params
                for (key, value) in contentDict {
                    multipartFormData.append((value.data(using: .utf8)!), withName: key)
                }
            },
            to: REGISTER_API,
            usingThreshold: multipartFormDataEncodingMemoryThreshold,
            method: .post,
            headers: nil,
            interceptor: nil,
            fileManager: FileManager.default
        ).responseJSON { (response) in
            self.hideIndicator()
            
            switch response.result {
            case .success(let JSON):
                guard let valueDict = JSON as? NSDictionary else {
                    self.showErrorVC(msg: "It's been failed to create your profile!")
                    return
                }

                guard let result = valueDict["result"] as? Bool,
                      result else {
                    let message = valueDict["msg"] as? String ?? ""
                    if message.isEmpty {
                        self.showErrorVC(msg: "It's been failed to create your profile!")

                    } else {
                        self.showErrorVC(msg: "Server returned the error message: " + message)
                    }

                    return
                }

                let userInfo = valueDict["extra"] as! NSDictionary
                g_myInfo = User(info: userInfo)

                Mixpanel.mainInstance().identify(distinctId: g_myInfo.ID)
                Mixpanel.mainInstance().people.set(properties: [ "type":"User",
                                                                 "$avatar":g_myInfo.profileImage,
                                                                 "$email":g_myInfo.emailAddress,
                                                                 "$first_name":g_myInfo.firstName,
                                                                 "$last_name":g_myInfo.lastName,
                                                                 "$name":g_myInfo.userName])

                let alUser : ALUser =  ALUser()
                alUser.userId = g_myInfo.ID
                alUser.email = g_myInfo.emailAddress
                alUser.imageLink = g_myInfo.profileImage
                alUser.displayName = g_myInfo.userName
                alUser.password = g_myInfo.ID

                ALUserDefaultsHandler.setUserId(alUser.userId)
                ALUserDefaultsHandler.setEmailId(alUser.email)
                ALUserDefaultsHandler.setDisplayName(alUser.displayName)

                let chatManager = ALChatManager(applicationKey: "emtrac2ba61d90383c69a7fbc7db07725fa3e5b")
                chatManager.connectUserWithCompletion(alUser, completion: { _, _ in })

                let defaults = UserDefaults.standard
                if let deviceTokenString = defaults.string(forKey: "push_token") {
                    let params = [
                        "token" : g_myToken,
                        "push_token" : deviceTokenString,
                    ]

                    _ = ATB_Alamofire.POST(UPDATE_NOTIFCATION_TOKEN, parameters: params as [String : AnyObject],showLoading: false,showSuccess: false,showError: false){
                        (result, responseObject) in

                    }
                }

                self.gotoSelectFeed()

            case .failure(_):
                self.showErrorVC(msg: "It's been failed to create your profile!")
            }
        }
    }
    
    private func gotoSelectFeed() {
        let toVC = CreateFeedViewController.instance()
        self.navigationController?.pushViewController(toVC, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CreateProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard textField == txfLocation else { return true }
        
        let toVC = LocationViewController.instance()
        toVC.locationInputDelegate = self
        
        self.navigationController?.pushViewController(toVC, animated: true)
        
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField == txfUsername else { return }
        
        let username = textField.text!.trimmedString
        guard username.count > 2 else { return }
        
        validateUsername(username) { valid in
            if valid {
                textField.rightViewMode = .always
                self.txfUsername.borderColor = .colorGreen
                
            } else {
                textField.rightViewMode = .never
                self.txfUsername.borderColor = .colorRed1
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txfUsername {
            txfFirstname.becomeFirstResponder()
            
        } else if textField == txfFirstname {
            txfLastname.becomeFirstResponder()
        }
        
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: - UITextViewDelegate
extension CreateProfileViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateValidation()
    }
}

// MARK: UIImagePickerControllerDelegate
extension CreateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let pickedImage = info[.editedImage] as? UIImage,
              let photoData = pickedImage.jpegData(compressionQuality: 1.0) else { return }
        
        imvProfile.image = pickedImage
        selectedPhoto = photoData
        
        imvCamera.isHidden = true
        
        updateValidation()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - LocationInputDelegate
extension CreateProfileViewController: LocationInputDelegate {
    
    func locationSelected(address: String, latitude: String, longitude: String, radius: Float) {
        txfLocation.text = address
        
        self.latitude = latitude
        self.longitude = longitude
        
        self.radius = radius
        
        // should call validation
        checkValidation(txfLocation)
    }
}
