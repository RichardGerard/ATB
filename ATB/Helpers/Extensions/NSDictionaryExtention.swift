//
//  NSDictionaryExtention.swift
//  ATB
//
//  Created by Zachary Powell on 03/11/2019.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation

extension NSDictionary{

func toStringDic() throws -> [String : Any]? {
    do {
        let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
        return jsonData
    }
    catch (let error){
        throw error
    }
}
}
