//
//  InfoPopupViewController.swift
//  The Motor App
//
//  Created by Zachary Powell on 14/05/2018.
//  Copyright © 2018 Motor App. All rights reserved.
//

import UIKit
import PopupDialog

class InfoPopupViewController: UIViewController {
    
    var text:String!
    var header:String!
    var backgroundColour:UIColor!
    var presentedPopup: PopupDialog!
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var outterView: UIView!
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var headerText: UILabel!
    
    @IBAction func close(_ sender: Any) {
        //Mixpanel.mainInstance().track(event: "Close Button Clicked",
        //                              properties: ["click" : self.classForCoder.description() + "." + #function])
        
        presentedPopup.dismiss()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        infoText.text = text
        headerText.text = header
        outterView.backgroundColor = backgroundColour
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
