//
//  CardModel.swift
//  ATB
//
//  Created by mobdev on 2019/5/26.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation

enum CardType: String {
    case ApplePay = "Apple Pay"
    case Amex = "Amex"
    case Visa = "Visa"
    case Discover = "Discover"
    case MasterCard = "Master Card"
}

class PaymentMethodModel{
    
    var ID:String = ""
    var CardID:String = ""
    var CardName:String = ""
    var CardNumber:String = ""
    var isPrimary:Bool = false
    var type:CardType = .Visa
    
    init(info:NSDictionary) {
        let strID = info.object(forKey: "id") as? String ?? ""
        if(strID == "")
        {
            let nID = info.object(forKey: "id") as? Int ?? 0
            self.ID = String(nID)
        }
        else
        {
            self.ID  = strID
        }

        self.CardName = info.object(forKey: "title") as? String ?? ""
        self.CardNumber = info.object(forKey: "card_number") as? String ?? ""
        self.CardID = info.object(forKey: "card_id") as? String ?? ""
        
        self.isPrimary = false
        
        let strPrimary = info.object(forKey: "is_primary") as? String ?? ""
        if(strPrimary == "")
        {
            let nPrimary = info.object(forKey: "is_primary") as? Int ?? 0
            if(nPrimary == 1)
            {
                self.isPrimary = true
            }
        }
        else
        {
            if(strPrimary == "1")
            {
                self.isPrimary = true
            }
        }
    }
    
    init()
    {
        self.ID = ""
        self.CardID = ""
        self.CardName = ""
        self.CardNumber = ""
        self.isPrimary = false
    }
}
