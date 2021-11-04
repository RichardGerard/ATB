//
//  ATBBrainTreeManager.swift
//  ATB
//
//  Created by mobdev on 1/5/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import Foundation
import Braintree

class ATBBraintreeManager {
    
    static let shared = ATBBraintreeManager()
    
    private init() {}
    
    // (result, token or message)
    func getBraintreeClientToken(_ token: String, completion: @escaping (Bool, String) -> Void) {
        
        let params = [
            "token" : token
        ]
        
        _ = ATB_Alamofire.POST(GET_BRAINTREE_CLIENT_TOKEN, parameters: params as [String : AnyObject]) { (result, responseObject) in
            if result {
                let res_dict = responseObject["msg"] as! NSDictionary
                
                let bt_client_token = res_dict["client_token"] as! String
                let bt_customer_id = res_dict["customer_id"] as! String
                
                g_myInfo.bt_customer_id = bt_customer_id
                
                completion(true, bt_client_token)
                
            } else {
                let msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if msg == "" {
                    completion(false, "Server Connection Error!")
                    
                } else {
                    completion(false, msg)
                }
            }
        }
    }
}
