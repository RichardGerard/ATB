//
//  AuctionModel.swift
//  ATB
//
//  Created by YueXi on 5/1/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit

class AuctionModel {
    
    var id: String = ""
    var uid: String = ""
    var type: String = ""
    var price: Float = 0.0
    var position: Int = -1      // invalid, position will be in (0 ... 4)
    var category: String?
    var country: String?
    var county: String?
    var region: String?
    var tag: String?
    var totalBids: Int = 0      // number of bids placed on the position
    var bidOn: Int = -1         // invalid, used in only profile pins
    var user: UserModel?
}
