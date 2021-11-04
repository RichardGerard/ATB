//
//  ConfigurationMnuVC.swift
//  ATB
//
//  Created by mobdev on 2019/5/23.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Applozic
import BraintreeDropIn
import Braintree

class ConfigurationMnuVC: UIViewController {
    
    var mnu_array = ["Create/Amend User Bio", "Set Post Range", "User Settings", "Change Password", "Payment Settings", "Transaction History", "Contact Admin", "Log Out"]
    
    @IBOutlet weak var tbl_mnu: UITableView!
    @IBOutlet weak var btnUpgradeView: UIView!
    @IBOutlet weak var btnUpgradeHeight: NSLayoutConstraint!
    @IBOutlet weak var lblBtnUpgrade: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnUpgradeView.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc private func accountUpgraded(notification: NSNotification){
        self.initUpgradeButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tbl_mnu.reloadData()
        self.initUpgradeButton()
    }
    
    func initUpgradeButton()
    {
        if(g_myInfo.accountType == 1)
        {
            lblBtnUpgrade.text = "Edit"
        }
        else
        {
            lblBtnUpgrade.text = "Upgrade to a"
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.view.layoutIfNeeded()
    }
    
    @IBAction func OnBtnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func OnBtnUpgrade(_ sender: UIButton) {
        if(g_myInfo.accountType == 0)
        {
            let upgradeVC = SubscribeBusinessViewController.instance()
            
            let nvc = UINavigationController(rootViewController: upgradeVC)
            nvc.modalPresentationStyle = .overFullScreen
            nvc.modalTransitionStyle = .crossDissolve
            nvc.isNavigationBarHidden = true
            
            let parentVC = self.navigationController?.parent as! MainTabBarVC
            parentVC.present(nvc, animated: true, completion: nil)
        }
        else
        {
            if (g_myInfo.business_profile.paid == "0"){
                let createBuisinessVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateBusinessVC") as! CreateBusinessVC
                createBuisinessVC.isEditSetting = true
                self.navigationController?.pushViewController(createBuisinessVC, animated: true)
            } else {
                let params = [
                    "token" : g_myToken
                ]
                
                print(params)
                
                _ = ATB_Alamofire.POST(LOAD_BUSINESS_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
                    (result, responseObject) in
                    self.view.isUserInteractionEnabled = true
                    print(responseObject)
                    
                    if(result)
                    {
                        let businessInfoDict = responseObject.object(forKey: "msg") as? NSDictionary
                        if(businessInfoDict != nil)
                        {
                            let businessInfoModel = BusinessModel(info: businessInfoDict!)
                            g_myInfo.accountType = 1
                            g_myInfo.business_profile = businessInfoModel
                            
                            if (businessInfoModel.approved == "0") {
                                self.showAlertVC(msg: "Business Account is currently pending approval")
                            } else if (businessInfoModel.approved == "1") {
//                                let businessProfileNav = self.storyboard?.instantiateViewController(withIdentifier: "BusinessProfileNav") as! UINavigationController
//                                let businessProfileVC = businessProfileNav.viewControllers.first! as! BusinessProfileVC
//                                self.navigationController?.pushViewController(businessProfileVC, animated: true)
                            } else {
                                let alertController = UIAlertController(title: "Rejected", message: "This business has been rejected, reason: " + businessInfoModel.approvedReason, preferredStyle: .actionSheet)
                                let OKAction = UIAlertAction(title: "Email admin", style: .default) { (action:UIAlertAction!) in
                                    let email = "support@myatb.co.uk"
                                    if let url = URL(string: "mailto:\(email)") {
                                        if #available(iOS 10.0, *) {
                                            UIApplication.shared.open(url)
                                        } else {
                                            UIApplication.shared.openURL(url)
                                        }
                                    }
                                }
                                alertController.addAction(OKAction)
                                
                                // Create Cancel button
                                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
                                }
                                alertController.addAction(cancelAction)
                                self.present(alertController, animated: true, completion:nil)
                            }
                            
                        }
                    }
                    else
                    {
                        let msg = responseObject.object(forKey: "Loading Business Info Error.") as? String ?? ""
                        
                        if(msg == "")
                        {
                            self.showErrorVC(msg: "Failed adding your card to your account, please try again")
                        }
                        else
                        {
                            self.showErrorVC(msg: "Server returned the error message: " + msg)
                        }
                    }
                }
            }
            
            
        }
    }
}

extension ConfigurationMnuVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mnu_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let confCell = tableView.dequeueReusableCell(withIdentifier: "ConfigurationTableViewCell",
                                                          for: indexPath) as! ConfigurationTableViewCell
        confCell.lblTitle.text = self.mnu_array[indexPath.row]
        
        if(indexPath.row == 7)
        {
            confCell.viewSeparator.isHidden = true
        }
        else
        {
            confCell.viewSeparator.isHidden = false
        }
        return confCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row + 1
        
        switch index {
        
        case 1:
//            let setBioVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingUserBioVC") as! SettingUserBioVC
//            self.navigationController?.pushViewController(setBioVC, animated: true)
            break
        case 2:
            let setRangeVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingRangeVC") as! SettingRangeVC
            setRangeVC.isFromRegister = false
            self.navigationController?.pushViewController(setRangeVC, animated: true)
            break
        case 3:
            let setUserVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingUserVC") as! SettingUserVC
            self.navigationController?.pushViewController(setUserVC, animated: true)
            break
        case 4:
            let changePwdVC = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordViewController") as! ChangePasswordViewController
            self.navigationController?.pushViewController(changePwdVC, animated: true)
            break
        case 5:
//            ATBBrainTreeManager.getBraintreeClientToken(){ (result, msg) in
//                if(result)
//                {
//                    self.showDropIn(clientTokenOrTokenizationKey: msg)
//                }
//                else
//                {
//                    self.showErrorVC(msg: "Server returned the error message: " + msg)
//                }
//            }
            break
        case 6:
            let transactionVC = self.storyboard?.instantiateViewController(withIdentifier: "TransactionHistoryVC") as! TransactionHistoryVC
            self.navigationController?.pushViewController(transactionVC, animated: true)
            break
        case 7:
//            let contactAdminVC = self.storyboard?.instantiateViewController(withIdentifier: "ContactAdminVC") as! ContactAdminVC
//            self.navigationController?.pushViewController(contactAdminVC, animated: true)
            break
        case 8:
            let alert = UIAlertController(title: "Do you want to log out?", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                g_myInfo = User()
                ATB_UserDefault.clear()
                
                let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
                registerUserClientService.logout { (response, error) in
                    if(error == nil && response!.status == "success") {
                        
                    } else {
                        
                    }
                }
                
                let mainNav = self.storyboard?.instantiateViewController(withIdentifier: "LoginNav") as! UINavigationController
                
                UIApplication.shared.keyWindow?.rootViewController = mainNav
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                self.tbl_mnu.reloadData()
            }))
            self.navigationController?.present(alert, animated: true)
            break
        default:
            break
        }
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        request.cardDisabled = true
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil)
            {
                self.showErrorVC(msg: error?.localizedDescription ?? "Failed to process payment.")
                controller.dismiss(animated: true, completion: nil)
            }
            else if (result?.isCancelled == true)
            {
                print("CANCELLED")
                controller.dismiss(animated: true, completion: nil)
            }
            else if let result = result
            {
                let paymentNonce = result.paymentMethod?.nonce
                print(paymentNonce)
                controller.dismiss(animated: true, completion: nil)
                
                let alertView = UIAlertController(title: "Payment Method Confirmation", message: "Would you like to receive the payment through this payment method?", preferredStyle: .actionSheet)
                
                alertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) -> Void in
                    if(result.paymentOptionType == BTUIKPaymentOptionType.payPal)
                    {
                        self.retrievePaypalInfo(paymentNonce: paymentNonce!)
                    }
                    else
                    {
                        self.showErrorVC(msg: "You can not use your card to receive the payments. Please create a Paypal account.")
                    }
                }))
                
                alertView.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (alertAction) -> Void in
                    
                }))
                
                UIApplication.shared.delegate?.window!!.rootViewController?.present(alertView, animated: true, completion: nil)
            }
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func retrievePaypalInfo(paymentNonce: String)
    {
        let params = [
            "token" : g_myToken,
            "customerId" : g_myInfo.bt_customer_id,
            "paymentMethodNonce" : paymentNonce
        ]
        
        _ = ATB_Alamofire.POST(GET_PP_ADDRESS, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            self.view.isUserInteractionEnabled = true
            print(responseObject)
            
            if(result)
            {
                let pp_address = responseObject.object(forKey: "msg") as? String ?? ""
                g_myInfo.bt_paypal_account = pp_address
                
                self.showSuccessVC(msg: "Paypal connected to your account successfully.")
            }
            else
            {
                let msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if(msg == "")
                {
                    self.showErrorVC(msg: "Failed to connect your paypal account, please try again")
                }
                else
                {
                    self.showErrorVC(msg: "Server returned the error message: " + msg)
                }
            }
        }
    }
}
