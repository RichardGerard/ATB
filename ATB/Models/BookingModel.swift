//
//  BookingModel.swift
//  ATB
//
//  Created by YueXi on 12/23/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class Transaction {
    var id: String = ""
    var tid: String = ""
    var type: String = ""
    var amount: Float = 0.0
    var method: String = "" // 'Card' or 'PayPal'
    var quantity: Int = 0
    
    var isSale: Bool {
        return type == "Sale"
    }
}

// MARK: Booking Slot Model
class BookingModel {
    
    var id = ""             // booking id
    var sid = ""            // service id
    var state = ""          // active, cancelled, complete
    var date = ""           // day & time, unix timestamp
    
    var total: Float = 0.0
    
    var transactions = [Transaction]()
    
    var user: UserModel!
    
    
    var service: PostModel!
    var business: BusinessModel!
    
    var isReminderEnabled: Bool = false
    
    var isActive: Bool {
        return state == "active"
    }
    
    var created: String = ""
}

// MARK: Booking Slot Model
class BookingSlot {
    
    var isEnabled = true
    
    var time = "" // slot time
    var booking: BookingModel?
    
    var isBooked: Bool {
        return booking != nil
    }
}
