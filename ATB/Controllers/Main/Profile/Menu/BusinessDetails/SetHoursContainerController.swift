//
//  SetHoursContainerController.swift
//  ATB
//
//  Created by YueXi on 11/2/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class SetHoursContainerController: BaseViewController {
    
    static let kStoryboardID = "SetHoursContainerController"
    class func instance() -> SetHoursContainerController {
        let storyboard = UIStoryboard(name: "BusinessDetails", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: SetHoursContainerController.kStoryboardID) as? SetHoursContainerController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")
            
        } else {
            // Fallback on earlier versions
        }
        imvBack.tintColor = .white
    }}
    
    @IBOutlet weak var imvTitle: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var segmentedControl: BetterSegmentedControl!
    @IBOutlet weak var regularWeekContainer: UIView!    // SetHours2RegularWeek
    @IBOutlet weak var holidaysContainer: UIView!       // SetHours2Holidays
    
    var isUpdating = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        /// add gradient layer
        view.addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 47, alphaValue: 1.0)
        
        segmentContainer.backgroundColor = .colorGray14
        
        /// Title View
        if #available(iOS 13.0, *) {
            imvTitle.image = UIImage(systemName: "clock")
        } else {
            // Fallback on earlier versions
        }
        imvTitle.tintColor = .white
        
        lblTitle.text = "Operating Hours"
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 29)
        lblTitle.textColor = .white
        
        segmentedControl.segments = LabelSegment.segments(withTitles: ["Regular Week", "Holidays / Off"],
                                                        normalBackgroundColor: .colorBlue10,
                                                        normalFont: UIFont(name: Font.SegoeUISemibold, size: 19),
                                                        normalTextColor: .white,
                                                        selectedBackgroundColor: .colorGray14,
                                                        selectedFont: UIFont(name: Font.SegoeUISemibold, size: 19),
                                                        selectedTextColor: .colorGray5)
        
        segmentedControl.indicatorViewInset = 0
        segmentedControl.panningDisabled = true
        segmentedControl.animationDuration = 0.3
        segmentedControl.animationSpringDamping = 0.85
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        segmentedControl.setIndex(0, animated: false)
        
        selectView(0, animated: false)
    }
    
    @objc private func segmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        selectView(sender.index)
    }
    
    private func selectView(_ selected: Int, animated: Bool = true) {
        showRegularWeek(selected == 0, animated: animated)
        showHolidays(selected == 1, animated: animated)
    }
    
    private func showRegularWeek(_ show: Bool, animated: Bool) {
        if show {
            regularWeekContainer.isHidden = false
            
            if animated {
                UIView.animate(withDuration: 0.35) {
                    self.regularWeekContainer.alpha = 1
                }
                
            } else {
                regularWeekContainer.alpha = 1
            }
            
        } else {
            if animated {
                UIView.animate(withDuration: 0.35) {
                    self.regularWeekContainer.alpha = 0
                } completion: { _ in
                    self.regularWeekContainer.isHidden = true
                }
                
            } else {
                regularWeekContainer.alpha = 0
                regularWeekContainer.isHidden = true
            }
        }
    }
    
    private func showHolidays(_ show: Bool, animated: Bool) {
        if show {
            holidaysContainer.isHidden = false
            
            if animated {
                UIView.animate(withDuration: 0.35) {
                    self.holidaysContainer.alpha = 1
                }
                
            } else {
                holidaysContainer.alpha = 1
            }
            
        } else {
            if animated {
                UIView.animate(withDuration: 0.35) {
                    self.holidaysContainer.alpha = 0
                    
                } completion: { _ in
                    self.holidaysContainer.isHidden = true
                }
                
            } else {
                holidaysContainer.alpha = 0
                holidaysContainer.isHidden = true
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "SetHours2RegularWeek",
              let regularVC = segue.destination as? RegularWeekViewController else { return }
        
        regularVC.isUpdating = isUpdating
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
