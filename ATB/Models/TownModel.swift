//
//  TownModel.swift
//  ATB
//
//  Created by YueXi on 3/30/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit

class TownModel: NSObject {

    var country: String = "United Kingdom"
    var county: String = ""
    var region: String = ""
    var latitude: Float = 0.0
    var longitude: Float = 0.0
    
    override init() {
        super.init()
    }
    
    init(with dictionary: NSDictionary) {
//        country = dictionary.object(forKey: "country") as? String ?? ""
        county = dictionary.object(forKey: "county") as? String ?? ""
        region = dictionary.allValues.last as? String ?? ""
        latitude = dictionary.object(forKey: "latitude") as? Float ?? 0.0
        longitude = dictionary.object(forKey: "longitude") as? Float ?? 0.0
    }
}
