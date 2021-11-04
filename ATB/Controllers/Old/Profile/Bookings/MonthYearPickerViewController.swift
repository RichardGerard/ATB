//
//  MonthYearPickerViewController.swift
//  ATB
//
//  Created by YueXi on 10/21/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import MonthYearPicker

protocol MonthSelectDelegate {
    
    func dateSelected(_ date: Date)
}

class MonthYearPickerViewController: BaseViewController {
    
    static let kStoryboardID = "MonthYearPickerViewController"
    class func instance() -> MonthYearPickerViewController {
        let storyboard = UIStoryboard(name: "Sheet", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: MonthYearPickerViewController.kStoryboardID) as? MonthYearPickerViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var vContainer: UIView!
    
    @IBOutlet weak var vMaterialTab: UIView! { didSet {
        vMaterialTab.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        vMaterialTab.layer.cornerRadius = 2
        vMaterialTab.layer.masksToBounds = true
        }}
    
    @IBOutlet weak var lblSelectMonth: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    
    var delegate: MonthSelectDelegate? = nil

    var calendar: Calendar = Calendar.current
    var locale: Locale?
    var selectedDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        vContainer.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
    }
    
    private func setupViews() {
        view.backgroundColor = .clear
        
        lblSelectMonth.text = "Select a Month"
        lblSelectMonth.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblSelectMonth.textColor = .colorPrimary
        
        btnSelect.setTitle("Select", for: .normal)
        btnSelect.setTitleColor(.colorBlue7, for: .normal)
        btnSelect.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        btnSelect.layer.cornerRadius = 4
        btnSelect.layer.masksToBounds = true
        btnSelect.layer.borderWidth = 1
        btnSelect.layer.borderColor = UIColor.colorPrimary.withAlphaComponent(0.43).cgColor
        
        let picker = MonthYearPickerView(frame: CGRect(origin: CGPoint(x: 0, y: 70), size: CGSize(width: view.bounds.width, height: 216)))
//        picker.minimumDate = Date()
//        picker.maximumDate = Calendar.current.date(byAdding: .year, value: 10, to: Date())
        
        picker.date = selectedDate
        picker.labelFont = UIFont(name: Font.SegoeUISemibold, size: 19)!
        vContainer.addSubview(picker)
    
        picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
    }
    
    @objc func dateChanged(_ picker: MonthYearPickerView) {
        selectedDate = picker.date
    }
    
    @IBAction func didTapSelect(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.dateSelected(self.selectedDate)
        }
    }
}
