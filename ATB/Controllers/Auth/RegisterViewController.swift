//
//  RegisterViewController.swift
//  ATB
//
//  Created by YueXi on 5/28/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import TTGTagCollectionView
import FacebookLogin
import FBSDKCoreKit

class RegisterViewController: BaseViewController {
    
    static let kStoryboardID = "RegisterViewController"
    class func instance() -> RegisterViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: RegisterViewController.kStoryboardID) as? RegisterViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvBack: UIImageView!
    @IBOutlet weak var imvLogo: UIImageView!
    @IBOutlet weak var lblSeparator: UILabel!
    @IBOutlet weak var lblCreateAccount: UILabel!
    
    @IBOutlet weak var vSignOption: UIView!
    @IBOutlet weak var lblHowToSignIn: UILabel!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var lblOr: UILabel!
    @IBOutlet weak var btnUseEmail: UIButton!
    
    @IBOutlet weak var lblBottomSeparator: UILabel!
    @IBOutlet weak var lblLogin: UILabel!
    
    @IBOutlet weak var signOptionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var signOptionBottomConstraint: NSLayoutConstraint!
    
    // Email Options
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var emailContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblHeadLineOne: UILabel!
    @IBOutlet weak var lblHeadLineTwo: UILabel!
    @IBOutlet weak var txfEmail: RoundRectTextField!
    @IBOutlet weak var txfConfirmEmail: RoundRectTextField!
    
    var fbToken:String = ""
    
    private let emailInputView: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60)
        button.backgroundColor = .colorPrimary
        button.addTarget(self, action: #selector(didTapCreatePassword(_:)), for: .touchUpInside)
        return button
    }()
    
    let tags = ["@gmail.com", "@outlook.com", "@icloud.com", "@hotmail.com", "@yahoo.com"]
    @IBOutlet weak var emailTagView: TTGTextTagCollectionView!
    @IBOutlet weak var confirmEmailTagView: TTGTextTagCollectionView!
    
    enum SignUpProgress: Int {
        case SignOption
        case InputEmail
    }
    
    var signupProgress: SignUpProgress = .SignOption

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        // back button
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")
        } else {
            // Fallback on earlier versions
        }
        imvBack.tintColor = .white
        imvBack.contentMode = .scaleAspectFit
    
        lblCreateAccount.textColor = .white
        lblCreateAccount.font = UIFont(name: "SegoeUI-Semibold", size: 21)
        lblCreateAccount.text = "Create A New Account"
        
        // sign up option view
        vSignOption.backgroundColor = .colorGray14
        lblHowToSignIn.text = "How Would You Like To Sign Up?"
        lblHowToSignIn.textColor = .colorGray2
        lblHowToSignIn.font = UIFont(name: Font.SegoeUIBold, size: 20)
        // facebook button
        btnFacebook.layer.cornerRadius = 5.0
        btnFacebook.backgroundColor = .colorBlue6
        btnFacebook.setTitle("  facebook", for: .normal)
        btnFacebook.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 22)
        btnFacebook.setTitleColor(.white, for: .normal)
        btnFacebook.setImage(#imageLiteral(resourceName: "fb.login"), for: .normal)
        btnFacebook.tintColor = .white
        
        lblOr.text = " Or "
        lblOr.textColor = .colorGray2
        lblOr.font = UIFont(name: Font.SegoeUILight, size: 18)
        // Use your email button
        btnUseEmail.layer.cornerRadius = 5.0
        btnUseEmail.layer.borderWidth = 1
        btnUseEmail.layer.borderColor = UIColor.colorGray17.cgColor
        btnUseEmail.backgroundColor = .colorBlue6
        btnUseEmail.setTitle("Use your email", for: .normal)
        btnUseEmail.titleLabel?.font = UIFont(name: "SegoeUI-Semibold", size: 20)
        btnUseEmail.setTitleColor(.white, for: .normal)
        btnUseEmail.contentHorizontalAlignment = .center
        btnUseEmail.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let prefix = "I Already Have An Account  "
        let suffix = "Sign In Instead "
        let chevronAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            chevronAttachment.image = UIImage(systemName: "chevron.right")?.withTintColor(.colorPrimary)
        } else {
            // Fallback on earlier versions
        }
        let attributedString = NSMutableAttributedString(string: prefix + suffix)
        attributedString.append(NSAttributedString(attachment: chevronAttachment))
        attributedString.addAttributes([
            .font: UIFont(name: Font.SegoeUILight, size: 15)!,
            .foregroundColor: UIColor.colorGray2
            ], range: NSRange(location: 0, length: prefix.count))
        attributedString.addAttributes([
            .font: UIFont(name: Font.SegoeUIBold, size: 16)!,
            .foregroundColor: UIColor.colorPrimary
            ], range: NSRange(location: prefix.count, length: suffix.count))
        lblLogin.attributedText = attributedString
        
        let loginGesture = UITapGestureRecognizer(target: self, action: #selector(didTapLogin(_:)))
        lblLogin.isUserInteractionEnabled = true
        lblLogin.addGestureRecognizer(loginGesture)
        
        // sign up view
        emailContainer.backgroundColor = .colorGray14
        
        let evelopeAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            evelopeAttachment.image = UIImage(systemName: "envelope.fill")?.withTintColor(.colorGray2)
            
        } else {
            // Fallback on earlier versions
        }
        
        let headlineOne = NSMutableAttributedString(string: " Use Your Email For Sign Up", attributes: [
            .font: UIFont(name: Font.SegoeUISemibold, size: 20)!,
            .foregroundColor: UIColor.colorGray2
            ])
        headlineOne.insert(NSAttributedString(attachment: evelopeAttachment), at: 0)
        lblHeadLineOne.attributedText = headlineOne
        
        lblHeadLineTwo.text = "We will use the following email everytime you try to sign up in our app"
        lblHeadLineTwo.textColor = .colorGray2
        lblHeadLineTwo.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblHeadLineTwo.numberOfLines = 0
        
        // email field
        setupInputField(txfEmail, placeholder: "Email")
        txfEmail.keyboardType = .emailAddress
        txfEmail.rightViewMode = .whileEditing
        txfEmail.returnKeyType = .next
        
        // clear button
        let clearButton = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            clearButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        clearButton.frame = CGRect(x: 0, y: 0, width: 24, height: txfEmail.bounds.size.height)
        clearButton.contentMode = .scaleAspectFit
        clearButton.addTarget(self, action: #selector(didTapClearEmail(_:)), for: .touchUpInside)
        clearButton.tintColor = .colorGray10
        txfEmail.rightView = clearButton
        txfEmail.rightPadding = 12
        
        // confirm email field
        setupInputField(txfConfirmEmail, placeholder: "Confirm Email")
        txfConfirmEmail.keyboardType = .emailAddress
        txfConfirmEmail.rightViewMode = .whileEditing
        txfConfirmEmail.returnKeyType = .done
        
        // clear button
        let clearConfirmButton = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            clearConfirmButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        clearConfirmButton.frame = CGRect(x: 0, y: 0, width: 24, height: txfEmail.bounds.size.height)
        clearConfirmButton.contentMode = .scaleAspectFit
        clearConfirmButton.addTarget(self, action: #selector(didTapClearConfirmEmail(_:)), for: .touchUpInside)
        clearConfirmButton.tintColor = .colorGray10
        txfConfirmEmail.rightView = clearConfirmButton
        txfConfirmEmail.rightPadding = 12
        
        // input accessory view
        txfEmail.inputAccessoryView = emailInputView
        txfConfirmEmail.inputAccessoryView = emailInputView
        
        updateInputView(false)
        
        setupTagViews()
        
        // set initial values for animation
        vSignOption.isHidden = true
        vSignOption.alpha = 0.0
        lblCreateAccount.alpha = 0.0
        
        signOptionTopConstraint.constant = SCREEN_HEIGHT
        signOptionBottomConstraint.constant = -(SCREEN_HEIGHT - 200)
        
        emailContainer.isHidden = true
        lblHeadLineOne.isHidden = true
        lblHeadLineTwo.isHidden = true
    }
    
    // setup input field
    private func setupInputField(_ textField: RoundRectTextField, placeholder: String, image: String? = nil) {
        textField.backgroundColor = .white
        textField.borderColor = .colorGray17
        textField.borderWidth = 1
       
        textField.placeholder = placeholder
        textField.tintColor = .colorGray19
        textField.textColor = .colorGray19
        textField.font = UIFont(name: "SegoeUI-Light", size: 18)
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
    
    // set up email tag views
    private func setupTagViews() {
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
        emailTagView.addTags(tags)
        emailTagView.delegate = self
        emailTagView.reload()
        
        // confirm email tag view
        guard let confirmEmailConfig = confirmEmailTagView.defaultConfig else { return }
        
        confirmEmailConfig.textFont = UIFont(name: Font.SegoeUILight, size: 18)
        confirmEmailConfig.textColor = .colorGray12
        confirmEmailConfig.selectedTextColor = .colorGray12
        confirmEmailConfig.backgroundColor = .colorGray4
        confirmEmailConfig.selectedBackgroundColor = .colorGray4
        confirmEmailConfig.borderColor = .colorGray4
        confirmEmailConfig.selectedBorderColor = .colorGray4
        confirmEmailConfig.borderWidth = 1
        confirmEmailConfig.selectedBorderWidth = 1
        confirmEmailConfig.shadowColor = .black
        confirmEmailConfig.shadowOffset = CGSize(width: 0, height: 0.3)
        confirmEmailConfig.shadowOpacity = 0.3
        confirmEmailConfig.shadowRadius = 0.5
        confirmEmailConfig.cornerRadius = 5
        confirmEmailConfig.exactHeight = 30
        confirmEmailConfig.enableGradientBackground = false
        
        confirmEmailTagView.scrollDirection = .horizontal
        confirmEmailTagView.alignment = .fillByExpandingWidth
        confirmEmailTagView.numberOfLines = 1
        confirmEmailTagView.horizontalSpacing = 10.0
        confirmEmailTagView.verticalSpacing = 4.0
        confirmEmailTagView.showsVerticalScrollIndicator = false
        confirmEmailTagView.showsHorizontalScrollIndicator = false
        confirmEmailTagView.scrollView.bounces = false
        confirmEmailTagView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 16)
        confirmEmailTagView.addTags(tags)
        confirmEmailTagView.delegate = self
        confirmEmailTagView.reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // auto-focus getting back from 'Create Password'
        if signupProgress == .InputEmail {
            txfEmail.becomeFirstResponder()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if signupProgress == .SignOption {
            showSignOption()
        }
    }
    
    @objc private func didTapClearEmail(_ sender: Any) {
        txfEmail.text = ""
        
        checkValidation()
    }
    
    @objc private func didTapClearConfirmEmail(_ sender: Any) {
        txfConfirmEmail.text = ""
        
        checkValidation()
    }
    
    private func showSignOption(_ isFirstLoad: Bool = true) {
        vSignOption.isHidden = false
        
        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.vSignOption.alpha = 1.0
            self.lblCreateAccount.alpha = 1.0
        })
        
        if isFirstLoad {
            signOptionTopConstraint.constant = 200
            signOptionBottomConstraint.constant = 0
            
            UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkValidation()
    }
    
    private func updateInputView(_ enabled: Bool) {
        // Do whatever you need more UI effect like button background color
        let next = "Next: "
        let createPassword = "Create a Password "
        
        let attributedTitle = NSMutableAttributedString(string: next + createPassword)
        
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
            [.font: UIFont(name: Font.SegoeUILight, size: 18)!,
             .foregroundColor: enabled ? UIColor.white : UIColor.white.withAlphaComponent(0.22)],
            range: NSRange(location: 0, length: next.count))
        attributedTitle.addAttributes(
            [.font: UIFont(name: Font.SegoeUIBold, size: 18)!,
            .foregroundColor: enabled ? UIColor.white : UIColor.white.withAlphaComponent(0.22)],
            range: NSRange(location: next.count, length: createPassword.count-1))
        
        emailInputView.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    private func checkValidation() {
        guard let email = txfEmail.text,
              let confirmEmail = txfConfirmEmail.text,
              !email.isEmpty,
              !confirmEmail.isEmpty,
              email.isValidEmail(),
              confirmEmail.isValidEmail(),
              email.trimmedString == confirmEmail.trimmedString else {
            updateInputView(false)
            return
        }
        
        updateInputView(true)
    }
    
    private func showEmailSignUp() {
        // hide sign option view
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.vSignOption.alpha = 0.0
            self.lblCreateAccount.alpha = 0.0
            
        }, completion: { _ in
            self.vSignOption.isHidden = true
        })
        
        imvBack.tintColor = .colorPrimary
        
        emailContainer.isHidden = false

        // show headlines
        self.lblHeadLineOne.isHidden = false
        self.lblHeadLineTwo.isHidden = false
        
        emailContainerTopConstraint.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
            
        }, completion: { _ in
            self.signupProgress = .InputEmail
            
            self.txfEmail.becomeFirstResponder()
        })
    }
    
    private func hideInputEmail() {
        // end editing
        self.view.endEditing(true)
        
        // hide Input Email
        imvBack.tintColor = .white
        
        // hide headlines
        lblHeadLineOne.isHidden = true
        lblHeadLineTwo.isHidden = true
               
        emailContainerTopConstraint.constant = 200
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            
        }, completion: { _ in
            self.signupProgress = .SignOption
            self.emailContainer.isHidden = true
        })
        
        showSignOption(false)
    }
    
    private func completeEmailInput(for textField: UITextField, with tag: String) {
        guard let text = textField.text,
            !text.isEmpty else { return }
        
        textField.text = text + tag
        
        // check validation to enable 'Create a Password'
        checkValidation()
    }
    
    @objc private func didTapCreatePassword(_ sender: Any) {
        checkEmailValidation()
    }
    
    private func isValid() -> Bool {
        guard let email = txfEmail.text,
              !email.isEmpty else {
            showErrorVC(msg: "Please enter your email address.")
            return false
        }
        
        guard email.isValidEmail() else {
            showErrorVC(msg: "Please enter a valid email address.")
            return false
        }
        
        guard let confirmEmail = txfConfirmEmail.text,
              !confirmEmail.isEmpty else {
            showErrorVC(msg: "Please re-enter your email address.")
            return false
        }
        
        guard confirmEmail.isValidEmail() else {
            showErrorVC(msg: "Please re-enter a valid email address.")
            return false
        }
        
        guard email.trimmedString == confirmEmail.trimmedString else {
            showErrorVC(msg: "The entered emails do not match.")
            return false
        }
        
        return true
    }
    
    private func checkEmailValidation() {
        guard isValid() else { return }
        
        showIndicator()
        
        let email = txfEmail.text!.trimmedString
        APIManager.shared.isEmailValid(email) { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                self.gotoCreatePassword(withEmail: email)
            
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private func gotoCreatePassword(withEmail email: String) {
        self.view.endEditing(true)
        
        let toVC = CreatePasswordViewController.instance()
        toVC.email = email
        toVC.fbToken = fbToken
        
        self.navigationController?.pushViewController(toVC, animated: true)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        txfEmail.text = ""
        txfConfirmEmail.text = ""
        
        switch signupProgress {
        case .SignOption:
            self.navigationController?.popViewController(animated: true)
            break
            
        case .InputEmail:
            hideInputEmail()
            break
        }
    }
    
    @objc func didTapLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapFacebook(_ sender: Any) {
        let loginManager = LoginManager()
            loginManager.logIn(
                permissions: [.publicProfile, .email],
                viewController: self
            ) { result in
                self.loginManagerDidComplete(result)
            }
        }
        
    func loginManagerDidComplete(_ result: LoginResult) {
        switch result {
        case .failed(let error):
            print(error)
            
            break
        case .cancelled:
            print("User cancelled login.")
            
            break
        case .success(let _, let _, let accessToken):
            fbToken = accessToken.userID
            let connection = GraphRequestConnection()
            connection.add(GraphRequest(graphPath: "me", parameters: ["fields":"id,email,name"])) { httpResponse, result, error   in
                if error != nil {
                    NSLog(error.debugDescription)
                    return
                }

                // Handle vars
                if let result = result as? [String:String],
                    let email: String = result["email"],
                    let fbId: String = result["id"],
                    let name: String = result["name"]{

                    self.txfEmail.text = email
                    self.showEmailSignUp()
                    self.checkValidation()
                }

            }
            connection.start()
            break

        }
    }
    
    @IBAction func didTapUseEmail(_ sender: Any) {
        showEmailSignUp()
    }
}

// MARK: - UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         // always push user to enter email address and go to next
        if textField == txfEmail {
            txfConfirmEmail.becomeFirstResponder()
            textField.resignFirstResponder()
            
        } else if textField == txfConfirmEmail {
            checkEmailValidation()
        }
        
        return true
    }
}

// MARK: - TTGTextTagCollectionViewDelegate
extension RegisterViewController: TTGTextTagCollectionViewDelegate {
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTapTag tagText: String!, at index: UInt, selected: Bool, tagConfig config: TTGTextTagConfig!) {
        if textTagCollectionView == emailTagView {
            completeEmailInput(for: txfEmail, with: tagText)
            
        } else if textTagCollectionView == confirmEmailTagView {
            completeEmailInput(for: txfConfirmEmail, with: tagText)
        }
    }
}

