//
//  BookingSlotCell.swift
//  ATB
//
//  Created by YueXi on 10/23/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class BookingSlotCell: UITableViewCell {
    
    static let reuseIdentifier = "BookingSlotCell"
    
    @IBOutlet weak var lblTime: UILabel! { didSet {
        lblTime.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblTime.textColor = .colorGray11
    }}
    
    // for shadow effect
    @IBOutlet weak var vCard: CardView! { didSet {
        vCard.cornerRadius = 4
        vCard.shadowOffsetHeight = 2
        vCard.shadowRadius = 2
        vCard.shadowOpacity = 0.22
    }}
    
    @IBOutlet weak var vContainer: UIView! { didSet {
        vContainer.layer.cornerRadius = 5
        vContainer.layer.masksToBounds = true
        vContainer.layer.borderColor = UIColor.colorGray7.cgColor
        vContainer.layer.borderWidth = 1
    }}
    
    @IBOutlet weak var imvLeftIcon: UIImageView!
    
    @IBOutlet weak var lblSlotTime: UILabel! { didSet {
        lblSlotTime.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblSlotTime.textColor = UIColor.colorGray2.withAlphaComponent(0.6)
    }}
    
    @IBOutlet weak var lblText: UILabel! { didSet {
        lblText.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        lblText.textColor = .colorGray2
    }}
    
    @IBOutlet weak var vRightContainer: UIView!
    @IBOutlet weak var imvAvailable: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvAvailable.image = UIImage(systemName: "checkmark.square.fill")
        } else {
            // Fallback on earlier versions
        }
        imvAvailable.tintColor = .colorPrimary
    }}
    @IBOutlet weak var lblSlotActionTitle: UILabel! { didSet {
        lblSlotActionTitle.font = UIFont(name: Font.SegoeUILight, size: 11)
        lblSlotActionTitle.textColor = UIColor.colorGray2.withAlphaComponent(0.6)
    }}

    var slotEnabled: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ slot: BookingSlot, editable: Bool = false, selected: Bool = false, displaySlotTime: Bool = false) {
        lblTime.text = slot.time.toDate("h:mm a")?.toString("h:mm a", timeZone: .current)
        
        // show/hide the checkbox to enable/disable the slot
        // This is only available on business booking page, not on user's booking page
        vRightContainer.isHidden = !editable
        
        if editable {
            vContainer.layer.borderWidth = 1
            // slot on business booking page
            vRightContainer.isHidden = selected
            
            // hide slot time label when the slot is disabled
            lblSlotTime.isHidden = !slot.isEnabled
            
            if slot.isEnabled {
                if displaySlotTime {
                    if let start = slot.time.toDate("h:mm a") {
                        let end = start.addingTimeInterval(TimeInterval(60*60))
                        lblSlotTime.text = start.toString("h:mm a", timeZone: .current) + " - " + end.toString("h:mm a", timeZone: .current)
                        
                    } else {
                        lblSlotTime.text = " - "
                    }
                    
                } else {
                    lblSlotTime.text = "Free Slot"
                }
                
                
                if #available(iOS 13.0, *) {
                    imvAvailable.image = UIImage(systemName: "checkmark.square.fill")
                } else {
                    // Fallback on earlier versions
                }
                lblSlotActionTitle.text = "Disable Slot"
                
                if selected {
                    vContainer.backgroundColor = .colorPrimary
                    if #available(iOS 13.0, *) {
                        imvLeftIcon.image = UIImage(systemName: "checkmark.circle.fill")
                    } else {
                        // Fallback on earlier versions
                    }
                    imvLeftIcon.tintColor = .white
                    
                    lblSlotTime.textColor = .white
                    
                    lblText.text = "Selected"
                    lblText.textColor = .white
                    
                } else {
                    vContainer.backgroundColor = .white
                    if #available(iOS 13.0, *) {
                        imvLeftIcon.image = UIImage(systemName: "plus")
                    } else {
                        // Fallback on earlier versions
                    }
                    imvLeftIcon.tintColor = .colorPrimary
                    
                    lblSlotTime.textColor = UIColor.colorGray2.withAlphaComponent(0.6)
                    
                    lblText.text = "Add Booking Here"
                    lblText.textColor = .colorGray2
                }
                
            } else {
                if #available(iOS 13.0, *) {
                    imvLeftIcon.image = UIImage(systemName: "shield.slash.fill")
                } else {
                    // Fallback on earlier versions
                }
                imvLeftIcon.tintColor = UIColor.colorGray2.withAlphaComponent(0.35)
                
                lblText.text = "Disabled Slot"
                lblText.textColor = UIColor.colorGray2.withAlphaComponent(0.35)
                
                if #available(iOS 13.0, *) {
                    imvAvailable.image = UIImage(systemName: "square")
                } else {
                    // Fallback on earlier versions
                }
                lblSlotActionTitle.text = "Enable Slot"
            }
            
        } else {
            vContainer.layer.borderWidth = 0
            
            // slot on user booking/appointment page
            let isAvaialble = !slot.isBooked && slot.isEnabled
            
            // hide slot time label when the slot is not avaialble
            lblSlotTime.isHidden = !isAvaialble
            
            if isAvaialble {
                if selected {
                    vContainer.backgroundColor = .colorPrimary
                    if #available(iOS 13.0, *) {
                        imvLeftIcon.image = UIImage(systemName: "checkmark.circle.fill")
                    } else {
                        // Fallback on earlier versions
                    }
                    imvLeftIcon.tintColor = .white
                    lblSlotTime.textColor = .white
                    lblText.text = "Selected"
                    lblText.textColor = .white
                    
                } else {
                    vContainer.backgroundColor = .white
                    if #available(iOS 13.0, *) {
                        imvLeftIcon.image = UIImage(systemName: "plus")
                    } else {
                        // Fallback on earlier versions
                    }
                    imvLeftIcon.tintColor = .colorPrimary
                    
                    lblSlotTime.textColor = UIColor.colorGray2.withAlphaComponent(0.6)
                    lblText.text = "Add Booking Here"
                    lblText.textColor = .colorGray2
                }
                
                if let start = slot.time.toDate("h:mm a") {
                    let end = start.addingTimeInterval(TimeInterval(60*60))
                    lblSlotTime.text = start.toString("h:mm a", timeZone: .current) + " - " + end.toString("h:mm a", timeZone: .current)
                    
                } else {
                    lblSlotTime.text = " - "
                }
                
            } else {
                vContainer.backgroundColor = UIColor.colorPrimary.withAlphaComponent(0.5)
                
                if #available(iOS 13.0, *) {
                    imvLeftIcon.image = UIImage(systemName: "minus.circle")
                } else {
                    // Fallback on earlier versions
                }
                imvLeftIcon.tintColor = .white
                
                lblText.text = "Not Available"
                lblText.textColor = .white
            }
        }
    }
    
    @IBAction func didTapEnable(_ sender: Any) {
        slotEnabled?()
    }
}
