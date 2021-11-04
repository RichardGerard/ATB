//
//  ATB_Alamofire.swift
//  ATB
//
//  Created by mobdev on 11/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView

var loadingView: UIView = UIView()
var loadingAcitivity: NVActivityIndicatorView? = nil
var curviewcontroller: UIViewController? = nil

let multipartFormDataEncodingMemoryThreshold: UInt64 = 10_000_000

class ATB_Alamofire: Session {
    
    struct Static {
        static var instance: ATB_Alamofire? = nil
        static var token: Int = 0
    }
    
    private static var __once: () = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60.0
        configuration.timeoutIntervalForResource = 60.0
        let manager = ATB_Alamofire(configuration: configuration)
        Static.instance = manager
        
    }()
    
    static var spiningShowed:Bool = false
    
    class var shareInstance: ATB_Alamofire {
        get {
            
            _ = ATB_Alamofire.__once
            return Static.instance!
        }
    }
    
    
    class func DELETE(_ url:String, parameters: [String: AnyObject],showLoading:Bool,showSuccess:Bool,showError:Bool, completionHandler: @escaping (_ result:Bool,_ responseObject:NSDictionary) -> Void) -> Request {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            ]
        
        return ATB_Alamofire.shareInstance.request(url, method: .delete, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON{ response in
            
            switch response.result {
            case .success(let JSON):
                
                let res = JSON as! NSDictionary
                print(res)
                if let ok = res["ok"] as? Bool {
                    if ok{
                        if res["message"] != nil && showSuccess{
                            self.displaySuccess(res["message"] as? String ?? "")
                        }
                        completionHandler( true,res)
                    }else{
                        if res["message"] != nil && showError{
                            self.displayError(res["message"] as! String)
                        }
                        completionHandler( false,res)
                    }
                }
                
            case .failure(let error):
                print(error)
                switch response.response!.statusCode {
                case -1005:
                    self.displayError(error.localizedDescription)
                    break
                default:
                    break
                }
                completionHandler( false,[:])
            }
            hideIndicator()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    class  func POST(_ url: String, parameters: [String: AnyObject], showLoading:Bool = false, showSuccess:Bool = false, showError: Bool = false, completionHandler: @escaping (_ result: Bool, _ responseObject: NSDictionary) -> Void) -> Request {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if showLoading {
            showIndicator()
        }
        
        return ATB_Alamofire.shareInstance.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default).validate().responseJSON { response in
            if showLoading {
                hideIndicator()
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            switch response.result {
            case .success(let JSON):
                
                let res = JSON as! NSDictionary
                if let ok = res["result"] as? Bool {
                    if ok {
                        if res["msg"] != nil && showSuccess {
                            self.displaySuccess(res["msg"] as? String ?? "")
                        }
                        
                        completionHandler(true, res)
                        
                    } else {
                        if res["msg"] != nil && showError {
                            self.displayError(res["msg"] as! String)
                        }
                        
                        completionHandler(false, res)
                    }
                }
                
            case .failure(_):
                completionHandler( false, [:])
            }
        }
    }
    
    class  func POSTAPI(_ url: String, parameters: [String: AnyObject],showLoading:Bool,showSuccess:Bool,showError:Bool, completionHandler: @escaping (_ result:Bool,_ responseObject:NSDictionary) -> Void) -> Request {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if showLoading {
            showIndicator()
        }
        
        let user = "44DD7CwxfuccIecQZRdHGbBnbgm87BlDyO6qVyEuwwatOn9KujDAvBmAFD555lwTJtDU8R"
        let password = "wm7pYHxT"
        let credentialData = "\(user):\(password)".data(using: String.Encoding.utf8)!
        let base64Credentials = credentialData.base64EncodedString(options: [])
        let headers: HTTPHeaders = ["Content-Type": "application/json","Authorization": "Basic \(base64Credentials)"]
        
        return ATB_Alamofire.shareInstance.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.init(), headers : headers).validate().responseJSON { response in
                        
                switch response.result {
                case .success(let data):
                    hideIndicator()
                    //let responseData = response.result.value as! NSDictionary
                    let responseData = JSON(data)
                    let errormsg = responseData["Errors"].stringValue
                    
                    if(errormsg == "")
                    {
//                        let customerData = responseData.object(forKey: "Customer") as! NSDictionary
//                        let cardDetailData = customerData.object(forKey: "CardDetails") as! NSDictionary
//                        let cardNum = cardDetailData.object(forKey: "Number") as! String
                        
                        let customerData = responseData["Customer"].dictionaryValue
                        let cardDetailData = responseData["CardDetails"].dictionaryValue
                        let cardNum = cardDetailData["Number"]?.stringValue
                        
                        let res : NSDictionary = ["cardnum":cardNum]
                        completionHandler(true, res)
                    }
                    else
                    {
                        completionHandler( false,[:])
                    }
                case .failure(let error):
                    hideIndicator()
                    print(error.localizedDescription)
                    if response.response?.statusCode == 400
                    {
                        
                    }
                    completionHandler( false,[:])
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    class func GET(_ url: String, parameters: [String: AnyObject],showLoading:Bool,showSuccess:Bool,showError:Bool, completionHandler: @escaping (_ result:Bool,_ responseObject:NSDictionary) -> Void) -> Request {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if showLoading {
            showIndicator()
        }
        return ATB_Alamofire.shareInstance.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).validate().responseJSON{ response in
            
            
            switch response.result {
            case .success(let JSON):
                let res = JSON as! NSDictionary
                if let ok = res["result"] as? Bool {
                    if ok{
                        if res["message"] != nil && showSuccess{
                            self.displaySuccess(res["message"] as? String ?? "")
                        }
                        completionHandler( true,res)
                    }else{
                        if res["message"] != nil && showError{
                            self.displayError(res["message"] as! String)
                        }
                        completionHandler( false,res)
                    }
                }
                
            case .failure(let error):
                print(error)
                switch response.response!.statusCode {
                case -1005:
                    self.displayError(error.localizedDescription)
                    break
                default:
                    break
                }
                completionHandler( false,[:])
            }
            hideIndicator()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    class func GET2(_ url: String, parameters: [String: AnyObject],showLoading:Bool,showSuccess:Bool,showError:Bool, completionHandler: @escaping (_ result:Bool,_ responseObject:AnyObject) -> Void) -> Request {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print(url)
        if showLoading {
            showIndicator()
        }
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded",
            //            "Authorization": "Bearer " + FHUserDefaults.getUserToken()
        ]
        print(headers)
        return ATB_Alamofire.shareInstance.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON{ response in
            
            switch response.result {
            case .success(let JSON):
                completionHandler( true,JSON as AnyObject)
            case .failure(let error):
                print(error)
                
                completionHandler( false,[] as AnyObject)
            }
            
            hideIndicator()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
        
    class  func PostStripeResult(_ url: String, parameters: [String: AnyObject],showLoading:Bool,showSuccess:Bool,showError:Bool, completionHandler: @escaping (_ result:Bool,_ responseObject:NSDictionary) -> Void) -> Request {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if showLoading {
            showIndicator()
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + STP_SK
        ]
        
        return ATB_Alamofire.shareInstance.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers:headers).validate().responseJSON{ response in
            hideIndicator()
            
            switch response.result {
            case .success(let JSON):
                let res = JSON as! NSDictionary
                completionHandler( true,res)
            case .failure(let error):
                print(error.localizedDescription)
                completionHandler( false,[:])
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    class func GetStripeResult(_ url: String, parameters: [String: AnyObject],showLoading:Bool,showSuccess:Bool,showError:Bool, completionHandler: @escaping (_ result:Bool,_ responseObject:AnyObject) -> Void) -> Request {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print(url)
        if showLoading {
            showIndicator()
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + STP_SK
        ]
        print(headers)
        return ATB_Alamofire.shareInstance.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers).validate().responseJSON{ response in
            print(response)
            hideIndicator()
            
            switch response.result {
            case .success(let JSON):
                completionHandler( true,JSON as AnyObject)
            case .failure(let error):
                print(error)
                completionHandler( false,[] as AnyObject)
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    class func displaySuccess(_ message:String){
        InfoPopup.presentPopup(infoText: message, header: "Success", backgroundColour: UIColor(red:0.65, green:0.75, blue:0.87, alpha:1.00), view: UIApplication.topViewController()!)
    }
    
    class func displayError(_ message:String){
       InfoPopup.presentPopup(infoText: message, header: "Error", backgroundColour: .red, view: UIApplication.topViewController()!)
    }
    
    class  func showIndicator(_ vc:UIViewController)
    {
        curviewcontroller = vc
        
        let curframe = curviewcontroller?.view.frame
        
        loadingView = UIView(frame: (curviewcontroller?.view.frame)!)
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        loadingAcitivity = NVActivityIndicatorView(frame: CGRect(x: (curframe?.width)!/2 - 18, y: (curframe?.height)!/2 - 18, width: 36, height: 36), type: .ballRotateChase, color: self.UIColorFromHex(0xEC644B), padding: CGFloat(0))
        loadingAcitivity!.startAnimating()
        loadingView.addSubview(loadingAcitivity!)
        
        vc.view.isUserInteractionEnabled = false
        
        if loadingView.superview == nil{
            vc.view.addSubview(loadingView)
        }
    }
    
    
    class  func showIndicator() {
        curviewcontroller = UIApplication.topViewController()
        let curframe = curviewcontroller?.view.frame
        
        loadingView = UIView(frame: (curviewcontroller?.view.frame)!)
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        loadingAcitivity = NVActivityIndicatorView(frame: CGRect(x: (curframe?.width)!/2 - 18, y: (curframe?.height)!/2 - 18, width: 36, height: 36), type: .ballRotateChase, color: self.UIColorFromHex(0xEC644B), padding: CGFloat(0))
        loadingAcitivity!.startAnimating()
        loadingView.addSubview(loadingAcitivity!)
        
        KEYWINDOW?.isUserInteractionEnabled = false
        
        if loadingView.superview == nil{
            UIApplication.topViewController()?.view.addSubview(loadingView)
        }
    }
    
    class func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    class func hideIndicator(){
        if loadingView.superview != nil{
            loadingAcitivity!.stopAnimating()
            KEYWINDOW?.isUserInteractionEnabled = true
            loadingView.removeFromSuperview()
        }
    }
}
