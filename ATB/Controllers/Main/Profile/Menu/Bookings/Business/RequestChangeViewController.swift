//
//  RequestChangeViewController.swift
//  ATB
//
//  Created by YueXi on 11/2/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import NBBottomSheet
import MaterialComponents.MaterialButtons
import FSCalendar

// MARK: ChangeRequestDelegate
protocol ChangeRequestDelegate {
    
    func didSendChangeRequest(withUpdated updated: String)
}

class RequestChangeViewController: BaseViewController {
    
    static let kStoryboardID = "RequestChangeViewController"
    class func instance() -> RequestChangeViewController {
        let storyboard = UIStoryboard(name: "Bookings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: RequestChangeViewController.kStoryboardID) as? RequestChangeViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvChange: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imvClose: UIImageView!
    
    // Business & Booking information Information
    @IBOutlet weak var imvProfile: ProfileView!
    @IBOutlet weak var lblServiceTitle: UILabel!
    @IBOutlet weak var imvCalendar: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imvClock: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var imvPrevious: UIImageView!
    @IBOutlet weak var imvNext: UIImageView!
    @IBOutlet weak var bookingCalendar: FSCalendar!
            
    // slot container view
    @IBOutlet weak var vSlotsCountContainer: UIView! { didSet {
        vSlotsCountContainer.layer.cornerRadius = 15
        vSlotsCountContainer.layer.borderWidth = 2
        vSlotsCountContainer.layer.borderColor = UIColor.colorPrimary.cgColor
        vSlotsCountContainer.layer.masksToBounds = true
    }}
    @IBOutlet weak var lblSlotsCount: UILabel!
    @IBOutlet weak var lblAvailableSlots: UILabel!
    @IBOutlet weak var lblSelect: UILabel!
    
    // time slots table view
    @IBOutlet weak var tblSlots: UITableView!
    
    @IBOutlet weak var btnSend: MDCRaisedButton!
    
    private enum CalenderRefreshMode: String {
        case currentPage = "CurrentPage"
        case selectedDate = "SelectedDate"
    }
      
    // -1: no slot selected
    var selectedSlotIndex = -1
    
    private let currentCalendar = Calendar.current
    
    /// The default date calendar to be load
    var defaultDate: Date = Date()
    /// the date of the selected booking
    var selectedDate: Date? = nil
    
    /// The array of bookings made on the selected month
    var bookings = [BookingModel]()
    var bookingSlots = [BookingSlot]()
    
    var selectedBooking: BookingModel!
    
    var delegate: ChangeRequestDelegate?
    
    private var calenderRefreshMode: CalenderRefreshMode = .currentPage
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        
        setupViews()
        
        getBookings()
    }
    
    private func initData() {
        defaultDate = Date(timeIntervalSince1970: selectedBooking.date.doubleValue).startOfDay
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
        if #available(iOS 13.0, *) {
            imvChange.image = UIImage(systemName: "arrow.up.arrow.down.circle")
        } else {
            // Fallback on earlier versions
        }
        imvChange.tintColor = .colorPrimary
        
        lblTitle.text = "Request a Change"
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 26)
        lblTitle.textColor = .colorPrimary
        
        if #available(iOS 13.0, *) {
            imvClose.image = UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvClose.tintColor = UIColor.colorGray1.withAlphaComponent(0.19)
        
        imvProfile.loadImageFromUrl(selectedBooking.user.profile_image, placeholder: "profile.placeholder")
        
        lblServiceTitle.text = selectedBooking.service.Post_Title
        lblServiceTitle.font = UIFont(name: Font.SegoeUILight, size: 20)
        lblServiceTitle.textColor = .colorGray1
        
        if #available(iOS 13.0, *) {
            imvCalendar.image = UIImage(systemName: "calendar")
        } else {
            // Fallback on earlier versions
        }
        imvCalendar.tintColor = .colorBlue8
        lblDate.text = Date(timeIntervalSince1970: selectedBooking.date.doubleValue).toString("EEEE d MMMM", timeZone: .current)
        lblDate.font = UIFont(name: Font.SegoeUILight, size: 14)
        lblDate.textColor = .colorBlue8
        
        if #available(iOS 13.0, *) {
            imvClock.image = UIImage(systemName: "clock")
        } else {
            // Fallback on earlier versions
        }
        imvClock.tintColor = .colorBlue8
        lblTime.text = Date(timeIntervalSince1970: selectedBooking.date.doubleValue).toString("h:mm a", timeZone: .current)
        lblTime.font = UIFont(name: Font.SegoeUILight, size: 14)
        lblTime.textColor = .colorBlue8
        
        lblSlotsCount.text = ""
        lblSlotsCount.font = UIFont(name: Font.SegoeUISemibold, size: 16)
        lblSlotsCount.textColor = .colorPrimary
        lblSlotsCount.textAlignment = .center
        
        lblAvailableSlots.text = "Slots Available this day"
        lblAvailableSlots.font = UIFont(name: Font.SegoeUISemibold, size: 23)
        lblAvailableSlots.textColor = .colorPrimary
        
        // hide available slot count label
        showAvailableSlotsLabels(false)
        
        lblSelect.text = "Select the available slots below"
        lblSelect.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblSelect.textColor = .colorGray1
        
        tblSlots.backgroundColor = .clear
        tblSlots.tableFooterView = UIView()
        tblSlots.showsVerticalScrollIndicator = false
        tblSlots.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 96, right: 0)
        tblSlots.separatorStyle = .none
        tblSlots.register(UINib(nibName: "BookingSlotCell", bundle: nil), forCellReuseIdentifier: BookingSlotCell.reuseIdentifier)
        tblSlots.register(UINib(nibName: "BookedSlotCell", bundle: nil), forCellReuseIdentifier: BookedSlotCell.reuseIdentifier)
        tblSlots.dataSource = self
        tblSlots.delegate = self
        
        btnSend.setTitle(" Send Change Request", for: .normal)
        btnSend.setTitleFont(UIFont(name: Font.SegoeUISemibold
                                    , size: 18), for: .normal)
        if #available(iOS 13.0, *) {
            btnSend.setImage(UIImage(systemName: "arrow.up.arrow.down.circle"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnSend.tintColor = .white
        btnSend.setTitleColor(.white, for: .normal)
        btnSend.layer.cornerRadius = 5
        btnSend.isUppercaseTitle = false
        btnSend.backgroundColor = .colorPrimary
        
        // hide send button
        updateSendButton()
        
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
    
    // show/hide send button & adjust slot tableview's bottom inset
    private func updateSendButton() {
        guard selectedSlotIndex >= 0 else {
            tblSlots.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 16, right: 0)
            btnSend.isHidden = true
            return
        }
        
        tblSlots.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 96, right: 0)
        btnSend.isHidden = false
    }
    
    /// get bookings for the selected day
    private func getBookings() {
        showIndicator()
        
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
    
    private var availableSlotsCount: Int = 0 {
        didSet {
            if lblAvailableSlots.isHidden {
                showAvailableSlotsLabels(true)
            }
            
            if availableSlotsCount > 0 {
                vSlotsCountContainer.isHidden = false
                lblSlotsCount.text = "\(availableSlotsCount)"
                lblAvailableSlots.text = (availableSlotsCount > 1 ? "Slots" : "Slot") + " Available this day"
                
            } else {
                vSlotsCountContainer.isHidden = true
                lblAvailableSlots.text = "No available slots this day"
            }
        }
    }
    
    private func showAvailableSlotsLabels(_ show: Bool) {
        vSlotsCountContainer.isHidden = !show
        lblSlotsCount.isHidden = !show
        lblAvailableSlots.isHidden = !show
        
        lblSelect.isHidden = !show
    }
    
    private let SLOT_INTERVAL = 1
    private func didSelectDayOnCalendar(_ selected: Date) {
        selectedDate = selected
        
        selectedSlotIndex = -1
        // hide update button
        updateSendButton()
        
        updateTimeSlots(withDate: selected)
    }
    
    private func updateTimeSlots(withDate selected: Date) {
        let endOfDay = selected.endOfDay
        
        let dayOfWeek = selected.dayOfWeek
        let weekdays = g_myInfo.business_profile.weekdays
        guard weekdays.count > dayOfWeek else {
            // no available slots when the weekday is invalid
            availableSlotsCount = 0
            return
        }
        
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

            bookingSlots.append(bookingSlot)
        }

        availableSlotsCount = timeSlots.count - disabledSlotsCount - bookedSlotsCount
        
        tblSlots.reloadData()
    }
    
    @IBAction func didTapPrevious(_ sender: Any) {
        bookingCalendar.setCurrentPage(currentCalendar.date(byAdding: .month, value: -1, to: bookingCalendar.currentPage)!, animated: true)
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        bookingCalendar.setCurrentPage(currentCalendar.date(byAdding: .month, value: 1, to: bookingCalendar.currentPage)!, animated: true)
    }
    
    @IBAction func didTapSend(_ sender: Any) {
        guard let selected = selectedDate,
              selectedSlotIndex >= 0,
                    let slotTime = bookingSlots[selectedSlotIndex].time.toDate("h:mm a") else { return }
        
        var dateComponents = currentCalendar.dateComponents([.minute, .hour, .day, .month, .year], from: selected)
        let timeComponents = currentCalendar.dateComponents([.hour, .minute], from: slotTime)
        
        // update time for the selected date
        dateComponents.minute = timeComponents.minute
        dateComponents.hour = timeComponents.hour
        
        guard let bookingDate = currentCalendar.date(from: dateComponents) else  { return }
        
        let updated = "\(Int64(bookingDate.timeIntervalSince1970))"
        
        showIndicator()
        APIManager.shared.requestChange(g_myToken, bid: selectedBooking.id, updated: updated, isRequestedBy: "1") { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                self.didSendRequest(withUpdated: updated)
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private func didSendRequest(withUpdated updated: String) {
        navigationController?.popViewController(animated: true)
        delegate?.didSendChangeRequest(withUpdated: updated)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Date Hanlders
extension RequestChangeViewController {
    
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
extension RequestChangeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookingSlots.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let slot = bookingSlots[indexPath.row]

        if slot.isBooked {
            let cell = tableView.dequeueReusableCell(withIdentifier: BookedSlotCell.reuseIdentifier, for: indexPath) as! BookedSlotCell
            // configure the cell
            cell.configureCell(slot, isEnabled: false)

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: BookingSlotCell.reuseIdentifier, for: indexPath) as! BookingSlotCell
            // cnfigure the cell
            cell.configureCell(slot, editable: true, selected: indexPath.row == selectedSlotIndex, displaySlotTime: true)
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
        let slot = bookingSlots[indexPath.row]
        
        guard !slot.isBooked else {
            showInfoVC("ATB", msg: "The slot has always been booked.")
            return
        }
        
        if slot.isEnabled {
            var reloadIndexes = [IndexPath]()
            if selectedSlotIndex >= 0 {
                reloadIndexes.append(IndexPath(row: selectedSlotIndex, section: 0))
            }
            
            reloadIndexes.append(indexPath)
            selectedSlotIndex = indexPath.row
            
            // show send button
            updateSendButton()
            
            // reload to updat selection
            tableView.reloadRows(at: reloadIndexes, with: .fade)
            
        } else {
            // if the selected slot is disabled, enable it back
            enableSlot(slot, indexPath: indexPath)
        }
    }
    
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
        guard let selected = selectedDate else { return }
        
        // remove the enabled slot from disabled slots
        let disabledSlots = g_myInfo.business_profile.disabledSlots
        guard let index = disabledSlots.firstIndex(where: { $0.id == id }) else { return }
        g_myInfo.business_profile.disabledSlots.remove(at: index)
        
        guard bookingSlots.count > indexPath.row else { return }
        bookingSlots[indexPath.row].isEnabled = true
        
        // reload the item to update appreance
        tblSlots.reloadRows(at: [indexPath], with: .fade)
        
        availableSlotsCount += 1
        
        // need to post notification to get business booking page slot updated
        let object = [
            "slot_date": selected
        ]
        NotificationCenter.default.post(name: .SlotEnabled, object: object)
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
        
        // need to post notification to get business booking page slot updated
        let object = [
            "slot_date": selectedDate!
        ]
        NotificationCenter.default.post(name: .SlotDisabled, object: object)
    }
}

// MARK: FSCalendarDataSource, FSCalendarDelegate
extension RequestChangeViewController: FSCalendarDataSource, FSCalendarDelegate {
    
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
