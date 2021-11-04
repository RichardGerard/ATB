//
//  LoginViewController.swift
//  ATB
//
//  Created by YueXi on 5/27/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Applozic
import FacebookLogin
import Mixpanel

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var txfEmail: RoundRectTextField!
    @IBOutlet weak var txfPassword: RoundRectTextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var lblLoginOption: UILabel!
    @IBOutlet weak var btnFacebook: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    
    @IBOutlet weak var vBack: UIView!
    @IBOutlet weak var backViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var imvBack: UIImageView!
    
    var isFirstLoad: Bool = true
    @IBOutlet weak var inputViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var vInputView: UIView!
    
    var fbToken:String = ""
    var fbstopped = false
    
    let loginInputButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60)
        button.backgroundColor = .colorBlue7
        button.setTitle("login", for: .normal)
        button.titleLabel?.font = UIFont(name: "SegoeUI-Bold", size: 23)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.22), for: .disabled)
        button.addTarget(self, action: #selector(didTapLoginInputButton(_:)), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
           
        // handle keyboard
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil
        , queue: .main) { (notification) in
            self.handleKeyboard(notification)
        }
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
            self.handleKeyboard(notification)
        }
        
        inputViewBottomConstraint.constant = -402
        vInputView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (ATB_UserDefault.hasLoginDetails()) {
            self.Login(email: ATB_UserDefault.getUserEmail(), password: ATB_UserDefault.getPassword(), fbToken: ATB_UserDefault.getfbToken())
            
        } else {
            showInputView()
        }
    }
    
    private func setupViews() {
        // email address
        setupInputField(txfEmail, placeholder: "Email")
        txfEmail.keyboardType = .emailAddress
        // uncomment below line if you don't want to set input accessoryview for instant login
        txfEmail.inputAccessoryView = loginInputButton
        
        // password inputfield
        setupInputField(txfPassword, placeholder: "Password")
        txfPassword.isSecureTextEntry = true
        txfPassword.rightPadding = 12
        txfPassword.rightViewMode = .always
        // uncomment below line if you don't want to set input accessoryview for instant login
        txfPassword.inputAccessoryView = loginInputButton
        
        // right view for password textfield
        let heightForTextField = txfPassword.bounds.size.height
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: heightForTextField))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: heightForTextField))
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: "questionmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .colorPrimary
        rightView.addSubview(imageView)
        
        let forgotTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapForgotPassword(_:)))
        forgotTapGesture.numberOfTapsRequired = 1
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(forgotTapGesture)
        
        txfPassword.rightView = rightView
        
        btnLogin.layer.cornerRadius = 5.0
        btnLogin.backgroundColor = .colorBlue7
        btnLogin.titleLabel?.font = UIFont(name: "SegoeUI-Bold", size: 23)
        btnLogin.setTitle("login", for: .normal)
        btnLogin.setTitleColor(.white, for: .normal)
        btnLogin.setTitleColor(UIColor.white.withAlphaComponent(0.22), for: .disabled)
        btnLogin.isEnabled = false
        
        lblLoginOption.textColor = .white
        lblLoginOption.font = UIFont(name: "SegoeUI-Light", size: 17)
        lblLoginOption.text = "or login using"
        
        btnFacebook.layer.cornerRadius = 5.0
        btnFacebook.backgroundColor = .colorBlue6
        btnFacebook.titleLabel?.font = UIFont(name: "SegoeUI-Semibold", size: 22)
        btnFacebook.setImage(#imageLiteral(resourceName: "fb.login"), for: .normal)
        btnFacebook.setTitleColor(.white, for: .normal)
        btnFacebook.setTitle("  facebook", for: .normal)
        btnFacebook.tintColor = .white
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Light", size: 20)!,
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.white
        ]
        let attributedStr = NSMutableAttributedString(string: "New User? Register here")
        attributedStr.addAttributes(attributes, range: NSRange(location: 0, length: attributedStr.length))
        btnRegister.setAttributedTitle(attributedStr, for: .normal)
        
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")
        } else {
            // Fallback on earlier versions
        }
        imvBack.tintColor = .white
        imvBack.contentMode = .scaleAspectFit
        
        vBack.isHidden = true
        vBack.alpha = 0
    }
    
    private func setupInputField(_ textField: RoundRectTextField, placeholder: String, image: String? = nil) {
        textField.backgroundColor = .white
        textField.borderColor = .colorGray17
        textField.borderWidth = 1
       
        textField.placeholder = placeholder
        textField.tintColor = .colorGray19
        textField.textColor = .colorGray19
        textField.font = UIFont(name: "SegoeUI-Light", size: 20) // 23 (design size) looks little weird
        textField.inputPadding = 16
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
    }
    
    @objc func handleKeyboard(_ notification: Notification) {
        guard let info = notification.userInfo,
            let rate = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else {
            return
        }
        
        guard notification.name == UIResponder.keyboardWillChangeFrameNotification else {
            self.backViewLeftConstraint.constant = 0
            
            UIView.animate(withDuration: rate, animations: {
                self.vBack.alpha = 0
                self.view.layoutIfNeeded()
                
            }) { _ in
                self.vBack.isHidden = true
            }
            
            return
        }
        
        // show backview
        if vBack.isHidden {
            self.vBack.isHidden = false
            
            UIView.animate(withDuration: rate, animations: {
                self.vBack.alpha = 1
            })
            
            self.backViewLeftConstraint.constant = 16
            UIView.animate(withDuration: rate, animations: {
                self.view.layoutIfNeeded()
            }) { _ in
            }
        }
    }
    
    private func showInputView() {
        UIView.animate(withDuration: 0.75, delay: 0.5, options: .curveEaseIn, animations: {
            self.vInputView.alpha = 1.0
        })
        
        inputViewBottomConstraint.constant = 30
        UIView.animate(withDuration: 0.75, delay: 0.5, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let inputText = textField.text,
            !inputText.isEmpty else {
                loginInputButton.isEnabled = false
                btnLogin.isEnabled = false
                return
        }
        
        checkValidation()
    }
    
    private func checkValidation() {
        if let email = txfEmail.text,
            !email.isValidEmail() {
            loginInputButton.isEnabled = false
            btnLogin.isEnabled = false
            return
        }
        
        if let password = txfPassword.text,
            password.count < 6 {
            loginInputButton.isEnabled = false
            btnLogin.isEnabled = false
            return
        }
        
        btnLogin.isEnabled = true
        loginInputButton.isEnabled = true
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        doLogin()
    }
    
    @objc func didTapLoginInputButton(_ sender: Any) {
        doLogin()
    }
    
    private func isValid() -> Bool {
        fbstopped = false
        let userEmail = txfEmail.text!
        let userPassword = txfPassword.text!
        
        txfEmail.resignFirstResponder()
        txfPassword.resignFirstResponder()
        
        if(userEmail == "")
        {
            InfoPopup.presentPopup(infoText: "Please input your email.", header: "Error", backgroundColour: .red, view: self)
            return false
        }
        
        if(userPassword == "")
        {
            InfoPopup.presentPopup(infoText: "Please input your password.", header: "Error", backgroundColour: .red, view: self)
            return false
        }
        
        if(userPassword.count < 6)
        {
            InfoPopup.presentPopup(infoText: "Password length should be 6 at least.", header: "Error", backgroundColour: .red, view: self)
            return false
        }
        
        return true
    }
    
    private func doLogin() {
        guard isValid() else { return }
        
        self.Login(email: txfEmail.text!, password: txfPassword.text!, fbToken: "")
    }
    
    @IBAction func didTapFacebook(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(
            permissions: [.publicProfile],
            viewController: self
        ) { result in
            self.loginManagerDidComplete(result)
        }
    }
    
    func loginManagerDidComplete(_ result: LoginResult) {
        switch result {
        case .failed(let error):
            print(error)
            fbstopped = true
            break
        case .cancelled:
            fbstopped = true
            break
        case .success(_, _, let accessToken):
            fbToken = accessToken.userID
            self.Login(email: "", password: "", fbToken: accessToken.userID)
            break

        }
    }
    
    @objc func didTapForgotPassword(_ sender: Any) {
        let forgotVC = ForgotPwdViewController.instance()
        self.navigationController?.pushViewController(forgotVC, animated: true)
    }
        
    @IBAction func didTapRegister(_ sender: Any) {
        let registerVC = RegisterViewController.instance()
        
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.view.endEditing(true)
    }
    

    func Login(email: String, password: String, fbToken: String)
    {
        let fcmToken = ATB_UserDefault.getFCMToken()
        
        let params = [
            "email" : email,
            "pwd" : password,
            "fbToken": fbToken,
            "fcmtoken" : fcmToken
            ] as [String : Any]
        
        _ = ATB_Alamofire.POST(LOGIN_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            self.view.isUserInteractionEnabled = true
            
            if(result)
            {
                let loggedInData = responseObject.object(forKey: "extra") as! NSDictionary
                let userInfo = loggedInData.object(forKey: "profile") as! NSDictionary
                let businessInfo = loggedInData.object(forKey: "business_info") as? NSDictionary
                let feedInfos = loggedInData.object(forKey: "feed_info") as? [NSDictionary] ?? []
                
                let userToken = responseObject.object(forKey: "msg") as! String
                g_myToken = userToken
                g_myInfo = User(info: userInfo)
                
                var accountType = "User"
                if(g_myInfo.accountType == 1)
                {
                    if(businessInfo != nil)
                    {
                        accountType = "Business"
                        let businessModel = BusinessModel(info: businessInfo!)
                        g_myInfo.business_profile = businessModel
                    }
                }
                
                ATB_UserDefault.setUserToken(token: userToken)
                ATB_UserDefault.setUserToken(token: userToken)
                ATB_UserDefault.setFBToken(val: fbToken)
                ATB_UserDefault.setUserEmail(email: email)
                ATB_UserDefault.setPassword(val: password)
                
                Mixpanel.mainInstance().identify(distinctId: g_myInfo.ID)
                Mixpanel.mainInstance().people.set(properties: [ "type": accountType,
                                                                 "$avatar": g_myInfo.profileImage,
                                                                 "$email": g_myInfo.emailAddress,
                                                                 "$first_name": g_myInfo.firstName,
                                                                 "$last_name": g_myInfo.lastName,
                                                                 "$name": g_myInfo.userName])
                                
                if !ALUserDefaultsHandler.isLoggedIn() {
                    // Creating "ALUser" and Passing user details
                    let alUser : ALUser =  ALUser()
                    if g_myInfo.isBusiness {
                        let business = g_myInfo.business_profile

                        let userId = business.ID + "_" + g_myInfo.ID
                        alUser.userId = userId
                        alUser.imageLink = business.businessPicUrl
                        alUser.displayName = business.businessProfileName
                        alUser.password = userId

                    } else {
                        alUser.userId = g_myInfo.ID
                        
                        alUser.imageLink = g_myInfo.profileImage
                        alUser.displayName = g_myInfo.userName
                        alUser.password = g_myInfo.ID
                    }
                    
                    alUser.email = g_myInfo.emailAddress

                    // Saving these details
                    ALUserDefaultsHandler.setUserId(alUser.userId)
                    ALUserDefaultsHandler.setEmailId(alUser.email)
                    ALUserDefaultsHandler.setDisplayName(alUser.displayName)
                    
                    // Registering or Login in the User
                    let chatManager = ALChatManager(applicationKey: "emtrac2ba61d90383c69a7fbc7db07725fa3e5b")
                    chatManager.connectUserWithCompletion(alUser, completion: { _, _ in })
                }
                
                let mainNav = self.storyboard?.instantiateViewController(withIdentifier: "MainNav") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = mainNav
                
            } else  {
                if (fbToken.count > 0) {
                    let registerVC = RegisterViewController.instance()
                    registerVC.fbToken = fbToken
                    self.navigationController?.pushViewController(registerVC, animated: true)
                    
                } else {
                    let msg = responseObject.object(forKey: "msg") as? String ?? ""
                    let errorCode = responseObject.object(forKey: "code") as? String ?? ""
                    
                    if (msg == "User Blocked") {
                        ContactAdminPopup.presentPopup(infoText: "User account has been blocked, for more infomation please contact admin.", header: "Blocked", view: self)
                        
                    } else {
                        if(msg == "") {
                            self.showErrorVC(msg: "Login Failed!")
                            
                        } else  {
                            self.showErrorVC(msg: "Server returned the error message: " + msg)
                        }
                    }
                }
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txfEmail {
            txfPassword.becomeFirstResponder()
        }
        
        textField.resignFirstResponder()
        
        return true
    }
}
