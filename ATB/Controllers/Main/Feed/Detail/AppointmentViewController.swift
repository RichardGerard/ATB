//
//  AppointmentViewController.swift
//  ATB
//
//  Created by YueXi on 10/24/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import NBBottomSheet
import PopupDialog
import MaterialComponents.MaterialButtons
import Kingfisher
import Braintree
import BraintreeDropIn
import FSCalendar

class AppointmentViewController: BaseViewController {
    
    static let kStoryboardID = "AppointmentViewController"
    class func instance() -> AppointmentViewController {
        let storyboard = UIStoryboard(name: "Bookings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: AppointmentViewController.kStoryboardID) as? AppointmentViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        
        imvBack.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var imvLogo: UIImageView! { didSet {
        imvLogo.contentMode = .scaleAspectFill
        imvLogo.layer.cornerRadius = 5
        imvLogo.layer.masksToBounds = true
    }}
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var imvPrevious: UIImageView!
    @IBOutlet weak var imvNext: UIImageView!
    @IBOutlet weak var bookingCalendar: FSCalendar!
    
    @IBOutlet weak var lblAvailableSlots: UILabel!
    
    @IBOutlet weak var lblShowAvailableOnly: UILabel!
    @IBOutlet weak var imvAvailableOnly: UIImageView!
    
    // time slots table view
    @IBOutlet weak var tblSlots: UITableView!
    
    @IBOutlet weak var btnBook: MDCRaisedButton!
    
    private enum CalenderRefreshMode: String {
        case currentPage = "CurrentPage"
        case selectedDate = "SelectedDate"
    }
    
    private let currentCalendar: Calendar = .current
    
    /// This date will be used when the selected date is nil
    /// The reason have this date value here is to keep the default selection as same until a date is selected by the user
    var defaultDate = Date().startOfDay
    /// selected date when picker is displayed, default to current date
    var selectedDate: Date?
    
    // -1: no slot selected
    var selectedSlotIndex = -1
    
    var bookings = [BookingModel]()
    
    var bookingSlots = [BookingSlot]()
    var unbookedSlots = [BookingSlot]()
    
    /// The businesses weekdays and disabled slots
    var businessWeekdays = [Weekday]()
    var businessHolidays = [Holiday]()
    var businessDisabledSlots = [Slot]()
    
    private var calenderRefreshMode: CalenderRefreshMode = .currentPage
    
    var selectedService: PostModel!
    var business: BusinessModel!
    
    var isFromBusinessStore = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius = 5
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color = .colorPrimary
        
        setupViews()
        
        getBookings()
    }
    
    private func initData() {
        businessWeekdays.append(contentsOf: business.weekdays)
        businessHolidays.append(contentsOf: business.holidays)
        businessDisabledSlots.append(contentsOf: business.disabledSlots)
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
        navigationView.layer.shadowOffset = CGSize(width: 0, height: -2)
        navigationView.layer.shadowRadius = 4.0
        navigationView.layer.shadowColor = UIColor.gray.cgColor
        navigationView.layer.shadowOpacity = 0.4
        
        let url = selectedService.Post_Media_Urls.count > 0 ? selectedService.Post_Media_Urls[0] : ""
        if selectedService.isVideoPost {
            // set placeholder
            imvLogo.image = UIImage(named: "post.placeholder")
            
            if ImageCache.default.imageCachedType(forKey: url).cached {
                ImageCache.default.retrieveImage(forKey: url) { result in
                    switch result {
                    case .success(let cacheResult):
                        if let image = cacheResult.image {
                            let animation = CATransition()
                            animation.type = .fade
                            animation.duration = 0.25
                            self.imvLogo.layer.add(animation, forKey: "transition")
                            self.imvLogo.image = image
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
                        self.imvLogo.layer.add(animation, forKey: "transition")
                        self.imvLogo.image = thumbnail
                        
                        ImageCache.default.store(thumbnail, forKey: url)
                    }
                }
            }
            
        } else {
            imvLogo.loadImageFromUrl(url, placeholder: "post.placeholder")
        }
        
        let serviceName = selectedService.Post_Title.capitalizingFirstLetter
        let businessName = business.businessName
        
        let titleString = "Book an appointment for\n\(serviceName) at \(businessName)"
        let attributedTitle = NSMutableAttributedString(string: titleString)
        
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.colorGray5,
            .font: UIFont(name: Font.SegoeUISemibold, size: 18)!
        ]
        
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.colorGray5,
            .font: UIFont(name: Font.SegoeUILight, size: 15)!
        ]
        
        let linkAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.colorPrimary,
            .font: UIFont(name: Font.SegoeUILight, size: 15)!,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.colorPrimary
        ]
        
        let topTitleRange = (titleString as NSString).range(of: "Book an appointment for")
        attributedTitle.addAttributes(boldAttrs, range: topTitleRange)
        
        let serviceNameRange = (titleString as NSString).range(of: "\(serviceName) at ")
        attributedTitle.addAttributes(normalAttrs, range: serviceNameRange)
        
        let businessNameRange = (titleString as NSString).range(of: businessName)
        attributedTitle.addAttributes(linkAttrs, range: businessNameRange)
        
        lblTitle.attributedText = attributedTitle
        lblTitle.numberOfLines = 2
        lblTitle.lineBreakMode = .byTruncatingMiddle
        
        lblAvailableSlots.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblAvailableSlots.textColor = .colorGray21
        lblAvailableSlots.isHidden = true
        
        lblShowAvailableOnly.text = "Show avaialble\nSlots only"
        lblShowAvailableOnly.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblShowAvailableOnly.textColor = .colorPrimary
        lblShowAvailableOnly.numberOfLines = 2
        lblShowAvailableOnly.setLineSpacing(lineHeightMultiple: 0.75)
        lblShowAvailableOnly.textAlignment = .right
        
        if #available(iOS 13.0, *) {
            imvAvailableOnly.image = UIImage(systemName: "square")
        } else {
            // Fallback on earlier versions
        }
        imvAvailableOnly.tintColor = .colorPrimary
        
        tblSlots.backgroundColor = .clear
        tblSlots.tableFooterView = UIView()
        tblSlots.showsVerticalScrollIndicator = false
        tblSlots.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 96, right: 0) // 16(top) + 60(button height  + 20(bottom)
        tblSlots.separatorStyle = .none
        
        tblSlots.register(UINib(nibName: "BookingSlotCell", bundle: nil), forCellReuseIdentifier: BookingSlotCell.reuseIdentifier)
        tblSlots.dataSource = self
        tblSlots.delegate = self
        
        btnBook.layer.cornerRadius = 5
        btnBook.isUppercaseTitle = false
        btnBook.backgroundColor = .colorPrimary
        
        updateBookingButton()
        
        if #available(iOS 13.0, *) {
            imvPrevious.image = UIImage(systemName: "chevron.left")
        } else {
            // Fallback on earlier versions
        }
        imvPrevious.tintColor = .colorPrimary
        
        if #available(iOS 13.0, *) {
            imvNext.image = UIImage(systemName: "chevron.right")
        } else {
            // Fallback on earlier versions
        }
        imvNext.tintColor = .colorPrimary
        
        setupCalendar()
    }
    
    // update button title with selected date & slot time
    private func updateBookingButton() {
        guard let selected = selectedDate,
              selectedSlotIndex >= 0,
              let slotTime = bookingSlots[selectedSlotIndex].time.toDate("h:mm a") else {
            tblSlots.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 16, right: 0)
            btnBook.isHidden = true
            return
        }

        tblSlots.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 96, right: 0)
        btnBook.isHidden = false
        
        let bookText = "Book for "
        let dateText = selected.toString("d'\(selected.daySuffix())' MMMM", timeZone: .current) + " at " + slotTime.toString("h:mm a", timeZone: .current)
        let allText = bookText + dateText

        let attributedTitle = NSMutableAttributedString(string: allText)

        let normalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: Font.SegoeUILight, size: 18)!
        ]

        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUIBold, size: 18)!
        ]

        attributedTitle.addAttributes(normalAttrs, range: NSRange(location: 0, length: allText.count))
        let boldRange = (allText as NSString).range(of: dateText)
        attributedTitle.addAttributes(boldAttrs, range: boldRange)

        btnBook.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    // setup calendar
    private func setupCalendar() {
        bookingCalendar.appearance.headerDateFormat = "LLLL yyyy"
        bookingCalendar.appearance.headerTitleColor = .black
        bookingCalendar.appearance.headerTitleFont = UIFont(name: Font.SegoeUISemibold, size: 20)
        
        bookingCalendar.appearance.weekdayTextColor = UIColor.colorGray13.withAlphaComponent(0.3)
        
        bookingCalendar.appearance.titleFont = UIFont(name: Font.SegoeUILight, size: 19)
        bookingCalendar.appearance.titleDefaultColor = .black
        
        bookingCalendar.appearance.todayColor = .clear
        bookingCalendar.appearance.titleTodayColor = .colorPrimary
        
        bookingCalendar.appearance.titleSelectionColor = .colorPrimary
        bookingCalendar.appearance.selectionColor = UIColor.colorPrimary.withAlphaComponent(0.3)
        
        bookingCalendar.appearance.headerMinimumDissolvedAlpha = 0.0
        
        bookingCalendar.dataSource = self
        bookingCalendar.delegate = self
    }
    
    private var availableSlotsCount: Int = 0 {
        didSet {
            if lblAvailableSlots.isHidden {
                lblAvailableSlots.isHidden = false
            }
            
            if availableSlotsCount > 0 {
                let availableSlots = "\(availableSlotsCount) available \(availableSlotsCount > 1 ? "slots" : "slot")"
                let attributedSlots = NSMutableAttributedString(string: availableSlots)
                attributedSlots.addAttributes(
                    [.font: UIFont(name: Font.SegoeUIBold, size: 15)!],
                    range: (availableSlots as NSString).range(of: "\(availableSlotsCount)"))
                lblAvailableSlots.attributedText = attributedSlots
                
            } else {
                lblAvailableSlots.text = "No available slots"
            }
        }
    }
    
    private func getBookings() {
        showIndicator()
        
        let uid = business.uid
        APIManager.shared.getBookings(g_myToken, id: uid, isBusinenss: true, month: "") { result in
            self.hideIndicator()
            
            switch result {
            case.success(let bookings):
                self.bookings.removeAll()
                for booking in bookings {
                    if booking.isActive {
                        // put only active bookings into the array
                        self.bookings.append(booking)
                    }
                }
                
                let selected = self.selectedDate ?? self.defaultDate
                
                self.bookingCalendar.select(selected)
                self.didSelectDayOnCalendar(selected)
                                
                break
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private let SLOT_INTERVAL = 1
    private func didSelectDayOnCalendar(_ selected: Date) {
        selectedDate = selected
        
        showAvailableSlotsOnly = false
        
        selectedSlotIndex = -1
        // hide update button
        updateBookingButton()
        
        updateTimeSlots(withDate: selected)
    }
    
    private func updateTimeSlots(withDate selected: Date) {
        let endOfDay = selected.endOfDay
        
        let dayOfWeek = selected.dayOfWeek
        let weekdays = businessWeekdays
        guard weekdays.count > dayOfWeek else { return }
        
        var timeSlots = [String]()
        
        var dayOfWeekBeforeTheDay = dayOfWeek - 1
        if dayOfWeekBeforeTheDay < 0 {
            dayOfWeekBeforeTheDay += 7
        }
        
        let weekdayBeforeTheDay = weekdays[dayOfWeekBeforeTheDay]
        if weekdayBeforeTheDay.isAvailable,
           let start = weekdayBeforeTheDay.start.toDate("HH:mm:ss"),
           let end = weekdayBeforeTheDay.end.toDate("HH:mm:ss") {
            let slots = getSlotsBetween(startTime: start, endTime: end, date: selected.addingTimeInterval(TimeInterval(-24*60*60)), interval: SLOT_INTERVAL)
            
            let slotsOnTheDay = slots.filter({
                return currentCalendar.compare($0, to: selected, toGranularity: .day) == .orderedSame
                    && endOfDay.timeIntervalSince($0) >= 3599 // (60*60-1)
                    && !isHoliday($0)
                    && !isHoliday($0.addingTimeInterval(TimeInterval(SLOT_INTERVAL*60*60)))
            })
            
            for slot in slotsOnTheDay {
                timeSlots.append(slot.toString("h:mm a"))
            }
        }
        
        let weekday = weekdays[dayOfWeek]
        if weekday.isAvailable,
           let start = weekday.start.toDate("HH:mm:ss"),
           let end = weekday.end.toDate("HH:mm:ss") {
            let slots = getSlotsBetween(startTime: start, endTime: end, date: selected, interval: SLOT_INTERVAL)
            
            let slotsOnTheDay = slots.filter({
                return currentCalendar.compare($0, to: selected, toGranularity: .day) == .orderedSame
                    && endOfDay.timeIntervalSince($0) >= 3599 // (60*60-1)
                    && !isHoliday($0)
                    && !isHoliday($0.addingTimeInterval(TimeInterval(SLOT_INTERVAL*60*60)))
            })
            
            for slot in slotsOnTheDay {
                timeSlots.append(slot.toString("h:mm a"))
            }
        }
        
        var dayOfWeekAfterTheDay = dayOfWeek + 1
        if dayOfWeekAfterTheDay > 6 {
            dayOfWeekAfterTheDay -= 7
        }
        
        let weekdayAfterTheDay = weekdays[dayOfWeekAfterTheDay]
        if weekdayAfterTheDay.isAvailable,
           let start = weekday.start.toDate("HH:mm:ss"),
           let end = weekday.end.toDate("HH:mm:ss") {
            let slots = getSlotsBetween(startTime: start, endTime: end, date: selected.addingTimeInterval(TimeInterval(24*60*60)), interval: SLOT_INTERVAL)
            
            let slotsOnTheDay = slots.filter({
                return currentCalendar.compare($0, to: selected, toGranularity: .day) == .orderedSame
                    && endOfDay.timeIntervalSince($0) >= 3599 // (60*60-1)
                    && !isHoliday($0)
                    && !isHoliday($0.addingTimeInterval(TimeInterval(SLOT_INTERVAL*60*60)))
            })
            
            for slot in slotsOnTheDay {
                timeSlots.append(slot.toString("h:mm a"))
            }
        }
        
        var gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.timeZone = TimeZone(abbreviation: "UTC")!
        
        // get disabled slots on the selected day
        let disabledSlots = businessDisabledSlots
        let disabledSlotsOnTheDay = disabledSlots.filter({
            let slotDate = Date(timeIntervalSince1970: $0.date.doubleValue)
            guard let slotStartTime = $0.start.toDate("HH:mm:ss") else { return false }
            
            var dateCompoents = gregorianCalendar.dateComponents([.year, .month, .day], from: slotDate)
            let timeCompoents = gregorianCalendar.dateComponents([.hour, .minute], from: slotStartTime)
            dateCompoents.hour = timeCompoents.hour
            dateCompoents.minute = timeCompoents.minute
            
            guard let slotDateAndTime = gregorianCalendar.date(from: dateCompoents) else { return false }
            
            return currentCalendar.isDate(slotDateAndTime, inSameDayAs: selected)
        })

        // get bookings on the selected day
        let bookingsOnTheDay = bookings.filter({
            return currentCalendar.isDate(Date(timeIntervalSince1970: $0.date.doubleValue), inSameDayAs: selected)
        })
        
        // create booking slots
        // clear the slot arrays
        bookingSlots.removeAll()
        unbookedSlots.removeAll()
        
        var disabledSlotsCount = 0
        var bookedSlotsCount = 0
        
        for slot in timeSlots {
            guard let slotTime = slot.toDate("h:mm a") else { continue }
            
            let bookingSlot = BookingSlot()
            // slot time
            bookingSlot.time = slot
            
            // check for disabled slots
            if disabledSlotsOnTheDay.count > 0,
               let _ = disabledSlotsOnTheDay.firstIndex(where: {
                guard let disabledSlotTime = $0.start.toDate("HH:mm:ss") else { return false }
                // campare hour & minute
                return currentCalendar.compare(disabledSlotTime, to: slotTime, toGranularity: .hour) == .orderedSame && currentCalendar.compare(disabledSlotTime, to: slotTime, toGranularity: .minute) == .orderedSame
               }) {
                bookingSlot.isEnabled = false
                disabledSlotsCount += 1
            }
            
            // check for booked slots
            if bookingsOnTheDay.count > 0,
               let index = bookingsOnTheDay.firstIndex(where: {
                guard let bookingTime = Date(timeIntervalSince1970: $0.date.doubleValue).toString("HH:mm:ss").toDate("HH:mm:ss") else { return false }
                // campare hour & minute
                return currentCalendar.compare(bookingTime, to: slotTime, toGranularity: .hour) == .orderedSame && currentCalendar.compare(bookingTime, to: slotTime, toGranularity: .minute) == .orderedSame
               }) {
                bookingSlot.booking = bookingsOnTheDay[index]
                
                bookedSlotsCount += 1
            }
            
            if bookingSlot.isEnabled && !bookingSlot.isBooked {
                unbookedSlots.append(bookingSlot)
            }
            
            bookingSlots.append(bookingSlot)
        }
        
        DispatchQueue.main.async {
            self.availableSlotsCount = timeSlots.count - disabledSlotsCount - bookedSlotsCount
            
            self.tblSlots.reloadData()
        }
    }
    private var showAvailableSlotsOnly: Bool = false { didSet {
        if #available(iOS 13.0, *) {
            imvAvailableOnly.image = UIImage(systemName: showAvailableSlotsOnly ? "checkmark.square.fill" : "square")
        } else {
            // Fallback on earlier versions
        }
    }}
    
    @IBAction func didTapShowAvailableOnly(_ sender: Any) {
        showAvailableSlotsOnly = !showAvailableSlotsOnly
        
        tblSlots.reloadData()
    }
    
    @IBAction func didTapBook(_ sender: Any) {
        // check selected booking time to make sure that user always book a service on a feature date
        guard let selected = selectedDate,
              selectedSlotIndex >= 0 else { return }
        
        let slot = showAvailableSlotsOnly ? unbookedSlots[selectedSlotIndex] : bookingSlots[selectedSlotIndex]
        guard let slotTime = slot.time.toDate("h:mm a") else { return }
        
        var selectedDateComponents = currentCalendar.dateComponents([.minute, .hour, .day, .month, .year], from: selected)
        let timeComponents = currentCalendar.dateComponents([.hour, .minute], from: slotTime)
        
        // update time for the selected date
        selectedDateComponents.minute = timeComponents.minute
        selectedDateComponents.hour = timeComponents.hour
        
        guard let bookingDate = currentCalendar.date(from: selectedDateComponents),
              bookingDate > Date() else {
            showInfoVC("ATB", msg: "Please select a future date!")
            return
        }
        
        // check if the service is required for a deposit to book with
        if selectedService.isDepositRequired {
            askForDeposit()
            
        } else {
            // the selected service is not requried for a deposit
            // or deposit amount is just '0'
            // create a booking
            createBooking(withTransaction: "")
        }
    }
    
    // show a popup dialog ask for user to pay deposit amount to book the service
    private func askForDeposit() {
        let dialogVC = DepositPopupViewController(nibName: "DepositPopupViewController", bundle: nil)
        dialogVC.serviceName = selectedService.Post_Title.capitalizingFirstLetter
        dialogVC.depositAmount = selectedService.Post_Deposit.floatValue
        dialogVC.cancellationInDays = selectedService.cancellations
        dialogVC.businessName = business.businessName
        dialogVC.makePayment = {
            self.makeDeposit()
        }

        let popupDialog = PopupDialog(viewController: dialogVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: true, panGestureDismissal: false, hideStatusBar: false, completion: nil)

        present(popupDialog, animated: true, completion: nil)
    }
    
    private func makeDeposit() {
        showIndicator()
        ATBBraintreeManager.shared.getBraintreeClientToken(g_myToken) { (result, message) in
            self.hideIndicator()
            
            guard result else {
                self.showErrorVC(msg: "Server returned the error message: " + message)
                return
            }
            
            let clientToken = message
            self.showDropIn(clientTokenOrTokenizationKey: clientToken)
        }
    }
    
    private func showDropIn(clientTokenOrTokenizationKey: String) {
        let request = BTDropInRequest()
        request.vaultManager = true
        
        let amountToPay = selectedService.Post_Deposit
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request) { (controller, result, error) in
            controller.dismiss(animated: true, completion: nil)
            guard error == nil,
                  let result = result else {
                // show error
                self.showErrorVC(msg: "Failed to proceed your payment.\nPlease try again later!")
                
                return
            }
            
            guard !result.isCancelled,
                  let paymentMethod = result.paymentMethod else {
                // Payment has been cancelled by the user
                return
            }
            
            let nonce = paymentMethod.nonce
            self.showAlert("Payment Confirmation", message: "Would you like to proceed the payment?", positive: "Yes", positiveAction: { _ in
                switch result.paymentOptionType {
                case .payPal:
                    self.proceedPayment(withPaymentMethod: "Paypal", nonce: nonce, amount: amountToPay)
                    
                case .masterCard,
                     .AMEX,
                     .dinersClub,
                     .JCB,
                     .maestro,
                     .visa:
                    self.proceedPayment(withPaymentMethod: "Card", nonce: nonce, amount: amountToPay)
                    
                default: break
                }
                
            }, negative: "No", negativeAction: nil, preferredStyle: .actionSheet)
        }
        
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    private func proceedPayment(withPaymentMethod method: String, nonce: String, amount: String) {
        let params = [
            "token" : g_myToken,
            "customerId" : g_myInfo.bt_customer_id,
            "paymentNonce" : nonce,
            "paymentMethod" : method,
            "toUserId" : business.uid,
            "amount" : amount,
            "is_business": "1",
            "quantity": "1",
            "serviceId": isFromBusinessStore ? selectedService.Post_ID : selectedService.sid
        ]
        
        showIndicator()
        _ = ATB_Alamofire.POST(MAKE_PP_PAYMENT, parameters: params as [String: AnyObject], completionHandler: { (result, response) in
            if result,
               let transArray = response["msg"] as? NSArray {
                for transArrObject in transArray {
                    guard let transDictArr = transArrObject as? [NSDictionary],
                       let transDict = transDictArr.first,
                       let type = transDict["transaction_type"] as? String,
                       type == "Sale" else {
                        continue
                    }
                    
                    let tid = transDict["id"] as? String ?? ""
                    
                    self.createBooking(withTransaction: tid, loading: false)
                    return
                }
            
            } else {
                self.hideIndicator()
                
                let msg = response.object(forKey: "msg") as? String ?? "Failed to proceed your payment, please try again!"
                self.showErrorVC(msg: msg)
            }
        })
    }
    
    private func createBooking(withTransaction tid: String, loading: Bool = true) {
        // service id validation
        // booking date and slot selected
        guard let sid = isFromBusinessStore ? selectedService.Post_ID : selectedService.sid,
              !sid.isEmpty,
              let selected = selectedDate,
              selectedSlotIndex >= 0 else { return }
        
        let slot = showAvailableSlotsOnly ? unbookedSlots[selectedSlotIndex] : bookingSlots[selectedSlotIndex]
        
        guard let slotTime = slot.time.toDate("h:mm a") else { return }
        
        var selectedDateComponents = currentCalendar.dateComponents([.minute, .hour, .day, .month, .year], from: selected)
        let timeComponents = currentCalendar.dateComponents([.hour, .minute], from: slotTime)
        
        // update time for the selected date
        selectedDateComponents.minute = timeComponents.minute
        selectedDateComponents.hour = timeComponents.hour
        
        guard let bookingDate = currentCalendar.date(from: selectedDateComponents) else  { return }
        
        let uid = g_myInfo.ID
        let buid = business.uid
        let datetime = "\(Int64(bookingDate.timeIntervalSince1970))"
        let totalCost = selectedService.Post_Price
        
        if loading {
            showIndicator()
        }
        
        APIManager.shared.createBooking(withATBUser: true, token: g_myToken, buid: buid, sid: sid, cost: totalCost, time: datetime, uid: uid) { result in
            switch result {
            case .success(let created):
                if tid.isEmpty {
                    self.hideIndicator()
                    self.didCreateBooking()
                    
                } else {
                    self.updateTransaction(withBooking: created.id, transaction: tid)
                }
                
                
            case .failure(let error):
                self.hideIndicator()
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private func updateTransaction(withBooking bid: String, transaction: String) {
        APIManager.shared.updateTransation(g_myToken, bid: bid, tid: transaction) { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                self.didCreateBooking()
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private func didCreateBooking() {
        let completedVC = BookingCompletedViewController(nibName: "BookingCompletedViewController", bundle: nil)
        completedVC.viewMyBooking = {
            self.gotoMyBookings()
        }
        
        completedVC.returnATB = {
            self.navigationController?.popToRootViewController(animated: true)
        }

        let popupDialog = PopupDialog(viewController: completedVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)

        present(popupDialog, animated: true, completion: nil)
    }
    
    private func gotoMyBookings() {
        var viewControllers: [UIViewController] = []
        
        if let navigationController = self.navigationController,
           let firstVC = navigationController.viewControllers.first {
            // get & add only feed view controller which is in the first in naviagtion stack
            viewControllers.append(firstVC)
        }
        
        // add normal profile
        SlideMenuOptions.contentViewScale = 1.0
        SlideMenuOptions.leftViewWidth = SCREEN_WIDTH - 104
        // profile controller
        let newProfileVC = ProfileViewController.instance()
        newProfileVC.isBusiness = false
        newProfileVC.isBusinessUser = g_myInfo.isBusiness
        
        // menu controller
        let menuVC = ProfileMenuViewController.instance()
        menuVC.isBusiness = false
        menuVC.isBusinessUser = g_myInfo.isBusiness

        let slideController = ExSlideMenuController(mainViewController: newProfileVC, rightMenuViewController: menuVC)
        viewControllers.append(slideController)
        
        // add MyBookingsViewController
        let myBookingsVC = MyBookingsViewController.instance()
        myBookingsVC.hidesBottomBarWhenPushed = true
        viewControllers.append(myBookingsVC)
        
        navigationController?.setViewControllers(viewControllers, animated: true)
    }
    
    @IBAction func didTapPrevious(_ sender: Any) {
        bookingCalendar.setCurrentPage(currentCalendar.date(byAdding: .month, value: -1, to: bookingCalendar.currentPage)!, animated: true)
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        bookingCalendar.setCurrentPage(currentCalendar.date(byAdding: .month, value: 1, to: bookingCalendar.currentPage)!, animated: true)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Date Hanlders
extension AppointmentViewController {
    
    // if the date is holiday, returns true.
    // otherwise will return 'false'
    private func isHoliday(_ date: Date) -> Bool {
        for holiday in businessHolidays {
            let offDate = Date(timeIntervalSince1970: holiday.dayOff.doubleValue)
            
            if Calendar.current.compare(date, to: offDate, toGranularity: .day) == .orderedSame {
               return true
            }
        }
        
        return false
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension AppointmentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showAvailableSlotsOnly ? unbookedSlots.count : bookingSlots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let slot = showAvailableSlotsOnly ? unbookedSlots[indexPath.row] : bookingSlots[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: BookingSlotCell.reuseIdentifier, for: indexPath) as! BookingSlotCell
        // configure the cell
        cell.configureCell(slot, selected: indexPath.row == selectedSlotIndex)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let slot = showAvailableSlotsOnly ? unbookedSlots[indexPath.row] : bookingSlots[indexPath.row]
        guard slot.isEnabled, !slot.isBooked else { return }
        
        var reloadIndexes = [IndexPath]()
        if selectedSlotIndex >= 0 {
            reloadIndexes.append(IndexPath(row: selectedSlotIndex, section: 0))
        }
        reloadIndexes.append(indexPath)
        
        // update selected slot index with new selected
        selectedSlotIndex = indexPath.row
        
        updateBookingButton()
        
        // reload to updat selection
        tableView.reloadRows(at: reloadIndexes, with: .fade)
    }
}

// MARK: FSCalendarDataSource, FSCalendarDelegate
extension AppointmentViewController: FSCalendarDataSource, FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        return nil
    }
        
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        // implement and return a valid image for the date if you want to display image on the calendar
        return nil
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        if calenderRefreshMode == .currentPage {
            let current = calendar.currentPage
            
            calendar.select(current)
            didSelectDayOnCalendar(current)
            
        } else {
            calenderRefreshMode = .currentPage
            guard let selected = calendar.selectedDate else { return }
            
            didSelectDayOnCalendar(selected)
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if monthPosition == .previous || monthPosition == .next {
            calenderRefreshMode = .selectedDate
            calendar.setCurrentPage(date, animated: true)
            
        } else {
            didSelectDayOnCalendar(date)
        }
    }
}
