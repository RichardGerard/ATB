//
//  AddHolidayViewController.swift
//  ATB
//
//  Created by YueXi on 12/14/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import FSCalendar

protocol AddHolidayDelegate {
    
    func didAddHoliday(_ added: Holiday)
}

class AddHolidayViewController: BaseViewController {
    
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
    
    @IBOutlet weak var calendar: FSCalendar!
    
    var selectedDate: Date = Date().startOfDay
    
    @IBOutlet weak var titleField: RoundRectTextField!
    
    let addInputButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60)
        button.backgroundColor = UIColor.colorPrimary.withAlphaComponent(0.5)
        button.setTitle("  Add as Holiday", for: .normal)
        button.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.22), for: .normal)
        button.addTarget(self, action: #selector(didTapAdd(_:)), for: .touchUpInside)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "calendar.badge.plus"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.tintColor = UIColor.white.withAlphaComponent(0.22)
        
        return button
    }()
    
    var delegate: AddHolidayDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }

    private func setupViews() {
        view.backgroundColor = .clear
        
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
        
        calendar.layer.cornerRadius = 16

        calendar.dataSource = self
        calendar.delegate = self
        
        titleField.backgroundColor = .white
        titleField.borderRadius = 16
        titleField.placeholder = "Holiday Name"
        titleField.tintColor = .colorGray19
        titleField.textColor = .colorGray19
        titleField.inputPadding = 12
        titleField.font = UIFont(name: Font.SegoeUILight, size: 18)
        titleField.inputAccessoryView = addInputButton
        titleField.autocapitalizationType = .words
        titleField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        titleField.delegate = self
    }
    
    private func isValid() -> Bool {
        guard let title = titleField.text,
              title.count > 2 else { return false }
        
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard isValid() else {
            updateAddButton(false)
            return
        }
        
        updateAddButton(true)
    }
    
    private func updateAddButton(_ enabled: Bool) {
        if enabled {
            addInputButton.backgroundColor = .colorPrimary
            addInputButton.setTitleColor(.white, for: .normal)
            addInputButton.tintColor = .white
            
        } else {
            addInputButton.backgroundColor = UIColor.colorPrimary.withAlphaComponent(0.5)
            addInputButton.setTitleColor(UIColor.white.withAlphaComponent(0.22), for: .normal)
            addInputButton.tintColor = UIColor.white.withAlphaComponent(0.22)
        }
    }
    
    @IBAction func didTapPrevious(_ sender: Any) {
        calendar.setCurrentPage(Calendar.current.date(byAdding: .month, value: -1, to: calendar.currentPage)!, animated: true)
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        calendar.setCurrentPage(Calendar.current.date(byAdding: .month, value: 1, to: calendar.currentPage)!, animated: true)
    }

    @objc func didTapAdd(_ sender: Any) {
        addHoliday()
    }
    
    private func addHoliday() {
        guard isValid() else { return }
        
        titleField.resignFirstResponder()
        
        let title = titleField.text!
        let dayOff = "\(Int64(selectedDate.timeIntervalSince1970))"
        
        showIndicator()
        APIManager.shared.addHoliday(g_myToken, title: title, dayOff: dayOff) { result in
            self.hideIndicator()
            
            switch result {
            case .success(let id):
                var added = Holiday()
                added.id = id
                added.name = title
                added.dayOff = dayOff
                
                self.dismiss(animated: true) {
                    self.delegate?.didAddHoliday(added)
                }
                break
                
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
}

// MARK: FSCalendarDataSource, FSCalendarDelegate
extension AddHolidayViewController: FSCalendarDataSource, FSCalendarDelegate {
    
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
        
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
    }
}


extension AddHolidayViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addHoliday()
        
        return true
    }
}
