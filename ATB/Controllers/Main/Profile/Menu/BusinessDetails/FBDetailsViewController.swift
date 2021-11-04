//
//  FBDetailsViewController.swift
//  ATB
//
//  Created by YueXi on 7/22/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

// MARK: FBConnectDelegate
protocol FBConnectDelegate {
    
    func facebookConnected(_ username: String)
}

class FBDetailsViewController: BaseViewController {
    
    static let kStoryboardID = "FBDetailsViewController"
    class func instance() -> FBDetailsViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: FBDetailsViewController.kStoryboardID) as? FBDetailsViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvFBLogo: UIImageView!
    @IBOutlet weak var lblConfirmDetails: UILabel!
    @IBOutlet weak var imvClose: UIImageView!
    
    @IBOutlet weak var imvProfilePicture: UIImageView! { didSet {
        imvProfilePicture.layer.cornerRadius = 33
        imvProfilePicture.layer.masksToBounds = true
        imvProfilePicture.contentMode = .scaleAspectFill
        }}
    @IBOutlet weak var lblProfilePicture: UILabel!
    
    @IBOutlet weak var lblCreator: UILabel!
    @IBOutlet weak var txfCreator: RoundRectTextField!

    @IBOutlet weak var lblBusinessName: UILabel!
    @IBOutlet weak var txfBusinessName: RoundRectTextField! { didSet {
        txfBusinessName.isUserInteractionEnabled = false
        }}
    
    @IBOutlet weak var lblURL: UILabel!
    @IBOutlet weak var txfURL: RoundRectTextField!
    
    @IBOutlet weak var lblPrimaryPage: UILabel!
    @IBOutlet weak var txfPrimaryPage: RoundRectTextField!
    
    @IBOutlet weak var btnLink: UIButton!
    
    let imagePicker = UIImagePickerController()
    var profileImage: UIImage? = nil
    
    @IBOutlet weak var containerView: UIView! { didSet {
        containerView.backgroundColor = .colorGray14
        }}
    
    var username: String = "" // user id
    var name: String = "" // full name
    var link: String = ""
    var profileLink: String = ""
    
    var delegate: FBConnectDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image"]
    }
    
    func setupViews() {
        imvFBLogo.image = UIImage(named: "social_fb")
        imvFBLogo.contentMode = .scaleAspectFit
        
        lblConfirmDetails.text = "Confirm Your Details"
        lblConfirmDetails.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblConfirmDetails.textColor = .colorGray19
        
        if #available(iOS 13.0, *) {
            imvClose.image = UIImage(systemName: "xmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvClose.tintColor = .colorGray4
        
        imvProfilePicture.loadImageFromUrl(profileLink, placeholder: "profile.placeholder")
        lblProfilePicture.text = "PROFILE PICTURE"
        lblProfilePicture.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblProfilePicture.textColor = .colorGray19
        
        setupLabel(lblCreator, title: "CREATOR OF THE BUSINESS")
        setupInputField(txfCreator)
        txfCreator.text = name
        setupLabel(lblBusinessName, title: "THE BUSINESS NAME")
        setupInputField(txfBusinessName)
        txfBusinessName.text = name
        setupLabel(lblURL, title: "URL FOR THE BUSINESS PAGE")
        setupInputField(txfURL)
        txfURL.text = link
        setupLabel(lblPrimaryPage, title: "THE PRIMARY FACEBOOK\nPAGE FOR THE BUSINESS")
        lblPrimaryPage.numberOfLines = 2
        setupInputField(txfPrimaryPage)
        
        btnLink.setTitle("  Link with this Information", for: .normal)
        btnLink.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        btnLink.setImage(UIImage(named: "add_link")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnLink.layer.cornerRadius = 5
        
//        lblBusinessName
        updateLinkButton(true)
    }
    
    private func setupLabel(_ label: UILabel, title: String) {
        label.text = title
        label.font = UIFont(name: Font.SegoeUILight, size: 18)
        label.textColor = UIColor.colorGray19.withAlphaComponent(0.4)
    }
    
    private func setupInputField(_ textField: RoundRectTextField, placeholder: String = "") {
        textField.backgroundColor = .white
        textField.borderColor = .colorGray17
        textField.borderWidth = 1

        textField.placeholder = placeholder
        textField.tintColor = .colorGray19
        textField.textColor = .colorGray19
        textField.font = UIFont(name: "SegoeUI-Light", size: 18) // 23 (design size) looks little weird
        textField.inputPadding = 16

        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
    }
    
    private func updateLinkButton(_ isEnabled: Bool) {
        if isEnabled {
            btnLink.backgroundColor = .colorBlue5
            btnLink.setTitleColor(.white, for: .normal)
            btnLink.tintColor = .white
            
        } else {
            btnLink.backgroundColor = UIColor.colorBlue5.withAlphaComponent(0.5)
            btnLink.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
            btnLink.tintColor = UIColor.white.withAlphaComponent(0.5)
        }
    }
    
    /// always check validation and update 'Save Business Details' button
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // update validation here whenever text is changed or just call this on DidEndEditing if you want
        checkValidation()
    }
    
    private func checkValidation() {
        guard let _ = profileImage,
            !txfCreator.isEmpty(),
            !txfBusinessName.isEmpty(),
            !txfURL.isEmpty(),
            !txfPrimaryPage.isEmpty() else {
                updateLinkButton(false)
                return
        }

        updateLinkButton(true)
    }
    
    @IBAction func didTapProfilePicture(_ sender: Any) {
//        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//        if let camera = actionAction(for: .camera, title: "Take photo") {
//            alertController.addAction(camera)
//        }
//
//        if let photoLibrary = actionAction(for: .photoLibrary, title: "Photo Library") {
//            alertController.addAction(photoLibrary)
//        }
//
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        alertController.view.tintColor = .colorPrimary
//
//        self.present(alertController, animated: true, completion: nil)
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
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapLink(_ sender: Any) {
        showIndicator()
        
        // pass '0' as type for facebook
        APIManager.shared.addSocial(g_myToken, type: "0", name: username) { (result, message) in
            self.hideIndicator()
            
            if result {
                self.dismiss(animated: true) {
                    self.delegate?.facebookConnected(self.username)
                }
                
            } else {
                self.showErrorVC(msg: "We were unable to link your facebook account in your business profile.")
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension FBDetailsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txfCreator {
            txfBusinessName.becomeFirstResponder()
            
        } else if textField == txfBusinessName {
            txfURL.becomeFirstResponder()
            
        } else if textField ==  txfURL {
            txfPrimaryPage.becomeFirstResponder()
        }
        
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: - UIImagePickerControllerDelegate
extension FBDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        
//        let imgdata = image.jpegData(compressionQuality: 1.0)
//        self.photoData = imgdata!
        profileImage = image
        imvProfilePicture.image = image
        checkValidation()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
        profileImage = nil
        checkValidation()
    }
}
