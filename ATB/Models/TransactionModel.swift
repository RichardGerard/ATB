//
//  TransactionModel.swift
//  ATB
//
//  Created by Zachary Powell on 14/12/2019.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation

class TransactionModel {
    
    var ID:String = ""
    var transaction:String = ""
    var amount:String = ""
    var post:PostDetailModel = PostDetailModel()
    var date:String = ""

}

class PPTransactionModel {
    var ID: String = ""
    var transactionID = ""              // Sale, Service, Subscription
    var transactionType: String = ""
    var amount: String = ""
    var post: PostDetailModel = PostDetailModel()
    var date: Date?
}

class TransactionHistoryModel {
    
    var id: String = ""                 // id
    var tid: String = ""                // transaction id
    var uid: String = ""                // 
    var type: String = ""               // type - Subscription, Sale, Service
    var method: String = ""             // method - Paypal, Card
    var amount: Float = 0.0
    var quantity: Int = 0
    var date: String = ""
    
    var item: PostModel!
    
    var purchasedUser: UserModel?
}
