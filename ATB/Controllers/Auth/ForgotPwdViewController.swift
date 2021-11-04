//
//  ForgotPwdViewController.swift
//  ATB
//
//  Created by mobdev on 19/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import TTGTagCollectionView

class ForgotPwdViewController: BaseViewController {
    
    static let kStoryboardID = "ForgotPwdViewController"
    class func instance() -> ForgotPwdViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: ForgotPwdViewController.kStoryboardID) as? ForgotPwdViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvBack: UIImageView!
    
    @IBOutlet weak var lblForgotPassword: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var emailField: RoundRectTextField!
    @IBOutlet weak var emailTagView: TTGTextTagCollectionView!
    
    private let emailInputView: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60)
        button.setTitle("Send Request", for: .normal)
        button.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        button.backgroundColor = .colorPrimary
        button.addTarget(self, action: #selector(didTapSendRequest(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailField.becomeFirstResponder()
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
        
        let forgotPassword = NSMutableAttributedString(string: " Password Forgotten?", attributes: [
            .font: UIFont(name: Font.SegoeUISemibold, size: 20)!,
            .foregroundColor: UIColor.colorGray2
            ])
        forgotPassword.insert(NSAttributedString(attachment: lockAttachment), at: 0)
        lblForgotPassword.attributedText = forgotPassword
        
        lblDescription.text = "To recover your password, you need to enter your registered email address. We will send you the recovery code to your email"
        lblDescription.textColor = .colorGray2
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.numberOfLines = 0
        
        // confirm email field
        setupInputField(emailField, placeholder: "Use your email")
        emailField.keyboardType = .emailAddress
        emailField.rightViewMode = .whileEditing
        emailField.returnKeyType = .done
        emailField.autocorrectionType = .no
        
        // clear button
        let clearButton = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        clearButton.frame = CGRect(x: 0, y: 0, width: 24, height: emailField.bounds.size.height)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(didTapClearEmail(_:)), for: .touchUpInside)
        clearButton.tintColor = .colorGray10
        emailField.rightView = clearButton
        emailField.rightPadding = 12
        
        emailField.inputAccessoryView = emailInputView
        
        setupTagCollectionView()
        
        updateInputView(false)
    }
    
    // setup input field
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
            
            if #available(iOS 13.0, *) {
                textField.rightImage = UIImage(systemName: image)
                
            } else {
                // Fallback on earlier versions
            }
        }
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
    }
    
    private let emailTags = ["@gmail.com", "@outlook.com", "@icloud.com", "@hotmail.com", "@yahoo.com"]
    private func setupTagCollectionView() {
        // email tag view
        guard let emailConfig = emailTagView.defaultConfig else { return }
        
        emailConfig.textFont = UIFont(name: Font.SegoeUILight, size: 18)
        emailConfig.textColor = .colorGray12
        emailConfig.selectedTextColor = .colorGray12
        emailConfig.backgroundColor = .colorGray4
        emailConfig.selectedBackgroundColor = .colorGray4
        emailConfig.borderColor = .colorGray4
        emailConfig.selectedBorderColor = .colorGray4
        emailConfig.borderWidth = 1
        emailConfig.selectedBorderWidth = 1
        emailConfig.shadowColor = .black
        emailConfig.shadowOffset = CGSize(width: 0, height: 0.3)
        emailConfig.shadowOpacity = 0.3
        emailConfig.shadowRadius = 0.5
        emailConfig.cornerRadius = 5
        emailConfig.exactHeight = 30
        emailConfig.enableGradientBackground = false
        
        emailTagView.scrollDirection = .horizontal
        emailTagView.alignment = .fillByExpandingWidth
        emailTagView.numberOfLines = 1
        emailTagView.horizontalSpacing = 10.0
        emailTagView.verticalSpacing = 4.0
        emailTagView.showsVerticalScrollIndicator = false
        emailTagView.showsHorizontalScrollIndicator = false
        emailTagView.scrollView.bounces = false
        emailTagView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 16)
        emailTagView.addTags(emailTags)
        emailTagView.delegate = self
        emailTagView.reload()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkValidation()
    }
    
    @objc private func didTapClearEmail(_ sender: Any) {
        emailField.text = ""
        
        checkValidation()
    }
    
    private func completeEmailInput(for textField: UITextField, with tag: String) {
        guard let text = textField.text,
            !text.isEmpty else { return }
        
        textField.text = text + tag
        
        // check validation to enable 'Send Request' button
        checkValidation()
    }
    
    private func checkValidation() {
        guard let email = emailField.text,
              !email.isEmpty,
              email.isValidEmail() else {
            updateInputView(false)
            return
        }
        
        updateInputView(true)
    }
    
    private func updateInputView(_ enabled: Bool) {
        emailInputView.setTitleColor(enabled ? UIColor.white : UIColor.white.withAlphaComponent(0.22) , for: .normal)
    }
    
    private func isValid() -> Bool {
        guard let email = emailField.text,
              !email.isEmpty else {
            showErrorVC(msg: "Please enter your email address.")
            return false
        }
        
        guard email.isValidEmail() else {
            showErrorVC(msg: "Please enter a valid email address.")
            return false
        }
        
        return true
    }
    
    @objc private func didTapSendRequest(_ sender: Any) {
        sendRequest()
    }
    
    private func sendRequest() {
        guard isValid() else { return }
        
        emailField.resignFirstResponder()
        
        let email = emailField.text!.trimmedString
        
        let params = ["email": email]
        _ = ATB_Alamofire.POST(SEND_PWDRESETEMAIL_API, parameters: params as [String: AnyObject], showLoading: true, completionHandler: { (result, response) in
            guard result else {
                let message = response.object(forKey: "message") as? String ?? "Sorry, we couldn't find your email address in our record."
                self.showInfoVC("ATB", msg: message)
                return
            }
            
            self.gotoVerification(email)
        })
    }
    
    private func gotoVerification(_ email: String) {
        let toVC = CodeVerificationViewController.instance()
        toVC.email = email
        
        self.navigationController?.pushViewController(toVC, animated: true)
    }
    
    @IBAction func didTapBaack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension ForgotPwdViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendRequest()
        
        return true
    }
}

// MARK: - TTGTextTagCollectionViewDelegate
extension ForgotPwdViewController: TTGTextTagCollectionViewDelegate {
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTapTag tagText: String!, at index: UInt, selected: Bool, tagConfig config: TTGTextTagConfig!) {
        completeEmailInput(for: emailField, with: tagText)
    }
}
