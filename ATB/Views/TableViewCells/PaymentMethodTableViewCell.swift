//
//  PaymentMethodTableViewCell.swift
//  ATB
//
//  Created by mobdev on 2019/5/26.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Stripe

protocol PaymentMethodCellDelegate {
    func onSelectedPayment(index:Int)
}

class PaymentMethodTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgCard: UIImageView!
    
    var cardData:PaymentMethodModel!
    var paymentCellDelegate:PaymentMethodCellDelegate!
    var cardType:String = ""
    var index:Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func OnClickMethod(_ sender: UIButton) {
        paymentCellDelegate.onSelectedPayment(index:self.index)
    }
    
    func configureWithData(cardInfo:PaymentMethodModel, index:Int)
    {
        self.index = index
        var cardImage = STPImageLibrary.templatedBrandImage(for: STPCardBrand.unknown)
        
        switch(cardInfo.CardName)
        {
        case "American Express":
            cardImage = STPImageLibrary.templatedBrandImage(for: STPCardBrand.amex)
            break
        case "Diners Club":
            cardImage = STPImageLibrary.templatedBrandImage(for: STPCardBrand.dinersClub)
            break
        case "Discover":
            cardImage = STPImageLibrary.templatedBrandImage(for: STPCardBrand.discover)
            break
        case "JCB":
            cardImage = STPImageLibrary.templatedBrandImage(for: STPCardBrand.JCB)
            break
        case "MasterCard":
            cardImage = STPImageLibrary.templatedBrandImage(for: STPCardBrand.masterCard)
            break
        case "UnionPay":
            cardImage = STPImageLibrary.templatedBrandImage(for: STPCardBrand.unionPay)
            break
        case "Visa":
            cardImage = STPImageLibrary.templatedBrandImage(for: STPCardBrand.visa)
            break
        default:
            cardImage = STPImageLibrary.templatedBrandImage(for: STPCardBrand.unknown)
            break
        }
        
        self.imgCard.tintColor = UIColor.darkGray
        self.imgCard.image = cardImage
        self.cardData = cardInfo
        self.setPaymentData()
    }
    
    func setPaymentData()
    {
        var titleString = self.cardData.CardName
        
        if(titleString != "Apple Pay")
        {
            titleString = titleString + " Ending In " + self.cardData.CardNumber
        }
 
        let txtFontAttribute = [ NSAttributedString.Key.font: UIFont(name: "SegoeUI-Light", size: 16.0)! ]
        let titleTextString = NSMutableAttributedString(string: titleString, attributes: txtFontAttribute)
        let cardtyperange = (titleString as NSString).range(of: cardData.CardName)
        let cardnumberrange = (titleString as NSString).range(of: cardData.CardNumber)
        titleTextString.addAttribute(.foregroundColor, value: UIColor.black, range: cardtyperange)
        titleTextString.addAttribute(.foregroundColor, value: UIColor.black, range: cardnumberrange)
        
        let endinginrange = (titleString as NSString).range(of: "Ending In")
        
        titleTextString.addAttribute(.foregroundColor, value: UIColor.lightGray, range: endinginrange)
        self.lblTitle.attributedText = titleTextString
        
        var cardImgString = self.cardData.CardName
        cardImgString = cardImgString.replacingOccurrences(of: " ", with: "")
        cardImgString = cardImgString.lowercased()
        self.cardType = cardImgString

        self.imgCheck.isHidden = true
    }
    
    func setPaymentSelected()
    {
        self.imgCheck.isHidden = false
        self.imgCard.tintColor = UIColor.primaryButtonColor
        var titleString = self.cardData.CardName
        
        if(titleString != "Apple Pay")
        {
            titleString = titleString + " Ending In " + self.cardData.CardNumber
        }
        
        let txtFontAttribute = [ NSAttributedString.Key.font: UIFont(name: "SegoeUI-Bold", size: 16.0)! ]
        let titleTextString = NSMutableAttributedString(string: titleString, attributes: txtFontAttribute)
    
        let endingInRange = (titleString as NSString).range(of: "Ending In")
        
        titleTextString.addAttribute(.font, value: UIFont(name: "SegoeUI-Light", size: 16.0)!, range: endingInRange)
        let fullrange = (titleString as NSString).range(of: titleString)
        titleTextString.addAttribute(.foregroundColor, value: UIColor.primaryButtonColor, range: fullrange)
        
        self.lblTitle.attributedText = titleTextString
    }
}
