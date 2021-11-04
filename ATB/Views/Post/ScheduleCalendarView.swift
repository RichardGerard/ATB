//
//  ScheduleCalendarView.swift
//  ATB
//
//  Created by YueXi on 11/10/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import FSCalendar

protocol ScheduleCalendarDelegate {
    
    func dateSelected(_ date: Date)
}

class ScheduleCalendarView: UIView {
    
    @IBOutlet weak var container: UIView!

    @IBOutlet weak var imvPrevious: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvPrevious.image = UIImage(systemName: "chevron.left")
        } else {
            // Fallback on earlier versions
        }
        imvPrevious.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var imvNext: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvNext.image = UIImage(systemName: "chevron.right")
        } else {
            // Fallback on earlier versions
        }
        imvNext.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var timePicker: UIPickerView! { didSet {
        timePicker.dataSource = self
        timePicker.delegate = self
    }}
    
    @IBOutlet weak var calendar: FSCalendar!
    private let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    
    var timeFont = UIFont(name: Font.SegoeUILight, size: 22)
    var meridiemFont = UIFont(name: Font.SegoeUISemibold, size: 14)
    
    var selectedDate: Date = Date() {
        didSet {
            
        }
    }
    
    var delegate: ScheduleCalendarDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        container.layer.cornerRadius = 13
        container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        container.layer.masksToBounds = true
    }
    
    private func setupViews() {
        // setup calendar
        calendar.appearance.headerDateFormat = "LLLL yyyy"
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.headerTitleFont = UIFont(name: Font.SegoeUISemibold, size: 20)
        
        calendar.appearance.weekdayTextColor = UIColor.colorGray13.withAlphaComponent(0.3)
        
        calendar.appearance.titleFont = UIFont(name: Font.SegoeUILight, size: 19)
        
        calendar.appearance.todayColor = .clear
        calendar.appearance.titleTodayColor = .colorPrimary
        
        calendar.appearance.titleSelectionColor = .colorPrimary
        calendar.appearance.selectionColor = UIColor.colorPrimary.withAlphaComponent(0.3)
        
//        calendar.appearance.borderRadius = 1.0
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        
        calendar.select(selectedDate)

        calendar.dataSource = self
        calendar.delegate = self
        
        components = currentCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: selectedDate)
        
        setTime(selectedDate, animated: false)
    }
    
    fileprivate enum Component: Int {
        case hour
        case minute
        case meridiem
    }
    
    private let currentCalendar: Calendar = .current
    private var components: DateComponents!
    private func setTime(_ date: Date, animated: Bool) {
        if let hour = components.hour {
            if hour >= 12 {
                timePicker.selectRow(hour - 13, inComponent: .hour, animated: animated)
                timePicker.selectRow(1, inComponent: .meridiem, animated: animated)
                
            } else {
                timePicker.selectRow(hour-1, inComponent: .hour, animated: animated)
                timePicker.selectRow(0, inComponent: .meridiem, animated: animated)
            }
        }
        
        if let minute = components.minute {
            timePicker.selectRow(minute, inComponent: .minute, animated: animated)
        }
    }
    
    @IBAction func didTapPrevious(_ sender: Any) {
        calendar.setCurrentPage(Calendar.current.date(byAdding: .month, value: -1, to: calendar.currentPage)!, animated: true)
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        calendar.setCurrentPage(Calendar.current.date(byAdding: .month, value: 1, to: calendar.currentPage)!, animated: true)
    }
}

// MARK: UIPickerViewDataSource, UIPickerViewDelegate
extension ScheduleCalendarView: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let component = Component(rawValue: component) else { return 0 }
        
        switch component {
        case .hour:
            return 12
        case .minute:
            return 60
        case .meridiem:
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel = view as? UILabel ?? {
            let label = UILabel()
            if #available(iOS 10.0, *) {
                label.adjustsFontForContentSizeCategory = true
            } else {
                // Fallback on earlier versions
            }
            label.textAlignment = .center
            return label
        }()
        
        guard let component = Component(rawValue: component) else { return label }
        
        switch component {
        case .hour, .minute:
            if component == .hour {
                label.text = String(format: "%02i", (row % 12) + 1)
                
            } else {
                label.text = String(format: "%02i", row % 60)
            }
            
            label.font = timeFont
            
        case .meridiem:
            label.text = (row == 0) ? "AM" : "PM"
            label.font = meridiemFont
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    private func value(for row: Int, representing component: Calendar.Component) -> Int? {
        guard let range = currentCalendar.maximumRange(of: component) else { return nil }
        return range.lowerBound + row
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // hour
        components.hour = value(for: pickerView.selectedRow(inComponent: .hour), representing: .hour)
        guard let hour = components.hour else { return }
        
        if pickerView.selectedRow(inComponent: .meridiem) == 0 {
            if hour > 10 {
                components.hour = 0
                
            } else {
                components.hour! += 1
            }
            
        } else if pickerView.selectedRow(inComponent: .meridiem) == 1 {
            if hour > 10 {
                components.hour = 12
                
            } else {
                components.hour! += 13
            }
            
        }
        
        // minues
        components.minute = value(for: pickerView.selectedRow(inComponent: .minute), representing: .minute)
        
        if let selected = currentCalendar.date(from: components) {
            print(selected)
            
            delegate?.dateSelected(selected)
        }
    }
}

// MARK: FSCalendarDataSource, FSCalendarDelegate
extension ScheduleCalendarView: FSCalendarDataSource, FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
//        return gregorian.isDateInToday(date) ? "Today" : nil
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
        
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let dayComponent = currentCalendar.dateComponents([.day, .month, .year], from: date)
        components.day = dayComponent.day
        components.month = dayComponent.month
        components.year = dayComponent.year
        
        if let selected = currentCalendar.date(from: components) {
            delegate?.dateSelected(selected)
        }
    }
}

// MARK: UIPickerView
private extension UIPickerView {
    
    func selectedRow(inComponent component: ScheduleCalendarView.Component) -> Int {
        selectedRow(inComponent: component.rawValue)
    }

    func selectRow(_ row: Int, inComponent component: ScheduleCalendarView.Component, animated: Bool) {
        selectRow(row, inComponent: component.rawValue, animated: animated)
    }
}

