//
//  ResetPwdViewController.swift
//  ATB
//
//  Created by mobdev on 19/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class ResetPwdViewController: BaseViewController {
    
    static let kStoryboardID = "ResetPwdViewController"
    class func instance() -> ResetPwdViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: ResetPwdViewController.kStoryboardID) as? ResetPwdViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvBack: UIImageView!
    
    @IBOutlet weak var lblReset: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var passwordField: PasswordTextField!
    @IBOutlet weak var confirmPwdField: PasswordTextField!
    
    @IBOutlet weak var lblAlert: UILabel! { didSet {
        lblAlert.text = ""
        lblAlert.font =  UIFont(name: Font.SegoeUILight, size: 15)
        lblAlert.textColor = .colorRed1
        lblAlert.numberOfLines = 0
    }}
    
    private let passwordInputView: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60)
        button.backgroundColor = .colorPrimary
        button.addTarget(self, action: #selector(didTapReset(_:)), for: .touchUpInside)
        return button
    }()
    
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        passwordField.becomeFirstResponder()
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
        // back button
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")
        } else {
            // Fallback on earlier versions
        }
        imvBack.tintColor = .colorPrimary
        imvBack.contentMode = .scaleAspectFit
        
        let lockAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            lockAttachment.image = UIImage(systemName: "lock.fill")?.withTintColor(.colorGray2)
            lockAttachment.setImageHeight(height: 24, verticalOffset: -2)
            
        } else {
            // Fallback on earlier versions
        }
        
        let reset = NSMutableAttributedString(string: " Set a new Password", attributes: [
            .font: UIFont(name: Font.SegoeUISemibold, size: 20)!,
            .foregroundColor: UIColor.colorGray2
            ])
        reset.insert(NSAttributedString(attachment: lockAttachment), at: 0)
        lblReset.attributedText = reset
        
        lblDescription.text = "You'll be changing the password for accessing the app."
        lblDescription.textColor = .colorGray2
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.numberOfLines = 0
        
        setupInputField(passwordField, placeholder: "Set a password")
        passwordField.returnKeyType = .next
        passwordField.inputAccessoryView = passwordInputView
        
        setupInputField(confirmPwdField, placeholder: "Repeat password")
        confirmPwdField.returnKeyType = .done
        confirmPwdField.inputAccessoryView = passwordInputView
        
        lblAlert.isHidden = true
        
        updateInputView(false)
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
    
    private func updateInputView(_ enabled: Bool) {
        let setTitle = "Set new Password "
        let attributedSetTitle = NSMutableAttributedString(string: setTitle)
        
        /// add arrow attachment
        let nextAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            nextAttachment.image = enabled ? UIImage(systemName: "chevron.right")?.withTintColor(.white) : UIImage(systemName: "chevron.right")?.withTintColor(UIColor.white.withAlphaComponent(0.22))
        } else {
            // Fallback on earlier versions
        }
        attributedSetTitle.append(NSAttributedString(attachment: nextAttachment))
        /// add text attributes
        attributedSetTitle.addAttributes(
            [.font: UIFont(name: Font.SegoeUISemibold, size: 18)!,
             .foregroundColor: enabled ? UIColor.white : UIColor.white.withAlphaComponent(0.22)],
            range: NSRange(location: 0, length: setTitle.count-1))
        passwordInputView.setAttributedTitle(attributedSetTitle, for: .normal)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        checkValidation()
        
        if !lblAlert.isHidden {
            hideInvalidPasswordAlert()
        }
    }
    
    private func checkValidation() {
        guard let password = passwordField.text,
              password.count >= 6 else {
            updateInputView(false)
            return
        }
        
        guard let confirmPassword = confirmPwdField.text,
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
        guard let password = passwordField.text,
              !password.isEmpty else {
            alertForInvalidPassword(for: .PasswordRequired)
            return false
        }
        
        guard password.count >= 6 else {
            alertForInvalidPassword(for: .PasswordLength)
            return false
        }
        
        guard let confirmPassword = confirmPwdField.text,
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
            alertMessage = "Please enter a new password."
            
        case .PasswordLength:
            alertMessage = "Password must be at least 6 charaters"
            
        case .ConfirmPasswordRequired:
            alertMessage = "Please re-enter the new password."
            
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
    
    @objc private func didTapReset(_ sender: Any) {
        resetPassword()
    }
    
    private func resetPassword() {
        guard isValid() else { return }
        
        view.endEditing(true)
        
        let newPassword = passwordField.text!
        
        let params = [
            "email": email,
            "pass": newPassword
        ]
        
        _ = ATB_Alamofire.POST(PWDRESET_API, parameters: params as [String: AnyObject], showLoading: true, completionHandler: { (result, response) in
            guard result else {
                let message = response.object(forKey: "messsage") as? String ?? "It's been failed to reset your password, please try again"
                self.showInfoVC("ATB", msg: message)
                return
            }
            
            self.showAlert("ATB", message: "Your password has been updated successfully!", negative: "Thanks", negativeAction: { _ in
                self.gotoLogin()
                
            }, preferredStyle: .actionSheet)
        })
    }
    
    private func gotoLogin() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension ResetPwdViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordField {
            textField.resignFirstResponder()
            confirmPwdField.becomeFirstResponder()
            
        } else if textField == confirmPwdField {
            resetPassword()
        }
        
        return true
    }
}
