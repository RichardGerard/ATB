//
//  DepositPopupViewController.swift
//  ATB
//
//  Created by YueXi on 9/12/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class DepositPopupViewController: UIViewController {
    
    @IBOutlet weak var imvLogo: UIImageView!
    
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var policyCheckbox: CheckBox!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var imvClose: UIImageView!
    
    @IBOutlet weak var btnPay: UIButton!
    
    var depositAmount: Float = 0.0
    var serviceName: String = ""
    var businessName: String = ""
    var cancellationInDays: String = ""
    
    var makePayment: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }

    private func setupViews() {
        imvLogo.image = UIImage(named: "payment.paypal")
        imvLogo.contentMode = .scaleAspectFit
        
        lblPrice.text = "£" + depositAmount.priceString
        lblPrice.font = UIFont(name: Font.SegoeUISemibold, size: 43)
        lblPrice.textColor = .colorPrimary
        
        lblTitle.text = serviceName
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 23)
        lblTitle.textColor = .colorGray5
        lblTitle.numberOfLines = 0
        lblTitle.textAlignment = .center
        
        policyCheckbox.borderStyle = .roundedSquare(radius: 4)
        policyCheckbox.style = .tick
        policyCheckbox.borderWidth = 2
        policyCheckbox.tintColor = .colorPrimary
        policyCheckbox.uncheckedBorderColor = .colorPrimary
        policyCheckbox.checkedBorderColor = .colorPrimary
        policyCheckbox.checkmarkSize = 0.8
        policyCheckbox.checkmarkColor = .colorPrimary
        policyCheckbox.isUserInteractionEnabled = false
//        policyCheckbox.addTarget(self, action: #selector(duractionChecked(_:)), for: .valueChanged)
       
        let description = "Please Tick box to confirm that you agree with \(businessName) cancellation policy of \(cancellationInDays) days and deposit payment of £\(depositAmount.priceString)"
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray5
//        lblDescription.textAlignment = .center
        lblDescription.numberOfLines = 0
        
        let descriptionBoldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUIBold, size: 15)!
        ]
        let attrDescription = NSMutableAttributedString(string: description)
        attrDescription.addAttributes(descriptionBoldAttrs, range: (description as NSString).range(of: businessName))
        attrDescription.addAttributes(descriptionBoldAttrs, range: (description as NSString).range(of: "\(cancellationInDays) days"))
        attrDescription.addAttributes(descriptionBoldAttrs, range: (description as NSString).range(of: "£\(depositAmount.priceString)"))
        lblDescription.attributedText = attrDescription
        
        let buttonTitle = "Pay £\(depositAmount.priceString) Deposit and Book"
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUISemibold, size: 20)!,
            .foregroundColor: UIColor.white
        ]
        let attrButtonTitle = NSMutableAttributedString(string: buttonTitle, attributes: normalAttrs)
        
        let priceRange = (buttonTitle as NSString).range(of: "£" + depositAmount.priceString)
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUIBold, size: 20)!
        ]
        attrButtonTitle.addAttributes(boldAttrs, range: priceRange)
        
        btnPay.setAttributedTitle(attrButtonTitle, for: .normal)
        btnPay.backgroundColor = .colorPrimary
        btnPay.layer.cornerRadius = 5
        btnPay.layer.masksToBounds = true
    }
    
    @IBAction func didTapAgreeTerms(_ sender: Any) {
        policyCheckbox.isChecked = !policyCheckbox.isChecked
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapPay(_ sender: Any) {
        guard policyCheckbox.isChecked else {
            showInfoVC("ATB", msg: "You need to agree to the businesses Deposit & Cancellation policy.")
            return
        }
        dismiss(animated: true) {
            self.makePayment?()
        }
    }
}
