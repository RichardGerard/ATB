//
//  ATB_LocationProvider.swift
//  ATB
//
//  Created by mobdev on 17/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol ATB_LocationProviderDelegate: class {
    func didUpdate(position: CLLocation)
}

class ATB_LocationProvider: NSObject, CLLocationManagerDelegate {
    
    weak var delegate: ATB_LocationProviderDelegate?
    
    var locationManager: CLLocationManager
    var lastLocation: CLLocation?
    var interval: Double
    //    var address:AddressModel
    
    override init() {
        interval = 300
        locationManager = CLLocationManager()
        //address = AddressModel()
        super.init()
        
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 10
        
        //        self.startUpdates()
    }
    
    func startUpdates() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    func getBatteryLevel() -> Float {
        let device = UIDevice.current
        if device.batteryState != .unknown {
            return device.batteryLevel * 100
        } else {
            return 0
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last
        {
            delegate?.didUpdate(position: location)
            lastLocation = location
//            self.updateUserLocation(location: lastLocation!)
            //self.getAddressFromLatLon(location: lastLocation!)
        }
    }
    
//    func updateUserLocation(location:CLLocation)
//    {
//        if(g_myToken != "")
//        {
//            let params = [
//                "token" : g_myToken,
//                "lat" : location.coordinate.latitude,
//                "lng" : location.coordinate.longitude
//                ] as [String : Any]
//
//            _ = ATB_Alamofire.POST(USER_LOCATION_API, parameters: params as [String : AnyObject],showLoading: false,showSuccess: false,showError: false
//            ) { (result, responseObject)
//                in
//                print(result)
//            }
//        }
//    }
    
    
    //    func getAddressFromLatLon(location:CLLocation) {
    //        let ceo: CLGeocoder = CLGeocoder()
    //
    //        ceo.reverseGeocodeLocation(location, completionHandler:
    //            {(placemarks, error) in
    //                if (error != nil)
    //                {
    //                    print("err")
    //                    return
    //                }
    //                let pm = placemarks! as [CLPlacemark]
    //
    //                if pm.count > 0 {
    //                    self.address = AddressModel()
    //                    let pm = placemarks![0]
    //
    //                    if pm.subThoroughfare != nil{
    //                        self.address.Address2 = pm.subThoroughfare!
    //                    }
    //
    //                    if pm.thoroughfare != nil{
    //                        if(self.address.Address2 == "")
    //                        {
    //                            self.address.Address2 = pm.thoroughfare!
    //                        }
    //                        else
    //                        {
    //                            self.address.Address2 = self.address.Address2 + " " + pm.thoroughfare!
    //                        }
    //                    }
    //
    //                    if pm.locality != nil {
    //                        self.address.Address1 = pm.locality!
    //                    }
    //                    if pm.country != nil {
    //                        self.address.Country = pm.country!
    //                    }
    //
    //                    if pm.administrativeArea != nil{
    //                        self.address.State = pm.administrativeArea!
    //                    }
    //
    //                    if pm.postalCode != nil {
    //                        self.address.Zipcode = pm.postalCode!
    //                    }
    //                }
    //        })
    //    }
    //
    //    func fetchCountry()
    //    {
    //        do {
    //            if let file = Bundle.main.url(forResource: "countries", withExtension: "json") {
    //                let data = try Data(contentsOf: file)
    //                let json = try JSONSerialization.jsonObject(with: data, options: [])
    //                if let object = json as? Dictionary<String, Any> {
    //                    // json is a dictionary
    //                    let countryList = object["countries"] as! NSArray
    //                    countryArray = []
    //                    for item in countryList
    //                    {
    //                        let country = countryModel()
    //                        country.Id = (item as AnyObject).object(forKey: "id") as! String
    //                        country.CountryName = (item as AnyObject).object(forKey: "name") as! String
    //                        countryArray.append(country)
    //                    }
    //                } else if let object = json as? [Any] {
    //
    //                    print(object)
    //                } else {
    //                    print("JSON is invalid")
    //                }
    //            } else {
    //                print("no file")
    //            }
    //        } catch {
    //            print(error.localizedDescription)
    //        }
    //    }
    //
    //    func fetchState()
    //    {
    //        do {
    //            if let file = Bundle.main.url(forResource: "states", withExtension: "json") {
    //                let data = try Data(contentsOf: file)
    //                let json = try JSONSerialization.jsonObject(with: data, options: [])
    //                if let object = json as? Dictionary<String, Any> {
    //                    // json is a dictionary
    //                    let states = object["states"] as! NSArray
    //                    stateArray = []
    //                    for item in states
    //                    {
    //                        let state = stateModel()
    //                        state.Id = (item as AnyObject).object(forKey: "id") as! String
    //                        state.StateName = (item as AnyObject).object(forKey: "name") as! String
    //                        state.CountryId = (item as AnyObject).object(forKey: "country_id") as! String
    //                        stateArray.append(state)
    //                    }
    //                } else if let object = json as? [Any] {
    //                    print(object)
    //                } else {
    //                    print("JSON is invalid")
    //                }
    //            } else {
    //                print("no file")
    //            }
    //        } catch {
    //            print(error.localizedDescription)
    //        }
    //    }
}

