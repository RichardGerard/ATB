//
//  ATB_UserDefault.swift
//  ATB
//
//  Created by mobdev on 11/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation

class ATB_UserDefault: NSObject {
    
    class func setInt(key: String, value: Int) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getInt(key: String, defaultValue: Int) -> Int {
        guard let _ = UserDefaults.standard.object(forKey: key) else {
            return defaultValue
        }
        
        let value = UserDefaults.standard.integer(forKey: key)
        return value
    }
    
    class func setBool(key:String,value:Bool){
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getBool(key:String) -> Bool{
        let value = UserDefaults.standard.bool(forKey: key)
        return value
    }
    
    class func setDouble(key:String, value:Double)
    {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getDouble(key:String) ->Double{
        let value = UserDefaults.standard.double(forKey: key)
        return value
    }
    
    class func setString(key:String,value:String){
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getString(key:String) -> String{
        let value = UserDefaults.standard.string(forKey: key) ?? ""
        return value
    }
    
    class func setRemember(val:Bool)
    {
        self.setBool(key: "Remember", value: val)
    }
    
    class func getRemember()->Bool
    {
        return self.getBool(key: "Remember")
    }
    
    class func setUserToken(token:String)
    {
        self.setString(key: "UserToken", value: token)
    }
    
    class func getUserToken()->String
    {
        return self.getString(key: "UserToken")
    }
    
    class func setUserEmail(email:String)
    {
        self.setString(key: "UserEmail", value: email)
    }
    
    class func getUserEmail()->String
    {
        return self.getString(key: "UserEmail")
    }
    
    class func setFCMToken(val:String) {
        setString(key: "fcmtoken", value: val)
    }
    
    class func getFCMToken()->String {
        return getString(key: "fcmtoken")
    }
    
    class func setPassword(val:String) {
        setString(key: "password", value: val)
    }
    
    class func getPassword()->String {
        return getString(key: "password")
    }
    
    class func setFBToken(val:String) {
        setString(key: "fbToken", value: val)
    }
    
    class func getfbToken()->String {
        return getString(key: "fbToken")
    }
    
    class func setDeviceUDID(val:String) {
        setString(key: "myudid", value: val)
    }
    
    class func getDeviceUDID()->String {
        return getString(key: "myudid")
    }
    
    class func hasLoginDetails()->Bool {
        return self.getfbToken() != "" || self.getPassword() != ""
    }
    
    class func clear()
    {
        self.setRemember(val: false)
        self.setUserToken(token: "")
        self.setUserEmail(email: "")
        self.setPassword(val: "")
        self.setFBToken(val: "")
        
        UserDefaults.standard.synchronize()
    }
}

