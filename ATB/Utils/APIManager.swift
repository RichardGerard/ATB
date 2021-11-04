//
//  APIManager.swift
//  ATB
//
//  Created by YueXi on 4/13/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIManager {
    
    static let shared = APIManager()
    
    fileprivate init() {}
    //  MARK: - Private Helper for HTTP requst
    ///
    /// - parameter method:             HTTP Method(get, post, put, delete)
    /// - parameter url:                Call URL
    /// - parameter parameters:         Parameters
    /// - parameter completion:         Function to call when the response is obtained (Status: Bool, Message:  String?, Response: [String; Any]?
    fileprivate func request(_ method: HTTPMethod = .get, url: String, parameters: [String: Any]? = nil, completion: @escaping (Bool, String?, Any?) -> Void) {
        AF.request(url, method: method, parameters: parameters)
        .validate()
        .responseJSON { response in
            guard response.error == nil else {
               // got an error in response
                completion(false, (response.error)?.localizedDescription, nil)
                return
            }

            // check response valud is valid
            guard let value = response.value as? [String: Any] else {
               completion(false, "Internal server error is occured.", nil)
               return
            }
           
            // TODO:
            // Do common parse from response, extra will have main data from server
            // This represents common response format of app API server
//            if  let result = value["result"] as? Bool {
//                let message = (value["msg"] as? String) ?? (value["msg"] as? Int != nil ? "\(value["msg"] as! Int)" : "")
//                completion(result, message, value["extra"])
            if  let result = value["result"] as? Bool {
                let message = value["msg"] as? String
                completion(result, message, value["extra"])
                
            } else {
                completion(false, "Internal server error is occured.", nil)
            }
        }
    }
    
    //  MARK: - Private Helper for multipartFormData upload
    ///
    /// - parameter to:                         URL to upload
    /// - parameter multipartFormData:          FormData to upload
    /// - parameter completion:                 Function to call when the response is obtained (Status: Bool, Message:  String?, Response: [String; Any]?
    fileprivate func multipartFormDataUpload(_ multipartFormData: @escaping (MultipartFormData) -> Void, url: String, completion: @escaping (Bool, String?, Any?) -> Void) {
        AF.upload(multipartFormData: multipartFormData, to: url)
        .validate()
        .responseJSON { response in
            guard response.error == nil else {
               // got an error in response
                completion(false, (response.error)?.localizedDescription, nil)
                return
            }

            // check response valud is valid
            guard let value = response.value as? [String: Any] else {
               completion(false, "Internal server error is occured.", nil)
               return
            }
            
            // TODO:
            // Do common parse from response, extra will have main data from server
            // This represents common response format of app API server
            if  let result = value["result"] as? Bool {
                let message = value["msg"] as? String
                completion(result, message, value["extra"])
                
            } else {
                completion(false, "Internal server error is occured.", nil)
            }
        }
    }
    
    func getComments(forPost id: String, token: String, completion: @escaping (Bool, String?, [CommentViewModel]?) -> Void) {
        let parameters = [
            "token" : token,
            "post_id": id
        ]
        
        let url = API_BASE_URL + "post/get_comments"
        
        request(.post, url: url, parameters: parameters) { result, message, value in
            guard result,
                let value = value else {
                completion(result, message, nil)
                return
            }
            
            let comments = try! JSONDecoder.decode(JSON(value).rawData(), to: [CommentViewModel].self)
            completion(result, message, comments)
            
//            let comments = try! JSONDecoder.decode((value as AnyObject).data, to: [CommentViewModel].self)
//            completion(result, message, comments)
        }
    }
    
    func postComment(forPost id: String, token: String, withID: String, withComment: String, attachments: [(Data, String, String, String)]? = nil, completion: @escaping (Bool, String?, CommentViewModel?) -> Void) {
        let url = API_BASE_URL + "post/add_comment_post"
        
        multipartFormDataUpload({ multipartFormData in
            multipartFormData.append(Data(id.utf8), withName: "post_id")
            multipartFormData.append(Data(token.utf8), withName: "token")
            multipartFormData.append(Data(withID.utf8), withName: "user_id")
            multipartFormData.append(Data(withComment.utf8), withName: "comment")
            // attach image(s) here
            if let attachments = attachments {
                for attachment in attachments {
                    multipartFormData.append(attachment.0, withName: attachment.1, fileName: attachment.2, mimeType: attachment.3)
                }
            }
        }, url: url) { (result, message, value) in
            guard result,
                let value = value as? [String: Any] else {
                completion(result, message, nil)
                return
            }
            
            let comment = try! JSONDecoder.decode(value, to: CommentViewModel.self)
            completion(result, message, comment)
        }
    }
    
    func postReply(forComment id: String, token: String, withID: String, withReply: String, attachments: [(Data, String, String, String)]? = nil, completion: @escaping (Bool, String?, ReplyModel?) -> Void) {
        let url = API_BASE_URL + "post/add_comment_reply"
        
        multipartFormDataUpload({ multipartFormData in
            multipartFormData.append(Data(id.utf8), withName: "comment_id")
            multipartFormData.append(Data(token.utf8), withName: "token")
            multipartFormData.append(Data(withID.utf8), withName: "reply_user_id")
            multipartFormData.append(Data(withReply.utf8), withName: "reply")
            // attach image(s) here
            if let attachments = attachments {
                for attachment in attachments {
                    multipartFormData.append(attachment.0, withName: attachment.1, fileName: attachment.2, mimeType: attachment.3)
                }
            }             
        }, url: url) { (result, message, value) in
            guard result,
                let value = value as? [String: Any] else {
                completion(result, message, nil)
                return
            }
            
            let reply = try! JSONDecoder.decode(value, to: ReplyModel.self)
            completion(result, message, reply)
        }
    }
    
    func addLike(forComment id: String, token: String, isComment: Bool, completion: @escaping (Bool, String?) -> Void) {
        
        var url = API_BASE_URL
        
        var params = [
            "token": token
        ]
        
        if isComment {
            url += "post/add_like_comment"
            params["comment_id"] = id
        } else {
            url += "post/add_like_reply"
            params["reply_id"] = id
        }
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            completion(result, message)
        }
    }
    
    func hideComment(forComment id: String, token: String, completion: @escaping (Bool, String?) -> Void) {
        let url = API_BASE_URL + "post/add_hide_comment"
        
        let params = [
            "token": token,
            "comment_id":  id
        ]
        
        request(.post, url: url, parameters: params) { result, message, extra in
            completion(result, message)
        }
    }
    
    func postReport(_ token: String, reportType: REPORT_TYPE, reportId: String, reason: String, content: String, completion: @escaping (Result<Bool, String>) -> Void) {
        let url = API_BASE_URL + "post/add_report"
        
        var params = [
            "token": token,
            "reason": reason,
            "content": content
        ]
        
        switch reportType {
        case .USER:
            params["user_id"] = reportId
            
        case .PRODUCT:
            params["product_id"] = reportId
            
        case .SERVICE:
            params["service_id"] = reportId
            
        case .POST:
            params["post_id"] = reportId
            
        case .COMMENT:
            params["comment_id"] = reportId
            
        default:
            completion(.failure("Report ID is invalid"))
        }
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? Constants.GENERAL_BACKEND_ERROR))
                return
            }
            
            completion(.success(true))
        }
    }
    
    // get products in cart
    // (Status, Message, Result)
    func getCartProducts(_ token: String, completion: @escaping (Bool, String?, [CartItemModel]?) -> Void) {
        let url = API_BASE_URL + "post/get_cart_products"
        
        let params = [
            "token": token
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result,
            let extra = extra,
                let jsonCart = JSON(extra).array else {
                completion(false, message, nil)
                return
            }
            
            var carts = [CartItemModel]()
            for product in jsonCart {
                let cart = CartItemModel()
                cart.id = product["id"].stringValue
                // API returns the own user ID which is wrong, we need the store ID who posted this sales item
//                cart.userID = product["user_id"].stringValue
                cart.pid = product["product_id"].stringValue
                let variantID = product["variant_id"].stringValue
                // API return invalid variant id as '0', in the application empty used
                cart.vid = variantID == "0" ? "" : variantID
                cart.quantity = product["quantity"].intValue
                
                let jsonProduct = product["product"]
                cart.product.Post_ID = jsonProduct["id"].stringValue
                cart.product.Post_User_ID = jsonProduct["user_id"].stringValue
                cart.product.Post_Title = jsonProduct["title"].stringValue
                cart.product.Post_Text = jsonProduct["description"].stringValue
                cart.product.Post_Price = jsonProduct["price"].stringValue
                
                cart.uid = jsonProduct["user_id"].stringValue
                cart.unitPrice = jsonProduct["price"].floatValue
                
                let mediaType = jsonProduct["media_type"].stringValue
                
                switch mediaType {
                case "0":
                    cart.product.Post_Media_Type = "Text"
                    break
                case "1":
                    cart.product.Post_Media_Type = "Image"
                    break
                case "2":
                    cart.product.Post_Media_Type = "Video"
                    break
                default:
                    cart.product.Post_Media_Type = "Text"
                    break
                }
                                
                if let jsonMedias = jsonProduct["post_imgs"].array {
                    for jsonMedia in jsonMedias {
                        cart.product.Post_Media_Urls.append(jsonMedia["path"].stringValue)
                    }
                }
                
                carts.append(cart)
            }
            
            completion(true, message, carts)
        }
    }
    
    func addItemInCart(_ token: String, pid: String, vid: String, completion: @escaping (Bool, String?, (String, Int)?) -> Void) {
        let url = API_BASE_URL + "post/cart_add_item"
        
        let params = [
            "token": token as Any,
            "product_id": pid as Any,
            "variant_id": vid as Any
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result,
            let extra = extra else {
                completion(false, message, nil)
                return
            }
            
            let jsonExtra = JSON(extra)
            let id = jsonExtra["cart_id"].stringValue
            let quantity = jsonExtra["quantity"].intValue
            
            completion(true, message, (id, quantity))
        }
    }
    
    /// delete an item/items in the cart
    func deleteItemInCart(_ token: String, pid: String, vid: String, isAll: Bool, completion: @escaping (Bool, String?) -> Void) {
        let url = API_BASE_URL + (isAll ? "post/cart_delete_items" : "post/cart_delete_item")
        
        var params = [
            "token": token as Any,
            "product_id": pid as Any,
            "variant_id": vid as Any
        ]
        
        // decrease by one
        if !isAll {
            params["quantity"] = "1" as Any
        }
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(false, message)
                return
            }
            
            completion(true, nil)
        }
    }

    /// Add a service file
    func addServiceFile(_ token: String, type: String, name: String, reference: String, expiry: String, serviceFile: (String, String, Any?)?, completion: @escaping (Bool, String?, Int?) -> Void) {
        let url = API_BASE_URL + "profile/add_service_file"
        
        let params = [
            "token": token,
            "type": type,
            "company": name,
            "reference": reference,
            "expiry": expiry
        ]
        
        multipartFormDataUpload({ multipartFormData in
            for param in params {
                multipartFormData.append(param.value.data(using: .utf8)!, withName: param.key)
            }
            
            if let serviceFile = serviceFile,
                let attachment = serviceFile.2 as? Data {
                // data attached
                let fileName = serviceFile.0//(serviceFile.0 as NSString).deletingPathExtension
                multipartFormData.append(attachment, withName: "service_files", fileName: fileName, mimeType: serviceFile.1)
            }
            
            
        }, url: url) { (result, message, extra) in
            completion(result, message, extra as? Int)
        }
    }
    
    // update the service file
    func updateServiceFile(_ token: String, id: String, type: String, name: String, reference: String, expiry: String, serviceFile: (String, String, Any?)?, completion: @escaping (Bool, String?) -> Void) {
        let url = API_BASE_URL + "profile/update_service_file"
        
        let params = [
            "token": token,
            "id": id,
            "type": type,
            "company": name,
            "reference": reference,
            "expiry": expiry
        ]
        
        multipartFormDataUpload({ multipartFormData in
            for param in params {
                multipartFormData.append(param.value.data(using: .utf8)!, withName: param.key)
            }
            
            if let serviceFile = serviceFile,
                let attachment = serviceFile.2 as? Data {
                // data attached
//                let fileName = (serviceFile.0 as NSString).deletingPathExtension
                multipartFormData.append(attachment, withName: "service_files", fileName: serviceFile.0, mimeType: serviceFile.1)
            }
            
        }, url: url) { (result, message, _) in
            completion(result, message)
        }
    }
    
    // delete the service file
    func deleteServieFile(_ token: String, id: String, completion: @escaping (Bool, String?) -> Void) {
        let url = API_BASE_URL + "profile/delete_service_file"
        
        let params = [
            "token": token,
            "id": id
        ]
        
        request(.post, url: url, parameters: params) { (result, message, _) in
            completion(result, message)
        }
    }
    
    // get service files
    func getServiceFiles(_ token: String, completion: @escaping (Bool, String?, [ServiceFileModel]?) -> Void) {
        let url = API_BASE_URL + "profile/get_service_files"
        
        let params = [
            "token": token
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            if result {
                var serviceFiles = [ServiceFileModel]()
                
                if let extra = extra,
                    let jsonServiceFiles = JSON(extra).array {
                    for jsonServiceFile in jsonServiceFiles {
                        let serviceFile = ServiceFileModel()
                        
                        serviceFile.id = jsonServiceFile["id"].stringValue
                        serviceFile.type = jsonServiceFile["type"].stringValue
                        serviceFile.name = jsonServiceFile["company"].stringValue
                        serviceFile.reference = jsonServiceFile["reference"].stringValue
                        serviceFile.expiry = jsonServiceFile["expiry"].stringValue.toDateString(fromFormat: "YYYY/MM/dd", toFormat: "d MMM yyyy")
                        
                        if let file = jsonServiceFile["file"].string,
                            !file.isEmpty {
                            
//                            let url = DOMAIN_URL + file
                            let url = file
                            if url.isValidUrl {
                                serviceFile.fileName = (url as NSString).lastPathComponent
                            }
                        }
                        
                        serviceFiles.append(serviceFile)
                    }
                }
                
                completion(true, message, serviceFiles)
                
            } else {
                completion(false, message, nil)
            }
        }
    }
    
    // update business bio
    func updateBusinessBio(_ token: String, id: String, bio: String, completion: @escaping (Bool, String?) -> Void) {
        let url = API_BASE_URL + "profile/update_business_bio"
        
        let params = [
            "token": token,
            "id": id,
            "business_bio": bio
        ]
        
        request(.post, url: url, parameters: params) { (result, message, _) in
            completion(result, message)
        }
    }
    
    // add social
    // type: 0 - facebook, 1 - instagram, 2 - twitter
    func addSocial(_ token: String, type: String, name: String, completion: @escaping (Bool, String?) -> Void) {
        let url = API_BASE_URL + "profile/add_social"
        
        let params = [
            "token": token,
            "type": type,
            "social_name": name
        ]
        
        request(.post, url: url, parameters: params) { (result, message, _) in
            completion(result, message)
        }
    }
    
    // delete social
    func deleteSocial(_ token: String, type: String, completion: @escaping (Bool, String?) -> Void) {
        let url = API_BASE_URL + "profile/remove_social"
        
        let params = [
            "token": token,
            "type": type
        ]
        
        request(.post, url: url, parameters: params) { (result, message, _) in
            completion(result, message)
        }
    }
    
    func updateWeek(_ token: String, week: [Any], completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + "business/update_week"
        
        let params = [
            "token": token as Any,
            "week": JSON(week) as Any
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure("It's been failed to update your working days."))
                return
            }
            
            completion(.success(true))
        }
    }
    
    func addHoliday(_ token: String, title: String, dayOff: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = API_BASE_URL + "business/add_holiday"
        
        let params = [
            "token": token,
            "name": title,
            "day_off": dayOff
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result,
                  let extra = extra else {
                completion(.failure(message ?? "It's been failed to add the holiday!"))
                return
            }
            
            let jsonHoliday = JSON(extra)
            let id = jsonHoliday["id"].stringValue
            completion(.success(id))
        }
    }
    
    func deleteHoliday(_ token: String, id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + "business/delete_holiday"
        
        let params = [
            "token": token,
            "holiday_id": id
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? "It's been failed to delete the holiday!"))
                return
            }
                        
            completion(.success(true))
        }
    }
    
    /// month - yyyy MM string
    func getBookings(_ token: String, id: String, isBusinenss: Bool, month: String, completion: @escaping (Result<[BookingModel], Error>) -> Void) {
        let url = API_BASE_URL + "booking/get_bookings"
        
        var params = [
            "token": token,
            "user_id": id,
            "is_business": isBusinenss ? "1" : "0"
        ]
        
        if !month.isEmpty {
            params["month"] = month
        }
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result,
               let extra = extra else {
                completion(.failure("Server returned the error message."))
                return
            }
            
            let jsonBookings = JSON(extra).arrayValue
            var bookings = [BookingModel]()
            for jsonBooking in jsonBookings {
                let booking = BookingModel()
                
                booking.id = jsonBooking["id"].stringValue
                booking.sid = jsonBooking["service_id"].stringValue
                booking.state = jsonBooking["state"].stringValue
                booking.date = jsonBooking["booking_datetime"].stringValue
                booking.created = jsonBooking["created_at"].stringValue
                
                booking.total = jsonBooking["total_cost"].floatValue
                
                // transactions
                if let jsonTransactions = jsonBooking["transactions"].array,
                   jsonTransactions.count > 0 {
                    for jsonTransaction in jsonTransactions {
                        let transaction = Transaction()
                        transaction.id = jsonTransaction["id"].stringValue
                        transaction.tid = jsonTransaction["tid"].stringValue
                        transaction.type = jsonTransaction["transaction_type"].stringValue
                        transaction.amount = jsonTransaction["amount"].floatValue
                        transaction.method = jsonTransaction["payment_method"].stringValue
                        transaction.quantity = jsonTransaction["quantity"].intValue
                        
                        booking.transactions.append(transaction)
                    }
                }
                
                // booked user
                if let jsonUsers = jsonBooking["user"].array,
                   jsonUsers.count > 0,
                   let userDict = jsonUsers[0].rawValue as? NSDictionary {
                    booking.user = UserModel(info: userDict)
                    
                } else {
                    let noneATBUser = UserModel()
                    noneATBUser.ID = "none"
                    noneATBUser.name = jsonBooking["full_name"].stringValue
                    noneATBUser.email_address = jsonBooking["email"].stringValue
                    noneATBUser.phone_number = jsonBooking["phone"].stringValue
                    
                    booking.user = noneATBUser
                }
                
                if let jsonBusinesses = jsonBooking["business"].array,
                   jsonBusinesses.count > 0,
                   let businessDict = jsonBusinesses[0].rawValue as? NSDictionary {
                    booking.business = BusinessModel(info: businessDict)
                }
                
                // booked service
                if let jsonServices = jsonBooking["service"].array,
                   let serviceDict = jsonServices.first?.rawValue as? NSDictionary {
                    booking.service = PostModel(info: serviceDict)
                }
                
                booking.isReminderEnabled = jsonBooking["is_reminder_enabled"].stringValue == "1"
                
                bookings.append(booking)
            }
            
            completion(.success(bookings))
        }
    }
    
    func getBooking(_ token: String, bid: String, completion: @escaping (Result<BookingModel, Error>) -> Void) {
        let params = [
            "token": token,
            "booking_id": bid
        ]
        
        let url = API_BASE_URL + "booking/get_booking"
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result,
               let extra = extra else {
                completion(.failure("Server returned the error message."))
                return
            }
            
            let jsonBookings = JSON(extra).arrayValue
            guard let jsonBooking = jsonBookings.first else {
                completion(.failure("We couldn't find the request details!"))
                return
            }
            
            let booking = BookingModel()
            
            booking.id = jsonBooking["id"].stringValue
            booking.sid = jsonBooking["service_id"].stringValue
            booking.state = jsonBooking["state"].stringValue
            booking.date = jsonBooking["booking_datetime"].stringValue
            booking.created = jsonBooking["created_at"].stringValue
            
            booking.total = jsonBooking["total_cost"].floatValue
            
            // transactions
            if let jsonTransactions = jsonBooking["transactions"].array,
               jsonTransactions.count > 0 {
                for jsonTransaction in jsonTransactions {
                    let transaction = Transaction()
                    transaction.id = jsonTransaction["id"].stringValue
                    transaction.tid = jsonTransaction["tid"].stringValue
                    transaction.type = jsonTransaction["transaction_type"].stringValue
                    transaction.amount = jsonTransaction["amount"].floatValue
                    transaction.method = jsonTransaction["payment_method"].stringValue
                    transaction.quantity = jsonTransaction["quantity"].intValue
                    
                    booking.transactions.append(transaction)
                }
            }
            
            // booked user
            if let jsonUsers = jsonBooking["user"].array,
               jsonUsers.count > 0,
               let userDict = jsonUsers[0].rawValue as? NSDictionary {
                booking.user = UserModel(info: userDict)
                
            } else {
                let noneATBUser = UserModel()
                noneATBUser.ID = "none"
                noneATBUser.name = jsonBooking["full_name"].stringValue
                noneATBUser.email_address = jsonBooking["email"].stringValue
                noneATBUser.phone_number = jsonBooking["phone"].stringValue
                
                booking.user = noneATBUser
            }
            
            if let jsonBusinesses = jsonBooking["business"].array,
               jsonBusinesses.count > 0,
               let businessDict = jsonBusinesses[0].rawValue as? NSDictionary {
                booking.business = BusinessModel(info: businessDict)
            }
            
            // booked service
            if let jsonServices = jsonBooking["service"].array,
               let serviceDict = jsonServices.first?.rawValue as? NSDictionary {
                booking.service = PostModel(info: serviceDict)
            }
            
            booking.isReminderEnabled = jsonBooking["is_reminder_enabled"].stringValue == "1"
            
            completion(.success(booking))
        }
    }
    
    func addDisabledSlot(_ token: String, time: String, start: String, end: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = API_BASE_URL + "business/add_disabled_slot"
        
        let params = [
            "token": token,
            "day_timestamp": time,
            "start": start,
            "end": end
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result,
                  let extra = extra else {
                completion(.failure(message ?? "It's been failed to disabled the slot!"))
                return }
            
            let jsonSlot = JSON(extra)
            let disabledSlotID = jsonSlot["id"].stringValue
            
            completion(.success(disabledSlotID))
        }
    }
    
    func deleteDisabledSlot(_ token: String, id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + "business/delete_disabled_slot"
        
        let params = [
            "token": token,
            "slot_id": id
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? "It's been failed to enable the slot!"))
                return
            }
            
            completion(.success(true))
        }
    }
    
    func searchUser(_ token: String, email: String, completion: @escaping (Result<UserModel?, Error>) -> Void) {
        let url = API_BASE_URL + "booking/search_user"
        
        let params = [
            "token": token,
            "email": email
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result,
                  let extra = extra else {
                completion(.failure(message != nil ? "Server returned the error message: \(message!)": "Server returned the error message."))
                return }
            let jsonUsers = JSON(extra)
            guard jsonUsers.count > 0,
                  let userDict = jsonUsers[0].rawValue as? NSDictionary else {
                completion(.success(nil))
                return
            }
            
            completion(.success(UserModel(info: userDict)))
        }
    }
    
    // buid - the businesses user id who is creating booking for a user
    // id - user id
    // sid - service id
    func createBooking(withATBUser withATB: Bool, token: String, buid: String, sid: String, cost: String, time: String, uid: String = "", email: String = "", name: String = "", phone: String = "", completion: @escaping (Result<BookingModel, Error>) -> Void) {
        let url = API_BASE_URL + "booking/create_booking"
        
        var params = [
            "token": token,
            "business_user_id": buid,
            "service_id": sid,
            "booking_datetime": time,
            "is_reminder_enabled": "0",
            "total_cost": cost
        ]
        
        if withATB {
            params["user_id"] = uid
            
        } else {
            params["email"] = email
            params["full_name"] = name
            params["phone"] = phone
        }
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result,
                  let extra = extra else {
                completion(.failure(message ?? "It's been failed to create the booking!"))
                return
            }
            
            let jsonBooking = JSON(extra)
            
            let booking = BookingModel()
            
            booking.id = jsonBooking["id"].stringValue
            booking.sid = jsonBooking["service_id"].stringValue
            booking.state = jsonBooking["state"].stringValue
            booking.date = jsonBooking["booking_datetime"].stringValue
            
            booking.total = jsonBooking["total_cost"].floatValue
            
            // transactions
            if let jsonTransactions = jsonBooking["transactions"].array,
               jsonTransactions.count > 0 {
                for jsonTransaction in jsonTransactions {
                    let transaction = Transaction()
                    transaction.id = jsonTransaction["id"].stringValue
                    transaction.tid = jsonTransaction["tid"].stringValue
                    transaction.type = jsonTransaction["transaction_type"].stringValue
                    transaction.amount = jsonTransaction["amount"].floatValue
                    transaction.method = jsonTransaction["payment_method"].stringValue
                    transaction.quantity = jsonTransaction["quantity"].intValue
                    
                    booking.transactions.append(transaction)
                }
            }
            
            // booked user
            if let jsonUsers = jsonBooking["user"].array,
               jsonUsers.count > 0,
               let userDict = jsonUsers[0].rawValue as? NSDictionary {
                booking.user = UserModel(info: userDict)
                
            } else {
                let noneATBUser = UserModel()
                noneATBUser.ID = "none"
                noneATBUser.name = jsonBooking["full_name"].stringValue
                noneATBUser.email_address = jsonBooking["email"].stringValue
                noneATBUser.phone_number = jsonBooking["phone"].stringValue
                
                booking.user = noneATBUser
            }
            
            // booked service
            if let jsonServices = jsonBooking["service"].array,
               let serviceDict = jsonServices.first?.rawValue as? NSDictionary {
                booking.service = PostModel(info: serviceDict)
            }
            
            booking.isReminderEnabled = jsonBooking["is_reminder_enabled"].stringValue == "1"
            
            completion(.success(booking))
        }
    }
    
    func requestPayment(_ token: String, bid: String, buid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + "business/request_payment"
        
        let params = [
            "token": token,
            "booking_id": bid,
            "booked_user_id": buid
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? "It's been failed to request the payment."))
                return
            }
            
            completion(.success(true))
        }
    }
    
    func requestRating(_ token: String, bid: String, buid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + "business/request_rating"
        
        let params = [
            "token": token,
            "booking_id": bid,
            "booked_user_id": buid
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? "It's been failed to request a rating from user."))
                return
            }
            
            completion(.success(true))
        }
    }
    
    // isRequestBy - "1" : by business, "0" - by user
    func requestCancel(_ token: String, bid: String, isRequestedBy: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + "booking/cancel_booking"
        
        let params = [
            "token": token,
            "booking_id": bid,
            "is_requested_by": isRequestedBy
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? "It's been failed to cancel this booking."))
                return
            }
            
            completion(.success(true))
        }
    }
    
    func requestChange(_ token: String, bid: String, updated: String, isRequestedBy: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = API_BASE_URL + "booking/update_booking"
        
        let params = [
            "token": token,
            "booking_id": bid,
            "update_date": updated,
            "is_requested_by": isRequestedBy
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? "It's been failed to update the booking."))
                return
            }
            
            completion(.success(bid))
        }
    }
    
    func finishBooking(_ token: String, bid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + "booking/complete_booking"
        
        let params = [
            "token": token,
            "booking_id": bid
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? "It's been failed to complete the booking."))
                return
            }
            
            completion(.success(true))
        }
    }
    
    func reportBooking(_ token: String, bid: String, sid: String, buid: String, problem: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + "booking/create_booking_report"
        
        let params = [
            "token": token,
            "problem": problem,
            "booking_id": bid,
            "service_id": sid,
            "business_id": buid
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? "It's been failed to report a problem!"))
                return
            }
            
            completion(.success(true))
        }
    }
    
    func rateBusiness(_ token: String, buid: String, rating: String, comment: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + "profile/addbusinessreviews"
        
        let params = [
            "token" : token,
            "business_id" : buid,
            "rating" : rating,
            "review" : comment
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? "It's been failed to send your rating!"))
                return
            }
            
            completion(.success(true))
        }
    }
    
    func updateTransation(_ token: String, bid: String, tid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + "profile/set_transaction_booking_id"
        
        let params = [
            "token" : token,
            "booking_id": bid,
            "transaction_id": tid
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? "Failed to update transaction for the booking"))
                return
            }
            
            completion(.success(true))
        }
    }
    
    func isEmailValid(_ email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + "auth/is_email_used"
        
        let params = [
            "email": email
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? "The email was already used."))
                return
            }
            
            completion(.success(true))
        }
    }
    
    func getProfilePins(_ token: String, category: String, completion: @escaping (Result<[AuctionModel], Error>) -> Void) {
        let url = API_BASE_URL + "auction/profilepins"
        
        let params = [
            "token": token,
            "category": category
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result,
                  let extra = extra else {
                completion(.failure(message ?? "It's been failed to load boosted businesses."))
                return
            }
            
            let jsonAuctions = JSON(extra).arrayValue
            
            var auctions = [AuctionModel]()
            for jsonAuction in jsonAuctions {
                let auction = AuctionModel()
                
                auction.id = jsonAuction["id"].stringValue
                auction.uid = jsonAuction["user_id"].stringValue
                auction.type = jsonAuction["type"].stringValue
                auction.price = jsonAuction["price"].floatValue
                auction.position = jsonAuction["position"].intValue
                auction.category = jsonAuction["category"].string
                auction.country = jsonAuction["country"].string
                auction.county = jsonAuction["county"].string
                auction.region = jsonAuction["region"].string
                auction.tag = jsonAuction["tags"].string
                auction.totalBids = jsonAuction["total_bids"].intValue
                auction.bidOn = jsonAuction["bidon"].intValue
                
                let jsonUser = jsonAuction["user"]
                if let userDict = jsonUser.rawValue as? NSDictionary {
                    auction.user = UserModel(info: userDict)
                }
                
                auctions.append(auction)
            }
            
            completion(.success(auctions))
        }
    }
    
    func getAuctions(_ token: String, type: String, category: String, country: String = "", county: String = "", region: String = "", tag: String = "", completion: @escaping (Result<[AuctionModel], Error>) -> Void) {
        let url = API_BASE_URL + "auction/auctions"
        
        var params = [
            "token" : token,
            "type": type,
            "category": category
        ]
        
        if type == "0" {
            params["country"] = country
            params["county"] = county
            params["region"] = region
            
        } else {
            params["tags"] = tag
        }
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result,
                  let extra = extra else {
                completion(.failure(message ?? "Something went wrong, please try again later!"))
                return
            }
            
            let jsonAuctions = JSON(extra).arrayValue
            
            var auctions = [AuctionModel]()
            for jsonAuction in jsonAuctions {
                let auction = AuctionModel()
                
                auction.id = jsonAuction["id"].stringValue
                auction.uid = jsonAuction["user_id"].stringValue
                auction.type = jsonAuction["type"].stringValue
                auction.price = jsonAuction["price"].floatValue
                auction.position = jsonAuction["position"].intValue
                auction.category = jsonAuction["category"].string
                auction.country = jsonAuction["country"].string
                auction.county = jsonAuction["county"].string
                auction.region = jsonAuction["region"].string
                auction.tag = jsonAuction["tags"].string
                auction.totalBids = jsonAuction["total_bids"].intValue
                auction.bidOn = jsonAuction["bidon"].intValue
                
                let jsonUser = jsonAuction["user"]
                if let userDict = jsonUser.rawValue as? NSDictionary {
                    auction.user = UserModel(info: userDict)
                }
                
                auctions.append(auction)
            }
            
            completion(.success(auctions))
        }
    }
    
    func placeBid(_ token: String, type: String, category: String, position: Int, price: String, country: String? = nil, county: String? = nil, region: String? = nil, tag: String? = nil, completion: @escaping (Bool, String, String?) -> Void) {
        let url = API_BASE_URL + "auction/placebid"
        
        var params = [
            "token": token,
            "type": type,
            "category": category,
            "position": "\(position)",
            "price": price,
        ]
        
        if type == "0" {
            if let country = country {
                params["country"] = country
            }
            
            if let county = county {
                params["county"] = county
            }
            
            if let region = region {
                params["region"] = region
            }
            
        } else {
            guard let tag = tag else {
                completion(false, "Tag can't be null!", nil)
                return
            }
            
            params["tags"] = tag
        }
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(false, message ?? "It's been failed to place your bid!", nil)
                return }
            
            guard let extra = extra,
                let approvalLink = JSON(extra)["approval_link"].string,
                  !approvalLink.isEmpty else {
                completion(false, "It's been failed to create a payment authorization!", nil)
                return
            }
            
            completion(true, message ?? "Your bid has been placed successfully.", approvalLink)
        }
    }
    
    // completion(result, message, pins, results) // pins will includes only top 3
    func searchBusiness(_ token: String, category: String, tag: String, completion: @escaping (Bool, String, [UserModel]?, [UserModel]?) -> Void) {
        let url = API_BASE_URL + "search/business"
        
        let params = [
            "token": token,
            "category": category,
            "tags": tag
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result,
                  let extra = extra else {
                completion(false, message ?? "Server returned an error message.", nil, nil)
                return
            }
            
            let jsonExtra = JSON(extra)
            let jsonPins = jsonExtra["pins"].arrayValue
            let jsonResults = jsonExtra["search_result"].arrayValue
            
            var pins = [UserModel]()
            var results = [UserModel]()
            
            for jsonPin in jsonPins {
                if let userDict = jsonPin.rawValue as? NSDictionary {
                    pins.append(UserModel(info: userDict))
                }
            }
            
            for jsonResult in jsonResults {
                if let userDict = jsonResult.rawValue as? NSDictionary {
                    results.append(UserModel(info: userDict))
                }
            }
            
            completion(true, "", pins, results)
        }
    }
    
    
    func getUserTags(_ token: String, completion: @escaping (Result<[TagModel], Error>) -> Void) {
        let url = API_BASE_URL + "profile/get_tags"
        
        let params = [
            "token": token
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result,
                  let extra = extra else {
                completion(.failure(message ?? "It's been failed to load your tags."))
                return
            }
            
            let jsonTags = JSON(extra).arrayValue
            
            var tags = [TagModel]()
            for jsonTag in jsonTags {
                let tag = TagModel()
                tag.id = jsonTag["id"].stringValue
                tag.name = jsonTag["name"].stringValue
                
                tags.append(tag)
            }
            
            completion(.success(tags))
        }
    }
    
    func addTag(_ token: String, tag: String, completion: @escaping (Result<TagModel, Error>) -> Void) {
        let url = API_BASE_URL + "profile/add_tag"
        
        let params = [
            "token": token,
            "tag_name": tag
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result,
                  let extra = extra else {
                completion(.failure(message ?? "It's been failed to add the tag."))
                return }
            
            let jsonTag = JSON(extra)
            
            let added = TagModel()
            added.id = jsonTag["id"].stringValue
            added.name = jsonTag["name"].stringValue
            
            completion(.success(added))
        }
    }
    
    func deleteTag(_ token: String, tagId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + "profile/delete_tag"
        
        let params = [
            "token": token,
            "tag_id": tagId
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? "It's been failed to delete the tag."))
                return
            }
            
            completion(.success(true))
        }
    }
    
    func readNotification(_ token: String, notificationId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + "profile/read_notification"
        
        let params = [
            "token": token,
            "notification_id": notificationId
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? ""))
                return
            }
            
            completion(.success(true))
        }
    }
    
    func makeCashPayment(_ token: String, productId: String, variantId: String, deliveryOption: Int, quantity: Int, toUserId: String, isBusiness: String, completion: @escaping (Result<String, Error>)-> Void) {
        let url = API_BASE_URL + "profile/make_cash_payment"
        
        var params = [
            "token" : g_myToken,
            "toUserId" : toUserId,
            "quantity": "\(quantity)",
            "is_business": isBusiness,
            "delivery_option": "\(deliveryOption)"
        ]
        
        if !variantId.isEmpty {
            params["variation_id"] = variantId
            
        } else {
            params["product_id"] = productId
        }
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? "Something went wrong, please try again later!"))
                return
            }
            
            completion(.success(message ?? "We've sent a notification to the seller.\nPlease be touch in with the seller."))
        }
    }
    
    func isProductAvailable(_ token: String, productId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + "post/is_sold"
        
        let params = [
            "token": token,
            "product_id": productId
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result,
                  let extra = extra else {
                completion(.failure(message ?? "Something went wrong, please try again later!"))
                return
            }
            
            let jsonExtra = JSON(extra)
            let isAvailable = !jsonExtra["is_sold"].boolValue
            
            completion(.success(isAvailable))
        }
    }
    
    func deleteStoreItem(_ token: String, isSale: Bool, id: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + (isSale ? "/profile/delete_product" : "/profile/delete_service")
        
        let params = [
            "token": token,
            "id": id
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result else {
                completion(.failure(message ?? "It's been failed to delete the \(isSale ? "product" : "service")."))
                return
            }
            
            completion(.success(true))
        }
    }
    
    func canRateBusiness(_ token: String, toUserId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let url = API_BASE_URL + "profile/can_rate_business"
        
        let params = [
            "token": token,
            "toUserId": toUserId
        ]
        
        request(.post, url: url, parameters: params) { (result, message, extra) in
            guard result,
                  let extra = extra else {
                completion(.failure(message ?? Constants.GENERAL_BACKEND_ERROR))
                return
            }
            
            let jsonExtra = JSON(extra)
            let canRate = jsonExtra["can_rate"].stringValue == "1"
            completion(.success(canRate))
        }
    }
}

