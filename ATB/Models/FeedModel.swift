//
//  FeedModel.swift
//  ATB
//
//  Created by mobdev on 2019/5/15.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation

class FeedModel {
    
    var ID: String = ""
    var Title: String = ""
    var Checked: Bool = false
    
    var isMyATB: Bool {
        return Title == "My ATB"
    }
    
    init(info:NSDictionary) {
        
        self.ID = info.object(forKey: "id") as? String ?? ""
        if(self.ID == "")
        {
            let nID = info.object(forKey: "id") as? Int ?? 0
            self.ID = String(nID)
        }
        
        self.Title = info.object(forKey: "title") as? String ?? ""
        self.Checked = false
    }
    
    init()
    {
        self.ID = ""
        self.Title = ""
        self.Checked = false
    }
}


