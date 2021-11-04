//
//  CancelBookingViewController.swift
//  ATB
//
//  Created by YueXi on 10/19/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

//MARK: CancelBookingDelegate
protocol CancelBookingDelegate {
    
    func bookingModifyRequested()   // optional function
    func bookingCancelled()
}

extension CancelBookingDelegate {
    // optional protocol
    func bookingModifyRequested() {
        // return a default value or just leave emptys
    }
}

class CancelBookingViewController: BaseViewController {
    
    static let kStoryboardID = "CancelBookingViewController"
    class func instance() -> CancelBookingViewController {
        let storyboard = UIStoryboard(name: "Bookings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: CancelBookingViewController.kStoryboardID) as? CancelBookingViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var vContainer: UIView!
    
    @IBOutlet weak var imvCancel: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var btnModification: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    var delegate: CancelBookingDelegate? = nil
    
    var isBusiness: Bool = false
    var lastCancelDate: String = ""

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
            imvCancel.image = UIImage(systemName: "slash.circle")
        } else {
            // Fallback on earlier versions
        }
        imvCancel.tintColor = .colorRed1
        
        lblTitle.text = "Are you sure you want to\ncancel this booking?"
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 25)
        lblTitle.textColor = .colorGray1
        lblTitle.numberOfLines = 0
        lblTitle.setLineSpacing(lineHeightMultiple: 0.75)
        lblTitle.textAlignment = .center
        
        btnModification.isHidden = !isBusiness
        
        if isBusiness {
            btnModification.titleLabel?.lineBreakMode = .byWordWrapping
            btnModification.titleLabel?.textAlignment = .center
            let textTitle = "Send a modification request to the\nbooking instead"
            let bracketTitle = "[\(textTitle)]"
            let attributedTitle = NSMutableAttributedString(string: bracketTitle)
            
            let textAttrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.colorPrimary,
                .font: UIFont(name: Font.SegoeUILight, size: 19)!
            ]
            attributedTitle.addAttributes(textAttrs, range: NSRange(location: 0, length: attributedTitle.length))
            
            let underlineAttrs: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor.colorPrimary
            ]
            let underlineRange = (bracketTitle as NSString).range(of: textTitle)
            attributedTitle.addAttributes(underlineAttrs, range: underlineRange)
            btnModification.setAttributedTitle(attributedTitle, for: .normal)
            
            lblDescription.text = "We will let the user know that this is going to finished the booking and in case he wants to book again he have to select a different option."
            
        } else {
            lblDescription.text = "You can still cancel this booking before \(lastCancelDate) - if you cancel after this time you will lose your deposit."
        }
        
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray5
        lblDescription.textAlignment = .center
        lblDescription.numberOfLines = 0
        
        btnCancel.setTitle("Cancel Booking", for: .normal)
        btnCancel.setTitleColor(.colorRed1, for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 18)
        btnCancel.layer.cornerRadius = 5
        btnCancel.layer.borderWidth = 1
        btnCancel.layer.borderColor = UIColor.colorGray4.cgColor
    }
    
    @IBAction func didTapModification(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.bookingModifyRequested()
        }
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.bookingCancelled()
        }
    }
}
