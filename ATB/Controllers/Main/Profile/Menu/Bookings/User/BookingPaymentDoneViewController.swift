//
//  BookingPaymentDoneViewController.swift
//  ATB
//
//  Created by YueXi on 11/2/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

// MARK: PaymentDoneDelegate
protocol PaymentDoneDelegate {
    
    func rateServiceSelected()
    func backSelected()
}

class BookingPaymentDoneViewController: BaseViewController {
    
    static let kStoryboardID = "BookingPaymentDoneViewController"
    class func instance() -> BookingPaymentDoneViewController {
        let storyboard = UIStoryboard(name: "Bookings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: BookingPaymentDoneViewController.kStoryboardID) as? BookingPaymentDoneViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    // top corners rounded view
    @IBOutlet weak var vContainer: UIView!
    
    @IBOutlet weak var imvCheckbox: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var btnRate: UIButton!
    @IBOutlet weak var lblOr: UILabel!
    @IBOutlet weak var btnGoBooking: UIButton!
    
    var delegate: PaymentDoneDelegate?

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
        
        if #available(iOS 13.0, *) {
            imvCheckbox.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvCheckbox.tintColor = .colorGreen
        
        lblDescription.text = "Your payment has been done, this\nbooking has been completely paid."
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 20)
        lblDescription.textColor = .colorGray1
        lblDescription.textAlignment = .center
        lblDescription.numberOfLines = 0
        
        lblOr.text = "or"
        lblOr.font = UIFont(name: Font.SegoeUILight, size: 20)
        lblOr.textColor = .colorGray12
        
        let rateAttributedTitle = NSMutableAttributedString(string: " Rate this service")
        let rateNormalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.colorPrimary,
            .font: UIFont(name: Font.SegoeUILight, size: 24)!
        ]
        rateAttributedTitle.addAttributes(rateNormalAttrs, range: NSRange(location: 0, length: rateAttributedTitle.length))
        
        let rateBoldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUISemibold, size: 24)!
        ]
        rateAttributedTitle.addAttributes(rateBoldAttrs, range: NSRange(location: 1, length: 4))
        btnRate.setAttributedTitle(rateAttributedTitle, for: .normal)
        if #available(iOS 13.0, *) {
            btnRate.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnRate.tintColor = .colorPrimary
        
        let backAttributedTitle = NSMutableAttributedString(string: " Go to back to My Bookings")
        let backNormalAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.colorGray12,
            .font: UIFont(name: Font.SegoeUILight, size: 20)!
        ]
        backAttributedTitle.addAttributes(backNormalAttrs, range: NSRange(location: 0, length: backAttributedTitle.length))
        
        let backBoldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUISemibold, size: 20)!
        ]
        backAttributedTitle.addAttributes(backBoldAttrs, range: NSRange(location: 15, length: 11))
        btnGoBooking.setAttributedTitle(backAttributedTitle, for: .normal)
        if #available(iOS 13.0, *) {
            btnGoBooking.setImage(UIImage(systemName: "book.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnGoBooking.tintColor = .colorGray12
    }
    
    @IBAction func didTapRate(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.rateServiceSelected()
        }
    }
    
    @IBAction func didTapGoBack(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.backSelected()
        }
    }
}
