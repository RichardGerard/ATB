//
//  SettingUserBioVC.swift
//  ATB
//
//  Created by mobdev on 17/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class CreateBioViewController: BaseViewController {
    
    static let kStoryboardID = "CreateBioViewController"
    class func instance() -> CreateBioViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: CreateBioViewController.kStoryboardID) as? CreateBioViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    // Navigation
    @IBOutlet weak var imvBack: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var outterView: ShadowView!
    @IBOutlet weak var txtUserBio: RoundShadowTextView!
    
    @IBOutlet weak var btnSave: UIButton!
    
    var isForBusiness: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        setupViews()
    }
    
    private func setupViews() {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        
        imvBack.tintColor = .white
        imvBack.contentMode = .scaleAspectFit
        
        if isForBusiness {
            self.lblTitle.text = "Set Business Bio"
            self.txtUserBio.placeHolderText = "Type here..."
            self.btnSave.setTitle("Save Business Bio", for: .normal)
            
            txtUserBio.setText(text: g_myInfo.business_profile.businessBio)
            
        } else {
            self.lblTitle.text = "Set your Bio"
            self.txtUserBio.placeHolderText = "Type here..."
            self.btnSave.setTitle("Save Bio", for: .normal)
            
            txtUserBio.setText(text: g_myInfo.description)
        }
        
        lblTitle.font = UIFont(name: "SegoeUI-Semibold", size:27)
        lblTitle.textColor = .white
        
        btnSave.layer.cornerRadius = 5.0
        
        txtUserBio.layer.borderWidth = 0.0
    }
    
    private func isValid() -> Bool {
        guard !txtUserBio.isEmpty() else {
            self.showErrorVC(msg: isForBusiness ? "Please input business bio." : "Please input user bio.")
            return false
        }
        
        return true
    }
    
    @IBAction func OnBtnSave(_ sender: UIButton) {
        guard isValid() else { return }
        
        let updatedBio = txtUserBio.text.trimmedString
        
        var params = [
            "token" : g_myToken
        ]
        
        if isForBusiness {
            params["id"] = g_myInfo.business_profile.ID
            params["business_bio"] = updatedBio
            
        } else {
            params["bio"] = updatedBio
        }
        
        let apiUrl = isForBusiness ? UPDATE_BUSINESS_BIO : UPDATE_BIO_API
        
        showIndicator()
        _ = ATB_Alamofire.POST(apiUrl, parameters: params as [String : AnyObject], showLoading: false, showSuccess: false, showError: false) { (result, responseObject) in
            self.hideIndicator()
            if result {
                if self.isForBusiness {
                    g_myInfo.business_profile.businessBio = self.txtUserBio.text
                    
                } else  {
                    g_myInfo.description = self.txtUserBio.text
                }
                                
                self.didCompleteBioUpdate(self.isForBusiness ? "Business bio saved successfully!" : "User bio saved successfully!")
                
                
            } else {
                let msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if msg.isEmpty {
                    self.showErrorVC(msg: self.isForBusiness ? "Update business bio error!" : "Update user bio error!")
                    
                } else {
                    self.showErrorVC(msg: "Server returned the error message: " + msg)
                }
            }
        }
    }
    
    private func didCompleteBioUpdate(_ message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .actionSheet)
        
        alert.view.tintColor = UIColor.colorPrimary
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
            
            NotificationCenter.default.post(name: .BioUpdated, object: nil)
            }))
        
        present(alert, animated: true)
    }
    
    @IBAction func OnBtnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
