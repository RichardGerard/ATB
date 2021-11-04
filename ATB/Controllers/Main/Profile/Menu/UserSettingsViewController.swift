//
//  UserSettingsViewController.swift
//  ATB
//
//  Created by YueXi on 5/18/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import MapKit

class UserSettingsViewController: BaseViewController {
    
    static let kStoryboardID = "UserSettingsViewController"
    class func instance() -> UserSettingsViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: UserSettingsViewController.kStoryboardID) as? UserSettingsViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    // Navigation
    @IBOutlet weak var imvBack: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var imvUserProfile: UIImageView!{ didSet {
        imvUserProfile.contentMode = .scaleAspectFill
        imvUserProfile.layer.cornerRadius = 60
        imvUserProfile.layer.masksToBounds = true
        }}
    @IBOutlet weak var btnCamera: UIButton!
    
    // input fields
    @IBOutlet weak var txfFirstName: RoundRectTextField!
    @IBOutlet weak var txfLastName: RoundRectTextField!
    @IBOutlet weak var txfEmail: RoundRectTextField!
    // location selection
    @IBOutlet weak var txfLocation: RoundRectTextField!
    // gender selection
    var selectedGender: Gender = .Female
    @IBOutlet weak var txfMale: RoundRectTextField!
    @IBOutlet weak var txfFemale: RoundRectTextField!
    // date picker
    @IBOutlet weak var txfBirthday: RoundRectTextField!
    
    @IBOutlet weak var btnUpdate: GradientButton!
    
    var selectedPhoto: Data?
    
    private var latitude: String = ""
    private var longitude: String = ""
    private var radius: Float = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        loadProfile()
    }
    
    private func setupViews() {
        self.view.backgroundColor = .colorGray7
        
        lblTitle.font = UIFont(name: "SegoeUI-Semibold", size:27)
        lblTitle.text = "User Settings"
        lblTitle.textColor = .colorGray2
        
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        
        imvBack.tintColor = .colorPrimary
        imvBack.contentMode = .scaleAspectFit
        
        if #available(iOS 13.0, *) {
            btnCamera.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnCamera.tintColor = .white
        
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
        self.imagePicker.mediaTypes = ["public.image"]
        
        // update button
        btnUpdate.setTitle("Update Details", for: .normal)
        btnUpdate.setTitleColor(.white, for: .normal)
        btnUpdate.titleLabel?.font = UIFont(name: "SegoeUI-Bold", size: 18)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        setupTextField(txfFirstName, placeholder: "First Name", iconName: "checkmark")
        txfFirstName.autocapitalizationType = .sentences
        
        setupTextField(txfLastName, placeholder: "Last Name", iconName: "checkmark")
        txfLastName.autocapitalizationType = .sentences
        
        setupTextField(txfEmail, placeholder: "Email Address", iconName: "checkmark")
        txfEmail.keyboardType = .emailAddress
        
        setupTextField(txfLocation, placeholder: "Location", iconName: "mappin.and.ellipse")
        txfLocation.rightViewMode = .always
        
        setupTextField(txfMale, placeholder: "", iconName: "checkmark.circle.fill")
        txfMale.text = "Male"
        txfMale.isUserInteractionEnabled = false
        
        setupTextField(txfFemale, placeholder: "", iconName: "checkmark.circle.fill")
        txfFemale.text = "Female"
        txfFemale.isUserInteractionEnabled = false
        
        setupTextField(txfBirthday, placeholder: "Birthday", iconName: "calendar.badge.plus")
        txfBirthday.rightViewMode = .always
        
        // date picker
        // create a UIDatePicker
        let datePicker = UIDatePicker()
        datePicker.sizeToFit()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            // add conditions for iOS 14
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.backgroundColor = .colorGray7
        datePicker.setValue(UIColor.colorGray19, forKey: "textColor")
        
        // create a tool bar and assign it to inputAccessoryView
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barTintColor = .colorGray7
        toolbar.layer.borderWidth = 1
        toolbar.layer.borderColor = UIColor.colorGray17.cgColor
        toolbar.clipsToBounds = true
        
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Semibold", size: 18)!,
            .foregroundColor: UIColor.colorGray19
        ]
        
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Light", size: 18)!,
            .foregroundColor: UIColor.colorGray19
        ]
        
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nibName, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dateSelected))
        doneButton.setTitleTextAttributes(boldAttrs, for: .normal)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dateCanceled))
        cancelButton.setTitleTextAttributes(normalAttrs, for: .normal)
        
        toolbar.setItems([cancelButton, flexible, doneButton], animated: false)
        
        txfBirthday.inputAccessoryView = toolbar
        txfBirthday.inputView = datePicker
    }
    
    private func loadProfile() {
        imvUserProfile.loadImageFromUrl(g_myInfo.profileImage, placeholder: "profile.placeholder")
        
        txfFirstName.text = g_myInfo.firstName
        txfLastName.text = g_myInfo.lastName
        
        txfEmail.text = g_myInfo.emailAddress
        
        let location = g_myInfo.address
        txfLocation.text = location
        txfLocation.iconTintColor = location.isEmpty ? .colorGray11 : .colorPrimary
        
        let birthday = g_myInfo.birthDay.toDateString(fromFormat: "dd-MM-yyyy", toFormat: "d MMM yyyy")
        txfBirthday.text = birthday
        txfBirthday.iconTintColor = birthday.isEmpty ? .colorGray11 : .colorPrimary
        
        let gender = g_myInfo.gender
        if gender == 0 {
            genderSelected(txfFemale, isSelected: false)
            genderSelected(txfMale, isSelected: true)
            selectedGender = .Male
            
        } else {
            genderSelected(txfMale, isSelected: false)
            genderSelected(txfFemale, isSelected: true)
            selectedGender = .Female
        }
    }
    
    private func setupTextField(_ textField: RoundRectTextField, placeholder: String, iconName: String) {
        textField.backgroundColor = .white
        textField.borderColor = .colorGray17
        textField.borderWidth = 1
        textField.iconTintColor = .colorPrimary
        if #available(iOS 13.0, *) {
            textField.rightImage = UIImage(systemName: iconName)
        } else {
            // Fallback on earlier versions
        }
        textField.placeholder = placeholder
        textField.tintColor = .colorGray19
        textField.textColor = .colorGray19
        textField.font = UIFont(name: "SegoeUI-Light", size: 18)
        textField.inputPadding = 16
        textField.rightPadding = 12
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
    }
    
    @objc func dateSelected() {
        guard let datePicker = txfBirthday.inputView as? UIDatePicker else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "d MMM yyyy"
        
        txfBirthday.text = dateFormatter.string(from: datePicker.date)
        // should call validation check
        checkValidation(textField: txfBirthday)
        txfBirthday.resignFirstResponder()
    }
    
    @objc func dateCanceled() {
        txfBirthday.resignFirstResponder()
    }
    
    @IBAction func didTapCamera(_ sender: Any) {
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
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapUpdate(_ sender: Any) {
        guard isValid() else { return }
        
        let birthday = txfBirthday.text!.toDateString(fromFormat: "d MMM yyyy ", toFormat: "dd-MM-yyyy")
        
        let params = [
            "token" : g_myToken,
            "user_email" : txfEmail.text!,
            "first_name" : txfFirstName.text!,
            "last_name" : txfLastName.text!,
            "country" : txfLocation.text!,
            "lat": latitude,
            "lng": longitude,
            "range": "\(radius)",
            "birthday" : birthday,
            "gender" : String(selectedGender.rawValue)
        ]
        
        showIndicator()
        ATB_Alamofire.shareInstance.upload(
            multipartFormData: { (multipartFormData) in
                if let selected = self.selectedPhoto {
                    multipartFormData.append(selected, withName: "pic", fileName: "profileimg.jpg", mimeType: "image/jpeg")
                }
                
                let contentDict = params
                for (key, value) in contentDict {
                    multipartFormData.append((value.data(using: .utf8)!), withName: key)
                }
            },
            to: UPDATE_PROFILE_API,
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
                if let ok = res["result"] as? Bool
                {
                    if ok
                    {
                        let userInfo = res["msg"] as! NSDictionary
                        g_myInfo = User(info: userInfo)
                        
                        NotificationCenter.default.post(name: .DidUpdateUserSettings, object: nil)
                        self.showSuccessVC(msg: "User details has been updated successfully!")
                    }
                    else
                    {
                        let msg = res["msg"] as? String ?? ""
                        
                        if(msg == "")
                        {
                            self.showErrorVC(msg: "User update Failed.")
                        }
                        else
                        {
                            self.showErrorVC(msg: "Server returned the error message: " + msg)
                        }
                    }
                }
                
            case .failure(_):
                self.showErrorVC(msg: "It's failed to update user details.")
            }
        }
    }
    
    // update gender selection
    private func updateGenderSelection(_ gender: Gender)  {
        selectedGender = gender
        
        if gender == .Female {
            genderSelected(txfFemale, isSelected: true)
            genderSelected(txfMale, isSelected: false)
            
        } else {
            genderSelected(txfMale, isSelected: true)
            genderSelected(txfFemale, isSelected: false)
        }
    }
    
    private func genderSelected(_ textField: UITextField, isSelected: Bool) {
        if isSelected {
            textField.backgroundColor = .white
            textField.textColor = .colorGray19
            textField.rightViewMode = .always
            
        } else {
            textField.backgroundColor = .colorGray14
            textField.textColor = .colorGray11
            textField.rightViewMode = .never
        }
    }
    
    // gender buttons clicked
    let genderMaleTag = 450
    @IBAction func didTapGender(_ sender: UIButton) {
        updateGenderSelection(sender.tag == genderMaleTag ? .Male : .Female)
    }
    
    // whenever text is updated, pass through validation check
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkValidation(textField: textField)
    }
    
    // this is to update the rightview of UITextField
    // you can put your own validation check here
    // right now simple validation is going through
    func checkValidation(textField: UITextField) {
        if textField == txfFirstName || textField == txfLastName {
            guard !textField.isEmpty() else {
                textField.rightViewMode = .never
                return
            }
            
            textField.rightViewMode = .always
            return
        }
        
        if textField == txfEmail {
            guard !textField.isEmpty(),
                textField.text!.isValidEmail() else {
                    textField.rightViewMode = .never
                    return
            }
            
            textField.rightViewMode = .always
            return
        }
        
        if textField == txfLocation || textField == txfBirthday {
            guard let roundTextField = textField as? RoundRectTextField else {
                return
            }
            
            if textField.isEmpty() {
                roundTextField.iconTintColor = .colorGray11
                return
            }
            
            roundTextField.iconTintColor = .colorPrimary
            return
        }
    }
    
    // add validation here
    func isValid() -> Bool {
        // you can even show toats or alerts whenever it's needed
        //
        return true
    }
}

// MARK: - UITextFieldDelegate
extension UserSettingsViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txfLocation {
           let toVC = LocationViewController.instance()
            toVC.selectedAddress = g_myInfo.address
            toVC.locationInputDelegate = self
            self.navigationController?.pushViewController(toVC, animated: true)
            
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txfFirstName {
            txfLastName.becomeFirstResponder()
            
        } else if textField == txfLastName {
            txfEmail.becomeFirstResponder()
        }
        
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: - LocationInputDelegate
extension UserSettingsViewController: LocationInputDelegate {
    
    func locationSelected(address: String, latitude: String, longitude: String, radius: Float) {
        txfLocation.text = address
        
        self.latitude = latitude
        self.longitude = longitude
        
        self.radius = radius
        
        // should call validation
        checkValidation(textField: txfLocation)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension UserSettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let editedImage = info[.editedImage] as? UIImage,
              let selected = editedImage.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        imvUserProfile.image = editedImage
        // keep the photo data to upload to server
        selectedPhoto = selected
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}



