//
//  ContactAdminVC.swift
//  ATB
//
//  Created by mobdev on 11/12/19.
//  Copyright © 2019 mobdev. All rights reserved.
//
import Foundation
import UIKit
import Kingfisher

class ContactViewController: BaseViewController {
    
    static let kStoryboardID = "ContactViewController"
    class func instance() -> ContactViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: ContactViewController.kStoryboardID) as? ContactViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvBack: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var txtQuestion: UITextField!
    @IBOutlet weak var txtDetails: UITextView!
    @IBOutlet weak var btnSave: UIButton!
    
    var selectedPostID:String = ""
    
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
        
        lblTitle.text = "Contact Admin"
        lblTitle.font = UIFont(name: "SegoeUI-Semibold", size:27)
        lblTitle.textColor = .white
        
        btnSave.layer.cornerRadius = 5.0
        txtDetails.layer.cornerRadius = 5.0
        txtQuestion.layer.cornerRadius = 5.0
        
        txtQuestion.layer.shadowOffset = CGSize(width: 1, height: 1)
        txtQuestion.layer.shadowColor = UIColor.lightGray.cgColor
        txtQuestion.layer.shadowOpacity = 0.6
        txtQuestion.layer.shadowRadius = 2.0
        
        txtQuestion.setLeftPaddingPoints(10.0)
        txtQuestion.setRightPaddingPoints(10.0)
    }
    
    @IBAction func OnBtnReport(_ sender: UIButton) {
        if(self.txtQuestion.isEmpty())
        {
            self.showErrorVC(msg: "Please input your question.")
            return
        }
        
        
        let params = [
            "token" : g_myToken,
            "post_id" : self.selectedPostID,
            "reason" : self.txtQuestion.text!,
            "content" : self.txtDetails.text!
        ]
        
        _ = ATB_Alamofire.POST(REPORT_POST_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            self.view.isUserInteractionEnabled = true
            print(responseObject)
            
            if(result)
            {
               self.txtDetails.text = ""
               self.txtQuestion.text = ""
                
                let alert = UIAlertController(title: "Success", message: "Message Sent to Admin!", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                }))
                alert.view.tintColor = .colorPrimary
                self.navigationController?.present(alert, animated: true)
                
            }
            else
            {
                var msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if(msg == "")
                {
                    msg = "Post report error!"
                }
                
                self.dismiss(animated: true, completion: {
                    if var topController = UIApplication.shared.keyWindow?.rootViewController {
                        while let presentedViewController = topController.presentedViewController {
                            topController = presentedViewController
                        }
                        
                        // topController should now be your topmost view controller
                        let navVC = topController as! UINavigationController
                        let presentedVC = navVC.viewControllers.first
                        presentedVC?.showSuccessVC(msg: msg)
                    }
                })
            }
        }
    }
    
    @IBAction func OnBtnClose(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
