//
//  BusinessModel.swift
//  ATB
//
//  Created by mobdev on 12/8/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation


struct Holiday {
    
    var id = ""
    var name = ""
    var dayOff = ""
}

struct Weekday {
    
    var isAvailable: Bool = true
    var day: Int = 0
    var start = ""
    var end = ""
}

struct Slot {
    var id = ""
    var date = "" // start of the day, timestamp
    var start = ""
    var end = ""
}

//MARK: - BusinessModel
class BusinessModel {
    
    var ID:String = ""
    var uid: String = ""
    var businessName:String = ""
    var businessWebsite:String = ""
    var businessProfileName:String = ""
    var businessBio:String = ""
    var businessPicUrl:String = ""
    var approved: String = "" // 0 - pending, 1 - approved, other - rejected
    var paid: String = "" // 0 - not paid, 1 - paid
    var approvedReason: String = ""
    var businessServices: [QualifiedServiceModel] = []
    
    var followCount = 0
    var followerCount = 0
    var postCount = 0
    
    var timezone = 0
    
    var fbUsername = ""
    var instaUsername = ""
    var twitterUsername = ""
    
    var holidays = [Holiday]()
    var weekdays = [Weekday]()
    var disabledSlots = [Slot]()
    
    var reviews: Int = 0
    var rating: Double = 0
    
    var isPending: Bool {
        return approved == "0"
    }
    
    var isApproved: Bool {
        return approved == "1"
    }
    
    var isPaid: Bool {
        return paid == "1"
    }
    
    init() {}
    
    init(info:NSDictionary) {
        var strID = info.object(forKey: "id") as? String ?? ""
        if(strID == "")
        {
            let nID = info.object(forKey: "id") as? Int ?? 0
            strID = String(nID)
        }
        self.ID = strID
        
        uid = info.object(forKey: "user_id") as? String ?? ""
        
        self.businessName = info.object(forKey: "business_name") as? String ?? ""
        self.businessWebsite = info.object(forKey: "business_website") as? String ?? ""
        self.businessBio = info.object(forKey: "business_bio") as? String ?? ""
        self.businessProfileName = info.object(forKey: "business_profile_name") as? String ?? ""
        self.businessPicUrl = info.object(forKey: "business_logo") as? String ?? ""
        
        self.paid = info.object(forKey:"paid") as? String ?? "0"
        self.approved = info.object(forKey: "approved") as? String ?? ""
        self.approvedReason = info.object(forKey: "approval_reason") as? String ?? ""
        
        let serviceDicts = info.object(forKey: "services") as? [NSDictionary] ?? []
        if(serviceDicts.count > 0)
        {
            for serviceDict in serviceDicts
            {
                let newServiceModel = QualifiedServiceModel(info: serviceDict)
                self.businessServices.append(newServiceModel)
            }
        }
        
        timezone = info.object(forKey: "timezone") as? Int ?? 0
        
        followCount = info.object(forKey: "follow_count") as? Int ?? 0
        followerCount = info.object(forKey: "follower_count") as? Int ?? 0
        postCount = info.object(forKey: "post_count") as? Int ?? 0
        
        if let socialNames = info.object(forKey: "socials") as? [NSDictionary] {
            for socialNameDict in socialNames {
                let type = socialNameDict.object(forKey: "type") as? String ?? ""
                
                switch type {
                case "0":
                    fbUsername = socialNameDict.object(forKey: "social_name") as? String ?? ""
                    
                case "1":
                    instaUsername = socialNameDict.object(forKey: "social_name") as? String ?? ""
                    
                case "2":
                    twitterUsername = socialNameDict.object(forKey: "social_name") as? String ?? ""
                default:
                    break
                }
            }
        }
        
        if let holidays = info.object(forKey: "holidays") as? [NSDictionary] {
            for holidayDict in holidays {
                var holiday = Holiday()
                
                holiday.id = holidayDict.object(forKey: "id") as? String ?? ""
                holiday.name = holidayDict.object(forKey: "name") as? String ?? ""
                holiday.dayOff = holidayDict.object(forKey: "day_off") as? String ?? ""
            
                self.holidays.append(holiday)
            }
        }
        
        if let weekdays = info.object(forKey: "opening_times") as? [NSDictionary] {
            for weekdayDict in weekdays {
                var weekday = Weekday()
                
                weekday.isAvailable = ((weekdayDict.object(forKey: "is_available") as? String ?? "0") == "1")
                if let dayString = weekdayDict.object(forKey: "day") as? String {
                    weekday.day = dayString.intValue
                }
                weekday.start = weekdayDict.object(forKey: "start") as? String ?? ""
                weekday.end = weekdayDict.object(forKey: "end") as? String ?? ""
                
                self.weekdays.append(weekday)
            }
        }
        
        if let disabledSlots = info.object(forKey: "disabled_slots") as? [NSDictionary] {
            for slotDict in disabledSlots {
                var slot = Slot()
                
                slot.id = slotDict.object(forKey: "id") as? String ?? ""
                slot.date = slotDict.object(forKey: "day_timestamp") as? String ?? ""
                slot.start = slotDict.object(forKey: "start") as? String ?? ""
                slot.end = slotDict.object(forKey: "end") as? String ?? ""
                
                self.disabledSlots.append(slot)
            }
        }
        
        reviews = info.object(forKey: "reviews") as? Int ?? 0
        rating = info.object(forKey: "rating") as? Double ?? 0.0
    }
}
