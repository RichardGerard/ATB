//
//  StripeAPI.swift
//  ATB
//
//  Created by Zachary Powell on 03/11/2019.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import Stripe

class StripeAPIClient: NSObject, STPCustomerEphemeralKeyProvider {

    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        
        let params = [
            "token" : g_myToken
        ]
        
        _ = ATB_Alamofire.POST(GENERATE_EPHEMERAL_KEY, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            print(responseObject)
            
            if(result)
            {
                let key = responseObject.object(forKey: "key") as? String ?? ""
                let json = try? responseObject.toStringDic()
                completion(json, nil)
            }
        }
    }
}
