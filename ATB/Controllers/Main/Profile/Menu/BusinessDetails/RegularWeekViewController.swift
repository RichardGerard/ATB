//
//  RegularWeekViewController.swift
//  ATB
//
//  Created by YueXi on 11/2/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class RegularWeekViewController: BaseViewController {
    
    @IBOutlet weak var lblDayTitle: UILabel!
    @IBOutlet weak var lblOpen: UILabel!
    @IBOutlet weak var lblClose: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView! { didSet {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 94, right: 0)
        scrollView.keyboardDismissMode = .interactive
    }}
    
    @IBOutlet var checkViews: [UIImageView]!
    @IBOutlet var dayLabels: [UILabel]!
    @IBOutlet var openDayFields: [RoundRectTextField]!
    @IBOutlet var closeDayFields: [RoundRectTextField]!
    
    @IBOutlet weak var btnSave: UIButton!
    
    var disabledDays: [Int] = [6]
    
    private let days = ["Monday",
                        "Tuesday",
                        "Wednesday",
                        "Thursday",
                        "Friday",
                        "Saturday",
                        "Sunday"]
    
    var weekdays = [Weekday]()
    
    var isUpdating = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        
        setupViews()
        
        hideKeyboardWhenTapped()
    }
    
    private func initData() {
        if isUpdating {
            weekdays = g_myInfo.business_profile.weekdays
            
        } else {
            // generate by rule
            // 08:00 - 17:00 Mon - Fri are generated
            // Sat/Sun are generated with is available set to 0.
            for i in 0 ... 6 {
                var weekday = Weekday()
                
                weekday.isAvailable = (i < 5)
                weekday.day = i
                weekday.start = "08:00:00"
                weekday.end = "17:00:00"
                
                weekdays.append(weekday)
            }
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
        lblDayTitle.text = "Working Day"
        lblDayTitle.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDayTitle.textColor = .colorGray6
        
        lblOpen.text = "OPEN"
        lblOpen.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblOpen.textColor = .colorGray6
        
        lblClose.text = "CLOSE"
        lblClose.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblClose.textColor = .colorGray6
        
        for i in 0 ..< 7 {
            dayLabels[i].text = days[i]
            dayLabels[i].font = UIFont(name: Font.SegoeUILight, size: 18)
            dayLabels[i].textColor = .colorGray2
            
            setupHourField(openDayFields[i])
            openDayFields[i].tag = hourFieldBaseTag + 2*i
            setupHourField(closeDayFields[i])
            closeDayFields[i].tag = hourFieldBaseTag + 2*i + 1
            
            checkViews[i].tintColor = .colorPrimary
            
            if i < weekdays.count {
                if #available(iOS 13.0, *) {
                    checkViews[i].image = weekdays[i].isAvailable ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square")
                } else {
                    // Fallback on earlier versions
                }
                
                openDayFields[i].text = weekdays[i].start.toDate("HH:mm:ss")?.toString("h:mm a", timeZone: .current) //.toDateString(fromFormat: "HH:mm:ss", toFormat: "h:mm a")
                closeDayFields[i].text = weekdays[i].end.toDate("HH:mm:ss")?.toString("h:mm a", timeZone: .current) // toDateString(fromFormat: "HH:mm:ss", toFormat: "h:mm a")
                
                selectDay(i, enabled: weekdays[i].isAvailable)
                
            } else {
                openDayFields[i].text = ""
                closeDayFields[i].text = ""
            }
        }
        
        btnSave.backgroundColor = .colorPrimary
        btnSave.layer.cornerRadius = 5
        btnSave.layer.masksToBounds = true
        btnSave.setTitle("Save Changes", for: .normal)
        btnSave.setTitleColor(.white, for: .normal)
        btnSave.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 18)
    }
    
    private let hourFieldBaseTag = 700
    private func setupHourField(_ textField: RoundRectTextField) {
        textField.backgroundColor = .white
        
        textField.borderColor = .colorGray17
        textField.borderWidth = 1
        
        textField.tintColor = .colorGray2
        textField.textColor = .colorGray2
        textField.font = UIFont(name: Font.SegoeUILight, size: 18)
        textField.textAlignment = .center
        textField.delegate = self
        
        let datePicker = UIDatePicker()
        datePicker.sizeToFit()
        datePicker.datePickerMode = .time
        if #available(iOS 13.4, *) {
            // add conditions for iOS 14
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.backgroundColor = .colorGray7
        datePicker.setValue(UIColor.colorGray19, forKey: "textColor")
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        toolbar.barTintColor = .colorGray7
        toolbar.layer.borderWidth = 1
        toolbar.layer.borderColor = UIColor.colorGray17.cgColor
        toolbar.clipsToBounds = true
        
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUIBold, size: 18)!,
            .foregroundColor: UIColor.colorGray19
        ]
        
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUILight, size: 18)!,
            .foregroundColor: UIColor.colorGray19
        ]
        
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nibName, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dateSelected))
        doneButton.setTitleTextAttributes(boldAttrs, for: .normal)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dateCancelled))
        cancelButton.setTitleTextAttributes(normalAttrs, for: .normal)
        toolbar.setItems([cancelButton, flexible, doneButton], animated: false)
        
        textField.inputView = datePicker
        textField.inputAccessoryView = toolbar
    }
    
    @objc private func dateChanged(_ picker: UIDatePicker) {
        // add additional code if you want to update the time updated in real time
    }
    
    var currentEditingFieldIndex = -1
    @objc private func dateSelected() {
        view.endEditing(true)
        
        // check validation
        // start should be before the end, end should be after the start
        let editingIndex = currentEditingFieldIndex/2
        let editingField = currentEditingFieldIndex%2 == 0 ? openDayFields[editingIndex] : closeDayFields[editingIndex]
        
        guard let datePicker = editingField.inputView as? UIDatePicker else { return }
        
        let selectedTime = datePicker.date
        // to show local date
        let selectedTimeString = selectedTime.toString("h:mm a", timeZone: .current)
        
        if currentEditingFieldIndex%2 == 0 {
            // to save UTC time which is going to be sent to server
            weekdays[editingIndex].start = selectedTime.toString("HH:mm:ss")
            
        } else {
            // to save UTC time which is going to be sent to server
            weekdays[editingIndex].end = selectedTime.toString("HH:mm:ss")
        }
        
        // the selected time is valid to set on
        editingField.text = selectedTimeString
    }
    
    @objc private func dateCancelled() {
        view.endEditing(true)
        
        currentEditingFieldIndex = -1
    }
    
    private let selectBaseTag = 600
    @IBAction func didTapSelect(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        
        let selected = button.tag - selectBaseTag
        
        // validation for selected index
        guard selected >= 0, selected < weekdays.count else { return }
        
        weekdays[selected].isAvailable = !weekdays[selected].isAvailable
        selectDay(selected, enabled: weekdays[selected].isAvailable)
    }
    
    private func selectDay(_ selected: Int, enabled: Bool) {
        if #available(iOS 13.0, *) {
            checkViews[selected].image = UIImage(systemName: enabled ? "checkmark.square.fill" : "square")
        } else {
            // Fallback on earlier versions
        }
        
        openDayFields[selected].backgroundColor = enabled ? .white : .colorGray7
        openDayFields[selected].textColor = enabled ? .colorGray2 : UIColor.colorGray2.withAlphaComponent(0.45)
        openDayFields[selected].isUserInteractionEnabled = enabled
        
        closeDayFields[selected].backgroundColor = enabled ? .white : .colorGray7
        closeDayFields[selected].textColor = enabled ? .colorGray2 : UIColor.colorGray2.withAlphaComponent(0.45)
        closeDayFields[selected].isUserInteractionEnabled = enabled
    }

    @IBAction func didTapSave(_ sender: Any) {
        guard isUpdating else {
            didFinishUpdateWeek(weekdays)
            return
        }
        
        var week = [Any]()
        for weekday in weekdays {
            let weekdayDict: [String: Any] = [
                "is_available": weekday.isAvailable ? "1" : "0",
                "day": weekday.day as Any,
                "start": weekday.start,
                "end": weekday.end
            ]
            
            week.append(weekdayDict)
        }
                
        showIndicator()
        APIManager.shared.updateWeek(g_myToken, week: week) { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                self.showSuccessVC(msg: "Your working days has been updated successfully!")
                self.didFinishUpdateWeek(nil)
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private func didFinishUpdateWeek(_ week: [Weekday]?) {
        if let week = week {
            let object = [
                "week": week
            ]
            
            NotificationCenter.default.post(name: .DidSetOperatingHour, object: object)
            
            navigationController?.popViewController(animated: true)
            
        } else {
            g_myInfo.business_profile.weekdays.removeAll()
            
            for weekday in weekdays {
                g_myInfo.business_profile.weekdays.append(weekday)
            }
        }
    }
}

// MARK: UITextFieldDelegate
extension RegularWeekViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard textField.tag >= 700,
            let datePicker = textField.inputView as? UIDatePicker,
            let current = textField.text?.toDate("h:mm a", timeZone: .current) else { return }
        currentEditingFieldIndex = textField.tag - 700
        datePicker.date = current
    }
}

