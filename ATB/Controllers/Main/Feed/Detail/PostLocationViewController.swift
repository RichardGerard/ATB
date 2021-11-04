//
//  PostLocationViewController.swift
//  ATB
//
//  Created by mobdev on 12/10/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PostLocationViewController: UIViewController, MKMapViewDelegate {
    
    static let kStoryboardID = "PostLocationViewController"
    class func instance() -> PostLocationViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: PostLocationViewController.kStoryboardID) as? PostLocationViewController {
            return vc
            
        } else {
            return nil
        }
    }
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblTitle: UILabel!
    
    var regionRadius: CLLocationDistance = 30000
    var postLocation:CLLocation!
    var postAddress:String = ""
    var strTitle:String = ""
    
    var isPresented: Bool = false
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.lblTitle.text = strTitle
        //self.mapView.isUserInteractionEnabled = false
        self.centerMapOnLocation(location: postLocation)
    }
    
    @IBAction func OnBtnBack(_ sender: UIButton) {
        if isPresented {
            self.dismiss(animated: true, completion: nil)
            
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
