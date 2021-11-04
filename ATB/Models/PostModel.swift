//
//  PostModel.swift
//  ATB
//
//  Created by mobdev on 2019/5/21.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import CoreLocation

class PostDetailModel {
    
    var Post_Summerize: PostModel = PostModel()
    var Poster_Info: UserModel = UserModel()
    var Comments: [CommentModel] = []
}

class PostToPublishModel {
    
    var id = ""
    var type = ""
    var media_type = ""
    var profile_type = ""
    var title = ""
    var description = ""
    var brand = ""
    var price = ""
    var category_title = ""
    var post_condition = ""
    var item_title = ""
    var size_title = ""
    var payment_options = ""
    var location_id = ""
    var delivery_option = "" // 1 => FreePostage, >=3 && <5 => Buyer Collections, >=5 => Delivery Cost
    var deliveryCost = ""
    var lat = ""
    var lng = ""
    var post_tags: String = ""
    var photoDatas: [Data] = []
    
    var videoURL: URL? = nil
    var videoData: Data? = nil
    
    // urls from server
    var mediaUrls = [String]()
    
    var depositRequired: String = ""
    var depositAmount: String = ""
    var cancellations: String = ""
    var insuranceID: String = ""
    var qualificationID: String = ""
    
    var variants: [[String: String]] = []
    var productVariants = [ProductVariant]()
    
    var stock_level: String = ""
    
    var isSale: Bool {
        return type == "2"
    }
    
    var isVideo: Bool {
        return media_type == "Video"
    }
    
    init() { }
    
    convenience init(_ post: PostModel) {
        self.init()
        
        id = post.Post_ID
        media_type = post.Post_Media_Type
        title = post.Post_Title
        description = post.Post_Text
        brand = post.Post_Brand
        price = post.Post_Price
        category_title = post.Post_Category
        post_condition = post.Post_Condition
        item_title = post.Post_Item
        size_title = post.Post_Size
        payment_options = post.Post_Payment_Option
        location_id = post.Post_Location
        delivery_option = post.Delivery_Option
        deliveryCost = post.deliveryCost
        lat = "\(post.Post_Position.latitude)"
        lng = "\(post.Post_Position.longitude)"
        post_tags = post.Post_Tags
        mediaUrls = post.Post_Media_Urls
        
        depositRequired = post.Post_DepositRequired
        depositAmount = post.Post_Deposit
        cancellations = post.cancellations
        insuranceID = post.insuranceID
        qualificationID = post.qualificationID
    }
}

class PollModel {
    
    var id: String = ""
    var value: String = ""
    var votes: [String] = [] // user ids array who votes the option
}

class PostModel {
    
    var Post_ID:String = "" // own post id
    
    var pid: String? = nil  // product id
    var sid: String? = nil // service id
    
    // 0: reported, 1: active, 2: blocked, 3: pending approval, 4: rejected, 5: scheduled
    var Post_Status: String = ""
    var Post_User_ID = ""
    var Post_Type:String = ""               // "Advice", "Sales", "Service", "Poll"
    var Post_Media_Type:String = ""         // "Text", "Image", "Video"
    var Post_Media_Urls:[String] = []
    var Post_Title:String = ""
    var Post_Text:String = ""
    var Post_Likes:String = ""
    var Post_Comments:String = ""
    var Post_Price:String = ""
    var Poster_Name:String = ""
    var Poster_Account_Type:String = ""
    var Post_Brand:String = ""
    var Post_Item:String = ""
    var Post_Condition:String = ""
    var Post_Size:String = ""
    var Post_Location:String = ""
    var Post_Category: String = ""
    
    // free - 1, collect - 3, deliver - 5
    // sum of possible delivery options
    var Delivery_Option: String = ""
    
    var isFreeEnabled: Bool = false              // free
    var isCollectEnabled: Bool = false          // buyer collect
    var isDeliverEnabled: Bool = false          // will deliver
    
    var deliveryCost: String = ""
    
    var stock_level: String = ""
    
    // 1 - Cash on collection, 2 - Stripe/PayPal, 3 - both of 1 & 2
    var Post_Payment_Option: String = ""
    // will have one of below string values -  Cash, PayPal, PayPal or Cash
    var Post_Payment_Type:String = ""
    
    var isPayPalEnabled: Bool {
        return Post_Payment_Type != "Cash"
    }
    
    var isCashEnabled: Bool {
        return Post_Payment_Type != "PayPal"
    }
    
    var Post_DepositRequired = ""
    var Post_Deposit:String = ""
    
    var isDepositRequired: Bool {
        return Post_Deposit.doubleValue > 0.0
    }
    
    var Post_Is_Sold: String = ""
    
    var Post_Position:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    var Post_Date:String = ""
    var Post_Human_Date:String = ""
    var Poster_Profile_Img:String = ""
    var Post_Tags: String = ""
    
    var Post_Scheduled: String = ""
    
    var Post_PollOptions: [PollModel] = []
    var Poll_Options = [String]()
    var Poll_Votes = [Int]()
    
    var is_multi: Bool = false
    var multi_pos: String = ""
    var multi_group:String = ""
    var group_posts = [PostModel]()
    
    var isMultiplePost: Bool {
        return is_multi && group_posts.count > 0
    }
    
    var cancellations: String = ""
    var insuranceID: String = ""
    var insurance: ServiceFileModel?
    var qualificationID: String = ""
    var qualification: ServiceFileModel?
    
    var productVariants = [ProductVariant]()
    
    var isSale: Bool {
        return Post_Type == "Sales"
    }
    
    var isSoldOut: Bool {
        return Post_Is_Sold == "1"
    }
    
    var isService: Bool {
        return Post_Type == "Service"
    }
    
    var isAdvice: Bool {
        return Post_Type == "Advice"
    }
    
    var isPoll: Bool {
        return Post_Type == "Poll"
    }
    
    var isVideoPost: Bool {
        return Post_Media_Type == "Video"
    }
    
    var isTextPost: Bool { 
        return Post_Media_Type == "Text"
    }
    
    var isBusinessPost: Bool {
        return Poster_Account_Type == "Business"
    }
    
    var isScheduled: Bool {
        if isBusinessPost {
            if Post_Scheduled.isEmpty {
                return false

            } else {
                return Post_Status == "5"
//                let scheduledDate = Date(timeIntervalSince1970: Post_Scheduled.doubleValue)
//
//                let current = Date()
//
//                if current >= scheduledDate {
//                    return false
//
//                } else {
//                    return true
//                }
            }
            
            
        } else {
            return false
        }
    }
    
    var isActive: Bool {
        return Post_Status == "1"
    }
    
    var isInsured: Bool {
        return (!insuranceID.isEmpty && insurance != nil)
    }
    
    var isQualified: Bool {
        return (!qualificationID.isEmpty && qualification != nil)
    }
        
    init(info: NSDictionary) {
        self.Post_ID = info.object(forKey: "id") as? String ?? ""
        if(self.Post_ID == "")
        {
            let nID = info.object(forKey: "id") as? Int ?? 0
            self.Post_ID = String(nID)
        }
        
        pid = info.object(forKey: "product_id") as? String
        sid = info.object(forKey: "service_id") as? String
        
        Post_Status = info.object(forKey: "is_active") as? String ?? ""
        
        self.Post_User_ID = info.object(forKey: "user_id") as? String ?? ""
        if(self.Post_ID == "")
        {
            let nID = info.object(forKey: "user_id") as? Int ?? 0
            self.Post_User_ID = String(nID)
        }
        
        let multi_pos = info.object(forKey: "multi_pos") as? String ?? ""
        self.multi_pos = multi_pos
        
        let multi_group = info.object(forKey: "multi_group") as? String ?? ""
        self.multi_group = multi_group
        
        let is_multi = info.object(forKey: "is_multi") as? String ?? ""
        if (is_multi == "1") {
            self.is_multi = true
        }
        
        if (self.is_multi && multi_pos == "0") {
            let group_posts = info.object(forKey: "group_posts") as? [NSDictionary] ?? []
            
            for group_post in group_posts
            {
                let newPostModel = PostModel(info: group_post)
                self.group_posts.append(newPostModel)
            }
            
            self.group_posts.sort {
                $0.multi_pos < $1.multi_pos
            }
        }
        
        let strBrand = info.object(forKey: "post_brand") as? String ?? ""
        self.Post_Brand = strBrand
        
        let strItem = info.object(forKey: "post_item") as? String ?? ""
        self.Post_Item = strItem
        
        let strSize = info.object(forKey: "post_size") as? String ?? ""
        self.Post_Size = strSize
        
        let strCondition = info.object(forKey: "post_condition") as? String ?? ""
        self.Post_Condition = strCondition
        
        let strLocation = info.object(forKey: "post_location") as? String ?? ""
        self.Post_Location = strLocation
        
        Post_Category = (info.object(forKey: "category_title") as? String) ?? ""
        Post_Tags = (info.object(forKey: "post_tags") as? String) ?? ""
        
        var strLat = info.object(forKey: "lat") as? String ?? ""
        if(strLat == "")
        {
            let dLat = info.object(forKey: "lat") as? Double ?? 0.0
            strLat = String(dLat)
        }
        
        var strLng = info.object(forKey: "lng") as? String ?? ""
        if(strLng == "")
        {
            let dLng = info.object(forKey: "lng") as? Double ?? 0.0
            strLng = String(dLng)
        }
        
        self.Post_Position = CLLocationCoordinate2D(latitude: Double(strLat) as! CLLocationDegrees, longitude: Double(strLng) as! CLLocationDegrees)
        
        var is_sold = info.object(forKey: "is_sold") as? String ?? ""
        if(is_sold == "")
        {
            let nis_sold = info.object(forKey: "is_sold") as? Int ?? 0
            is_sold = String(nis_sold)
        }
        Post_Is_Sold = is_sold
        
        let strDeliveryOption = info.object(forKey: "delivery_option") as? String ?? ""
        Delivery_Option = strDeliveryOption
        
        if (strDeliveryOption == "1") {
            isFreeEnabled = true
            isCollectEnabled = false
            isDeliverEnabled = false
            
        } else if (strDeliveryOption == "3") {
            isFreeEnabled = false
            isCollectEnabled = true
            isDeliverEnabled = false
            
        } else if (strDeliveryOption == "5") {
            isFreeEnabled = false
            isCollectEnabled = false
            isDeliverEnabled = true
            
        } else if (strDeliveryOption == "4") {
            isFreeEnabled = true
            isCollectEnabled = true
            isDeliverEnabled = false
            
        } else if (strDeliveryOption == "6") {
            isFreeEnabled = true
            isCollectEnabled = false
            isDeliverEnabled = true
            
        } else if (strDeliveryOption == "8") {
            isFreeEnabled = false
            isCollectEnabled = true
            isDeliverEnabled = true
            
        } else if (strDeliveryOption == "9") {
            isFreeEnabled = true
            isCollectEnabled = true
            isDeliverEnabled = true
        }
        
        deliveryCost = info.object(forKey: "delivery_cost") as? String ?? "0"
        
        var payment = info.object(forKey: "payment_options") as? String ?? ""
        if(payment == "")
        {
            let nType = info.object(forKey: "payment_options") as? Int ?? 0
            payment = String(nType)
        }
        
        Post_Payment_Option = payment
        
        if(payment == "1")
        {
            self.Post_Payment_Type = "Cash"
        }
        else if(payment == "2")
        {
            self.Post_Payment_Type = "PayPal"
        }
        else if (payment == "3") {
            self.Post_Payment_Type = "PayPal or Cash"
        }
        
        Post_DepositRequired = info.object(forKey: "is_deposit_required") as? String ?? "0"
        if let deposit = info.object(forKey: "deposit") as? String {
            Post_Deposit = deposit
            
        } else {
            Post_Deposit = info.object(forKey: "deposit_amount") as? String ?? "0"
        }
        
        cancellations = info.object(forKey: "cancellations") as? String ?? "0"
        
        insuranceID = info.object(forKey: "insurance_id") as? String ?? ""
        if let insurances = info.object(forKey: "insurance") as? [NSDictionary],
           let insuraceDict = insurances.first {
            
            let insurance = ServiceFileModel()
            insurance.id = insuraceDict.object(forKey: "id") as? String ?? ""
            insurance.type = insuraceDict.object(forKey: "type") as? String ?? ""
            insurance.name = insuraceDict.object(forKey: "company") as? String ?? ""
            insurance.reference = insuraceDict.object(forKey: "reference") as? String ?? ""
            insurance.expiry = insuraceDict.object(forKey: "expiry") as? String ?? ""
            insurance.file = insuraceDict.object(forKey: "file") as? String ?? ""
            
            self.insurance = insurance
        }
        
        qualificationID = info.object(forKey: "qualification_id") as? String ?? ""
        if let qualifications = info.object(forKey: "qualification") as? [NSDictionary],
           let qualificationDict = qualifications.first {
            
            let qualification = ServiceFileModel()
            qualification.id = qualificationDict.object(forKey: "id") as? String ?? ""
            qualification.type = qualificationDict.object(forKey: "type") as? String ?? ""
            qualification.name = qualificationDict.object(forKey: "company") as? String ?? ""
            qualification.reference = qualificationDict.object(forKey: "reference") as? String ?? ""
            qualification.expiry = qualificationDict.object(forKey: "expiry") as? String ?? ""
            qualification.file = qualificationDict.object(forKey: "file") as? String ?? ""
            
            self.qualification = qualification
        }
        
        var strType = info.object(forKey: "post_type") as? String ?? ""
        if(strType == "")
        {
            let nType = info.object(forKey: "post_type") as? Int ?? 0
            strType = String(nType)
        }
        
        Post_Type = ""
        switch strType {
        case "1":
            Post_Type = "Advice"
            break
            
        case "2":
            Post_Type = "Sales"
            break
            
        case "3":
            Post_Type = "Service"
            break
            
        case "4":
            Post_Type = "Poll"
            if let options = info.object(forKey: "poll_options") as? [NSDictionary] {
                for option in options {
                    let poll = PollModel()
                    poll.id = option.object(forKey: "id") as? String ?? ""
                    poll.value = option.object(forKey: "poll_value") as? String ?? ""
                    if let votes = option.object(forKey: "votes") as? [NSDictionary] {
                        for vote in votes {
                            let voter = vote.object(forKey: "user_id") as? String ?? ""
                            poll.votes.append(voter)
                        }
                    }
                    
                    Post_PollOptions.append(poll)
                }
            }
            break
        
        default: break
        }
        
        var strMediaType = info.object(forKey: "media_type") as? String ?? ""
        if(strMediaType == "")
        {
            let nMediaType = info.object(forKey: "media_type") as? Int ?? 0
            strMediaType = String(nMediaType)
        }
        
        switch strMediaType {
        case "0":
            self.Post_Media_Type = "Text"
            break
        case "1":
            self.Post_Media_Type = "Image"
            break
        case "2":
            self.Post_Media_Type = "Video"
            break
        default:
            self.Post_Media_Type = "Text"
            break
        }
        
        if(self.Post_Media_Type != "Text")
        {
            self.Post_Media_Urls = []
            let urlDicts = info.object(forKey: "post_imgs") as? [NSDictionary] ?? []
            
            for urlDict in urlDicts
            {
                let strPath = urlDict.object(forKey: "path") as? String ?? ""
                if(strPath != "")
                {
                    self.Post_Media_Urls.append(strPath)
                }
            }
        }
        
        self.Post_Title = info.object(forKey: "title") as? String ?? ""
        self.Post_Text = info.object(forKey: "description") as? String ?? ""
        
        var strPoster_type = info.object(forKey: "poster_profile_type") as? String ?? ""
        if(strPoster_type == "")
        {
            let nPoster_type = info.object(forKey: "poster_profile_type") as? Int ?? 0
            strPoster_type = String(nPoster_type)
        }
        self.Poster_Account_Type = "User"
        if(strPoster_type == "1")
        {
            self.Poster_Account_Type = "Business"
        }
        // profile_name is wrong in api responsne
        let userArray = info.object(forKey: "user") as? [NSDictionary] ?? []
        if userArray.count > 0 {
            if isBusinessPost {
                let businessProfile = userArray[0].object(forKey: "business_info") as? NSDictionary ?? [:]
                Poster_Name = businessProfile.object(forKey: "business_profile_name") as? String ?? ""
                Poster_Profile_Img = businessProfile.object(forKey: "business_logo") as? String ?? ""

            } else {
                Poster_Name = userArray[0].object(forKey: "user_name") as? String ?? ""
                Poster_Profile_Img = userArray[0].object(forKey: "pic_url") as? String ?? ""
            }
            
        } else {
            Poster_Name = info.object(forKey: "profile_name") as? String ?? ""
            Poster_Profile_Img = info.object(forKey: "profile_img") as? String ?? ""
        }
        
        
        var strPost_likes = info.object(forKey: "likes") as? String ?? ""
        if(strPost_likes == "")
        {
            let nPost_likes = info.object(forKey: "likes") as? Int ?? 0
            strPost_likes = String(nPost_likes)
        }
        self.Post_Likes = strPost_likes
        
        var strPost_comments = info.object(forKey: "comments") as? String ?? ""
        if(strPost_comments == "")
        {
            let nPost_comments = info.object(forKey: "comments") as? Int ?? 0
            strPost_comments = String(nPost_comments)
        }
        self.Post_Comments = strPost_comments
        self.Post_Price = info.object(forKey: "price") as? String ?? ""
        
        var strPost_date = info.object(forKey: "created_at") as? String ?? ""
        if(strPost_date == "")
        {
            let dPost_date = info.object(forKey: "created_at") as? Double ?? 0
            strPost_date = String(dPost_date)
        }
        
        var strPost_human_date = info.object(forKey: "read_created") as? String ?? ""
        Post_Human_Date = strPost_human_date
        
        if(strPost_date != "")
        {
            let date = Date(timeIntervalSince1970: Double(strPost_date) as! TimeInterval)
            
            let dateFormatter = DateFormatter()
//            dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
//            dateFormatter.dateStyle = DateFormatter.Style.medium
            dateFormatter.dateFormat = "dd/MM/yy HH:mm"
            dateFormatter.timeZone = .current
            let localDate = dateFormatter.string(from: date)
            
            self.Post_Date = localDate
        }
        
        Post_Scheduled = info.object(forKey: "scheduled") as? String ?? ""
        
        if isSale {
            if let variantDicts = info.object(forKey: "variations") as? [NSDictionary],
               variantDicts.count > 0 {
                for variantDict in variantDicts {
                    let productVariant = ProductVariant(info: variantDict)
                    self.productVariants.append(productVariant)
                }
            }
            
            stock_level = info.object(forKey: "stock_level") as? String ?? ""
        }
    }
    
    init() { }
    
    func update(withPost updated: PostModel) {
        Post_Brand = updated.Post_Brand
        Post_Condition = updated.Post_Condition
        Post_Category = updated.Post_Category
        Post_Tags = updated.Post_Tags
        Post_Location = updated.Post_Location
        Post_Position = updated.Post_Position
        Post_Is_Sold = updated.Post_Is_Sold
        stock_level = updated.stock_level
        Delivery_Option = updated.Delivery_Option
        isFreeEnabled = updated.isFreeEnabled
        isCollectEnabled = updated.isCollectEnabled
        isDeliverEnabled = updated.isDeliverEnabled
        deliveryCost = updated.deliveryCost
        Post_Payment_Option = updated.Post_Payment_Option
        Post_Payment_Type = updated.Post_Payment_Type
        Post_DepositRequired = updated.Post_DepositRequired
        Post_Deposit = updated.Post_Deposit
        cancellations = updated.cancellations
        insuranceID = updated.insuranceID
        insurance = updated.insurance
        qualificationID = updated.qualificationID
        qualification = updated.qualification
        Post_Media_Type = updated.Post_Media_Type
        Post_Media_Urls = updated.Post_Media_Urls
        Post_Title = updated.Post_Title
        Post_Text = updated.Post_Text
        Poster_Account_Type = updated.Poster_Account_Type
        Poster_Name = updated.Poster_Name
        Poster_Profile_Img = updated.Poster_Profile_Img
        Post_Price = updated.Post_Price
        Post_Human_Date = updated.Post_Human_Date
        Post_Date = updated.Post_Date
        productVariants = updated.productVariants
    }
    
    func update(withProduct product: PostModel) {
        Post_Brand = product.Post_Brand
        Post_Condition = product.Post_Condition
        Post_Category = product.Post_Category
        Post_Tags = product.Post_Tags
        Post_Location = product.Post_Location
        Post_Position = product.Post_Position
        Post_Is_Sold = product.Post_Is_Sold
        stock_level = product.stock_level
        Delivery_Option = product.Delivery_Option
        isFreeEnabled = product.isFreeEnabled
        isCollectEnabled = product.isCollectEnabled
        isDeliverEnabled = product.isDeliverEnabled
        deliveryCost = product.deliveryCost
        Post_Payment_Option = product.Post_Payment_Option
        Post_Payment_Type = product.Post_Payment_Type
        Post_Media_Type = product.Post_Media_Type
        Post_Media_Urls = product.Post_Media_Urls
        Post_Title = product.Post_Title
        Post_Text = product.Post_Text
        Post_Price = product.Post_Price
        productVariants = product.productVariants
    }
    
    func update(withService service: PostModel) {
        Post_Media_Type = service.Post_Media_Type
        Post_Title = service.Post_Title
        Post_Text = service.Post_Text
        Post_Price = service.Post_Price
        Post_DepositRequired = service.Post_DepositRequired
        Post_Deposit = service.Post_Deposit
        cancellations = service.cancellations
        insuranceID = service.insuranceID
        insurance = service.insurance
        qualificationID = service.qualificationID
        qualification = service.qualification
        Post_Category = service.Post_Category
        Post_Location = service.Post_Location
        Post_Position = service.Post_Position
        Post_Payment_Option = service.Post_Payment_Option
        Post_Payment_Type = service.Post_Payment_Type
        Post_Media_Urls = service.Post_Media_Urls
        Post_Tags = service.Post_Tags
    }
}


