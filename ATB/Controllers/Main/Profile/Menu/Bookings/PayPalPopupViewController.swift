//
//  PayPalPopupViewController.swift
//  ATB
//
//  Created by YueXi on 11/2/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Braintree
import BraintreeDropIn

// MARK: PaymentRequestDelegate
protocol PayPalPopupDelegate {
    
    func didRequestPayment(_ result: Bool)
    func didPayPending(_ transactions: [Transaction])
}

extension PayPalPopupDelegate {
    
    func didRequestPayment(_ result: Bool) { }
    func didPayPending(_ transactions: [Transaction]) { }
}

// bottom sheet popup
// user - pay pending balance with paypal
// business - request payment by paypal
class PayPalPopupViewController: BaseViewController {
    
    static let kStoryboardID = "PayPalPopupViewController"
    class func instance() -> PayPalPopupViewController {
        let storyboard = UIStoryboard(name: "Bookings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: PayPalPopupViewController.kStoryboardID) as? PayPalPopupViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var vContainer: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    /// Invoice View
    @IBOutlet weak var lblInvoice: UILabel!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblTotalValue: UILabel!
    @IBOutlet weak var lblDeposit: UILabel!
    @IBOutlet weak var lblDepositValue: UILabel!
    @IBOutlet weak var lblPending: UILabel!
    @IBOutlet weak var lblPendingValue: UILabel!
    
    // request on business
    // pay on user
    var buttonTitle: String?
    @IBOutlet weak var btnPay: UIButton!
    
    @IBOutlet weak var sideConstraintForPay: NSLayoutConstraint!
    
    var delegate: PayPalPopupDelegate?
    
    var isBusiness = false
    
    var booking: BookingModel!
    
    var dotsIndicatorView: NVActivityIndicatorView!

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
        
        if isBusiness {
            lblTitle.text = "You are about to\nrequest a Payment"
            lblDescription.text = "Please confirm the payment request below, the user will have to pay the remaining balance."
            
        } else {
            lblTitle.text = "Pay now with your\nPayPal account"
            lblDescription.text = "You can pay now the complete the bill from your phone. You can also pay by cash the day of the service"
        }
        
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 25)
        lblTitle.textColor = .colorGray1
        lblTitle.numberOfLines = 0
        lblTitle.setLineSpacing(lineHeightMultiple: 0.8)
        
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray5
        lblDescription.numberOfLines = 0
        lblDescription.setLineSpacing(lineHeightMultiple: 0.8)
        
        lblInvoice.text = "Invoice"
        lblInvoice.font = UIFont(name: Font.SegoeUISemibold, size: 33)
        lblInvoice.textColor = UIColor.colorGray2.withAlphaComponent(0.59)
        
        lblTotal.text = "Total Per Booking"
        lblTotal.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblTotal.textColor = .colorGray5
        
        lblTotalValue.text = "£" + booking.total.priceString
        lblTotalValue.font = UIFont(name: Font.SegoeUIBold, size: 15)
        lblTotalValue.textColor = .colorPrimary
        lblTotalValue.textAlignment = .right
        
        lblDeposit.text = "Deposit"
        lblDeposit.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDeposit.textColor = .colorGray5
        
        var paid: Float = 0.0
        for transaction in booking.transactions {
            if transaction.isSale {
                paid += transaction.amount
            }
        }
        
        lblDepositValue.text = paid >= 0 ? "£" + paid.priceString : "-£" + (-1*paid).priceString
        lblDepositValue.font = UIFont(name: Font.SegoeUIBold, size: 15)
        lblDepositValue.textColor = .colorPrimary
        lblDepositValue.textAlignment = .right
        
        lblPending.text = "Payment Pending"
        lblPending.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblPending.textColor = .colorGray5
        
        let pendingBalance = booking.total + paid
        lblPendingValue.text = "£" + (pendingBalance).priceString
        lblPendingValue.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblPendingValue.textColor = .colorGray5
        lblPendingValue.textAlignment = .right
         
        buttonTitle = isBusiness ? "  Request Payment" : "  Pay £\(pendingBalance.priceString)"
        btnPay.setTitle(buttonTitle, for: .normal)
        btnPay.setTitleColor(.white, for: .normal)
        btnPay.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        btnPay.setImage(UIImage(named: "payment.paypal.logo")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnPay.tintColor = .white
        btnPay.backgroundColor = .colorPrimary
        btnPay.layer.cornerRadius = 5
        btnPay.layer.masksToBounds = true
        
        dotsIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 40), type: .ballBeat, color: .white, padding: 0)
        view.addSubview(dotsIndicatorView)
        
        dotsIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dotsIndicatorView.centerXAnchor.constraint(equalTo: btnPay.centerXAnchor),
            dotsIndicatorView.centerYAnchor.constraint(equalTo: btnPay.centerYAnchor),
        ])
        dotsIndicatorView.isHidden = true
    }
    
    @IBAction func didTapPay(_ sender: Any) {
        btnPay.setTitle("", for: .normal)
        btnPay.setImage(nil, for: .normal)
        
        showFakeIndicator()
        sideConstraintForPay.constant = (SCREEN_WIDTH - 80)/2.0
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
            
        } completion: { _ in
            self.dotsIndicatorView.isHidden = false
            self.dotsIndicatorView.startAnimating()
            self.isBusiness ? self.requestPayment() : self.payPendingBalance()
        }
    }
    
    private func stopAnimating() {
        dotsIndicatorView.stopAnimating()
        dotsIndicatorView.isHidden = true
        
        sideConstraintForPay.constant = 16
        
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
            
        } completion: { _ in
            self.btnPay.setTitle(self.buttonTitle, for: .normal)
            self.btnPay.setImage(UIImage(named: "payment.paypal.logo")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    private func payPendingBalance() {
        // get a client token to pay pending balance
        ATBBraintreeManager.shared.getBraintreeClientToken(g_myToken) { (result, message) in
            // hide indicator
            self.hideFakeIndicator()
            
            guard result else {
                self.stopAnimating()
                
                self.showErrorVC(msg: "Server returned the error message: " + message)
                return
            }

            let clientToken = message
            self.showDropIn(clientTokenOrTokenizationKey: clientToken)
        }
    }
    
    private func showDropIn(clientTokenOrTokenizationKey: String) {
        let request = BTDropInRequest()
        request.vaultManager = true
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request) { (controller, result, error) in
            controller.dismiss(animated: true, completion: nil)
            guard error == nil,
                  let result = result else {
                // show error
                self.stopAnimating()
                self.showErrorVC(msg: "Failed to proceed your payment.\nPlease try again later!")
                return
            }
            
            guard !result.isCancelled,
                  let paymentMethod = result.paymentMethod else {
                // Payment has been cancelled by the user
                self.stopAnimating()
                return
            }
            
            let nonce = paymentMethod.nonce
            self.showAlert("Payment Confirmation", message: "Would you like to proceed the payment?", positive: "Yes", positiveAction: { _ in
                switch result.paymentOptionType {
                case .payPal:
                    self.proceedPayment(withPaymentMethod: "Paypal", nonce: nonce)
                    
                case .masterCard,
                     .AMEX,
                     .dinersClub,
                     .JCB,
                     .maestro,
                     .visa:
                    self.proceedPayment(withPaymentMethod: "Card", nonce: nonce)
                    
                default: break
                }
                
            }, negative: "No", negativeAction: { _ in
                self.stopAnimating()
                
            }, preferredStyle: .actionSheet)
        }
        
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    private func proceedPayment(withPaymentMethod method: String, nonce: String) {
        guard let business = booking.business else {
            self.stopAnimating()
            return
        }
        
        var paid: Float = 0.0
        for transaction in booking.transactions {
            if transaction.isSale {
                paid += transaction.amount
            }
        }
        let pendingBalance = booking.total + paid
        
        let buid = business.uid
        let bid = booking.id // this will be service id from get_bookings
        
        let params = [
            "token" : g_myToken,
            "customerId" : g_myInfo.bt_customer_id,
            "paymentNonce" : nonce,
            "paymentMethod" : method,
            "toUserId" : buid,
            "booking_id" : bid,
            "amount" : "\(pendingBalance)",
            "is_business": "1",
            "quantity": "1"
        ]
        
        showFakeIndicator()
        _ = ATB_Alamofire.POST(MAKE_PP_PAYMENT, parameters: params as [String : AnyObject]) { (result, response) in
            self.hideFakeIndicator()
            self.stopAnimating()
            
            if result,
               let transArray = response["msg"] as? NSArray {
                var transactions = [Transaction]()
                for transArrObject in transArray {
                    guard let transDictArr = transArrObject as? [NSDictionary],
                       let transDict = transDictArr.first,
                       let type = transDict["transaction_type"] as? String,
                       type == "Sale" else { continue }
                        
                    let transaction = Transaction()
                    transaction.id = transDict["id"] as? String ?? ""
                    transaction.tid = transDict["transaction_id"] as? String ?? ""
                    transaction.type = type
                    transaction.amount = (transDict["amount"] as? String ?? "0").floatValue
                    transaction.method = transDict["payment_method"] as? String ?? ""
                    transaction.quantity = (transDict["quantity"] as? String ?? "1").intValue
                    
                    transactions.append(transaction)
                }
                
                self.dismiss(animated: true) {
                    self.delegate?.didPayPending(transactions)
                }                
            
            } else {
                let msg = response.object(forKey: "msg") as? String ?? "Failed to proceed your payment, please try again!"
                self.showErrorVC(msg: msg)
            }
        }
    }
    
    private func requestPayment() {
        APIManager.shared.requestPayment(g_myToken, bid: booking.id, buid: booking.user.ID) { result in
            self.hideFakeIndicator()
            self.dotsIndicatorView.stopAnimating()
            
            self.dismiss(animated: true) {
                switch result {
                case .success(_):
                    self.delegate?.didRequestPayment(true)
                    
                case .failure(_):
                    self.delegate?.didRequestPayment(false)
                }
            }
        }
    }
}
