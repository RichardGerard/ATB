//
//  BookingCompletedViewController.swift
//  ATB
//
//  Created by YueXi on 10/25/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class BookingCompletedViewController: UIViewController {
    
    @IBOutlet weak var imvCompleted: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var btnViewBooking: UIButton!
    @IBOutlet weak var btnReturnATB: UIButton!
    
    var isOwnCreated: Bool = true
    var email: String = ""
    
    var viewMyBooking: (() -> Void)?
    var returnATB: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        if #available(iOS 13.0, *) {
            imvCompleted.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvCompleted.tintColor = .colorGreen
        
        lblTitle.text = "The service has been booked"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 23)
        lblTitle.textColor = .colorGray5
        lblTitle.textAlignment = .center
        
        lblDescription.text = isOwnCreated ? "You will receive an email with the confirmation of your booking." : "We emailed \(email) with the information for the booking."
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray5
        lblDescription.numberOfLines = 2
        lblDescription.textAlignment = .center
        
        btnViewBooking.setTitle(isOwnCreated ? "View my Booking" : "Back to Bookings", for: .normal)
        btnViewBooking.backgroundColor = .colorPrimary
        btnViewBooking.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        btnViewBooking.setTitleColor(.white, for: .normal)
        btnViewBooking.layer.cornerRadius = 5
        btnViewBooking.layer.masksToBounds = true
        
        btnReturnATB.setTitle("Return to My ATB", for: .normal)
        btnReturnATB.backgroundColor = .colorGray14
        btnReturnATB.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        btnReturnATB.setTitleColor(.colorPrimary, for: .normal)
        btnReturnATB.layer.cornerRadius = 5
        btnReturnATB.layer.masksToBounds = true
        btnReturnATB.layer.borderWidth = 1
        btnReturnATB.layer.borderColor = UIColor.colorGray17.cgColor
        
        btnReturnATB.isHidden = !isOwnCreated
    }
    
    @IBAction func didTapView(_ sender: Any) {
        dismiss(animated: true) {
            self.viewMyBooking?()
        }
    }
    
    @IBAction func didTapReturn(_ sender: Any) {
        dismiss(animated: true) {
            self.returnATB?()
        }
    }
}
