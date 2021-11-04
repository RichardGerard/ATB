//
//  PhotoSelectPopupViewController.swift
//  ATB
//
//  Created by administrator on 14/04/2020.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import PopupDialog

class PhotoSelectPopupViewController: UIViewController {

    var text:String!
    var header:String!
    var presentedPopup: PopupDialog!
    let photoPicker = UIImagePickerController()
    var lowerView = UIViewController()
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var outterView: UIView!
    @IBOutlet weak var infoText: UILabel!
    @IBOutlet weak var headerText: UILabel!
    
    @IBAction func pickPhoto(_ sender: Any) {
        self.photoPicker.sourceType = .photoLibrary
        self.photoPicker.mediaTypes = ["public.image"]
        self.present(self.photoPicker, animated: true, completion: nil)
    }
    @IBAction func takePhoto(_ sender: Any) {
        self.photoPicker.sourceType = .camera
        self.photoPicker.delegate = lowerView as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.photoPicker.allowsEditing = true
        self.present(self.photoPicker, animated: true, completion: nil)
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
