//
//  CodeVerificationViewController.swift
//  ATB
//
//  Created by mobdev on 19/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import CHIOTPField

class CodeVerificationViewController: BaseViewController {
    
    static let kStoryboardID = "CodeVerificationViewController"
    class func instance() -> CodeVerificationViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: CodeVerificationViewController.kStoryboardID) as? CodeVerificationViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvBack: UIImageView!
    
    @IBOutlet weak var lblVerification: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var otpFieldContainer: UIView!
    private var otpField: CHIOTPFieldTwo!
    @IBOutlet weak var lblDidNotReceive: UILabel!
    @IBOutlet weak var btnResend: UIButton!
    
    private let codeInputView: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60)
        button.setTitle("Verify Code", for: .normal)
        button.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        button.backgroundColor = .colorPrimary
        button.addTarget(self, action: #selector(didTapVerifyCode(_:)), for: .touchUpInside)
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
        
        otpField.becomeFirstResponder()
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
            lockAttachment.setImageHeight(height: 24, verticalOffset: -4)
            
        } else {
            // Fallback on earlier versions
        }
        
        let verification = NSMutableAttributedString(string: " Recovery Code Verification", attributes: [
            .font: UIFont(name: Font.SegoeUISemibold, size: 20)!,
            .foregroundColor: UIColor.colorGray2
            ])
        verification.insert(NSAttributedString(attachment: lockAttachment), at: 0)
        lblVerification.attributedText = verification
        lblVerification.textAlignment = .center
        
        lblDescription.text = "Please enter the 6 digit code to recover your password. If you're not getting a recovery code yet, please click resent button"
        lblDescription.textColor = .colorGray2
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.numberOfLines = 0
        lblDescription.textAlignment = .center
        
        setupOTPField()
        
        lblDidNotReceive.text = "I didn't receive any code"
        lblDidNotReceive.textColor = .colorGray2
        lblDidNotReceive.font = UIFont(name: Font.SegoeUILight, size: 15)
        
        let resendTitle = "Re-send code "
        let attributedResend = NSMutableAttributedString(string: resendTitle)
        /// add arrow attachment
        let nextAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            nextAttachment.image = UIImage(systemName: "chevron.right")?.withTintColor(.colorPrimary)
        } else {
            // Fallback on earlier versions
        }
        attributedResend.append(NSAttributedString(attachment: nextAttachment))
        attributedResend.addAttributes(
            [.foregroundColor: UIColor.colorPrimary,
             .font: UIFont(name: Font.SegoeUISemibold, size: 16)!,
             .underlineStyle: NSUnderlineStyle.single.rawValue,
             .underlineColor: UIColor.colorPrimary],
            range: NSRange(location: 0, length: attributedResend.length))
        btnResend.setAttributedTitle(attributedResend, for: .normal)
        
        setupOTPField()
        
        updateInputView(false)
    }
    
    private func setupOTPField() {
        let otpFieldWidth: CGFloat = SCREEN_WIDTH - 32
        otpField = CHIOTPFieldTwo(frame: CGRect(x: 16, y: 0, width: otpFieldWidth, height: 56))
        otpFieldContainer.addSubview(otpField)
        otpField.numberOfDigits = 6
        otpField.cornerRadius = 5
        otpField.borderColor = .colorGray17
        otpField.tintColor = .colorGray19
        otpField.labels.forEach { (label) in
            label.textColor = .colorGray19
        }
        otpField.font = UIFont(name: Font.SegoeUISemibold, size: 24)
        otpField.activeBorderColor = .colorPrimary
        otpField.filledBorderColor = .colorPrimary
        otpField.otpFieldDelegate = self
        
        otpField.inputAccessoryView = codeInputView
    }
    
    private func updateInputView(_ enabled: Bool) {
        codeInputView.setTitleColor(enabled ? UIColor.white : UIColor.white.withAlphaComponent(0.22) , for: .normal)
    }
    
    private func isValid() -> Bool {
        guard let code = otpField.text,
              !code.isEmpty else {
            showInfoVC("ATB", msg: "Please enter the verification code you received in your email.")
            return false
        }
        
        guard code.count >= 6 else {
            showInfoVC("ATB", msg: "The verification code should be 6 digit code.")
            return false
        }
        
        return true
    }
    
    @objc private func didTapVerifyCode(_ sender: Any) {
        guard isValid() else { return }
        
        let code = otpField.text!
        
        let params = [
            "email": email,
            "verifycode": code
        ]
        
        _ = ATB_Alamofire.POST(RESETCODE_VERIFY_API, parameters: params as [String: AnyObject], showLoading: true, completionHandler: { (result, response) in
            guard result else {
                let message = response.object(forKey: "message") as? String ?? "Incorrect verification code."
                self.showInfoVC("ATB", msg: message)
                return
            }
            
            self.gotoReset()
        })
    }
    
    private func checkValidation() {
        guard let code = otpField.text,
              code.count >= 6 else {
            updateInputView(false)
            return
        }
        
        updateInputView(true)
    }
    
    @IBAction func didTapResend(_ sender: Any) {
        resendRequest()
    }
    
    private func resendRequest() {
        let params = ["email": email]
        
        _ = ATB_Alamofire.POST(SEND_PWDRESETEMAIL_API, parameters: params as [String: AnyObject], showLoading: true, completionHandler: { (result, response) in
            guard result else {
                let message = response.object(forKey: "message") as? String ?? "Sorry, we couldn't find your email address in our record."
                self.showInfoVC("ATB", msg: message)
                return
            }
            
            self.showInfoVC("ATB", msg: "A new verification code has been sent to your email.")
        })
    }
    
    private func gotoReset() {
        let toVC = ResetPwdViewController.instance()
        toVC.email = email
        
        navigationController?.pushViewController(toVC, animated: true)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - OTPFieldDelegate
extension CodeVerificationViewController: OTPFieldDelegate {
    
    func textChanged() {
        checkValidation()
    }
}
