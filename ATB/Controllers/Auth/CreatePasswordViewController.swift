//
//  CreatePasswordViewController.swift
//  ATB
//
//  Created by YueXi on 5/29/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class CreatePasswordViewController: BaseViewController {
    
    static let kStoryboardID = "CreatePasswordViewController"
    class func instance() -> CreatePasswordViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: CreatePasswordViewController.kStoryboardID) as? CreatePasswordViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvBack: UIImageView!
    @IBOutlet weak var lblBack: UILabel!
    
    @IBOutlet weak var lblHeadLineOne: UILabel!
    
    @IBOutlet weak var txfPassword: PasswordTextField!
    @IBOutlet weak var txfConfirmPwd: PasswordTextField!
    
    @IBOutlet weak var lblAlert: UILabel! { didSet {
        lblAlert.text = ""
        lblAlert.font =  UIFont(name: Font.SegoeUILight, size: 15)
        lblAlert.textColor = .colorRed1
        lblAlert.numberOfLines = 0
        }}
    
    let passwordInputView: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60)
        button.backgroundColor = .colorPrimary
        button.addTarget(self, action: #selector(didTapCreateProfile(_:)), for: .touchUpInside)
        return button
    }()
    
    var fbToken:String = ""
    
    var email:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        txfPassword.becomeFirstResponder()
    }
    
    private func setupViews() {
        self.view.backgroundColor = .colorGray14
        
        imvBack.contentMode = .scaleAspectFit
        // back button
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")
        } else {
            // Fallback on earlier versions
        }
        imvBack.tintColor = .colorPrimary
        
        lblBack.text = "Back To Email"
        lblBack.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblBack.textColor = .colorPrimary
        
        let lockAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            lockAttachment.image = UIImage(systemName: "lock.fill")?.withTintColor(.colorGray2)
            
        } else {
            // Fallback on earlier versions
        }
        
        let headlineOne = NSMutableAttributedString(string: " Set A Password", attributes: [
            .font: UIFont(name: Font.SegoeUISemibold, size: 20)!,
            .foregroundColor: UIColor.colorGray2
        ])
        headlineOne.insert(NSAttributedString(attachment: lockAttachment), at: 0)
        lblHeadLineOne.attributedText = headlineOne
        
        setupInputField(txfPassword, placeholder: "Password")
        txfPassword.returnKeyType = .next
        txfPassword.inputAccessoryView = passwordInputView
        
        setupInputField(txfConfirmPwd, placeholder: "Repeat password")
        txfConfirmPwd.returnKeyType = .done
        txfConfirmPwd.inputAccessoryView = passwordInputView
        
        updateInputView(false)
        
        lblAlert.isHidden = true
    }
    
    private func setupInputField(_ textField: PasswordTextField, placeholder: String) {
        textField.backgroundColor = .white
        textField.borderColor = .colorGray17
        textField.borderWidth = 1
        textField.placeholder = placeholder
        textField.font = UIFont(name: Font.SegoeUILight, size: 18)
        textField.textColor = .colorGray19
        textField.tintColor = .colorGray19
        textField.inputPadding = 16
        textField.rightPadding = 12
        
        if #available(iOS 13.0, *) {
            textField.showSecureTextImage = UIImage(systemName: "eye")
            textField.hideSecureTextImage = UIImage(systemName: "eye.slash")
            
        } else {
            // Fallback on earlier versions
        }
            
        textField.showTintColor = .colorPrimary
        textField.hideTintColor = .colorGray17
        textField.rightViewMode = .always
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkValidation()
        
        if !lblAlert.isHidden {
            hideInvalidPasswordAlert()
        }
    }
    
    private func updateInputView(_ enabled: Bool) {
        // Do whatever you need more UI effect like button background color
        let complete = "Complete and set your profile "
        
        let attributedTitle = NSMutableAttributedString(string: complete)
        
        /// add arrow attachment
        let textAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            textAttachment.image = enabled ? UIImage(systemName: "chevron.right")?.withTintColor(.white) : UIImage(systemName: "chevron.right")?.withTintColor(UIColor.white.withAlphaComponent(0.22))
        } else {
            // Fallback on earlier versions
        }
        attributedTitle.append(NSAttributedString(attachment: textAttachment))
        /// add text attributes
        attributedTitle.addAttributes(
            [.font: UIFont(name: Font.SegoeUIBold, size: 18)!,
             .foregroundColor: enabled ? UIColor.white : UIColor.white.withAlphaComponent(0.22)],
            range: NSRange(location: 0, length: complete.count-1))
        passwordInputView.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    // current user experience design is little weird with green tick and alert
    // if the green tick is supposed to be shown if the password is matched, then we don't need the alert
    // currently this is doing form validation check
    private func checkValidation() {
        guard let password = txfPassword.text,
              password.count >= 6 else {
            updateInputView(false)
            return
        }
        
        guard let confirmPassword = txfConfirmPwd.text,
              !confirmPassword.isEmpty else {
            updateInputView(false)
            return
        }
        
        guard confirmPassword.count >= 6,
              password == confirmPassword else {
            updateInputView(false)
            return
        }
        
        updateInputView(true)
    }
    
    private func isValid() -> Bool {
        guard let password = txfPassword.text,
              !password.isEmpty else {
            alertForInvalidPassword(for: .PasswordRequired)
            return false
        }
        
        guard password.count >= 6 else {
            alertForInvalidPassword(for: .PasswordLength)
            return false
        }
        
        guard let confirmPassword = txfConfirmPwd.text,
              !confirmPassword.isEmpty else {
            alertForInvalidPassword(for: .ConfirmPasswordRequired)
            return false
        }
        
        guard confirmPassword.count >= 6 else {
            alertForInvalidPassword(for: .ConfirmPasswordLength)
            return false
        }
        
        guard password == confirmPassword else {
            alertForInvalidPassword(for: .PasswordDoNotMatch)
            return false
        }
        
        return true
    }
    
    private enum InvalidPassword: Int {
        case PasswordRequired
        case PasswordLength
        case ConfirmPasswordRequired
        case ConfirmPasswordLength
        case PasswordDoNotMatch
    }
    
    private func alertForInvalidPassword(for invalidType: InvalidPassword) {
        lblAlert.isHidden = false
        
        var alertMessage = ""
        switch invalidType {
        case .PasswordRequired:
            alertMessage = "Please enter your password."
            
        case .PasswordLength:
            alertMessage = "Password must be at least 6 charaters"
            
        case .ConfirmPasswordRequired:
            alertMessage = "Please re-enter your password."
            
        case .ConfirmPasswordLength, .PasswordDoNotMatch:
            alertMessage = "Passwords do not match, please try again!"
        }
        
        let attachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            attachment.image = UIImage(systemName: "exclamationmark.circle.fill")?.withTintColor(.colorRed1)
        } else {
            // Fallback on earlier versions
        }
        
        alertMessage = " " + alertMessage
        
        let attributedText = NSMutableAttributedString(string: alertMessage)
        attributedText.insert(NSAttributedString(attachment: attachment), at: 0)
        lblAlert.attributedText = attributedText
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.lblAlert.alpha = 1.0
        })
    }
    
    private func hideInvalidPasswordAlert() {
        UIView.animate(withDuration: 0.25, animations: {
            self.lblAlert.alpha = 0.0
            
        }, completion: { _ in
            self.lblAlert.isHidden = true
        })
    }
    
    @objc func didTapCreateProfile(_ sender: Any) {
        createAccount()
    }
    
    private func createAccount() {
        guard isValid() else { return }
        
        // hide keyboard
        self.view.endEditing(true)
        
        let fcmToken = ATB_UserDefault.getFCMToken()
        
        let params = [
            "email" : email,
            "pwd" : txfPassword.text!,
            "fbToken": fbToken,
            "fcmtoken" : fcmToken]
        
        showIndicator()
        _ = ATB_Alamofire.POST(STAGE_ONE_REGISTER_API, parameters: params as [String : AnyObject]) { (result, response) in
            self.hideIndicator()
            
            guard result else {
                let message = response.object(forKey: "msg") as? String ?? ""
                if message.isEmpty {
                    self.showErrorVC(msg: "It's been failed to create your account!")
                    
                } else {
                    self.showErrorVC(msg: "Server returned the error message: " + message)
                }
                
                return
            }
            
            let userToken = response.object(forKey: "msg") as! String
            g_myToken = userToken
            
            ATB_UserDefault.setUserToken(token: userToken)
            ATB_UserDefault.setFBToken(val: self.fbToken)
            ATB_UserDefault.setUserEmail(email: self.email)
            ATB_UserDefault.setPassword(val: self.txfPassword.text!)
            
            self.gotoCreateProfile()
        }
    }
    
    // go to create profile
    private func gotoCreateProfile() {
        let createProfileVC = CreateProfileViewController.instance()
        let nvc = UINavigationController(rootViewController: createProfileVC)
        nvc.isNavigationBarHidden = true
        nvc.modalPresentationStyle = .fullScreen
        
        self.present(nvc, animated: true, completion: nil)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CreatePasswordViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txfPassword {
            textField.resignFirstResponder()
            txfConfirmPwd.becomeFirstResponder()
            
        } else if textField == txfConfirmPwd {
            createAccount()
        }
        
        return true
    }
}
