//
//  BookingDetailsViewController.swift
//  ATB
//
//  Created by YueXi on 10/18/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import NBBottomSheet
import PopupDialog
import Kingfisher
import AVKit
import EventKit

class BookingDetailsViewController: BaseViewController {
    
    static let kStoryboardID = "BookingDetailsViewController"
    class func instance() -> BookingDetailsViewController {
        let storyboard = UIStoryboard(name: "Bookings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: BookingDetailsViewController.kStoryboardID) as? BookingDetailsViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        
        imvBack.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var btnAddCalendar: UIButton!
    
    @IBOutlet weak var imvBusinessLogo: ProfileView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imvCalendar: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imvClock: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView! { didSet {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
    }}
    
    @IBOutlet weak var vMediaCard: CardView! { didSet {
        vMediaCard.cornerRadius = 10
        vMediaCard.shadowOpacity = 0.35
        vMediaCard.shadowOffsetHeight = 3
        vMediaCard.shadowRadius = 3
    }}
    @IBOutlet weak var vServiceMedia: UIView! { didSet {
        vServiceMedia.layer.cornerRadius = 10
        vServiceMedia.layer.masksToBounds = true
    }}
    @IBOutlet weak var imvServiceMedia: UIImageView! { didSet {
        imvServiceMedia.contentMode = .scaleAspectFill
    }}
    @IBOutlet weak var vPlay: UIView!
    
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var btnSendMessage: UIButton!
    
    @IBOutlet weak var lblInvoice: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblTotalValue: UILabel!
    @IBOutlet weak var lblDeposit: UILabel!
    @IBOutlet weak var lblDepositValue: UILabel!
    @IBOutlet weak var lblPending: UILabel!
    @IBOutlet weak var lblPendingValue: UILabel!
    @IBOutlet weak var btnPayPending: UIButton!
    
    @IBOutlet weak var imvChange: UIImageView!
    @IBOutlet weak var lblChange: UILabel!
    @IBOutlet weak var imvArrowForChange: UIImageView!
    @IBOutlet weak var imvCancel: UIImageView!
    @IBOutlet weak var lblCancel: UILabel!
    @IBOutlet weak var imvArrowForCancel: UIImageView!
    
    private let eventStore: EKEventStore = EKEventStore()
    
    var selectedBooking: BookingModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
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
        
        imvBusinessLogo.borderWidth = 1
        imvBusinessLogo.borderColor = UIColor.colorGray2.withAlphaComponent(0.25)
        imvBusinessLogo.loadImageFromUrl(selectedBooking.business.businessPicUrl, placeholder: "profile.placeholder")
        
        lblTitle.text = selectedBooking.service.Post_Title.capitalizingFirstLetter
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 29)
        lblTitle.textColor = .colorGray1
        
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
        
        if let selectedService = selectedBooking.service {
            let url = selectedService.Post_Media_Urls.count > 0 ? selectedService.Post_Media_Urls[0] : ""
            if selectedService.isVideoPost {
                vPlay.isHidden = false
                
                // set placeholder
                imvServiceMedia.image = UIImage(named: "post.placeholder")
                
                if ImageCache.default.imageCachedType(forKey: url).cached {
                    ImageCache.default.retrieveImage(forKey: url) { result in
                        switch result {
                        case .success(let cacheResult):
                            if let image = cacheResult.image {
                                let animation = CATransition()
                                animation.type = .fade
                                animation.duration = 0.25
                                self.imvServiceMedia.layer.add(animation, forKey: "transition")
                                self.imvServiceMedia.image = image
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
                            self.vServiceMedia.layer.add(animation, forKey: "transition")
                            self.imvServiceMedia.image = thumbnail
                            
                            ImageCache.default.store(thumbnail, forKey: url)
                        }
                    }
                }
                
                let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapVideo(_:)))
                vServiceMedia.addGestureRecognizer(recognizer)
                
            } else {
                vPlay.isHidden = true
                imvServiceMedia.loadImageFromUrl(url, placeholder: "post.placeholder")
            }
            
            lblDescription.text = selectedService.Post_Text
        }
        
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray5
        lblDescription.numberOfLines = 0
        
        btnSendMessage.setTitle("  Send A Message", for: .normal)
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
        
        updateInvoice()
        lblDeposit.text = "Deposit"
        lblDeposit.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDeposit.textColor = .colorGray5
        
        lblDepositValue.font = UIFont(name: Font.SegoeUIBold, size: 15)
        lblDepositValue.textColor = .colorPrimary
        lblDepositValue.textAlignment = .right
        
        lblPending.text = "Payment Pending"
        lblPending.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblPending.textColor = .colorGray5
        
        lblPendingValue.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblPendingValue.textColor = .colorGray5
        lblPendingValue.textAlignment = .right
        
        btnPayPending.setTitle("  Pay the pending balance", for: .normal)
        btnPayPending.setTitleColor(.colorGray1, for: .normal)
        btnPayPending.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        btnPayPending.setImage(UIImage(named: "payment.paypal.logo")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnPayPending.tintColor = .colorPrimary
        btnPayPending.backgroundColor = .white
        btnPayPending.layer.cornerRadius = 5
        btnPayPending.layer.borderWidth = 1
        btnPayPending.layer.borderColor = UIColor.colorGray4.cgColor
        btnPayPending.layer.masksToBounds = true
        
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
    }
    
    private func updateBookingTime(withDate unixstamp: String) {
        lblDate.text = Date(timeIntervalSince1970: unixstamp.doubleValue).toString("EEEE d MMMM", timeZone: .current)
        lblTime.text = Date(timeIntervalSince1970: unixstamp.doubleValue).toString("h:mm a", timeZone: .current)
    }
    
    private func updateInvoice(_ animated: Bool = false) {
        var paid: Float = 0.0
        for transaction in selectedBooking.transactions {
            if transaction.isSale {
                paid += transaction.amount
            }
        }
        
        lblDepositValue.text = paid >= 0 ? "£" + paid.priceString : "-£" + (-1*paid).priceString
        let pendingBalance = selectedBooking.total + paid
        lblPendingValue.text = "£" + pendingBalance.priceString
        
        btnPayPending.isHidden = (pendingBalance == 0)
        
        if animated {
            UIView.animate(withDuration: 0.35) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func didTapVideo(_ sender: UITapGestureRecognizer) {
        guard let selectedService = selectedBooking.service,
            selectedService.Post_Media_Urls.count > 0,
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
    
    @IBAction func didTapSendAMessage(_ sender: Any) {
        guard let business = selectedBooking.business else { return }
        
        let conversationVC = ConversationViewController()
        conversationVC.userId = business.ID + "_" + business.uid
        
        navigationController?.pushViewController(conversationVC, animated: true)
    }
    
    @IBAction func didTapPayPendingBalance(_ sender: Any) {
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35

        configuruation.sheetSize = .fixed(390)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        let sheetController = NBBottomSheetController(configuration: configuruation)
        
        let requestVC = PayPalPopupViewController.instance()
        requestVC.booking = selectedBooking
        requestVC.isBusiness = false
        requestVC.delegate = self
        sheetController.present(requestVC, on: self)
    }
    
    @IBAction func didTapRequestChange(_ sender: Any) {
        let editVC = EditBookingViewController.instance()
        editVC.selectedBooking = selectedBooking
        editVC.delegate = self
        
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    @IBAction func didTapCancelBooking(_ sender: Any) {
        let bookingDate = Date(timeIntervalSince1970: selectedBooking.date.doubleValue)
        let cancellationInDays = selectedBooking.service.cancellations.intValue
        var dateComponents = DateComponents()
        dateComponents.day = -1*cancellationInDays
        guard let lastCancellationDate = Calendar.current.date(byAdding: dateComponents, to: bookingDate) else { return }
        
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35
        
        let title = "Are you sure you want to\ncancel this booking?"
        let heightForTitle = title.heightForString(SCREEN_WIDTH - 32, font: UIFont(name: Font.SegoeUILight, size: 25)).height
                
        let cancelDateString = lastCancellationDate.toString("dd/MM/yy h:mm a", timeZone: .current)
        
        let description = "You can still cancel this booking before \(cancelDateString) - if you cancel after this time you will lose your deposit."
        let heightForDescription = description.heightForString(SCREEN_WIDTH - 32, font: UIFont(name: Font.SegoeUILight, size: 15)).height
        
        let heightForSheet: CGFloat =  213.0 + heightForTitle + heightForDescription

        configuruation.sheetSize = .fixed(heightForSheet)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        let bottomSheetController = NBBottomSheetController(configuration: configuruation)

        /// show action sheet with options (Edit or Delete)
        let cancelSheet = CancelBookingViewController.instance()
        cancelSheet.lastCancelDate = cancelDateString
        cancelSheet.delegate = self

        bottomSheetController.present(cancelSheet, on: self)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - CancelBookingDelegate
extension BookingDetailsViewController: CancelBookingDelegate {   
    
    func bookingCancelled() {
        showIndicator()
        
        let bid = selectedBooking.id
        APIManager.shared.requestCancel(g_myToken, bid: bid, isRequestedBy: "0") { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                self.didCompleteCancelBooking(bid)
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private func didCompleteCancelBooking(_ bid: String) {
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius = 0
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color = .white
        
        let completedVC = CancelCompletedViewController.instance()
        completedVC.backtoBookingsBlock = {
            self.navigationController?.popViewController(animated: true)
            
            NotificationCenter.default.post(name: .BookingCancelled, object: ["bid": bid])
        }
        
        let completedDialogVC = PopupDialog(viewController: completedVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(completedDialogVC, animated: true, completion: nil)
    }
}

// MARK: - PayPalPopupDelegate
extension BookingDetailsViewController: PayPalPopupDelegate {
    
    func didPayPending(_ transactions: [Transaction]) {
        // update transactions
        selectedBooking.transactions.append(contentsOf: transactions)
        // update invoice details
        updateInvoice(true)
        
        didCompletePayPendingBalance()
    }
    
    private func didCompletePayPendingBalance() {
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35

        configuruation.sheetSize = .fixed(390)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        let sheetController = NBBottomSheetController(configuration: configuruation)

        let doneVC = BookingPaymentDoneViewController.instance()
        doneVC.delegate = self
        sheetController.present(doneVC, on: self)
    }
}

// MARK: - PaymentDoneDelegate
extension BookingDetailsViewController: PaymentDoneDelegate {
    
    func rateServiceSelected() {
        let rateVC = RateServiceViewController.instance()
        rateVC.selectedBooking = selectedBooking
        
        navigationController?.pushViewController(rateVC, animated: true)
    }
    
    func backSelected() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - ChangeRequestDelegate
extension BookingDetailsViewController: ChangeRequestDelegate {
    
    func didSendChangeRequest(withUpdated updated: String) {
        DispatchQueue.main.async {
            self.updateBookingTime(withDate: updated)
        }
        
        selectedBooking.date = updated
        
        let object = [
            "bid": selectedBooking.id,
            "updated": updated
        ]
        
        NotificationCenter.default.post(name: .BookingUpdatedByUser, object: object)
    }
}
