//
//  ChangePasswordViewController.swift
//  ATB
//
//  Created by mobdev on 13/8/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var txtOld: FocusTextField!
    @IBOutlet weak var txtNew: FocusTextField!
    @IBOutlet weak var txtConfirm: FocusTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

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
    
    @IBAction func OnBtnChangePwd(_ sender: UIButton) {
        if(self.txtOld.isEmpty())
        {
            self.showErrorVC(msg: "Please input current password.")
            return
        }
        
        if(self.txtNew.isEmpty())
        {
            self.showErrorVC(msg: "Please input new password.")
            return
        }
        
        if(self.txtConfirm.isEmpty())
        {
            self.showErrorVC(msg: "Please input confirm password.")
            return
        }
        
        if(self.txtConfirm.text! != self.txtNew.text!)
        {
            self.showErrorVC(msg: "Confirm password doesn't match.")
            return
        }
        
        self.changePassword()
    }
    
    func changePassword()
    {
        let params = [
            "token" : g_myToken,
            "old_pass" : txtOld.text!,
            "new_pass" : txtNew.text!
        ]
        
        _ = ATB_Alamofire.POST(PWDCHANGE_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            self.view.isUserInteractionEnabled = true
            print(responseObject)
            
            if(result)
            {
                self.showSuccessVC(msg: "Password was updated successfully!")
                
            }
            else
            {
                let msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if(msg == "")
                {
                    self.showErrorVC(msg: "Failed to update password, please try again")
                }
                else
                {
                    self.showErrorVC(msg: "Server returned the error message: " + msg)
                }
            }
        }
    }
}
