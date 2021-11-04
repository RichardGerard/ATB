//
//  SettingRangeVC.swift
//  ATB
//
//  Created by mobdev on 2019/5/23.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import MapKit

protocol PostRangeSelectDelegate {
    
    func postRangeSelected(location:String, coordniate:CLLocation, range:Int)
}

class SettingRangeVC: UIViewController, MKMapViewDelegate, UITextFieldDelegate
{
    @IBOutlet weak var searchResHeight: NSLayoutConstraint!
    @IBOutlet weak var tbl_searchRes: UITableView!
    @IBOutlet weak var searchResView: UIView!
    
    @IBOutlet weak var txtSearch: UITextField!
    var addressMatchingItems: [MKMapItem] = []
    var selectedAddress:MKMapItem!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var slideHeader: RoundShadowView!
    @IBOutlet weak var progressWidth: NSLayoutConstraint!
    @IBOutlet weak var btnHeader: UIButton!
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var lblProgress: UILabel!
    @IBOutlet weak var rangeHeight: NSLayoutConstraint!
    
    var totalProgressWidth:CGFloat = 0.0
    var curProgress = 20
    var isHeaderReady:Bool = false

    var regionRadius: CLLocationDistance = 1
    
    var postRangeDelegate: PostRangeSelectDelegate!
    var initialLocation:CLLocation!
    var userAddress:String = ""
    
    var isFromRegister:Bool = true
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if(!self.isFromRegister)
        {
            if(g_myInfo.lat != "" && g_myInfo.lng != "")
            {
                initialLocation = CLLocation(latitude: Double(g_myInfo.lat)!, longitude: Double(g_myInfo.lng)!)
                if(g_myInfo.radius == 0)
                {
                    self.curProgress = 101
                }
                else
                {
                    self.curProgress = Int(g_myInfo.radius)
                }
                
                self.userAddress = g_myInfo.address
            }
        }
        
        if(initialLocation == nil)
        {
            if(LocationProvider.lastLocation != nil)
            {
                initialLocation = LocationProvider.lastLocation!
            }
            else
            {
                initialLocation = CLLocation(latitude: 0, longitude: 0)
            }
        }
        
        self.txtSearch.delegate = self
        self.txtSearch.isUserInteractionEnabled = true
        self.txtSearch.addTarget(self, action: #selector(searchFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        self.searchResView.isHidden = true
        self.tbl_searchRes.delegate = self
        self.tbl_searchRes.dataSource = self
        self.txtSearch.text = userAddress
        self.mapView.isUserInteractionEnabled = false
        
        self.totalProgressWidth = self.view.frame.width - 155
        
        progressWidth.constant = totalProgressWidth / 100 * CGFloat(curProgress)
        self.setProgressText()
        
        var maxHeight = self.mapView.frame.width * 0.8
        if(self.mapView.frame.width > self.mapView.frame.height)
        {
            maxHeight = self.mapView.frame.height * 0.8
        }
        self.rangeHeight.constant = maxHeight
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGestureHandler(panGesture:)))
        panGesture.minimumNumberOfTouches = 1
        self.btnHeader.addGestureRecognizer(panGesture)
        
        self.btnHeader.addTarget(self, action: #selector(HeaderButtonDown), for: .touchDown)
        self.btnHeader.addTarget(self, action: #selector(HeaderButtonUp), for: .touchUpInside)
        self.btnHeader.addTarget(self, action: #selector(HeaderButtonUp), for: .touchUpOutside)
    }
    
    @objc func searchFieldDidChange(_ textField: UITextField) {
        if(textField.isEmpty())
        {
            self.searchResView.isHidden = true
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = textField.text!
        let search = MKLocalSearch(request: request)
        self.addressMatchingItems = []
        self.tbl_searchRes.reloadData()
        search.start { response, _ in
            guard let response = response else {
                self.addressMatchingItems = []
                return
            }
            self.addressMatchingItems = response.mapItems
            self.showSearchResult()
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.txtSearch.text = userAddress
        self.searchResView.isHidden = true
        return true
    }
    
    func showSearchResult()
    {
        if(self.addressMatchingItems.count <= 0 || self.txtSearch.text == "")
        {
            self.searchResView.isHidden = true
            return
        }

        self.tbl_searchRes.reloadData()
        self.tbl_searchRes.bounces = false
        let tableViewHeight = self.tbl_searchRes.contentSize.height
        
        self.searchResView.isHidden = false
        
        if(tableViewHeight > 240)
        {
            self.searchResHeight.constant = 240.0
        }
        else
        {
            if(tableViewHeight == 0)
            {
                self.searchResHeight.constant = 0.0
            }
            else
            {
                self.searchResHeight.constant = tableViewHeight
            }
        }
        
        self.searchResView.layer.cornerRadius = 25
        self.tbl_searchRes.layer.cornerRadius = 25
        self.searchResView.layer.borderWidth = 0.25
        self.searchResView.layer.borderColor = UIColor.white.cgColor
        
        //To apply Shadow
        self.searchResView.layer.shadowOffset = CGSize(width: 1, height: 5)
        self.searchResView.layer.shadowColor = UIColor.lightGray.cgColor
        self.searchResView.layer.shadowOpacity = 0.8
        self.searchResView.layer.shadowRadius = 5.0
        
        self.view.layoutIfNeeded()
    }
    
    @objc func panGestureHandler(panGesture recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: view)
        let curX = location.x - 35
        
        if recognizer.state == .began {
            self.slideHeader.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            if(curX >= 0 && curX <= totalProgressWidth)
            {
                self.slideHeader.center.x = location.x
            }
        } else if recognizer.state == .ended || recognizer.state == .failed || recognizer.state == .cancelled {
            self.slideHeader.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            if(curX >= 0 && curX <= totalProgressWidth)
            {
                self.slideHeader.center.x = location.x
            }
        } else {
            self.slideHeader.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            var progress:CGFloat = 0.0
            
            if(curX <= 0)
            {
                self.slideHeader.center.x = 35.0
                progress = 0
            }
            else if(curX >= totalProgressWidth)
            {
                self.slideHeader.center.x = totalProgressWidth + 35.0
                progress = totalProgressWidth
            }
            else
            {
                self.slideHeader.center.x = location.x
                progress = curX
            }
            
            self.progressWidth.constant = progress
            
            curProgress = Int(progress / totalProgressWidth * 100 + 1)
        }
        
        self.setProgressText()
    }
    
    func setProgressText()
    {
        self.regionRadius = CLLocationDistance(CGFloat(curProgress) / 0.9 * CGFloat(1000 * 2))
        
        self.centerMapOnLocation(location: initialLocation)

        if(self.curProgress == 101)
        {
            let progressText = "∞ KM"
            let txtFontAttribute = [ NSAttributedString.Key.font: UIFont(name: "SegoeUI-Light", size: 30.0)! ]
            let progressTextString = NSMutableAttributedString(string: progressText, attributes: txtFontAttribute)
            
            let kmRange = (progressText as NSString).range(of: "KM")
            progressTextString.addAttribute(.font, value: UIFont(name: "SegoeUI-Light", size: 15.0)!, range: kmRange)
            progressTextString.addAttribute(.foregroundColor, value: UIColor.lightGray, range: kmRange)
            
            self.lblProgress.attributedText = progressTextString
        }
        else
        {
            let progressText = String(curProgress) + " KM"
            let txtFontAttribute = [ NSAttributedString.Key.font: UIFont(name: "SegoeUI-Light", size: 30.0)! ]
            let progressTextString = NSMutableAttributedString(string: progressText, attributes: txtFontAttribute)
            
            let kmRange = (progressText as NSString).range(of: "KM")
            progressTextString.addAttribute(.font, value: UIFont(name: "SegoeUI-Light", size: 15.0)!, range: kmRange)
            progressTextString.addAttribute(.foregroundColor, value: UIColor.lightGray, range: kmRange)
            
            self.lblProgress.attributedText = progressTextString
        }
    }
    
    @objc func HeaderButtonDown(_ sender: UIButton) {
        self.slideHeader.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    @objc func HeaderButtonUp(_ sender: UIButton) {
        self.slideHeader.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.view.layoutIfNeeded()
    }
    
    @IBAction func OnBtnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func OnBtnDone(_ sender: UIButton) {
        if(self.initialLocation == CLLocation(latitude: 0, longitude: 0) || self.userAddress == "")
        {
            self.showErrorVC(msg: "Please choose your location.")
            return
        }
        
        if(isFromRegister)
        {
            self.postRangeDelegate.postRangeSelected(location: self.userAddress, coordniate: self.initialLocation, range: self.curProgress)
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            self.savePostRange()
        }
    }
    
    func savePostRange()
    {
        var progressValue = self.curProgress
        if(progressValue == 101)
        {
            progressValue = 0
        }
        
        let params = [
            "token" : g_myToken,
            "address" : self.userAddress,
            "lat" : String(self.initialLocation.coordinate.latitude),
            "lng" : String(self.initialLocation.coordinate.longitude),
            "range" : String(progressValue)
            ]
        
        _ = ATB_Alamofire.POST(SET_POST_RANGE_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            self.view.isUserInteractionEnabled = true
            print(responseObject)
            
            if(result)
            {
                g_myInfo.address = self.userAddress
                g_myInfo.lat = String(self.initialLocation.coordinate.latitude)
                g_myInfo.lng = String(self.initialLocation.coordinate.longitude)
                g_myInfo.radius = Float(progressValue)
                
               
                let alert = UIAlertController(title: "Success", message: "Post range saved successfully!", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    case .cancel:
                        print("cancel")
                    case .destructive:
                        print("destructive")
                    }}))
                self.navigationController?.present(alert, animated: true)
            }
            else
            {
                let msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if(msg == "")
                {
                    self.showErrorVC(msg: "Failed to update post range, please try again")
                }
                else
                {
                    self.showErrorVC(msg: "Server returned the error message: " + msg)
                }
            }
        }
    }
}

extension SettingRangeVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedAddress = self.addressMatchingItems[indexPath.row]
        let selectedLocation = CLLocation(latitude: selectedAddress.placemark.coordinate.latitude, longitude: selectedAddress.placemark.coordinate.longitude)
        self.initialLocation = selectedLocation
        self.userAddress = parseAddress(selectedItem: self.selectedAddress.placemark)
        
        self.txtSearch.resignFirstResponder()
        self.centerMapOnLocation(location: selectedLocation)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addressMatchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let addressCell = tableView.dequeueReusableCell(withIdentifier: "LocationSearchTableViewCell",
                                                             for: indexPath) as! LocationSearchTableViewCell
        let locationData = self.addressMatchingItems[indexPath.row].placemark
        addressCell.lblAddress.text = locationData.name
        addressCell.lblDes.text = parseAddress(selectedItem: locationData)
        addressCell.configureWithData(index: indexPath.row)
        
        return addressCell
    }
    
    func appendAddress(destination:String, subAddress:String)->String
    {
        var strRes = destination
        
        if(strRes == "")
        {
            strRes = subAddress
        }
        else
        {
            if(subAddress == "" || subAddress == " ")
            {
                strRes = destination
            }
            else
            {
                strRes = destination + ", " + subAddress
            }
        }
        
        return strRes
    }
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        var addressString : String = ""
        let pm = selectedItem
        
        if pm.subLocality != nil {
            addressString = self.appendAddress(destination: addressString, subAddress: pm.subLocality!)
        }
        
        if pm.thoroughfare != nil {
            addressString = self.appendAddress(destination: addressString, subAddress: pm.thoroughfare!)
        }
        
        if pm.locality != nil {
            addressString = self.appendAddress(destination: addressString, subAddress: pm.locality!)
        }
        
        if(pm.administrativeArea != nil)
        {
            addressString = self.appendAddress(destination: addressString, subAddress: pm.administrativeArea!)
        }
        
        if pm.country != nil {
            addressString = self.appendAddress(destination: addressString, subAddress: pm.country!)
        }
        
        if pm.postalCode != nil {
            addressString = self.appendAddress(destination: addressString, subAddress: pm.postalCode!)
        }

        return addressString
    }
}
