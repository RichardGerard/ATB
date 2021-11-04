//
//  EditBookingViewController.swift
//  ATB
//
//  Created by YueXi on 10/19/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import NBBottomSheet
import MaterialComponents.MaterialButtons
import Kingfisher
import FSCalendar

class EditBookingViewController: BaseViewController {
    
    static let kStoryboardID = "EditBookingViewController"
    class func instance() -> EditBookingViewController {
        let storyboard = UIStoryboard(name: "Bookings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: EditBookingViewController.kStoryboardID) as? EditBookingViewController {
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
    
    @IBOutlet weak var imvPrevious: UIImageView!
    @IBOutlet weak var imvNext: UIImageView!
    @IBOutlet weak var bookingCalendar: FSCalendar!
    
    // time slots table view
    @IBOutlet weak var tblSlots: UITableView!
    
    @IBOutlet weak var btnUpdate: MDCRaisedButton!
    
    private enum CalenderRefreshMode: String {
        case currentPage = "CurrentPage"
        case selectedDate = "SelectedDate"
    }
    
    // -1: no slot selected
    var selectedSlotIndex = -1
    
    private let currentCalendar = Calendar.current
    
    /// The default date calendar to be load
    var defaultDate: Date = Date()
    /// selected date when picker is displayed, default to current date
    var selectedDate: Date?
    
    /// The array of bookings made on the selected month
    var bookings = [BookingModel]()
    
    var bookingSlots = [BookingSlot]()
    
    /// The businesses weekdays and disabled slots
    var businessWeekdays = [Weekday]()
    var businessHolidays = [Holiday]()
    var businessDisabledSlots = [Slot]()
    
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
        // initialize the calendar default load date with the booking date
        defaultDate = Date(timeIntervalSince1970: selectedBooking.date.doubleValue)
        
        // get business weekdays, holidays, and disabled slots
        guard let business = selectedBooking.business else { return }
        
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
        
        if let selectedService = selectedBooking.service {
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
        }
        
        let serviceName = selectedBooking.service.Post_Title.capitalizingFirstLetter
        let businessName = selectedBooking.business.businessName
        
        let titleString = "You are editing:\n\(serviceName) at \(businessName)"
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
        
        let topTitleRange = (titleString as NSString).range(of: "You are editing:")
        attributedTitle.addAttributes(boldAttrs, range: topTitleRange)
        
        let serviceNameRange = (titleString as NSString).range(of: "\(serviceName) at ")
        attributedTitle.addAttributes(normalAttrs, range: serviceNameRange)
        
        let businessNameRange = (titleString as NSString).range(of: businessName)
        attributedTitle.addAttributes(linkAttrs, range: businessNameRange)
        
        lblTitle.attributedText = attributedTitle
        lblTitle.numberOfLines = 2
                 
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
        tblSlots.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 96, right: 0) // 16(top) + 60(button height  + 20(bottom)
        tblSlots.separatorStyle = .none
        tblSlots.register(UINib(nibName: "BookingSlotCell", bundle: nil), forCellReuseIdentifier: BookingSlotCell.reuseIdentifier)
        tblSlots.dataSource = self
        tblSlots.delegate = self
        
        btnUpdate.layer.cornerRadius = 5
        btnUpdate.isUppercaseTitle = false
        btnUpdate.backgroundColor = .colorPrimary
        
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
    
    // update button title with selected date & slot time
    private func updateSendButton() {
        guard let selected = selectedDate,
            selectedSlotIndex >= 0,
            let slotTime = bookingSlots[selectedSlotIndex].time.toDate("h:mm a") else {
            tblSlots.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 16, right: 0)
            btnUpdate.isHidden = true
            return
        }

        tblSlots.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 96, right: 0)
        btnUpdate.isHidden = false
        
        let updateText = "Update for "
        let dateText = selected.toString("d'\(selected.daySuffix())' MMMM", timeZone: .current) + " at " + slotTime.toString("h:mm a", timeZone: .current)
        let allText = updateText + dateText

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

        btnUpdate.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    /// get bookings for the selected day
    private func getBookings() {
        showIndicator()
        
        let uid = selectedBooking.business.uid
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
    
    // show/hide available slots count label
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
        let weekdays = businessWeekdays
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
    
    @IBAction func didTapUpdate(_ sender: Any) {
        guard let selected = selectedDate,
              selectedSlotIndex >= 0,
                    let slotTime = bookingSlots[selectedSlotIndex].time.toDate("h:mm a") else { return }
        
        var dateComponents = currentCalendar.dateComponents([.minute, .hour, .day, .month, .year], from: selected)
        let timeComponents = currentCalendar.dateComponents([.hour, .minute], from: slotTime)
        
        // update time for the selected date
        dateComponents.minute = timeComponents.minute
        dateComponents.hour = timeComponents.hour
        
        guard let bookingDate = currentCalendar.date(from: dateComponents) else  { return }
        
        guard bookingDate > Date() else {
            showInfoVC("ATB", msg: "Please select a future date!")
            return
        }
        
        let updated = "\(Int64(bookingDate.timeIntervalSince1970))"
        showIndicator()
        
        APIManager.shared.requestChange(g_myToken, bid: selectedBooking.id, updated: updated, isRequestedBy: "0") { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                self.didSendRequest(withUpdated: updated)
                
            case .failure(_):
                self.showErrorVC(msg: "Unfortunately, you are trying to edit a booking which is out of the cancellation period the business has detailed. You'll need to contact the business to change the booking.")
            }
        }
    }
    
    private func didSendRequest(withUpdated updated: String) {
        navigationController?.popViewController(animated: true)
        delegate?.didSendChangeRequest(withUpdated: updated)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Date Hanlders
extension EditBookingViewController {
    
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
extension EditBookingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookingSlots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookingSlotCell.reuseIdentifier, for: indexPath) as! BookingSlotCell
        // configure the cell
        cell.configureCell(bookingSlots[indexPath.row], selected: indexPath.row == selectedSlotIndex)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let slot = bookingSlots[indexPath.row]
        guard slot.isEnabled, !slot.isBooked else { return }
        
        var reloadIndexes = [IndexPath]()
        if selectedSlotIndex >= 0 {
            reloadIndexes.append(IndexPath(row: selectedSlotIndex, section: 0))
        }
        reloadIndexes.append(indexPath)
        
        // update selected slot index with new selected
        selectedSlotIndex = indexPath.row
        
        updateSendButton()
        
        // reload to updat selection
        tableView.reloadRows(at: reloadIndexes, with: .fade)
    }
}

// MARK: FSCalendarDataSource, FSCalendarDelegate
extension EditBookingViewController: FSCalendarDataSource, FSCalendarDelegate {
    
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
