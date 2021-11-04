//
//  ServiceFileModel.swift
//  ATB
//
//  Created by mobdev on 28/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation

class ServiceFileModel {
    
    var id: String = ""
    var type: String = "0"  // 0 - Insurance, 1 - Qualification
    var name: String = ""
    var reference: String = ""
    var expiry: String = "" // "d MMM yyyy"
    var fileName: String = ""
    var file: String = "" // file url
    
    var isInsurance: Bool {
        return type == "0"
    }
    
    var isQualification: Bool {
        return type == "1"
    }
    
    // no required to have this
//    var files: (String, String, Any?)? = nil // (name, attachment type, attachment data or url)
}

class QualifiedServiceModel{
    
    var Service_ID:String = ""
    var Service_Name:String = ""
    var Deposit_Required:Bool = false
    var Deposit_Amount:Double = 0.0
    var Qualified_Date:String = ""
    var Qualified_Files:[FileModel] = []
    var Insurance_Company:String = ""
    var Insurance_Number:String = ""
    var Insurance_Expiry:String = ""
    var Insurance_Expiry_Files:[FileModel] = []
    
    init(info:NSDictionary) {
        var strID = info.object(forKey: "id") as? String ?? ""
        if(strID == "")
        {
            let nID = info.object(forKey: "id") as? Int ?? 0
            strID = String(nID)
        }
        self.Service_ID = strID
        self.Service_Name = info.object(forKey: "service_name") as? String ?? ""
        
        var strDepositRequired = info.object(forKey: "is_deposit_required") as? String ?? ""
        if(strDepositRequired == "")
        {
            let nDepositRequired = info.object(forKey: "is_deposit_required") as? Int ?? 0
            strDepositRequired = String(nDepositRequired)
        }
        
        if(strDepositRequired == "1")
        {
            self.Deposit_Required = true
        }
        else
        {
            self.Deposit_Required = false
        }
        
        var strDepositAmount = info.object(forKey: "deposit_amount") as? String ?? ""
        if(strDepositAmount == "")
        {
            let dDepositAmount = info.object(forKey: "deposit_amount") as? Double ?? 0.0
            strDepositAmount = String(dDepositAmount)
        }

        self.Qualified_Date = info.object(forKey: "qualified_since_date") as? String ?? ""
        self.Insurance_Expiry = info.object(forKey: "insurance_expirary_date") as? String ?? ""
        self.Insurance_Company = info.object(forKey: "insurance_company_name") as? String ?? ""
        self.Insurance_Number = info.object(forKey: "insurance_number") as? String ?? ""
        
        let strServiceFileUrls = info.object(forKey: "qualified_since_url") as? String ?? ""
        if(strServiceFileUrls != "")
        {
            var serviceFileUrls = strServiceFileUrls.components(separatedBy: CharacterSet(charactersIn: "[,]")).filter{$0 != ""}.map{$0}
            
            for index in 0..<serviceFileUrls.count
            {
                serviceFileUrls[index] = serviceFileUrls[index].replacingOccurrences(of: "\"", with: "")
                serviceFileUrls[index] = serviceFileUrls[index].replacingOccurrences(of: "\\", with: "")
                
                let newFileModel = FileModel(strFileUrl: serviceFileUrls[index])
                self.Qualified_Files.append(newFileModel)
            }
        }
        
        let strInsuranceFileUrls = info.object(forKey: "insurance_expirary_url") as? String ?? ""
        if(strInsuranceFileUrls != "")
        {
            var insuranceFileUrls = strInsuranceFileUrls.components(separatedBy: CharacterSet(charactersIn: "[,]")).filter{$0 != ""}.map{$0}
            
            for index in 0..<insuranceFileUrls.count
            {
                insuranceFileUrls[index] = insuranceFileUrls[index].replacingOccurrences(of: "\"", with: "")
                insuranceFileUrls[index] = insuranceFileUrls[index].replacingOccurrences(of: "\\", with: "")
                
                let newFileModel = FileModel(strFileUrl: insuranceFileUrls[index])
                self.Insurance_Expiry_Files.append(newFileModel)
            }
        }
    }
    
    init()
    {
        self.Service_ID = ""
        self.Service_Name = ""
        self.Deposit_Required = false
        self.Deposit_Amount = 0.0
        self.Qualified_Date = ""
        self.Qualified_Files = []
        self.Insurance_Company = ""
        self.Insurance_Number = ""
        self.Insurance_Expiry = ""
        self.Insurance_Expiry_Files = []
    }

}


