//
//  RatingDetailModel.swift
//  ATB
//
//  Created by mobdev on 2019/5/27.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation

class RatingDetailModel{
    
    var Rating_ID:String = ""
    var Rating_Value: String = ""
    var created: String = ""
    var Rater_Info:UserModel = UserModel()
    var Rating_Text:String = ""
    
    init(info:NSDictionary) {
    
    }
    
    init()
    {
        
    }
    
    func fillWithDummyDatas()->[RatingDetailModel]
    {
        var retModels:[RatingDetailModel] = []
        
        for i in 1..<20
        {
            let newModel = RatingDetailModel()
            newModel.Rating_ID = String(i)

            retModels.append(newModel)
        }
        
        return retModels
    }
}


