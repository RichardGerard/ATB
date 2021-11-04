//
//  Utils.swift
//  ATB
//
//  Created by YueXi on 8/20/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit

class Utils {
    
    static let shared = Utils()
    
    func getThumbnailImageFromVideoUrl(_ url: String, completion: @escaping ((UIImage?) -> Void)) {
        guard let videoURL = URL(string: url) else {
            completion(nil)
            return
        }
        
        DispatchQueue.global().async { //1
            let asset = AVAsset(url: videoURL) //2
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
                let thumbImage = UIImage(cgImage: cgThumbImage) //7
                
                DispatchQueue.main.async { //8
                    completion(thumbImage) //9
                }
                
            } catch {
                print(error.localizedDescription) //10
                
                DispatchQueue.main.async {
                    completion(nil) //11
                }
            }
        }
    }
    
    // MARK: - Parse Address
    func address(_ place: MKPlacemark) -> String {
        var address = ""

        if let subLocality = place.subLocality {
            address = appendAddress(address, subAddress: subLocality)
        }

        if let thoroughfare = place.thoroughfare {
            address = appendAddress(address, subAddress: thoroughfare)
        }

        if let locality = place.locality {
            address = appendAddress(address, subAddress: locality)
        }

        if let administrativeArea = place.administrativeArea {
            address = appendAddress(address, subAddress: administrativeArea)
        }

        if let country = place.country {
            address = appendAddress(address, subAddress: country)
        }

        if let postalCode = place.postalCode {
            address = appendAddress(address, subAddress: postalCode)
        }

        return address
    }

    func simpleAddress(_ place: MKPlacemark) -> String {
        var address = ""
        
        if let locality = place.locality {
            address = appendAddress(address, subAddress: locality)
        }
        
        if let country = place.country {
            address = appendAddress(address, subAddress: country)
        }
        
        return address
    }

    func appendAddress(_ destination: String, subAddress: String) -> String {
        var address = destination.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if address == "" {
            address = subAddress.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } else {
            let trimmedSubAddress = subAddress.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedSubAddress != "" {
                address += ", " + trimmedSubAddress
            }
        }
        
        return address
    }
    
    func json(from object:Any) -> String? {
        var options : JSONSerialization.WritingOptions
        if #available(iOS 13.0, *) {
            options = [JSONSerialization.WritingOptions.withoutEscapingSlashes]
        } else {
            options = [JSONSerialization.WritingOptions.fragmentsAllowed]
        }
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: options) else {
            return nil
        }
        var result = String(data: data, encoding: String.Encoding.utf8)!
        result = result.replacingOccurrences(of: "\\\"", with: "\"")
        return result
    }
}

// MARK: Notification
extension Notification.Name {
    
    static let onAccountUpgrade = Notification.Name("on-account-upgrade")
    
    static let Social_Links_Updated = Notification.Name("social_links_updated")
    
    static let BioUpdated = Notification.Name("Bio_Updated")
    
    static let DidUpgradeAccount = Notification.Name("didUpgradeAccount")
    
    static let DidUpdateBusinessProfile = Notification.Name("didUpdateBusinessProfile")
    static let DidUpdateUserSettings = Notification.Name("didUpdateUserSettings")
    
    static let FollowUpdated = Notification.Name("Follow_Updated")
    
    static let PollVoted = Notification.Name("Post_PollVoted")
    
    static let PostLiked = Notification.Name("Post_Liked")
    
    static let PostNewCommentAdded = Notification.Name("Post_New_Comment")
    
    
    
    static let ManualBookingCreated = Notification.Name("ManualBookingCreated")
    
    static let BookingCancelled = Notification.Name("BookingCancelled")
    
    static let SlotEnabled = Notification.Name("SlotEnabled")    
    static let SlotDisabled = Notification.Name("SlotDisabled")
    
    static let BookingUpdatedByBusiness = Notification.Name("BookingUpdatedByBusiness")
    
    static let BookingFinished = Notification.Name("BookingFinished")
    
    static let BookingUpdatedByUser = Notification.Name("BookingUpdatedByUser")
    
    static let LaunchingWithDeepLink = Notification.Name("LaunchingWithDeepLink")
    
    static let DidSetOperatingHour = Notification.Name("DidSetOperatingHour")
    
    static let DidSelectVariant = Notification.Name("DidSelectVariant")
    
    static let DidSavePost          =   Notification.Name("DidSavePost")
    static let DiDDeleteSavedPost   =   Notification.Name("DidDeleteSavedPost")
    static let DidReadNotification  =   Notification.Name("DidReadNotification")
    static let DiDLoadNotification = Notification.Name("DiDLoadNotification")
    
    static let DidDeletePost = Notification.Name("DidDeletePost")
    static let DidUpdatePost = Notification.Name("DidUpdatePost")
    
    static let DidDeleteProduct = Notification.Name("DidDeleteProduct")
    static let DidDeleteService = Notification.Name("DidDeleteService")
    
    static let ProductStockChanged = Notification.Name("ProductStockChanged")
}
