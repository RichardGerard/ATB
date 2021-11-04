//
//  User.swift
//  ATB
//
//  Created by mobdev on 11/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation

// MARK: - User
class User {
    
    var ID:String = ""
    
    var status:Int = 0
    
    var emailAddress:String = ""
    var userName:String = ""
    var firstName:String = ""
    var lastName:String = ""
    
    var accountType: Int = 0            // 0 - normal user, 1 - business user
    var profileImage:String = ""
    var description:String = ""
    
    var birthDay:String = ""
    var gender:Int = 0
    
    var fb_id:String = ""
    var fb_token:String = ""
    
    var address: String = ""    // address string value
    var lat: String = ""        // latitude value
    var lng: String = ""        // longitude value
    var radius: Float = 0.0      // range value
       
    var invite_code = ""
    var business_profile: BusinessModel = BusinessModel()

    var stp_cus_id:String = ""
    var stripe_connect_id = ""
    
    var bt_customer_id: String = ""
    var bt_paypal_account: String = ""
    
    var followCount = 0
    var followerCount = 0
    var postCount = 0
    
    init() {}
    
    init(info: NSDictionary) {
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
        
        self.emailAddress = info.object(forKey: "user_email") as? String ?? ""
        self.userName = info.object(forKey: "user_name") as? String ?? ""
        self.firstName = info.object(forKey: "first_name") as? String ?? ""
        self.lastName = info.object(forKey: "last_name") as? String ?? ""
        self.profileImage = info.object(forKey: "pic_url") as? String ?? ""
        
        self.invite_code = info.object(forKey: "invite_code") as? String ?? ""
        
        let strStatus = info.object(forKey: "status") as? String ?? ""
        if(strStatus == "")
        {
            let nStatus = info.object(forKey: "status") as? Int ?? 0
            self.status = nStatus
        }
        else
        {
            self.status  = Int(strStatus)!
        }

        let strAccountType = info.object(forKey: "account_type") as? String ?? ""
        if(strAccountType == "")
        {
            let nAccountType = info.object(forKey: "account_type") as? Int ?? 0
            self.accountType = nAccountType
        }
        else
        {
            self.accountType  = Int(strAccountType)!
        }
        
        self.address = info.object(forKey: "country") as? String ?? ""
        self.birthDay = info.object(forKey: "birthday") as? String ?? ""
        
        let strGender = info.object(forKey: "gender") as? String ?? ""
        if(strGender == "")
        {
            let nGender = info.object(forKey: "gender") as? Int ?? 0
            self.gender = nGender
        }
        else
        {
            self.gender  = Int(strGender)!
        }
        
        self.description = info.object(forKey: "description") as? String ?? ""
        self.fb_id = info.object(forKey: "facebook_token") as? String ?? ""
        self.fb_token = info.object(forKey: "fb_user_id") as? String ?? ""
        self.lat = info.object(forKey: "latitude") as? String ?? ""
        self.lng = info.object(forKey: "longitude") as? String ?? ""
        self.stp_cus_id = info.object(forKey: "stripe_customer_token") as? String ?? ""
        self.stripe_connect_id = info.object(forKey: "stripe_connect_account") as? String ?? ""
        
        let strRange = info.object(forKey: "post_search_region") as? String ?? ""
        if(strRange == "") {
            let nRange = info.object(forKey: "post_search_region") as? Float ?? 0.0
            self.radius = nRange
            
        } else {
            self.radius  = strRange.floatValue
        }

        self.bt_customer_id = info.object(forKey: "bt_customer_id") as? String ?? ""
        self.bt_paypal_account = info.object(forKey: "bt_paypal_account") as? String ?? ""
        
        followCount = info.object(forKey: "follow_count") as? Int ?? 0
        followerCount = info.object(forKey: "followers_count") as? Int ?? 0
        postCount = info.object(forKey: "post_count") as? Int ?? 0
    }
    
    var isBusinessApproved: Bool {
        guard isBusiness,
            business_profile.isApproved else {
            return false
        }
        
        return true
    }
    
    var isBusiness: Bool {
        return accountType == 1
    }
}

// MARK: - UserModel
class UserModel {
    
    var ID: String = ""
    var email_address:String = ""
    var user_name:String = ""
    var account_name:String = ""
    var firstName:String = ""
    var lastName:String = ""
    
    var phone_number:String = ""
    var profile_image:String = ""
    var user_type:String = ""       // 'User' or 'Business'
    
    var description:String = ""
    
    var distance: Float = 0.0
    
    var business_profile: BusinessModel = BusinessModel()
    
    var fullname: String {
        return firstName + " " + lastName
    }
    
    // This will be used on booking page for none ATB users
    var name: String = ""
    
    var followCount = 0
    var followerCount = 0
    var postCount = 0
    
    var isNoneATBUser: Bool {
        return ID == "none"
    }
    
    init() { }
        
    init(info: NSDictionary) {
        var id = info.object(forKey: "id") as? String ?? ""
        if id == "" {
            let nID = info.object(forKey: "id") as? Int ?? 0
            id = String(nID)
        }
        
        ID = id
        email_address = info.object(forKey: "user_email") as? String ?? ""
        user_name = info.object(forKey: "user_name") as? String ?? ""
        account_name = info.object(forKey: "user_name") as? String ?? ""
        firstName = info.object(forKey: "first_name") as? String ?? ""
        lastName = info.object(forKey: "last_name") as? String ?? ""
        profile_image = info.object(forKey: "pic_url") as? String ?? ""
        
        description = info.object(forKey: "description") as? String ?? ""
        
        var strAccountType = info.object(forKey: "account_type") as? String ?? "0"
        if(strAccountType == "") {
            let nAccountType = info.object(forKey: "account_type") as? Int ?? 0
            strAccountType = "\(nAccountType)"
        }
        
        user_type = strAccountType == "0" ? "User" : "Business"
        
        followCount = info.object(forKey: "follow_count") as? Int ?? 0
        followerCount = info.object(forKey: "followers_count") as? Int ?? 0
        postCount = info.object(forKey: "post_count") as? Int ?? 0
        
        
        if let businessDict = info.object(forKey: "business_info") as? NSDictionary {
            business_profile = BusinessModel(info: businessDict)
        }
        
        distance = info.object(forKey: "distance") as? Float ?? 0
    }
    
    var isBusinessApproved: Bool {
        guard isBusiness,
            business_profile.approved == "1" else {
            return false
        }
        
        return true
    }
    
    var isBusiness: Bool {
        guard user_type == "Business" else {
            return false
        }
        
        return true
    }
}

