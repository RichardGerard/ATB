//
//  BusinessBookingsViewController.swift
//  ATB
//
//  Created by YueXi on 10/13/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import NBBottomSheet
import FSCalendar

class BusinessBookingsViewController: BaseViewController {
    
    static let kStoryboardID = "BusinessBookingsViewController"
    class func instance() -> BusinessBookingsViewController {
        let storyboard = UIStoryboard(name: "Bookings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: BusinessBookingsViewController.kStoryboardID) as? BusinessBookingsViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvCalendar: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
        
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var imvPrevious: UIImageView!
    @IBOutlet weak var imvNext: UIImageView!
    @IBOutlet weak var bookingCalendar: FSCalendar!
    
    @IBOutlet weak var lblAvailableSlots: UILabel!
    
    @IBOutlet weak var lblShowConfirmedOnly: UILabel!
    @IBOutlet weak var imvConfirmedOnly: UIImageView!
    
    // time slots table view
    @IBOutlet weak var tblSlots: UITableView!
    
    private enum CalenderRefreshMode: String {
        case currentPage = "CurrentPage"
        case selectedDate = "SelectedDate"
    }
         
    private let currentCalendar: Calendar = .current
    
    /// This date will be used when the selected date is nil
    /// The reason have this date value here is to keep the default selection as same until a date is selected by the businesses
    var defaultDate = Date().startOfDay
    /// selected date
    var selectedDate: Date? = nil
    
    /// The array of bookings made on the selected month
    var bookings = [BookingModel]()
        
    var bookingSlots = [BookingSlot]()
    var bookedSlots = [BookingSlot]()
    
    private var calenderRefreshMode: CalenderRefreshMode = .currentPage
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        getBookings()
            
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(didCompleteCreateBooking(_:)), name: .ManualBookingCreated, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didCancelBooking(_:)), name: .BookingCancelled, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didUpdateSlot(_:)), name: .SlotEnabled, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didUpdateSlot(_:)), name: .SlotDisabled, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didUpdateBooking(_:)), name: .BookingUpdatedByBusiness, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didFinishBooking(_:)), name: .BookingFinished, object: nil)
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
        if #available(iOS 13.0, *) {
            imvCalendar.image = UIImage(systemName: "calendar.badge.plus")
        } else {
            // Fallback on earlier versions
        }
        imvCalendar.tintColor = .colorPrimary
        
        lblTitle.text = "Future Bookings"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 26)
        lblTitle.textColor = .colorGray5
        
        if #available(iOS 13.0, *) {
            btnClose.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnClose.tintColor = UIColor.colorGray1.withAlphaComponent(0.19)
             
        lblAvailableSlots.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblAvailableSlots.textColor = .colorGray21
        lblAvailableSlots.isHidden = true
                
        if #available(iOS 13.0, *) {
            imvConfirmedOnly.image = UIImage(systemName: "square")
        } else {
            // Fallback on earlier versions
        }
        imvConfirmedOnly.tintColor = .colorPrimary
        
        lblShowConfirmedOnly.text = "Show confirmed\nBookings only"
        lblShowConfirmedOnly.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblShowConfirmedOnly.textColor = .colorPrimary
        lblShowConfirmedOnly.numberOfLines = 2
        lblShowConfirmedOnly.setLineSpacing(lineHeightMultiple: 0.75)
        lblShowConfirmedOnly.textAlignment = .right
        
        tblSlots.backgroundColor = .clear
        tblSlots.tableFooterView = UIView()
        tblSlots.showsVerticalScrollIndicator = false
        tblSlots.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 16, right: 0)
        tblSlots.separatorStyle = .none
        tblSlots.register(UINib(nibName: "BookingSlotCell", bundle: nil), forCellReuseIdentifier: BookingSlotCell.reuseIdentifier)
        tblSlots.register(UINib(nibName: "BookedSlotCell", bundle: nil), forCellReuseIdentifier: BookedSlotCell.reuseIdentifier)
        tblSlots.dataSource = self
        tblSlots.delegate = self
        
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
        
//        let month = date.toString("yyyy MM")
        APIManager.shared.getBookings(g_myToken, id: g_myInfo.ID, isBusinenss: true, month: "") { result in
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
        
        showConfirmedSlotsOnly = false
        
        updateTimeSlots(withDate: selected)
    }
    
    private func updateTimeSlots(withDate selected: Date) {
        let startOfDay = selected.startOfDay
        let endOfDay = selected.endOfDay
        
        let dayOfWeek = selected.dayOfWeek
        let weekdays = g_myInfo.business_profile.weekdays
        guard weekdays.count > dayOfWeek else {
            // no available slots when the weekday is invalid
            availableSlotsCount = 0
            return
        }
        
        var timeSlots = [String]()
        
        let businessSetTimeZone = g_myInfo.business_profile.timezone
        let currentTimeZone = TimeZone.current.secondsFromGMT()/(60*60)
        
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
        let disabledSlots = g_myInfo.business_profile.disabledSlots
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
        bookedSlots.removeAll()
        
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
                bookedSlots.append(bookingSlot)
                
                bookedSlotsCount += 1
            }

            bookingSlots.append(bookingSlot)
        }

        DispatchQueue.main.async {
            self.availableSlotsCount = timeSlots.count - disabledSlotsCount - bookedSlotsCount
            
            self.tblSlots.reloadData()
        }
    }
    
    @objc private func didCompleteCreateBooking(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let bookingCreated = object["booking_created"] as? BookingModel else {
            return
        }
        
        // add the created booking
        bookings.append(bookingCreated)
        
        guard let selected = selectedDate else { return }
        updateTimeSlots(withDate: selected)
    }
    
    @objc private func didCancelBooking(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let bid = object["bid"] as? String,
              let index = bookings.firstIndex(where: {
                  $0.id == bid
              }) else { return }
        
        bookings.remove(at: index)
        
        guard let selected = selectedDate else { return }
        updateTimeSlots(withDate: selected)
    }
    
    // This will be called when a booking slot is enabled/disabled on other page/change
    @objc func didUpdateSlot(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let slotDate = object["slot_date"] as? Date,
              let selected = selectedDate else { return }
        
        guard currentCalendar.compare(slotDate, to: selected, toGranularity: .year) == .orderedSame,
              currentCalendar.compare(slotDate, to: selected, toGranularity: .month) == .orderedSame,
              currentCalendar.compare(slotDate, to: selected, toGranularity: .day) == .orderedSame else {
            return
        }
        
        updateTimeSlots(withDate: selected)
    }
    
    // This will be called when a booking has been updated by the business
    @objc func didUpdateBooking(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let bid = object["bid"] as? String,
              let updated = object["updated"] as? String,
              let selected = selectedDate else { return }
        
        for i in 0 ..< bookings.count {
            if bookings[i].id == bid {
                bookings[i].date = updated
                break
            }
        }
        
        updateTimeSlots(withDate: selected)
    }
    
    // This will be called when the booking has been finished by the business manually
    @objc func didFinishBooking(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let bid = object["bid"] as? String,
              let selected = selectedDate,
              let index = bookings.firstIndex(where: {
                  $0.id == bid
              }) else { return }
        
        bookings.remove(at: index)
        
        updateTimeSlots(withDate: selected)
    }
    
    @IBAction func didTapPrevious(_ sender: Any) {
        bookingCalendar.setCurrentPage(currentCalendar.date(byAdding: .month, value: -1, to: bookingCalendar.currentPage)!, animated: true)
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        bookingCalendar.setCurrentPage(currentCalendar.date(byAdding: .month, value: 1, to: bookingCalendar.currentPage)!, animated: true)
    }
    
    private var showConfirmedSlotsOnly: Bool = false { didSet {
        if #available(iOS 13.0, *) {
            imvConfirmedOnly.image = UIImage(systemName: showConfirmedSlotsOnly ? "checkmark.square.fill" : "square")
        } else {
            // Fallback on earlier versions
        }
    }}
    
    @IBAction func didTapShowConfirmedOnly(_ sender: Any) {
        showConfirmedSlotsOnly = !showConfirmedSlotsOnly
        
        tblSlots.reloadData()
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: Date Hanlders
extension BusinessBookingsViewController {
    
    // if the date is holiday, returns true.
    // otherwise will return 'false'
    private func isHoliday(_ date: Date) -> Bool {
        let holidays = g_myInfo.business_profile.holidays
        for holiday in holidays {
            let offDate = Date(timeIntervalSince1970: holiday.dayOff.doubleValue)
            
            if currentCalendar.isDate(date, inSameDayAs: offDate) {
               return true
            }
        }
        
        return false
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension BusinessBookingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showConfirmedSlotsOnly ? bookedSlots.count : bookingSlots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let slot = showConfirmedSlotsOnly ? bookedSlots[indexPath.row] : bookingSlots[indexPath.row]
        
        if slot.isBooked {
            let cell = tableView.dequeueReusableCell(withIdentifier: BookedSlotCell.reuseIdentifier, for: indexPath) as! BookedSlotCell
            // configure the cell
            cell.configureCell(slot)
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: BookingSlotCell.reuseIdentifier, for: indexPath) as! BookingSlotCell
            // configure the cell
            cell.configureCell(slot, editable: true)
            cell.slotEnabled = {
                slot.isEnabled ? self.disableSlot(slot, indexPath: indexPath) : self.enableSlot(slot, indexPath: indexPath)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let slot = showConfirmedSlotsOnly ? bookedSlots[indexPath.row] : bookingSlots[indexPath.row]
        
        if slot.isBooked {
            // go to booking detail page
            guard let booking = slot.booking else { return }
            
            let detailsVC = BusinessBookingDetailsViewController.instance()
            detailsVC.selectedBooking = booking
            
            navigationController?.pushViewController(detailsVC, animated: true)
            
        } else {
            if slot.isEnabled {
                // go to create a booking
                // the selected booking date ( date and time )
                guard let selected = selectedDate,
                      let slotTime = slot.time.toDate("h:mm a") else { return }
                
                var dateComponents = currentCalendar.dateComponents([.minute, .hour, .day, .month, .year], from: selected)
                let timeComponents = currentCalendar.dateComponents([.hour, .minute], from: slotTime)
                
                // update time for the selected date
                dateComponents.minute = timeComponents.minute
                dateComponents.hour = timeComponents.hour
                
                guard let bookingDate = currentCalendar.date(from: dateComponents) else  { return }
                
                let createVC = CreateBookingViewController.instance()
                createVC.bookingDate = bookingDate
                
                navigationController?.pushViewController(createVC, animated: true)
                
            } else {
                // if the selected slot is disabled, enable it back
                enableSlot(slot, indexPath: indexPath)
            }
        }
    }
    
    // enable the slot back
    private func enableSlot(_ slot: BookingSlot, indexPath: IndexPath) {
        guard let selectedDate = self.selectedDate,
              let startTime = slot.time.toDate("h:mm a") else { return }
        
        var gregorianCalendar = Calendar(identifier: .gregorian)
        gregorianCalendar.timeZone = TimeZone(abbreviation: "UTC")!
            
        // find the disabled slot id to enable back
        let disabledSlots = g_myInfo.business_profile.disabledSlots
        
        guard let disabledSlot = disabledSlots.first(where: {
            let slotDate = Date(timeIntervalSince1970: $0.date.doubleValue)
            guard let slotStartTime = $0.start.toDate("HH:mm:ss") else { return false }
            
            var dateCompoents = gregorianCalendar.dateComponents([.year, .month, .day], from: slotDate)
            let timeCompoents = gregorianCalendar.dateComponents([.hour, .minute], from: slotStartTime)
            dateCompoents.hour = timeCompoents.hour
            dateCompoents.minute = timeCompoents.minute
            
            guard let slotDateAndTime = gregorianCalendar.date(from: dateCompoents) else { return false }
            
            return currentCalendar.isDate(slotDateAndTime, inSameDayAs: selectedDate) &&
                currentCalendar.compare(slotStartTime, to: startTime, toGranularity: .hour) == .orderedSame &&
                currentCalendar.compare(slotStartTime, to: startTime, toGranularity: .minute) == .orderedSame
        }) else { return }
        
        let enableID = disabledSlot.id
        
        showIndicator()
        APIManager.shared.deleteDisabledSlot(g_myToken, id: enableID) { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                self.didEnableSlot(enableID, indexPath: indexPath)
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private func didEnableSlot(_ id: String, indexPath: IndexPath) {
        // remove the enabled slot from disabled slots
        let disabledSlots = g_myInfo.business_profile.disabledSlots
        guard let index = disabledSlots.firstIndex(where: { $0.id == id }) else { return }
        g_myInfo.business_profile.disabledSlots.remove(at: index)
        
        guard bookingSlots.count > indexPath.row else { return }
        bookingSlots[indexPath.row].isEnabled = true
        
        // reload the item to update appreance
        tblSlots.reloadRows(at: [indexPath], with: .fade)
        
        availableSlotsCount += 1
    }
    
    // disable the slot
    private func disableSlot(_ slot: BookingSlot, indexPath: IndexPath) {
        guard let selectedDate = self.selectedDate,
              let startTime = slot.time.toDate("h:mm a") else { return }
                
        var dateComponents = currentCalendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = currentCalendar.dateComponents([.hour, .minute], from: startTime)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        
        // booking date & time
        guard let bookingSlotDateAndTime = currentCalendar.date(from: dateComponents) else { return }
        
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(abbreviation: "UTC")!
        let bookingDateComponents = gregorian.dateComponents([.day, .month, .year], from: bookingSlotDateAndTime)
        guard let startOfBookingDayInUTC = gregorian.date(from: bookingDateComponents) else { return }
        
        let timestamp = "\(Int64(startOfBookingDayInUTC.timeIntervalSince1970))"
        let start = startTime.toString("HH:mm:ss")
        let end = startTime.addingTimeInterval(TimeInterval(60*60)).toString("HH:mm:ss")
     
        showIndicator()
        APIManager.shared.addDisabledSlot(g_myToken, time: timestamp, start: start, end: end) { result in
            self.hideIndicator()

            switch result {
            case .success(let id):
                var disabledSlot = Slot()
                disabledSlot.id = id
                disabledSlot.date = timestamp
                disabledSlot.start = start
                disabledSlot.end = end

                self.didDisableSlot(disabledSlot, indexPath: indexPath)

            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }

    private func didDisableSlot(_ disabled: Slot, indexPath: IndexPath) {
        // add the new disabled slot to business profile
        g_myInfo.business_profile.disabledSlots.append(disabled)
        
        guard bookingSlots.count > indexPath.row else { return }
        bookingSlots[indexPath.row].isEnabled = false
        
        // reload the item to update appreance
        tblSlots.reloadRows(at: [indexPath], with: .fade)
        
        availableSlotsCount -= 1
    }
}

// MARK: FSCalendarDataSource, FSCalendarDelegate
extension BusinessBookingsViewController: FSCalendarDataSource, FSCalendarDelegate {
    
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


