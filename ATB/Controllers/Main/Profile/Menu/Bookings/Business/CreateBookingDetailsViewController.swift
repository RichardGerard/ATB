//
//  CreateBookingDetailsViewController.swift
//  ATB
//
//  Created by YueXi on 11/6/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons
import PopupDialog
import Kingfisher
import AVKit

class CreateBookingDetailsViewController: AnimationBaseViewController {
    
    static let kStoryboardID = "CreateBookingDetailsViewController"
    class func instance() -> CreateBookingDetailsViewController {
        let storyboard = UIStoryboard(name: "Bookings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: CreateBookingDetailsViewController.kStoryboardID) as? CreateBookingDetailsViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var navigationView: UIView! { didSet {
        navigationView.layer.shadowOffset = CGSize(width: 0, height: -2)
        navigationView.layer.shadowRadius = 4.0
        navigationView.layer.shadowColor = UIColor.gray.cgColor
        navigationView.layer.shadowOpacity = 0.4
    }}
    
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")
            
        } else {
            // Fallback on earlier versions
        }
        imvBack.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imvCalendar: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imvClock: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView! { didSet {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 20, right: 0)
        scrollView.keyboardDismissMode = .interactive
    }}
    
    @IBOutlet weak var lblWhatService: UILabel!
    
    @IBOutlet weak var vMediaCard: CardView! { didSet {
        vMediaCard.cornerRadius = 10
        vMediaCard.shadowOpacity = 0.35
        vMediaCard.shadowOffsetHeight = 3
        vMediaCard.shadowRadius = 3
        vMediaCard.backgroundColor = .clear
    }}
    @IBOutlet weak var vMediaContainer: UIView! { didSet {
        vMediaContainer.layer.cornerRadius = 10
        vMediaContainer.layer.masksToBounds = true
        vMediaContainer.backgroundColor = .clear
    }}
    @IBOutlet weak var vPlay: UIView!
    @IBOutlet weak var imvService: UIImageView! { didSet {
        imvService.contentMode = .scaleAspectFill
    }}
    
    @IBOutlet weak var lblServiceTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblUserDetails: UILabel!
    
    @IBOutlet weak var emailFieldContainer: FieldContainerView! { didSet {
        emailFieldContainer.activeBackgroundColor = .white
    }}
    
    @IBOutlet weak var emailField: NoBorderTextField!
    @IBOutlet weak var errorMessageContainer: UIView!
    @IBOutlet weak var lblErrorMessage: UILabel!
    @IBOutlet weak var positiveSpacer: UIView!
    @IBOutlet weak var userProfileContainer: UIView!
    @IBOutlet weak var imvProfile: ProfileView!
    @IBOutlet weak var imvSelected: UIImageView!
    @IBOutlet weak var lblName: UILabel! // user full name
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var imvClose: UIImageView!
    
    @IBOutlet weak var nameField: RoundRectTextField!
    @IBOutlet weak var phoneNumberField: RoundRectTextField!
    
    @IBOutlet weak var btnCreate: MDCRaisedButton!
    
    private enum EmailFieldState: Int {
        case normal
        case enterEmail
        case enterValidEmail
        case enterOtherEmail
        case userFound
        case userNotFound
        case selected
    }
    
    private var emailFieldState: EmailFieldState = .normal
    
    var selectedService: PostModel!
    var bookingDate: Date!
    
    var foundUser: UserModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        hideKeyboardWhenTapped()
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
        lblTitle.text = "You're Creating A Booking"
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 25)
        lblTitle.textColor = .colorGray1
        
        if #available(iOS 13.0, *) {
            imvCalendar.image = UIImage(systemName: "calendar")
        } else {
            // Fallback on earlier versions
        }
        imvCalendar.tintColor = .colorBlue8
        lblDate.text = bookingDate.toString("EEEE d MMMM", timeZone: .current)
        lblDate.font = UIFont(name: Font.SegoeUILight, size: 16)
        lblDate.textColor = .colorBlue8
        
        if #available(iOS 13.0, *) {
            imvClock.image = UIImage(systemName: "clock")
        } else {
            // Fallback on earlier versions
        }
        imvClock.tintColor = .colorBlue8
        lblTime.text = bookingDate.toString("h:mm a", timeZone: .current)
        lblTime.font = UIFont(name: Font.SegoeUILight, size: 16)
        lblTime.textColor = .colorBlue8
        
        lblWhatService.text = "What service will you book?"
        lblWhatService.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        lblWhatService.textColor = .colorGray5
        
        let url = selectedService.Post_Media_Urls.count > 0 ? selectedService.Post_Media_Urls[0] : ""
        if selectedService.isVideoPost {
            vPlay.isHidden = false
            
            // set placeholder
            imvService.image = UIImage(named: "post.placeholder")
            
            if ImageCache.default.imageCachedType(forKey: url).cached {
                ImageCache.default.retrieveImage(forKey: url) { result in
                    switch result {
                    case .success(let cacheResult):
                        if let image = cacheResult.image {
                            let animation = CATransition()
                            animation.type = .fade
                            animation.duration = 0.25
                            self.imvService.layer.add(animation, forKey: "transition")
                            self.imvService.image = image
                        }
                        
                        break
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                }
                
            } else {
                // thumbnail is not cached, get thumbnail from video url
                Utils.shared.getThumbnailImageFromVideoUrl(url) { thumbnail in
                    if let thumbnail = thumbnail {
                        let animation = CATransition()
                        animation.type = .fade
                        animation.duration = 0.3
                        self.imvService.layer.add(animation, forKey: "transition")
                        self.imvService.image = thumbnail
                        
                        ImageCache.default.store(thumbnail, forKey: url)
                    }
                }
            }
            
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapVideo(_:)))
            vMediaContainer.addGestureRecognizer(recognizer)
            
        } else {
            vPlay.isHidden = true
            imvService.loadImageFromUrl(url, placeholder: "post.placeholder")
        }
        
        let serviceName = selectedService.Post_Title
        let infoAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            infoAttachment.image = UIImage(systemName: "info.circle.fill")?.withTintColor(.colorGray2)
        } else {
            // Fallback on earlier versions
        }
        let attributedTitle = NSMutableAttributedString(string: serviceName + " ")
        attributedTitle.append(NSAttributedString(attachment: infoAttachment))
        lblServiceTitle.attributedText = attributedTitle
        lblServiceTitle.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        lblServiceTitle.textColor = .colorGray2
        
        lblPrice.text = "£" + selectedService.Post_Price
        lblPrice.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblPrice.textColor = .colorPrimary
        
        let userDetails = " User Details"
        let accountAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            accountAttachment.image = UIImage(systemName: "person.circle.fill")?.withTintColor(.colorGray5)
        } else {
            // Fallback on earlier versions
        }
        let userAttributedTitle = NSMutableAttributedString(string: userDetails)
        userAttributedTitle.insert(NSAttributedString(attachment: accountAttachment), at: 0)
        lblUserDetails.attributedText = userAttributedTitle
        lblUserDetails.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        lblUserDetails.textColor = .colorGray5
        
        // setup email field
        setupEmailField()
               
        // update the first status with 'normal'
        updateEmailFieldState(.normal, animated: false)
        
        setupTextField(nameField, placeholder: "Name", iconName: "checkmark")
        nameField.autocapitalizationType = .words
        
        setupTextField(phoneNumberField, placeholder: "Phone", iconName: "checkmark")
        phoneNumberField.keyboardType = .phonePad
        
        btnCreate.backgroundColor = .colorPrimary
        btnCreate.layer.cornerRadius = 5
        btnCreate.isUppercaseTitle = false
        btnCreate.setTitle("Create Booking", for: .normal)
        btnCreate.setTitleFont(UIFont(name: Font.SegoeUIBold, size: 18), for: .normal)
        btnCreate.setTitleColor(.white, for: .normal)
    }
    
    @objc private func didTapVideo(_ sender: UITapGestureRecognizer) {
        guard selectedService.Post_Media_Urls.count > 0,
            let videoURL = URL(string: selectedService.Post_Media_Urls[0]) else {
                self.showErrorVC(msg: "The video URL is invalid.")
                return
        }
        
        let avPlayer = AVPlayer(url: videoURL)

        let playerViewController = AVPlayerViewController()
        playerViewController.player = avPlayer

        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
    
    private func setupEmailField() {
        // email
        emailField.placeholder = "User email"
        emailField.keyboardType = .emailAddress
        emailField.textColor = .colorGray5
        emailField.tintColor = .colorGray5
        emailField.font = UIFont(name: Font.SegoeUILight, size: 19)
        emailField.inputPadding = 16
        emailField.returnKeyType = .search
        
        emailField.rightPadding = 12
        emailField.iconTintColor = .colorPrimary
        if #available(iOS 13.0, *) {
            emailField.rightIcon = UIImage(systemName: "checkmark")
        } else {
            // Fallback on earlier versions
        }
        
        emailField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailField.delegate = self
        
        // error message label
        lblErrorMessage.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblErrorMessage.numberOfLines = 0
        
        // user profile - search result
        if #available(iOS 13.0, *) {
            imvSelected.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvSelected.tintColor = .colorPrimary
        
        lblName.font = UIFont(name: Font.SegoeUILight, size: 19)
        lblName.textColor = .colorGray5
        
        lblUsername.font = UIFont(name: Font.SegoeUILight, size: 16)
        lblUsername.textColor = .colorPrimary
        
        if #available(iOS 13.0, *) {
            imvClose.image = UIImage(systemName: "xmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvClose.tintColor = UIColor.colorGray5.withAlphaComponent(0.39)
    }
    
    // update email field status
    private func updateEmailFieldState(_ state: EmailFieldState, animated: Bool = true) {
        // update the state
        emailFieldState = state
        
        nameField.isHidden = (state == .selected)
        phoneNumberField.isHidden = (state == .selected)
        
        imvSelected.isHidden = (state != .selected)
        
        switch state {
        case .normal:
            emailField.isHidden = false
            errorMessageContainer.isHidden = true
            positiveSpacer.isHidden = true
            userProfileContainer.isHidden = true
            
        case .userFound:
            emailField.isHidden = false
            errorMessageContainer.isHidden = false
            lblErrorMessage.text = "This user already have an account, we will link the user to the booking"
            lblErrorMessage.textColor = .colorGreen
            positiveSpacer.isHidden = false
            userProfileContainer.isHidden = false
            
            didFoundUser()
            
        case .userNotFound, .enterEmail, .enterValidEmail, .enterOtherEmail:
            emailField.isHidden = false
            
            errorMessageContainer.isHidden = false
            if state == .userNotFound {
                lblErrorMessage.text = "No matches were found, please manually field the contact fields"
                
            } else if state == .enterEmail {
                lblErrorMessage.text = "Please enter an email address"
                
            } else if state == .enterValidEmail {
                lblErrorMessage.text = "Please enter a valid email address"
                
            } else {
                lblErrorMessage.text = "This is your email address linked to your account."
            }
            lblErrorMessage.textColor = .colorRed1
            
            positiveSpacer.isHidden = false
            userProfileContainer.isHidden = true
            
        case .selected:
            emailField.isHidden = true
            errorMessageContainer.isHidden = true
            positiveSpacer.isHidden = false
            userProfileContainer.isHidden = false
        }
        
        if animated {
            UIView.animate(withDuration: 0.35) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func setupTextField(_ textField: RoundRectTextField, placeholder: String, iconName: String) {
        textField.backgroundColor = .white
        
        textField.borderColor = .colorGray17
        textField.borderWidth = 1
        
        textField.placeholder = placeholder
        textField.tintColor = .colorGray5
        textField.textColor = .colorGray5
        textField.font = UIFont(name: Font.SegoeUILight, size: 19)
        textField.inputPadding = 16
        
        textField.rightPadding = 12
        textField.iconTintColor = .colorPrimary
        if #available(iOS 13.0, *) {
            textField.rightImage = UIImage(systemName: iconName)
        } else {
            // Fallback on earlier versions
        }
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        checkValidationFor(textField)
    }
    
    // check validation and update right view mode
    private func checkValidationFor(_ textField: UITextField) {
        if textField == emailField  {
            if emailFieldState != .normal {
                updateEmailFieldState(.normal)
            }
            
            if let emailAddress = textField.text,
               !emailAddress.isEmpty,
               emailAddress.isValidEmail() {
                textField.rightViewMode = .always
                return
            }
        }

        if textField == phoneNumberField,
           let phoneNumber = textField.text,
           !phoneNumber.isEmpty,
           phoneNumber.isValidPhoneNumber() {
            textField.rightViewMode = .always
            return
        }

        if textField == nameField,
           let name = textField.text,
           !name.isEmpty,
           name.count >= 3 {
            textField.rightViewMode = .always
            return
        }

        textField.rightViewMode = .never
    }
    
    private func updateUserInfoFilledState(_ filled: Bool) {
        emailField.rightViewMode = filled ? .always : .never
        nameField.rightViewMode = filled ? .always : .never
        phoneNumberField.rightViewMode = filled ? .always : .never
    }
    
    @IBAction func didTapUserSelect(_ sender: Any) {
        updateEmailFieldState(.selected)
    }
    
    @IBAction func didTapUserDeselect(_ sender: Any) {
        if emailFieldState == .selected {
            emailField.text = ""
            checkValidationFor(emailField)
            updateEmailFieldState(.normal)
            
        } else {
            updateEmailFieldState(.normal)
        }
    }
    
    @IBAction func didTapCreate(_ sender: Any) {
        if let bookingUser = foundUser,
           emailFieldState == .selected {
            createBooking(withATBUser: bookingUser)
            
        } else {
            createBookingWithNoneATBUser()
        }
    }
    
    private func createBooking(withATBUser user: UserModel) {
        let uid = user.ID
        let buid = g_myInfo.ID
        let sid = selectedService.Post_ID
        let time = "\(Int64(bookingDate.timeIntervalSince1970))"
        let totalCost = selectedService.Post_Price
        
        showIndicator()
        APIManager.shared.createBooking(withATBUser: true, token: g_myToken, buid: buid, sid: sid, cost: totalCost, time: time, uid: uid) { result in
            self.hideIndicator()
            
            switch result {
            case .success(let booking):
                self.didCompleteCreateBooking(withBooking: booking)
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private func isValid() -> Bool {
        guard !emailField.isEmpty() else {
            updateEmailFieldState(.enterEmail)
            return false
        }
        
        guard let email = emailField.text,
              email.isValidEmail() else {
            updateEmailFieldState(.enterValidEmail)
            return false
        }
        
        guard !nameField.isEmpty() else {
            showErrorVC(msg: "Please enter the user's name.")
            return false
        }
        
        guard !phoneNumberField.isEmpty() else {
            showErrorVC(msg: "Please enter the user's phone number")
            return false
        }
        
        guard let phoneNumber = phoneNumberField.text,
           phoneNumber.isValidPhoneNumber() else {
            showErrorVC(msg: "Please enter a valid phone number")
            return false
        }
        
        return true
    }
    
    private func createBookingWithNoneATBUser() {
        guard isValid() else { return }
        
        let buid = g_myInfo.ID
        let sid = selectedService.Post_ID
        let time = "\(Int64(bookingDate.timeIntervalSince1970))"
        let totalCost = selectedService.Post_Price        
        let email = emailField.text!.trimmedString
        let phone = phoneNumberField.text!.trimmedString
        let name = nameField.text!.trimmedString
        
        showIndicator()
        APIManager.shared.createBooking(withATBUser: false, token: g_myToken, buid: buid, sid: sid, cost: totalCost, time: time, email: email, name: name, phone: phone) { result in
            self.hideIndicator()
            
            switch result {
            case .success(let booking):
                self.didCompleteCreateBooking(withBooking: booking)
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private func didCompleteCreateBooking(withBooking booking: BookingModel) {
        // Do any additional setup after loading the view.
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius = 5
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color = .colorPrimary
        
        let completedVC = BookingCompletedViewController(nibName: "BookingCompletedViewController", bundle: nil)
        // This represent that booking has been made by the business rather than by the userself
        completedVC.isOwnCreated = false
        completedVC.email = booking.user.email_address
        completedVC.viewMyBooking = {
            self.gotoMyBookings(withCompletedBooking: booking)
        }
        
        let popupDialog = PopupDialog(viewController: completedVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)

        present(popupDialog, animated: true, completion: nil)
    }
    
    private func gotoMyBookings(withCompletedBooking booking: BookingModel) {
        guard let navigationController = self.navigationController else { return }
        
        // remove animation delegate
        navigationController.delegate = nil
        
        var viewControllers = navigationController.viewControllers
        // pop up CreateBookingDetailsViewController
        viewControllers.removeLast()
        // pop up CreateBookingViewController
        viewControllers.removeLast()
                
        navigationController.setViewControllers(viewControllers, animated: true)
        
        // post notification
        let object = [
            "booking_created": booking
        ]
        
        NotificationCenter.default.post(name: .ManualBookingCreated, object: object)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Search User
    private func searchForUser() {
        guard !emailField.isEmpty() else {
            updateEmailFieldState(.enterEmail)
            return
        }
        
        guard let email = emailField.text,
              email.isValidEmail() else {
            updateEmailFieldState(.enterValidEmail)
            return
        }
        
        let searchEmail = email.trimmedString
        
        guard searchEmail != g_myInfo.emailAddress else {
            updateEmailFieldState(.enterOtherEmail)
            return
        }
        
        showIndicator()
        APIManager.shared.searchUser(g_myToken, email: email) { result in
            self.hideIndicator()
            
            switch result {
            case .success(let user):
                guard let foundUser = user else {
                    self.updateEmailFieldState(.userNotFound)
                    return
                }
                
                self.foundUser = foundUser
                self.updateEmailFieldState(.userFound)
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private func didFoundUser() {
        guard let foundUser = self.foundUser else { return }
        
        imvProfile.loadImageFromUrl(foundUser.profile_image, placeholder: "profile.placeholder")
        lblName.text = foundUser.firstName + " " + foundUser.lastName
        lblUsername.text = foundUser.user_name
    }
    
    // MARK: - ImageTransitionZoomable
    override func createTransitionImageView() -> UIImageView {
        let imageView = UIImageView(image: imvService.image)
        
        imageView.contentMode = imvService.contentMode
        imageView.layer.cornerRadius = 5
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
//        imageView.frame = imvService.frame
        imageView.frame = imvService.convert(imvService.frame, to: self.view)
        
        return imageView
    }
    
    @objc override func presentationBeforeAction() {
        imvService.isHidden = true
    }
    
    @objc override func presentationCompletionAction(didComplete: Bool) {
        if didComplete {
            imvService.isHidden = false
        }
    }
    
    @objc override func dismissalBeforeAction() {
        imvService.isHidden = true
    }
    
    @objc override func dismissalCompletionAction(didComplete: Bool) {
        if !didComplete {
            imvService.isHidden = false
        }
    }
}

// MARK: UITextFieldDelegate
extension CreateBookingDetailsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            textField.resignFirstResponder()
            searchForUser()
        }
        
        if textField == nameField {
            phoneNumberField.becomeFirstResponder()
            textField.resignFirstResponder()
        }
        
        return true
    }
}
