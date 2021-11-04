//
//  ServiceInfoPopupViewController.swift
//  ATB
//
//  Created by YueXi on 9/12/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class ServiceInfoPopupViewController: UIViewController {
    
    @IBOutlet weak var imvLogo: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var imvClose: UIImageView!
    
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var btnPay: UIButton!
    
    var isDeposit = true
    var depositAmount: Float = 10.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }

    private func setupViews() {
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUISemibold, size: 20)!,
            .foregroundColor: UIColor.white
        ]
        
        buttonContainer.isHidden = isDeposit
        
        if isDeposit {
            imvLogo.image = UIImage(named: "sterlingsign.circle.add")
            lblTitle.text = "Why a deposit?"
            lblDescription.text = "The purpose of the deposit is to proect both you and the business. The deposit secures your booking with the business, in the event of the business cancelling the booking your deposit will be refunded. If you cancel the booking, the businesses has the right to keep the deposit paid or alternatively rebook you for another date. Please note that the deposit paid will be deducted from the cost of the service once completed (e.g. if the services costs £20 and you have paid a £5 deposit, then you will only need to pay £15 to the business"
            
//            let buttonTitle = "Pay £\(depositAmount.priceString) Deposit and Book"
//            let attrButtonTitle = NSMutableAttributedString(string: buttonTitle, attributes: normalAttrs)
//
//            let priceRange = (buttonTitle as NSString).range(of: "£" + depositAmount.priceString)
//            let boldAttrs: [NSAttributedString.Key: Any] = [
//                .font: UIFont(name: Font.SegoeUIBold, size: 20)!
//            ]
//            attrButtonTitle.addAttributes(boldAttrs, range: priceRange)
//
//            btnPay.setAttributedTitle(attrButtonTitle, for: .normal)            
            
        } else {
            imvLogo.image = UIImage(named: "pencil.circle.cross")
            lblTitle.text = "Cancellations Within"
            lblDescription.text = "Cancellations within is the period of time a purchaser of the service has to cancel the service booked for a full refund, if you choose to cancel after this time then the business is entitled to keep the deposit. After the cancellation period has lapsed, the business may refund you your deposit at their discretion"
            
            let buttonTitle = "I understand"
            let attrButtonTitle = NSAttributedString(string: buttonTitle, attributes: normalAttrs)
            
            btnPay.setAttributedTitle(attrButtonTitle, for: .normal)
        }
        
        imvLogo.contentMode = .scaleAspectFit
        
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 23)
        lblTitle.textColor = .colorGray5
        
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray5
        lblDescription.textAlignment = .center
        lblDescription.numberOfLines = 0
        
        if #available(iOS 13.0, *) {
            imvClose.image = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvClose.contentMode = .scaleAspectFit
        imvClose.tintColor = .colorGray2
        
        btnPay.backgroundColor = .colorPrimary
        btnPay.layer.cornerRadius = 5
        btnPay.layer.masksToBounds = true
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapPay(_ sender: Any) {
        dismiss(animated: true) {
            guard self.isDeposit else { return }
            
            
        }
    }
}
