//
//  ContactAdminPopupViewController.swift
//  ATB
//
//  Created by administrator on 14/04/2020.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import PopupDialog

class ContactAdminPopupViewController: UIViewController {

    var text:String!
    var header:String!
    var presentedPopup: PopupDialog!
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var outterView: UIView!
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var headerText: UILabel!
    
    @IBAction func contactAdmin(_ sender: Any) {
        let email = "support@myatb.co.uk"
        if let url = URL(string: "mailto:\(email)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func close(_ sender: Any) {
        //Mixpanel.mainInstance().track(event: "Close Button Clicked",
        //                              properties: ["click" : self.classForCoder.description() + "." + #function])
        
        presentedPopup.dismiss()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoText.text = text
        headerText.text = header
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
