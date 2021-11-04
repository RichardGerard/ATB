//
//  BusinessBookingDetailsViewController.swift
//  ATB
//
//  Created by YueXi on 10/25/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import NBBottomSheet
import PopupDialog
import EventKit

class BusinessBookingDetailsViewController: BaseViewController {
    
    static let kStoryboardID = "BusinessBookingDetailsViewController"
    class func instance() -> BusinessBookingDetailsViewController {
        let storyboard = UIStoryboard(name: "Bookings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: BusinessBookingDetailsViewController.kStoryboardID) as? BusinessBookingDetailsViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    /// Navigation View
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        
        imvBack.tintColor = .colorPrimary
    }}
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnAddCalendar: UIButton!
        
    /// User Information
    @IBOutlet weak var imvProfile: ProfileView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var btnSendMessage: UIButton!
    
    // Business Information
    @IBOutlet weak var lblServiceTitle: UILabel!
    @IBOutlet weak var imvCalendar: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imvClock: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView! { didSet {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }}
    
    /// Invoice View
    @IBOutlet weak var lblInvoice: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblTotalValue: UILabel!
    @IBOutlet weak var lblDeposit: UILabel!
    @IBOutlet weak var lblDepositValue: UILabel!
    @IBOutlet weak var lblPending: UILabel!
    @IBOutlet weak var lblPendingValue: UILabel!
    
    var paidByCash = false
    @IBOutlet weak var vPaidByCashContainer: UIView!
    @IBOutlet weak var imvPaidCash: UIImageView!
    @IBOutlet weak var lblPaidCash: UILabel!
    @IBOutlet weak var swPayCash: UISwitch!
    
    @IBOutlet weak var vRequestContainer: UIView!
    @IBOutlet weak var btnRequestPayPal: UIButton!
    
    @IBOutlet weak var imvChange: UIImageView!
    @IBOutlet weak var lblChange: UILabel!
    @IBOutlet weak var imvArrowForChange: UIImageView!
    
    @IBOutlet weak var imvRating: UIImageView!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var imvArrowForRating: UIImageView!
    
    @IBOutlet weak var vCancel: UIView!
    @IBOutlet weak var imvCancel: UIImageView!
    @IBOutlet weak var lblCancel: UILabel!
    @IBOutlet weak var imvArrowForCancel: UIImageView!
    
    @IBOutlet weak var vFinishContainer: UIView!
    @IBOutlet weak var btnFinish: UIButton!
    
    private let eventStore: EKEventStore = EKEventStore()
    
    // selected booking and time
    var selectedBooking: BookingModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14

        lblTitle.text = "Bookings"
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 24)
        lblTitle.textColor = .colorPrimary
        
        btnAddCalendar.setTitle(" Add to calendar", for: .normal)
        btnAddCalendar.setTitleColor(.colorBlue7, for: .normal)
        btnAddCalendar.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 20)
        if #available(iOS 13.0, *) {
            btnAddCalendar.setImage(UIImage(systemName: "calendar.badge.plus"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnAddCalendar.tintColor = .colorBlue7
        btnAddCalendar.layer.cornerRadius = 5
        btnAddCalendar.layer.masksToBounds = true
        btnAddCalendar.layer.borderWidth = 1
        btnAddCalendar.layer.borderColor = UIColor.colorPrimary.withAlphaComponent(0.43).cgColor
        btnAddCalendar.backgroundColor = .white
                
        btnSendMessage.setTitle(" Message", for: .normal)
        btnSendMessage.setTitleColor(.white, for: .normal)
        btnSendMessage.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        if #available(iOS 13.0, *) {
            btnSendMessage.setImage(UIImage(systemName: "quote.bubble.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnSendMessage.tintColor = .white
        btnSendMessage.backgroundColor = .colorPrimary
        btnSendMessage.layer.cornerRadius = 5
        btnSendMessage.layer.masksToBounds = true

        guard let bookedUser = selectedBooking.user,
              let bookedService = selectedBooking.service else { return }
        imvProfile.loadImageFromUrl(bookedUser.profile_image, placeholder: "profile.placeholder")
        
        if bookedUser.isNoneATBUser {
            lblName.text = bookedUser.name
            lblUsername.text = bookedUser.email_address
            
        } else {
            lblName.text = bookedUser.fullname
            lblUsername.text = "@\(bookedUser.user_name)"
        }
        
        lblName.font = UIFont(name: Font.SegoeUILight, size: 24)
        lblName.textColor = .colorGray1
        
        lblUsername.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblUsername.textColor = .colorPrimary
        
        lblServiceTitle.text = bookedService.Post_Title
        lblServiceTitle.font = UIFont(name: Font.SegoeUILight, size: 29)
        lblServiceTitle.textColor = .colorGray1
        
        if #available(iOS 13.0, *) {
            imvCalendar.image = UIImage(systemName: "calendar")
        } else {
            // Fallback on earlier versions
        }
        imvCalendar.tintColor = .colorBlue8
        updateBookingTime(withDate: selectedBooking.date)
        lblDate.font = UIFont(name: Font.SegoeUILight, size: 19)
        lblDate.textColor = .colorBlue8
        
        if #available(iOS 13.0, *) {
            imvClock.image = UIImage(systemName: "clock")
        } else {
            // Fallback on earlier versions
        }
        imvClock.tintColor = .colorBlue8
        lblTime.font = UIFont(name: Font.SegoeUILight, size: 19)
        lblTime.textColor = .colorBlue8
        
        lblDescription.text = selectedBooking.service.Post_Text
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray5
        lblDescription.numberOfLines = 0
        
        lblInvoice.text = "Invoice"
        lblInvoice.font = UIFont(name: Font.SegoeUISemibold, size: 33)
        lblInvoice.textColor = UIColor.colorGray2.withAlphaComponent(0.59)
        
        lblTotal.text = "Total Per Booking"
        lblTotal.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblTotal.textColor = .colorGray5
        
        lblTotalValue.text = "£" + selectedBooking.total.priceString
        lblTotalValue.font = UIFont(name: Font.SegoeUIBold, size: 15)
        lblTotalValue.textColor = .colorPrimary
        lblTotalValue.textAlignment = .right
        
        lblDeposit.text = "Deposit"
        lblDeposit.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDeposit.textColor = .colorGray5
        
        var paid: Float = 0.0
        for transaction in selectedBooking.transactions {
            if transaction.isSale {
                paid += transaction.amount
            }
        }
        
        lblDepositValue.text = paid >= 0 ? "£" + paid.priceString : "-£" + (-1*paid).priceString
        lblDepositValue.font = UIFont(name: Font.SegoeUIBold, size: 15)
        lblDepositValue.textColor = .colorPrimary
        lblDepositValue.textAlignment = .right
        
        lblPending.text = "Payment Pending"
        lblPending.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblPending.textColor = .colorGray5
        
        let pendingBalance = selectedBooking.total + paid
        lblPendingValue.text = "£" + pendingBalance.priceString
        lblPendingValue.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblPendingValue.textColor = .colorGray5
        lblPendingValue.textAlignment = .right
        
        swPayCash.onTintColor = .colorPrimary
        swPayCash.isOn = paidByCash
        
        let requestPayPalTitle = "Request Payment by PayPal"
        let attributedTitle = NSMutableAttributedString(string: requestPayPalTitle)
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUISemibold, size: 18)!,
            .foregroundColor: UIColor.colorGray5
        ]
        
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUISemibold, size: 18)!
        ]
        attributedTitle.addAttributes(normalAttrs, range: NSRange(location: 0, length: attributedTitle.length))
        attributedTitle.addAttributes(boldAttrs, range: (requestPayPalTitle as NSString).range(of: "PayPal"))
        btnRequestPayPal.setAttributedTitle(attributedTitle, for: .normal)
        btnRequestPayPal.backgroundColor = .white
        btnRequestPayPal.layer.cornerRadius = 5
        btnRequestPayPal.layer.borderWidth = 1
        btnRequestPayPal.layer.borderColor = UIColor.colorGray4.cgColor
        btnRequestPayPal.layer.masksToBounds = true
        
        /// Request Change
        if #available(iOS 13.0, *) {
            imvChange.image = UIImage(systemName: "arrow.up.arrow.down.circle")
        } else {
            // Fallback on earlier versions
        }
        imvChange.tintColor = .colorGray5
        lblChange.text = "Request a Change"
        lblChange.font = UIFont(name: Font.SegoeUILight, size: 20)
        lblChange.textColor = .colorGray5
        if #available(iOS 13.0, *) {
            imvArrowForChange.image = UIImage(systemName: "chevron.right")
        } else {
            // Fallback on earlier versions
        }
        imvArrowForChange.tintColor = .colorGray5
        
        /// Request Rating
        if #available(iOS 13.0, *) {
            imvRating.image = UIImage(systemName: "star")
        } else {
            // Fallback on earlier versions
        }
        imvRating.tintColor = .colorGray5
        lblRating.text = "Request Rating"
        lblRating.font = UIFont(name: Font.SegoeUILight, size: 20)
        lblRating.textColor = .colorGray5
        if #available(iOS 13.0, *) {
            imvArrowForRating.image = UIImage(systemName: "chevron.right")
        } else {
            // Fallback on earlier versions
        }
        imvArrowForRating.tintColor = .colorGray5
        
        /// Request Cancel
        if #available(iOS 13.0, *) {
            imvCancel.image = UIImage(systemName: "slash.circle")
        } else {
            // Fallback on earlier versions
        }
        imvCancel.tintColor = .colorRed1
        lblCancel.text = "Cancel Booking"
        lblCancel.font = UIFont(name: Font.SegoeUILight, size: 20)
        lblCancel.textColor = .colorRed1
        
        if #available(iOS 13.0, *) {
            imvArrowForCancel.image = UIImage(systemName: "chevron.right")
        } else {
            // Fallback on earlier versions
        }
        imvArrowForCancel.tintColor = .colorRed1
        
        /// Finish booking button
        btnFinish.setTitle("Finish Booking", for: .normal)
        btnFinish.setTitleColor(.white, for: .normal)
        btnFinish.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        btnFinish.backgroundColor = .colorPrimary
        btnFinish.layer.cornerRadius = 5
        btnFinish.layer.masksToBounds = true
        
        if pendingBalance == 0 {
            vPaidByCashContainer.isHidden = true
            vRequestContainer.isHidden = true

        } else {
            // update CashView
            updateCashView(paidByCash)
        }
    }
    
    private func updateBookingTime(withDate unixstamp: String) {
        lblDate.text = Date(timeIntervalSince1970: unixstamp.doubleValue).toString("EEEE d MMMM", timeZone: .current)
        lblTime.text = Date(timeIntervalSince1970: unixstamp.doubleValue).toString("h:mm a", timeZone: .current)
    }
    
    private func updateCashView(_ cashPaid: Bool, animated: Bool = false) {
        vRequestContainer.isHidden = cashPaid
        vCancel.isHidden = cashPaid
        vFinishContainer.isHidden = !cashPaid
        
        if animated {
            UIView.animate(withDuration: 0.35) {
                self.view.layoutIfNeeded()
            }
            
        } else {
            self.view.layoutIfNeeded()
        }
        
        imvPaidCash.image = UIImage(named: "payment.cash")?.withRenderingMode(.alwaysTemplate)
        lblPaidCash.text = "Have the user paid by cash"
        lblPaidCash.font = UIFont(name: Font.SegoeUILight, size: 18)
        
        if cashPaid {
            imvPaidCash.tintColor = .colorGray1
            lblPaidCash.textColor = .colorGray1
            
            
        } else {
            imvPaidCash.tintColor = UIColor.colorGray1.withAlphaComponent(0.5)
            lblPaidCash.textColor = UIColor.colorGray1.withAlphaComponent(0.5)
        }
    }
    
    // Ask the system what the current authorization status is for the event store
    // Pass EKEventType.reminder as the event type, which indicates you seek permission to access reminders
    private func updateAuthorizationStatusToAccessEventStore(_ completion: @escaping (Result<Bool, Error>) -> Void) {
        let authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        
        switch authorizationStatus {
        case .denied, .restricted:
            // denied: user explicitly denited access to the service for your application
            // restricted: your app is not authrozied to access the service
            completion(.failure("We cannot add this booking to your Calendar because this app is not permitted to access Calendar."))
            break
            
        case .authorized:
            // your app has access and you can read from & write to the database
            completion(.success(true))
            break
            
        case .notDetermined:
            // you haven't requested access yet
            eventStore.requestAccess(to: .event) { (granted, error) in
                if granted {
                    completion(.success(true))
                    
                } else {
                    completion(.failure("We cannot at this booking to your Calendar because this app is not permitted to access Calendar."))
                }
            }
            break
            
        @unknown default:
            completion(.failure("Something went wrong!\nPlease try again later."))
            break
        }
    }
    
    @IBAction func didTapAddCalendar(_ sender: Any) {
        guard let service = selectedBooking.service else { return }
        
        let title = service.Post_Title.capitalizingFirstLetter
        updateAuthorizationStatusToAccessEventStore { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.showAlert(title, message: "This will be added to your Calendar", positive: "Add", positiveAction: { _ in
                        self.addEvent()
                        
                    }, negative: Constants.cancelBtnTitle, negativeAction: nil)
                
                case .failure(let error):
                    self.showInfoVC("Access Denied", msg: error.localizedDescription)
                }
            }
        }
    }
    
    private func addEvent() {
        guard let service = selectedBooking.service else { return }
        
        let title = service.Post_Title.capitalizingFirstLetter
        let start = Date(timeIntervalSince1970: selectedBooking.date.doubleValue)
        // adding an hour
        let end = start.addingTimeInterval(1*60*60)
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = start
        event.endDate = end
        event.notes = service.Post_Text
        event.calendar = eventStore.defaultCalendarForNewEvents
        let alarm = EKAlarm(relativeOffset: -10*60) // 10 mins before
        event.addAlarm(alarm)
        
        do {
            try eventStore.save(event, span: .thisEvent)
            
            showSuccessVC(msg: "This booking has been added to your Calendar.\nYou can edit Frequency, Notes, Period, etc in your Calendar app.")
            
        } catch {
            print("\(error.localizedDescription)")
            showErrorVC(msg: "There was an error while adding this booking to Calendar.\nPlease try again later")
        }
    }
    
    @IBAction func didTapSendMessage(_ sender: Any) {
        guard let user = selectedBooking.user else { return }
        
        let conversationVC = ConversationViewController()
        conversationVC.userId = user.ID
        
        navigationController?.pushViewController(conversationVC, animated: true)
    }
    
    @IBAction func didTapCashSwitch(_ sender: UISwitch) {
        paidByCash = sender.isOn
        
        updateCashView(paidByCash, animated: true)
    }    
    
    @IBAction func didTapRequestPayPal(_ sender: Any) {
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35

        configuruation.sheetSize = .fixed(390)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        let sheetController = NBBottomSheetController(configuration: configuruation)
        
        let requestVC = PayPalPopupViewController.instance()
        requestVC.booking = selectedBooking
        requestVC.isBusiness = true
        requestVC.delegate = self
        sheetController.present(requestVC, on: self)
    }
    
    @IBAction func didTapRequestChange(_ sender: Any) {
        gotoUpdateBooking()
    }
    
    private func gotoUpdateBooking() {
        let changeVC = RequestChangeViewController.instance()
        changeVC.selectedBooking = selectedBooking
        changeVC.delegate = self
        
        navigationController?.pushViewController(changeVC, animated: true)
    }
    
    @IBAction func didTapRequestRating(_ sender: Any) {
        showIndicator()
        APIManager.shared.requestRating(g_myToken, bid: selectedBooking.id, buid: selectedBooking.user.ID) { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                self.didRequestRating()
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private func didRequestRating() {
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius = 5
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color = .black
        overlayAppearance.alpha = 0.7
        overlayAppearance.blurRadius = 8
        
        let requestVC = RequestRatingViewController(nibName: "RequestRatingViewController", bundle: nil)
        let requestDialogVC = PopupDialog(viewController: requestVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH-40, tapGestureDismissal: true, panGestureDismissal: true, hideStatusBar: false, completion: nil)
        
        present(requestDialogVC, animated: true, completion: nil)
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35
        
        let title = "Are you sure you want to\ncancel this booking?"
        let heightForTitle = title.heightForString(SCREEN_WIDTH - 32, font: UIFont(name: Font.SegoeUILight, size: 25)).height
        
        let description = "We will let the user know that this is going to finished the booking and in case he wants to book again he have to select a different option."
        let heightForDescription = description.heightForString(SCREEN_WIDTH - 32, font: UIFont(name: Font.SegoeUILight, size: 15)).height
        
        let heightForSheet: CGFloat =  279.0 + heightForTitle + heightForDescription

        configuruation.sheetSize = .fixed(heightForSheet)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        let bottomSheetController = NBBottomSheetController(configuration: configuruation)

        let cancelSheet = CancelBookingViewController.instance()
        cancelSheet.isBusiness = true
        cancelSheet.delegate = self

        bottomSheetController.present(cancelSheet, on: self)
    }
    
    @IBAction func didTapFinish(_ sender: Any) {
        showIndicator()
        
        APIManager.shared.finishBooking(g_myToken, bid: selectedBooking.id) { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                self.didCompleteBooking()
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private func didCompleteBooking() {
        let object = ["bid": selectedBooking.id]
        NotificationCenter.default.post(name: .BookingFinished, object: object)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - CancelBookingDelegate
extension BusinessBookingDetailsViewController: CancelBookingDelegate {
    
    func bookingModifyRequested() {
        gotoUpdateBooking()
    }
    
    func bookingCancelled() {
        let bid = selectedBooking.id
        
        showIndicator()
        APIManager.shared.requestCancel(g_myToken, bid: selectedBooking.id, isRequestedBy: "1") { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                self.didCancelBooking(bid)
                
            case .failure(_):
                self.showErrorVC(msg: "It's been failed to cancel the booking.")
            }
        }
    }
    
    private func didCancelBooking(_ bid: String) {
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius = 0
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color = .white
        
        let completedVC = CancelCompletedViewController.instance()
        completedVC.isBusiness = true
        completedVC.backtoBookingsBlock = {
            self.navigationController?.popViewController(animated: true)
            
            NotificationCenter.default.post(name: .BookingCancelled, object: ["bid": bid])
        }
        
        let completedDialogVC = PopupDialog(viewController: completedVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(completedDialogVC, animated: true, completion: nil)
    }
}

// MARK: - PayPalPopupDelegate
extension BusinessBookingDetailsViewController: PayPalPopupDelegate {
    
    private func didSendRequest(forPayment: Bool = true) {
        let configuruation = NBBottomSheetConfiguration(animationDuration: 0.35, sheetSize: .fixed(180), backgroundViewColor: UIColor.black.withAlphaComponent(0.45))
        let sheetController = NBBottomSheetController(configuration: configuruation)
        
        let sentVC = RequestSentViewController.instance()
        sentVC.isPaymentRequest = forPayment
        
        sheetController.present(sentVC, on: self)
    }
    
    func didRequestPayment(_ result: Bool) {
        if result {
            didSendRequest()
            
        } else {
            showErrorVC(msg: "It's been failed to request payment.")
        }
    }
}

// MARK: - ChangeRequestDelegate
extension BusinessBookingDetailsViewController: ChangeRequestDelegate {
    
    func didSendChangeRequest(withUpdated updated: String) {
        updateBookingTime(withDate: updated)
        selectedBooking.date = updated
        
        let object = [
            "bid": selectedBooking.id,
            "updated": updated
        ]
        NotificationCenter.default.post(name: .BookingUpdatedByBusiness, object: object)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.didSendRequest(forPayment: false)
        }
    }
}
