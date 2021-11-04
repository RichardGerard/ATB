//
//  SelectPaymentViewController.swift
//  ATB
//
//  Created by YueXi on 11/15/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Kingfisher

protocol SelectPaymentDelegate: class {
    
    // paymentOption: 1 - PayPal, 2 - Cash
    func proceedPayment(forProduct product: PostModel, paymentOption: Int, vid: String, quantity: Int, deliveryOption: Int)
    func contactSeller()
}

class SelectPaymentViewController: BaseViewController {
    
    @IBOutlet weak var imvProduct: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var deliveryContainer: FieldContainerView!
    @IBOutlet weak var imvDelivery: UIImageView!
    @IBOutlet weak var lblDelivery: UILabel!
    @IBOutlet weak var lblDeliveryPrice: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var paypalContainer: FieldContainerView! { didSet {
        paypalContainer.activeBackgroundColor = .colorPrimary
    }}
    @IBOutlet weak var imvPayPal: UIImageView!
    @IBOutlet weak var lblPayPal: UILabel!
    @IBOutlet weak var lblMyPayPal: UILabel!
    @IBOutlet weak var imvPayPalSelected: UIImageView!
    
    @IBOutlet weak var cashContainer: FieldContainerView! { didSet {
        cashContainer.activeBackgroundColor = .colorPrimary
    }}
    @IBOutlet weak var imvCash: UIImageView!
    @IBOutlet weak var lblCash: UILabel!
    @IBOutlet weak var lblAgreeSeller: UILabel!
    @IBOutlet weak var imvCashSelected: UIImageView!
    
    @IBOutlet weak var imvClose: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvClose.image = UIImage(systemName: "xmark")
        } else {
            // Fallback on earlier versions
        }
        imvClose.tintColor = .colorGray5
    }}
    
    @IBOutlet weak var btnPay: UIButton!
    
    var delegate: SelectPaymentDelegate?
    
    var selectedProduct: PostModel!
    var vid: String = ""
    var quantity: Int = 0
    var deliveryOption = 0
    
    var selectedOption = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
    }
    
    private func initView() {
        imvProduct.layer.cornerRadius = 5
        imvProduct.layer.masksToBounds = true
        imvProduct.contentMode = .scaleAspectFill
        let url = selectedProduct.Post_Media_Urls.count > 0 ? selectedProduct.Post_Media_Urls[0] : ""
        if selectedProduct.isVideoPost {
            // set placeholder
            imvProduct.image = UIImage(named: "post.placeholder")
            
            if ImageCache.default.imageCachedType(forKey: url).cached {
                ImageCache.default.retrieveImage(forKey: url) { result in
                    switch result {
                    case .success(let cacheResult):
                        if let image = cacheResult.image {
                            let animation = CATransition()
                            animation.type = .fade
                            animation.duration = 0.25
                            self.imvProduct.layer.add(animation, forKey: "transition")
                            self.imvProduct.image = image
                        }
                        
                        break
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                }
                
            } else {
                // thumbnail is not cached, get thumbnail from video url
                Utils.shared.getThumbnailImageFromVideoUrl(url) { thumbnail in
                    if let thumbnail = thumbnail {
                        let animation = CATransition()
                        animation.type = .fade
                        animation.duration = 0.3
                        self.imvProduct.layer.add(animation, forKey: "transition")
                        self.imvProduct.image = thumbnail
                        
                        ImageCache.default.store(thumbnail, forKey: url)
                    }
                }
            }
            
        } else {
            imvProduct.loadImageFromUrl(url, placeholder: "post.placeholder")
        }
                
        lblName.text = selectedProduct.Post_Title.capitalizingFirstLetter
        lblName.font = UIFont(name: Font.SegoeUISemibold, size: 23)
        lblName.textColor = .colorGray5
        lblName.adjustsFontSizeToFitWidth = true
        lblName.minimumScaleFactor = 0.8
        
        lblCount.text = "\(quantity)"
        lblCount.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblCount.textColor = .white
        lblCount.textAlignment = .center
        lblCount.backgroundColor = .colorGray5
        lblCount.layer.cornerRadius = 13
        lblCount.layer.masksToBounds = true
        
        var unitPrice = selectedProduct.Post_Price.floatValue
        if !vid.isEmpty,
           let selectedVariant = selectedProduct.productVariants.first(where: { $0.id == vid }) {
            unitPrice = selectedVariant.price.floatValue
        }
        lblPrice.text = unitPrice.priceString
        lblPrice.font  = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblPrice.textColor = .colorPrimary
        
        deliveryContainer.activeBackgroundColor = .colorPrimary
        deliveryContainer.state = .active
        
        switch deliveryOption {
        case 1:
            if #available(iOS 13.0, *) {
                    imvDelivery.image = UIImage(systemName: "paperplane.fill")
            } else {
                // Fallback on earlier versions
            }
            lblDelivery.text = "Free postage"
            lblDeliveryPrice.text = "+£0.00"
            break
            
        case 3:
            if #available(iOS 13.0, *) {
                imvDelivery.image = UIImage(systemName: "car.fill")
            } else {
                // Fallback on earlier versions
            }
            lblDelivery.text = "I'll Collect"
            lblDeliveryPrice.text = "+£0.00"
            break
            
        case 5:
            if #available(iOS 13.0, *) {
                imvDelivery.image = UIImage(systemName: "cube.box.fill")
            } else {
                // Fallback on earlier versions
            }
            lblDelivery.text = "Deliver"
            lblDeliveryPrice.text = "+£" + selectedProduct.deliveryCost.floatValue.priceString
            break
            
        default:
            break
        }
        imvDelivery.tintColor = .white
                
        lblDelivery.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblDelivery.textColor = .colorGray5
        
        lblDeliveryPrice.font = UIFont(name: Font.SegoeUILight, size: 14)
        lblDeliveryPrice.textColor = .colorGray18
        
        lblTitle.text = "How would you like to pay?"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 22)
        lblTitle.textColor = .colorGray2
        
        lblDescription.text = "The seller has specified you can pay with \(selectedProduct.Post_Payment_Type)"
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray2
        lblDescription.numberOfLines = 2
        
        imvPayPal.image = UIImage(named: "payment.paypal.logo")?.withRenderingMode(.alwaysTemplate)
        lblPayPal.text = "Use your PayPal account"
        lblPayPal.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblMyPayPal.text = g_myInfo.bt_paypal_account
        lblMyPayPal.font = UIFont(name: Font.SegoeUILight, size: 15)
        
        if #available(iOS 13.0, *) {
            imvPayPalSelected.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvPayPalSelected.tintColor = .white
        
        selectPayPal(false)
        
        imvCash.image = UIImage(named: "payment.cash")?.withRenderingMode(.alwaysTemplate)
        lblCash.text = "Cash"
        lblCash.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblAgreeSeller.font = UIFont(name: Font.SegoeUILight, size: 15)
        
        if #available(iOS 13.0, *) {
            imvCashSelected.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvCashSelected.tintColor = .white
        
        selectCash(false)
        
        btnPay.backgroundColor = .colorPrimary
        btnPay.layer.cornerRadius = 5
        updatePayButton()
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapPayPal(_ sender: Any) {
        selectPayPal(true)
        selectCash(false)
        
//        updatePayButton(forPayPal: true)
        selectedOption = 1
    }
    
    @IBAction func didTapCash(_ sender: Any) {
        selectPayPal(false)
        selectCash(true)
        
//        updatePayButton(forPayPal: false)
        selectedOption = 2
    }
    
    private func updatePayButton(forPayPal paypal: Bool = true) {
        UIView.setAnimationsEnabled(false)
        
        if paypal {
            var unitPrice = selectedProduct.Post_Price.floatValue
            if !vid.isEmpty,
               let selectedVariant = selectedProduct.productVariants.first(where: { $0.id == vid }) {
                unitPrice = selectedVariant.price.floatValue
            }
            
            var price = unitPrice * Float(quantity)
            if deliveryOption == 5 {
                price += selectedProduct.deliveryCost.floatValue
            }
            
            let priceString = price.priceString
            let title = "Pay £" + priceString
            let attributedTitle = NSMutableAttributedString(string: title)
            
            attributedTitle.addAttributes([
                .foregroundColor: UIColor.white,
                .font: UIFont(name: Font.SegoeUILight, size: 19)!
            ], range: NSRange(location: 0, length: attributedTitle.length))
            
            attributedTitle.addAttributes([
                .font: UIFont(name: Font.SegoeUISemibold, size: 20)!
            ], range: (title as NSString).range(of: "£" + priceString))
            
            btnPay.setAttributedTitle(attributedTitle, for: .normal)
            
        } else {
            let attributedTitle = NSMutableAttributedString(string: "Be in touch with the seller")
            attributedTitle.addAttributes([
                .foregroundColor: UIColor.white,
                .font: UIFont(name: Font.SegoeUISemibold, size: 19)!
            ], range: NSRange(location: 0, length: attributedTitle.length))
            
            btnPay.setAttributedTitle(attributedTitle, for: .normal)
        }
        
        UIView.setAnimationsEnabled(true)
    }
        
    private func selectPayPal(_ selected: Bool) {
        paypalContainer.state = selected ? .active : .normal
        
        imvPayPal.tintColor = selected ? .white : .colorPrimary
        lblPayPal.textColor = selected ? .white: .colorGray2
        lblMyPayPal.textColor = selected ? .white : .colorPrimary
        
        imvPayPalSelected.isHidden = !selected
    }
    
    private func selectCash(_ selected: Bool) {
        cashContainer.state = selected ? .active : .normal
        imvCash.tintColor = selected ? .white : .colorPrimary
        lblCash.textColor = selected ? .white : .colorGray2
        lblAgreeSeller.textColor = selected ? .white : .colorPrimary
        let attributedTitle = NSMutableAttributedString(string: "Agree with the seller ")
        let bubbleAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            bubbleAttachment.image = UIImage(systemName: "quote.bubble")?.withTintColor(selected ? .white : .colorPrimary)
        } else {
            // Fallback on earlier versions
        }
        attributedTitle.append(NSAttributedString(attachment: bubbleAttachment))
        lblAgreeSeller.attributedText = attributedTitle
        
        imvCashSelected.isHidden = !selected
    }

    @IBAction func didTapPay(_ sender: Any) {
        guard selectedOption > 0 else {
            showErrorVC(msg: "Please select a payment option")
            return
        }
        
        // enabled option by the seller
        let sellerOption = selectedProduct.Post_Payment_Option.intValue
        if sellerOption < 2 && selectedOption == 1 {
            // the seller didn't enable 'PayPal' option and user selected pay with 'PayPal'
            showErrorVC(msg: "The seller hasn't specified the PayPal option!")
            return
        }
        
        dismiss(animated: true) {
//            if self.selectedOption > 1 {
//                self.delegate?.contactSeller()
//
//            } else {
//                self.delegate?.proceedPayment(forProduct: self.selectedProduct, vid: self.vid, quantity: self.quantity, deliveryOption: self.deliveryOption)
//            }
            self.delegate?.proceedPayment(forProduct: self.selectedProduct, paymentOption: self.selectedOption, vid: self.vid, quantity: self.quantity, deliveryOption: self.deliveryOption)
        }
    }
}
