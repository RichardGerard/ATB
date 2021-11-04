//
//  PostDetailPaymentViewController.swift
//  ATB
//
//  Created by Zachary Powell on 03/11/2019.
//  Copyright © 2019 mobdev. All rights reserved.
//

import UIKit
import ReadMoreTextView
import Kingfisher
import Applozic
import Braintree
import BraintreeDropIn

class PostDetailPaymentViewController: UIViewController {
    
    static let kStoryboardID = "PostDetailPaymentVC"
    class func instance() -> PostDetailPaymentViewController? {
        let storyboard = UIStoryboard(name: "Outdated", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: PostDetailPaymentViewController.kStoryboardID) as? PostDetailPaymentViewController {
            return vc
            
        } else {
            return nil
        }
    }
    
    @IBOutlet weak var txtContent: ReadMoreTextView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewPostImgContainer: ReportView!
    @IBOutlet weak var viewDeliveryOptionContainer: UIView!
    @IBOutlet weak var heightPostTagView: NSLayoutConstraint!
    @IBOutlet var tagItems: [UIView]!
    
    @IBOutlet weak var topOfTxtContent: NSLayoutConstraint!
    @IBOutlet weak var imgPost: UIImageView!
    
    @IBOutlet weak var viewOptFree: UIView!
    @IBOutlet weak var viewOptCollect: UIView!
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var viewOptDeliver: UIView!
    
    @IBOutlet weak var imgOptDeliver: UIImageView!
    @IBOutlet weak var imgOptCollect: UIImageView!
    @IBOutlet weak var imgOptFree: UIImageView!
    @IBOutlet weak var textOptFree: UILabel!
    @IBOutlet weak var textOptCollect: UILabel!
    @IBOutlet weak var textOptDelivery: UILabel!
    @IBOutlet weak var priceOptFree: UILabel!
    @IBOutlet weak var priceOptCollect: UILabel!
    @IBOutlet weak var priceOptDelivery: UILabel!
    
    @IBOutlet weak var btnBuy: RoundedShadowButton!
    
    @IBOutlet weak var deliveryText: UILabel!
    
    var amountToPay = 0
    
    var selectedPost: PostDetailModel = PostDetailModel()
    var parentVC: PostDetailViewController!
    
    override func viewDidLoad() {
        initViews()
        displayTextContent()
    }
    
    func initViews() {
        lblTitle.text = self.selectedPost.Post_Summerize.Post_Title
        btnBuy.setTitle("Buy Now £" + self.selectedPost.Post_Summerize.Post_Price, for: .normal)
        
        if(self.selectedPost.Post_Summerize.Post_Media_Type == "Text")
        {
            self.viewPostImgContainer.heightAnchor.constraint(equalToConstant: 0).isActive = true
            self.imgPost.heightAnchor.constraint(equalToConstant: 0).isActive = true
            
            let screenWidth = UIScreen.main.bounds.width
            self.topOfTxtContent.constant = -screenWidth + 120
            self.viewPostImgContainer.isHidden = true
            self.imgPost.isHidden = true
        }
        else
        {
            if(self.selectedPost.Post_Summerize.Post_Media_Type == "Image")
            {
                let url = URL(string: self.selectedPost.Post_Summerize.Post_Media_Urls[0])
                self.imgPost.kf.setImage(with: url)
            }
            else if(self.selectedPost.Post_Summerize.Post_Media_Type == "Video")
            {
                let url = URL(string: selectedPost.Post_Summerize.Post_Media_Urls[0])
                DispatchQueue.main.async {
                    
//                    if ImageCache.default.imageCachedType(forKey: self.selectedPost.Post_Summerize.Post_Media_Urls[0]).cached {
//                        ImageCache.default.retrieveImage(forKey: self.selectedPost.Post_Summerize.Post_Media_Urls[0], options: nil, completionHandler: { cache, _ in
//                            self.imgPost.image = cache.image
//                        })
//                    } else {
//                        if let thumbnailImage = UIImage().thumbnailForVideoAtURL(url: url! as NSURL) {
//                            self.imgPost.image = thumbnailImage
//                            ImageCache.default.store(thumbnailImage, forKey: self.selectedPost.Post_Summerize.Post_Media_Urls[0])
//                        }
//                    }
                }
            }
        }
        
        var salesPostTagTitles = ["Brand", "Item", "Size", "Location"]
        var servicePostTagTitles = ["Area Covered", "Deposit Required", "Payment Option"]
        
        viewPostImgContainer.cornerRadius = 20.0
        
        let itemPrice = Int(Double(self.selectedPost.Post_Summerize.Post_Price)! * Double(100))
        amountToPay = itemPrice
        
        if(self.selectedPost.Post_Summerize.Post_Type == "Sales") {
            self.heightPostTagView.constant = 245.0
            self.viewSeparator.isHidden = false
            
            deliveryText.text = ""
            
            viewOptFree.isHidden = !selectedPost.Post_Summerize.isFreeEnabled
            viewOptCollect.isHidden = !selectedPost.Post_Summerize.isCollectEnabled
            viewOptDeliver.isHidden = !selectedPost.Post_Summerize.isDeliverEnabled
            
            textOptFree.isHidden = !selectedPost.Post_Summerize.isFreeEnabled
            textOptCollect.isHidden = !selectedPost.Post_Summerize.isCollectEnabled
            textOptDelivery.isHidden = !selectedPost.Post_Summerize.isDeliverEnabled
            
            priceOptFree.isHidden = !selectedPost.Post_Summerize.isFreeEnabled
            priceOptCollect.isHidden = !selectedPost.Post_Summerize.isCollectEnabled
            priceOptDelivery.isHidden = !selectedPost.Post_Summerize.isDeliverEnabled
        
            priceOptDelivery.text = "+£" + selectedPost.Post_Summerize.deliveryCost
            
            if( selectedPost.Post_Summerize.Post_Is_Sold == "1") {
                btnBuy.setTitle("SOLD", for: .normal)
            }
        
            for tagItem in self.tagItems {
                let titleLabel = tagItem.subviews[0] as! UILabel
                let valueLabel = tagItem.subviews[1] as! UILabel
                
                titleLabel.text = salesPostTagTitles[tagItem.tag - 1]
                
                switch(tagItem.tag)
                {
                case 1:
                    //valueLabel.text = self.selectedPost.Post_Summerize.Post_Brand   //Brand Value
                    valueLabel.text = self.selectedPost.Post_Summerize.Post_Brand
                    break
                case 2:
                    //valueLabel.text = "$ " + self.selectedPost.Post_Summerize.Post_Price   //Price Value
                    valueLabel.text = self.selectedPost.Post_Summerize.Post_Item
                    break
                case 3:
                    //valueLabel.text = "$ " + self.selectedPost.Post_Summerize.Postage_Cost   //Deliver Price
                    valueLabel.text = self.selectedPost.Post_Summerize.Post_Size
                    break
                case 4:
                    //valueLabel.text =  self.selectedPost.Post_Summerize.Post_Item   //Item Value
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapOnLocation(_:)))
                    tagItem.addGestureRecognizer(tap)
                    
                    valueLabel.textColor = UIColor.primaryButtonColor
                    valueLabel.attributedText = NSAttributedString(string: self.selectedPost.Post_Summerize.Post_Location.components(separatedBy: ",").last!.trimmingCharacters(in: .whitespacesAndNewlines), attributes:
                        [.underlineStyle: NSUnderlineStyle.single.rawValue])
                    break
                default:
                    break
                }
            }
            
        } else {
            self.heightPostTagView.constant = 180.0
            self.viewSeparator.isHidden = true
            self.viewDeliveryOptionContainer.isHidden = true
            self.viewDeliveryOptionContainer.heightAnchor.constraint(equalToConstant: 0).isActive = true
            
            for tagItem in self.tagItems
            {
                if(tagItem.tag < 4)
                {
                    let titleLabel = tagItem.subviews[0] as! UILabel
                    let valueLabel = tagItem.subviews[1] as! UILabel
                    
                    titleLabel.text = servicePostTagTitles[tagItem.tag - 1]
                    
                    switch(tagItem.tag)
                    {
                    case 1:
                        //Area Covered
                        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapOnLocation(_:)))
                        tagItem.addGestureRecognizer(tap)
                        
                        valueLabel.textColor = UIColor.primaryButtonColor
                        valueLabel.attributedText = NSAttributedString(string: self.selectedPost.Post_Summerize.Post_Location.components(separatedBy: ",").last!.trimmingCharacters(in: .whitespacesAndNewlines), attributes:
                            [.underlineStyle: NSUnderlineStyle.single.rawValue])
                        break
                    case 2:
                        //Deposit Required
                        valueLabel.text = "£" + self.selectedPost.Post_Summerize.Post_Deposit
                        break
                    case 3:
                        //Payment Option
                        valueLabel.text = "Stripe"
                        break
                    default:
                        break
                    }
                }
            }
            
            if (self.selectedPost.Post_Summerize.Post_Deposit == "") {
                btnBuy.setTitle("Buy Service Now", for: .normal)
                
                amountToPay = 0
                
            } else {
                btnBuy.setTitle("Pay £" + self.selectedPost.Post_Summerize.Post_Deposit + " deposit", for: .normal)
                
                amountToPay = Int(Double(self.selectedPost.Post_Summerize.Post_Deposit)! * Double(100))
                
            }
            
//            let titleLabel = tagItems[0].subviews[0] as! UILabel
//            let valueLabel = tagItems[0].subviews[1] as! UILabel
//
//            titleLabel.text = servicePostTagTitles[0]
//            valueLabel.text = "London"

            tagItems[3].isHidden = true
        }
        
        self.view.layoutIfNeeded()
    }
    
    @objc func tapOnLocation(_ sender: UITapGestureRecognizer) {
        print(self.selectedPost.Post_Summerize.Post_Position)
        
        let postLocationVC = self.storyboard?.instantiateViewController(withIdentifier: "PostLocationViewController") as! PostLocationViewController
        
        postLocationVC.postLocation = CLLocation(latitude: self.selectedPost.Post_Summerize.Post_Position.latitude, longitude: self.selectedPost.Post_Summerize.Post_Position.longitude)
        postLocationVC.postAddress = self.selectedPost.Post_Summerize.Post_Location
        
        if(self.selectedPost.Post_Summerize.Post_Type == "Service")
        {
            postLocationVC.strTitle = "Area Covered"
        }
        else
        {
            postLocationVC.strTitle = "Location"
        }
        
        self.navigationController?.pushViewController(postLocationVC, animated: true)
    }
    
    func displayTextContent() {
        txtContent.maximumNumberOfLines = 3
        txtContent.shouldTrim = true
        
        let contentAttributedText = NSMutableAttributedString(string: self.selectedPost.Post_Summerize.Post_Text)
        
        contentAttributedText.addAttribute(.font, value:  UIFont(name: "SegoeUI-Light", size: 18.0)!, range: NSMakeRange(0, contentAttributedText.length))
        contentAttributedText.addAttribute(.foregroundColor, value: UIColor(hex: "737373"), range: NSMakeRange(0, contentAttributedText.length))
        
        self.txtContent.attributedText = contentAttributedText
        
        let readMoreTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.viewMoreTextColor,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)
        ]
        
        let readLessTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.viewLessTextColor,
            NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 15)
        ]
        
        txtContent.attributedReadMoreText = NSAttributedString(string: " ...Read more", attributes: readMoreTextAttributes)
        txtContent.attributedReadLessText = NSAttributedString(string: " ...Read Less", attributes: readLessTextAttributes)
    }
        
    @IBAction func OnBtnClose(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onBuy(_ sender: Any) {
        if (self.btnBuy.title(for: .normal) == "Service Deposit Paid") {
            self.messageToBuy()
        }
        
        if (selectedPost.Post_Summerize.Post_Type == "Service") {
            
            if (self.selectedPost.Post_Summerize.Post_Deposit == "") {
                let alert = UIAlertController(title: "Message to buy", message: "This business does not require a deposit for this service. Message the business to buy this service.", preferredStyle: .actionSheet)
                alert.view.tintColor = UIColor.colorPrimary
                alert.addAction(UIAlertAction(title: "Message business", style: .default, handler: { action in
                    
                    self.messageToBuy()
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.view.tintColor = .colorPrimary
                self.present(alert, animated: true, completion: nil)
                
            } else {
                //Braintree Integration
                self.BuyProduct()
            }
            
        } else {
            if (self.selectedPost.Post_Summerize.Post_Is_Sold == "1") {
                let alert = UIAlertController(title: "Item already sold", message: "This item has already been sold.", preferredStyle: .actionSheet)
                alert.view.tintColor = UIColor.colorPrimary
                alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { action in
                    
                    self.navigationController?.popViewController(animated: true)
                }))
                alert.view.tintColor = .colorPrimary
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            if (selectedPost.Post_Summerize.Post_Payment_Type == "Cash") {
                let alert = UIAlertController(title: "Message to buy", message: "The seller has specified they want payment by cash on collection. Please message the buy to arrange this.", preferredStyle: .actionSheet)
                alert.view.tintColor = UIColor.colorPrimary
                alert.addAction(UIAlertAction(title: "Message seller", style: .default, handler: { action in
                    
                    self.messageToBuy()
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.view.tintColor = .colorPrimary
                self.present(alert, animated: true, completion: nil)
                
            } else if (selectedPost.Post_Summerize.Post_Payment_Type == "Stripe") {
                // Braintree Integration
                self.BuyProduct()
                
            } else {
                let alert = UIAlertController(title: "Pay with Paypal or Cash", message: "The seller has specified payment for this product can be taken via Stripe or Cash.", preferredStyle: .actionSheet)
                alert.view.tintColor = UIColor.colorPrimary
                alert.addAction(UIAlertAction(title: "Pay Securely with Paypal", style: .default, handler: { action in
                    //Braintree Integration
                    self.BuyProduct()
                }))
                alert.addAction(UIAlertAction(title: "Message Seller to Pay Cash", style: .default, handler: { action in
                    self.messageToBuy()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.view.tintColor = .colorPrimary
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func OnBtnDeliveryOption(_ sender: UIButton) {
        let clickedOption = sender.tag
        
        viewOptFree.backgroundColor = UIColor(hexString: "E5E5E5")
        viewOptCollect.backgroundColor = UIColor(hexString: "E5E5E5")
        viewOptDeliver.backgroundColor = UIColor(hexString: "E5E5E5")
        
        imgOptFree.image = UIImage(named: "ico_postage")
        imgOptCollect.image = UIImage(named: "ico_collect")
        imgOptDeliver.image = UIImage(named: "ico_deliver")
        
        switch clickedOption {
        case 1:
            viewOptFree.backgroundColor = UIColor.primaryButtonColor
            imgOptFree.image = UIImage(named: "ico_postage_white")
            btnBuy.setTitle("Buy Now £" + self.selectedPost.Post_Summerize.Post_Price, for: .normal)
            let itemPrice = Int(Double(self.selectedPost.Post_Summerize.Post_Price)! * Double(100))
            amountToPay = itemPrice
            break
            
        case 2:
            viewOptCollect.backgroundColor = UIColor.primaryButtonColor
            imgOptCollect.image = UIImage(named: "ico_collect_white")
            btnBuy.setTitle("Buy Now £" + self.selectedPost.Post_Summerize.Post_Price, for: .normal)
            let itemPrice = Int(Double(self.selectedPost.Post_Summerize.Post_Price)! * Double(100))
            amountToPay = itemPrice
            break
            
        case 3:
            viewOptDeliver.backgroundColor = UIColor.primaryButtonColor
            imgOptDeliver.image = UIImage(named: "ico_deliver_white")
            
            btnBuy.setTitle("Buy Now £" + String(format: "%.2f", Double(self.selectedPost.Post_Summerize.Post_Price)! + Double(self.selectedPost.Post_Summerize.deliveryCost)!), for: .normal)
            amountToPay = amountToPay + Int(Double(self.selectedPost.Post_Summerize.deliveryCost)! * Double(100))
            break
            
        default:
            break
        }
    }
    
    func BuyProduct(){
//        ATBBrainTreeManager.getBraintreeClientToken(){ (result, msg) in
//            if(result)
//            {
//                self.showDropIn(clientTokenOrTokenizationKey: msg)
//            }
//            else
//            {
//                self.showErrorVC(msg: "Server returned the error message: " + msg)
//            }
//        }
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        request.vaultManager = true
        let amountToPay = self.amountToPay / 100
//        request.amount = String(amountToPay)
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil)
            {
                self.showErrorVC(msg: error?.localizedDescription ?? "Failed to process payment please try again")
                
                controller.dismiss(animated: true, completion: nil)
            }
            else if (result?.isCancelled == true)
            {
                print("Cancelled")
                
                controller.dismiss(animated: true, completion: nil)
            }
            else if let result = result
            {
                let paymentNonce = result.paymentMethod?.nonce
                print(paymentNonce)
                controller.dismiss(animated: true, completion: nil)
                
                let alertView = UIAlertController(title: "Payment Confirmation", message: "Would you like to proceed the payment?", preferredStyle: .actionSheet)
                alertView.view.tintColor = UIColor.colorPrimary
                alertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) -> Void in
                    switch result.paymentOptionType
                    {
                    case BTUIKPaymentOptionType.payPal :
                        
                        print("payPal integration")
                        self.ProcessPayment(amount: String(amountToPay), paymentMethod: "Paypal", paymentNonce: paymentNonce!)
                        
                    case BTUIKPaymentOptionType.masterCard,
                         BTUIKPaymentOptionType.AMEX,
                         BTUIKPaymentOptionType.dinersClub,
                         BTUIKPaymentOptionType.discover,
                         BTUIKPaymentOptionType.JCB,
                         BTUIKPaymentOptionType.maestro,
                         //BTUIKPaymentOptionType.laser,
                    //BTUIKPaymentOptionType.solo,
                    //BTUIKPaymentOptionType.unionPay,
                    //BTUIKPaymentOptionType.venmo,
                    //BTUIKPaymentOptionType.ukMaestro,
                    //BTUIKPaymentOptionType.switch,
                    BTUIKPaymentOptionType.visa :
                        
                        print("card integration")
                        self.ProcessPayment(amount: String(amountToPay), paymentMethod: "Card", paymentNonce: paymentNonce!)
                    default:
                        break
                    }
                }))
                
                alertView.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (alertAction) -> Void in
                    
                }))
                alertView.view.tintColor = .colorPrimary
                UIApplication.shared.delegate?.window!!.rootViewController?.present(alertView, animated: true, completion: nil)
            }
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func ProcessPayment(amount:String, paymentMethod:String, paymentNonce:String)
    {
        let params = [
            "token" : g_myToken,
            "customerId" : g_myInfo.bt_customer_id,
            "paymentNonce" : paymentNonce,
            "paymentMethod" : paymentMethod,
            "toUserId" : self.selectedPost.Poster_Info.ID,
            "postId" : self.selectedPost.Post_Summerize.Post_ID,
            "amount" : amount
        ]
        
        _ = ATB_Alamofire.POST(MAKE_PP_PAYMENT, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            self.view.isUserInteractionEnabled = true
            print(responseObject)
            
            if(result)
            {
                self.selectedPost.Post_Summerize.Post_Is_Sold = "1"
                
                var message = "Product bought, please message the seller to arrange collection"
                if (self.selectedPost.Post_Summerize.Post_Type == "Service") {
                   message = "Deposit paid, please message the seller to arrange service."
                    self.btnBuy.setTitle("Service Deposit Paid", for: .normal)
                }
                let alert = UIAlertController(title: "Bought", message: message, preferredStyle: .actionSheet)
                alert.view.tintColor = .colorPrimary
                alert.addAction(UIAlertAction(title: "Message", style: .default, handler: { action in

                    self.messageToBuy()

                }))

                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                let msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if(msg == "")
                {
                    self.showErrorVC(msg: "Failed to process payment, please try again")
                }
                else
                {
                    self.showErrorVC(msg: "Server returned the error message: " + msg)
                }
            }
        }
    }
    
    func buyWithStripe(){
        let params = [
            "token" : g_myToken
        ]
        
        _ = ATB_Alamofire.POST(LOAD_CARDS_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            self.view.isUserInteractionEnabled = true
            print(responseObject)
            
            if(result)
            {
                let cardDicts = responseObject.object(forKey: "msg")  as! [NSDictionary]
                
                if (cardDicts.count > 0) {
                    let alert = UIAlertController(title: "Charge card", message: "Your default card on file will be used to purchase this product.", preferredStyle: .actionSheet)
                    alert.view.tintColor = UIColor.colorPrimary
                    alert.addAction(UIAlertAction(title: "Pay", style: .default, handler: { action in
                        let params = [
                            "token" : g_myToken,
                            "amount" : self.amountToPay,
                            "toUserId" : self.selectedPost.Poster_Info.ID,
                            "postId" : self.selectedPost.Post_Summerize.Post_ID
                            ] as [String : Any]
                        
                        _ = ATB_Alamofire.POST(MAKE_PAYMENT, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
                            (result, responseObject) in
                            print(responseObject)
                            
                            if(result)
                            {
                                self.selectedPost.Post_Summerize.Post_Is_Sold = "1"
                                
                                let alert = UIAlertController(title: "Bought", message: "Product bought, please message the seller to arrange collection", preferredStyle: .actionSheet)
                                alert.view.tintColor = UIColor.colorPrimary
                                alert.addAction(UIAlertAction(title: "Message", style: .default, handler: { action in
                                    
                                    self.messageToBuy()
                                    
                                }))
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        }
                    }
                    ))
                    
                    alert.addAction(UIAlertAction(title: "Use another Card", style: .default, handler: { action in
                        let setAccountVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingAccountVC") as! SettingAccountVC
                        
                        self.navigationController?.pushViewController(setAccountVC, animated: true)
                       
                        
                    }))
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    let alert = UIAlertController(title: "Add card", message: "You currently have no payment cards on file. Add a card to buy this product.", preferredStyle: .actionSheet)
                    alert.view.tintColor = UIColor.colorPrimary
                    alert.addAction(UIAlertAction(title: "Add Card", style: .default, handler: { action in
                        let setAccountVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingAccountVC") as! SettingAccountVC
                        
                        self.navigationController?.pushViewController(setAccountVC, animated: true)
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            else
            {
                let msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if(msg == "")
                {
                    self.showErrorVC(msg: "Failed to get payment details from server, please try again")
                }
                else
                {
                    self.showErrorVC(msg: "Server returned the error message: " + msg)
                }
            }
        }
    }
    
    func messageToBuy(){
        /*let alUser : ALUser =  ALUser()
        alUser.userId = g_myInfo.ID
        alUser.email = g_myInfo.emailAddress
        alUser.imageLink = DOMAIN_URL + g_myInfo.profileImage
        alUser.displayName = g_myInfo.userName
        alUser.password = g_myInfo.ID
        
        ALUserDefaultsHandler.setUserId(alUser.userId)
        ALUserDefaultsHandler.setEmailId(alUser.email)
        ALUserDefaultsHandler.setDisplayName(alUser.displayName)
        
        let chatManager = ALChatManager(applicationKey: "emtrac2ba61d90383c69a7fbc7db07725fa3e5b")
        
        chatManager.connectUserWithCompletion(alUser, completion: {response, error in
            if error == nil {
                let oppositeUserId = self.selectedPost.Poster_Info.ID
                
                let metadata = NSMutableDictionary()
                //metadata["title"] = self.selectedPost.Post_Summerize.Post_Title
                //	metadata["price"] = "£" + self.selectedPost.Post_Summerize.Post_Price
                
                if(self.selectedPost.Post_Summerize.Post_Media_Type == "Image")
                {
                    //metadata["link"] = DOMAIN_URL + self.selectedPost.Post_Summerize.Post_Media_Urls[0]
                }
                
                
                //metadata["AL_CONTEXT_BASED_CHAT"] = "true"
                
                chatManager.launchGroupOfTwo(withClientId: g_myInfo.ID + "ToBUY" + self.selectedPost.Post_Summerize.Post_ID, withMetaData: metadata, andWithUser: oppositeUserId, andFrom: self)
                
            } else {
                self.showErrorVC(msg: "You can't chat with this user.")
            }
        })*/
        let viewController = ConversationViewController()
        
        viewController.userId = self.selectedPost.Poster_Info.ID
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
