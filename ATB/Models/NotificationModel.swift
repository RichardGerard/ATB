//
//  NotificationModel.swift
//  ATB
//
//  Created by Zachary Powell on 10/11/2019.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation

class NotificationModel {
    
    var ID:String = ""
    
    var user_id: String = ""
    var type: String = ""
    var text: String = ""
    
    var related_id: String = ""
    
    var name: String = ""
    var profile_image: String = ""
    
    var isVisible: Bool = true
    var isRead: Bool = false
    
    var created: String = ""
    
    init() { }
    
    init(info: NSDictionary) {
        
        self.ID = info.object(forKey: "id") as? String ?? ""
        if(self.ID == "")
        {
            let nID = info.object(forKey: "id") as? Int ?? 0
            self.ID = String(nID)
        }
        
        let unixTimestamp = info.object(forKey: "created_at") as? String ?? ""
        let date = Date(timeIntervalSince1970: Double(unixTimestamp)!)
       
        created = date.timeAgoSinceDate()
        
        self.user_id = info.object(forKey: "user_id") as? String ?? ""
        if(self.user_id == "")
        {
            let nID = info.object(forKey: "user_id") as? Int ?? 0
            self.user_id = String(nID)
        }
        
        self.related_id = info.object(forKey: "related_id") as? String ?? ""
        if(self.related_id == "")
        {
            let nID = info.object(forKey: "related_id") as? Int ?? 0
            self.related_id = String(nID)
        }
        
        isRead = info.object(forKey: "read_status") as? String ?? "0" == "1"
        isVisible = info.object(forKey: "visible") as? String ?? "1" == "1"
        
        text = info.object(forKey: "text") as? String ?? ""
        name = info.object(forKey: "name") as? String ?? ""
        profile_image = info.object(forKey: "profile_image") as? String ?? ""
        
        if (name == "") {
            name = g_myInfo.userName
        }
        
        if (profile_image == "") {
            profile_image = g_myInfo.profileImage
        }
        
        var strType = info.object(forKey: "type") as? String ?? ""
        if(strType == "")
        {
            let nType = info.object(forKey: "type") as? Int ?? 0
            strType = String(nType)
        }
        
        self.type = "signup"
        
        if(strType == "1")  {
            self.type = "report"
            
        } else if(strType == "2") {
            self.type = "comment"
            
        } else if(strType == "3") {
            self.type = "rating"
            
        } else if(strType == "4") {
            self.type = "booking"
            
        } else if(strType == "5") {
            self.type = "message"
            
        } else if (strType == "6") {
            self.type = "payment"
            
        } else if strType == "7" {
            self.type = "liked"
            
        } else if strType == "8" {
            self.type = "post"
            
        } else if strType == "9" {
            self.type = "rating_requested"
            
        } else if strType == "10" {
            self.type = "payment_requested"
        }
    }    
}
