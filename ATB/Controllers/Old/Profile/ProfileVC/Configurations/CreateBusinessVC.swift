//
//  CreateBusinessVC.swift
//  ATB
//
//  Created by mobdev on 2019/6/1.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import BraintreeDropIn
import Braintree

protocol ServiceCellDelegate {
    func ServiceCellExtended(index:Int, extended:Bool)
    func ServiceRemoveClicked(index:Int)
    func OnServiceViewClicked(index:Int)
    func OnInsuranceViewClicked(index:Int)
}

protocol FileCellDelegate {
    func fileDeleted(index:Int, tableViewType:Int)
}

class CreateBusinessVC: UIViewController, UINavigationControllerDelegate {
    var isEditSetting:Bool = false
    
    @IBOutlet weak var btnBack: MainBackButton!
    @IBOutlet weak var imgViewProfile: RoundImageView!
    @IBOutlet weak var iconAddProfileImage: UIImageView!
    
    @IBOutlet weak var viewAddQualifiedSince: AddServiceFileView!
    @IBOutlet weak var viewQualifiedFiles: UIView!
    @IBOutlet weak var tblQualifiedFiles: UITableView!
    @IBOutlet weak var heightQualifiedFiles: NSLayoutConstraint!
    
    @IBOutlet weak var viewAddInsuranceExpiry: AddServiceFileView!
    @IBOutlet weak var viewInsuranceFiles: UIView!
    @IBOutlet weak var tblInsuranceFiles: UITableView!
    @IBOutlet weak var heightInsuranceFiles: NSLayoutConstraint!
    
    @IBOutlet weak var txtName: FocusTextField!
    @IBOutlet weak var txtWebsite: FocusTextField!
    @IBOutlet weak var txtProfileName: FocusTextField!
    
    @IBOutlet weak var viewServiceListContainer: UIView!
    @IBOutlet weak var tblServices: UITableView!
    @IBOutlet weak var tblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var serviceListContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewAddServiceContainer: AddQualifiedServiceView!
    @IBOutlet weak var addServiceContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewAddServiceContent: UIView!
    @IBOutlet weak var addServiceLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var addServiceBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addServiceBtnIcon: UIImageView!
    @IBOutlet weak var addServiceBtnIconLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblAddService: UILabel!
    
    @IBOutlet weak var switchDeposit: UISwitch!
    @IBOutlet weak var lblDeposit: UILabel!
    @IBOutlet weak var viewDepositPrice: RoundShadowView!
    @IBOutlet weak var viewDepositHeight: NSLayoutConstraint!
    @IBOutlet weak var depositBottomConstraint: NSLayoutConstraint!

    //Qualified Service Add View
    @IBOutlet weak var txtServiceName: UITextField!
    @IBOutlet weak var txtDepositAmount: UITextField!
    @IBOutlet weak var txtQualifiedDate: UITextField!
    @IBOutlet weak var lblQualifiedFile: UILabel!
    @IBOutlet weak var btnQualifiedFile: UIButton!
    
    @IBOutlet weak var txtInsuranceCompany: UITextField!
    @IBOutlet weak var txtInsurnaceNumber: UITextField!
    
    @IBOutlet weak var txtInsuranceDate: UITextField!
    @IBOutlet weak var lblInsuranceFile: UILabel!
    @IBOutlet weak var btnInsuranceFile: UIButton!
    
    @IBOutlet weak var btnSaveService: RoundedShadowButton!
    
    var service_list:[QualifiedServiceModel] = []
    var service_extended:[String] = []
    
    let photoPicker = UIImagePickerController()
    var profilePhotoData:Data! = Data()
    var ServicePhotoDatas:[FileModel] = []
    var InsurancePhotoDatas:[FileModel] = []
    
    var photoFlag:Int = 0
    var datePicker = UIDatePicker()

    var fileListTableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if(!isEditSetting)
        {
            btnBack.isHidden = true
        }
        
        self.txtInsuranceDate.delegate = self
        self.txtQualifiedDate.delegate = self
        self.txtDepositAmount.delegate = self
        
        if(service_list.count == 0)
        {
            tblHeightConstraint.constant = 0
            serviceListContainerHeightConstraint.constant = 0
            
            viewServiceListContainer.isHidden = true
        }
        
        viewAddServiceContainer.isExtended = false
        
        self.photoPicker.delegate = self
        if(isEditSetting)
        {
            self.loadBusinessInfo()
        }
    }
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        if(isEditSetting){
            if (g_myInfo.business_profile.paid == "0") {
                self.showSuccessVC(msg: "You have no yet paid for your business account. Please make any final changes and then click save to set up your business subscription.")
            
            }
        }
    }
    
    func loadBusinessInfo()
    {
        self.txtName.text = g_myInfo.business_profile.businessName
        self.txtProfileName.text = g_myInfo.business_profile.businessProfileName
        self.txtWebsite.text = g_myInfo.business_profile.businessWebsite
        
        if(g_myInfo.business_profile.businessPicUrl != "")
        {
            iconAddProfileImage.isHidden = true
            let url = URL(string: DOMAIN_URL + g_myInfo.business_profile.businessPicUrl)
            self.imgViewProfile.kf.setImage(with: url)
        }
        
        self.service_list = g_myInfo.business_profile.businessServices
        self.displayServiceList()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewAddServiceContainer.cornerRadius = 22.5//txtWebsite.frame.height / 2
        
        if(!viewAddServiceContainer.isExtended)
        {
            addServiceContainerHeightConstraint.constant = 45//txtWebsite.frame.height
            addServiceBtnHeightConstraint.constant = 25//txtWebsite.frame.height - 20
            self.hideDepositView()
            viewAddServiceContent.alpha = 0.0
        }
        viewAddInsuranceExpiry.cornerRadius = txtWebsite.frame.height / 2
        viewAddQualifiedSince.cornerRadius = txtWebsite.frame.height / 2
        self.view.layoutIfNeeded()
    }
    
    func showAddServiceViewAnimation()
    {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.addServiceContainerHeightConstraint.constant = self.txtWebsite.frame.height * 8 + 150 + 85
            self.addServiceBtnIconLeftConstraint.constant = self.viewAddServiceContainer.frame.width - 10 - self.addServiceBtnIcon.frame.width
            self.addServiceLabelLeftConstraint.constant = -self.viewAddServiceContainer.frame.width + 20
            self.addServiceBtnIcon.transform = CGAffineTransform(rotationAngle: .pi/4)
            
            self.view.layoutIfNeeded()
            
        }) { (isCompleted) in
            self.viewAddServiceContainer.isExtended = true
            self.lblAddService.font = UIFont(name: "SegoeUI-Bold", size: 20.0)!
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.viewAddServiceContent.alpha = 1.0
            }) { (isCompleted) in
                
            }
        }
    }
    
    func hideAddServiceViewAnimation(type:Int)
    {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            self.viewAddServiceContent.alpha = 0.0
        }) { (isCompleted) in
            self.viewAddServiceContainer.isExtended = false
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.addServiceContainerHeightConstraint.constant = 45
                self.addServiceBtnIconLeftConstraint.constant = 10
                self.addServiceLabelLeftConstraint.constant = 15
                self.addServiceBtnIcon.transform = CGAffineTransform(rotationAngle: 0)
                self.heightInsuranceFiles.constant = 0
                self.heightQualifiedFiles.constant = 0
                
                self.view.layoutIfNeeded()
            }) { (isCompleted) in
                self.lblAddService.font = UIFont(name: "SegoeUI-Light", size: 20.0)!
                self.hideDepositView()
                
                if(type == 1)
                {
                    self.displayServiceList()
                }
                
                self.initServiceValues()
            }
        }
    }
    
    func hideDepositView()
    {
        self.switchDeposit.isOn = false
        self.lblDeposit.alpha = 0.0
        self.viewDepositPrice.alpha = 0.0
        self.viewDepositHeight.constant = 0.0
        self.depositBottomConstraint.constant = 0.0
    }
    
    func displayServiceList()
    {
        tblServices.reloadData()
        
        if(service_list.count == 0)
        {
            tblHeightConstraint.constant = 0
            serviceListContainerHeightConstraint.constant = 0
            
            viewServiceListContainer.isHidden = true
        }
        else
        {
            let extenedCount = self.service_extended.count
            let unExtendedCount = self.service_list.count - extenedCount
            let tblHeight:CGFloat = CGFloat(extenedCount * 345 + unExtendedCount * 70)
            
            tblHeightConstraint.constant = tblHeight
            serviceListContainerHeightConstraint.constant = tblHeight + 79
            
            viewServiceListContainer.isHidden = false
        }
        
        self.view.layoutIfNeeded()
    }
    
    @IBAction func OnBtnAddService(_ sender: UIButton) {
        if(!self.viewAddServiceContainer.isExtended)
        {
            self.showAddServiceViewAnimation()
        }
        else
        {
            let alert = UIAlertController(title: "Warning", message: "This Service info will not be saved.", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.hideAddServiceViewAnimation(type: 0)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
                
            }))
            self.navigationController?.present(alert, animated: true)
        }
    }
    
    @IBAction func OnDepositSwitchChanged(_ sender: UISwitch) {
        if(sender.isOn)
        {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.addServiceContainerHeightConstraint.constant = self.txtWebsite.frame.height * 9 + 170 + 85
                self.viewDepositHeight.constant = self.txtWebsite.frame.height
                self.depositBottomConstraint.constant = 20.0
                self.view.layoutIfNeeded()
                
            }) { (isCompleted) in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    self.lblDeposit.alpha = 1.0
                    self.viewDepositPrice.alpha = 1.0
                    self.view.layoutIfNeeded()
                    
                }) { (isCompleted) in
                    
                }
            }
        }
        else
        {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                self.lblDeposit.alpha = 0.0
                self.viewDepositPrice.alpha = 0.0
                self.view.layoutIfNeeded()
                
            }) { (isCompleted) in
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                    self.addServiceContainerHeightConstraint.constant = self.txtWebsite.frame.height * 8 + 150 + 85
                    self.viewDepositHeight.constant = 0.0
                    self.depositBottomConstraint.constant = 0.0
                    
                    self.view.layoutIfNeeded()
                }) { (isCompleted) in
                    
                }
            }
        }
    }
    
    @IBAction func OnBtnCreateService(_ sender: UIButton) {
        if(self.checkServiceInputValues())
        {
            let alert = UIAlertController(title: "Confirm", message: "Would you like to add this service to your business?", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.addServiceToBusiness()
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
                
            }))
            self.navigationController?.present(alert, animated: true)
        }
    }
    
    func initServiceValues()
    {
        txtServiceName.text = ""
        txtDepositAmount.text = ""
        txtQualifiedDate.text = ""
        lblQualifiedFile.text = "Add a file"
        txtInsuranceCompany.text = ""
        txtInsurnaceNumber.text = ""
        txtInsuranceDate.text = ""
        lblInsuranceFile.text = "Add a file"
        self.InsurancePhotoDatas = []
        self.ServicePhotoDatas = []
        
        self.tblInsuranceFiles.reloadData()
        self.tblQualifiedFiles.reloadData()
    }
    
    func checkServiceInputValues()->Bool
    {
        if(txtServiceName.isEmpty())
        {
            self.showErrorVC(msg: "Please input service name.")
            return false
        }
        
        if(switchDeposit.isOn)
        {
            if(txtDepositAmount.isEmpty())
            {
                //self.showErrorVC(msg: "Please input deposit amount.")
                //return false
                txtDepositAmount.text = "0.00"
            }
            else
            {
                if(Double(txtDepositAmount.text!)! <= 0.0)
                {
                    //self.showErrorVC(msg: "Please input valid deposit amount.")
                    //return false
                    txtDepositAmount.text = "0.00"
                }
            }
        }
        
        /*if(txtQualifiedDate.isEmpty())
        {
            self.showErrorVC(msg: "Please input qualified since date.")
            return false
        }
        
        if(self.ServicePhotoDatas.count <= 0)
        {
            self.showErrorVC(msg: "Please attach your service qualified document.")
            return false
        }
        
        if(txtInsuranceCompany.isEmpty())
        {
            self.showErrorVC(msg: "Please input insurance company name.")
            return false
        }
        
        if(txtInsurnaceNumber.isEmpty())
        {
            self.showErrorVC(msg: "Please input insurance number.")
            return false
        }
        
        if(txtInsuranceDate.isEmpty())
        {
            self.showErrorVC(msg: "Please input insurance expiry date.")
            return false
        }
        
        if(self.ServicePhotoDatas.count <= 0)
        {
            self.showErrorVC(msg: "Please attach your insurance document.")
            return false
        }
        */
        
        return true
    }

    func addServiceToBusiness()
    {
        let serviceName = txtServiceName.text!
        let isRequireDeposit = self.switchDeposit.isOn
        var depositAmount:Double = 0.0
        
        var is_deposit_required:Int = 0
        if(isRequireDeposit)
        {
            let strDepositAmount = txtDepositAmount.text!
            depositAmount = Double(strDepositAmount)!
            is_deposit_required = 1
        }
        
        let serviceDate = (txtQualifiedDate.text! == "") ? "na" : txtQualifiedDate.text!
        let insuranceCompany = (txtInsuranceCompany.text! == "") ? "na" : txtInsuranceCompany.text!
        let insuranceNumber = (txtInsurnaceNumber.text! == "") ? "na" : txtInsurnaceNumber.text!
        let insuranceDate = (txtInsuranceDate.text! == "") ? "na" : txtInsuranceDate.text!
        
        let params = [
            "token" : g_myToken,
            "service_name" : serviceName,
            "is_deposit_required" : String(is_deposit_required),
            "deposit_amount" : String(depositAmount),
            "qualified_since_date" : serviceDate,
            "insurance_company_name" : insuranceCompany,
            "insurance_number" : insuranceNumber,
            "insurance_expirary_date" : insuranceDate
            ]
        
        self.showIndicator()
        
        ATB_Alamofire.shareInstance.upload(
            multipartFormData: { (multipartFormData) in
                var serviceFileIndex = 0
                
                for servicePhotoData in self.ServicePhotoDatas
                {
                    if(servicePhotoData.fileType.lowercased() == "pdf")
                    {
                        multipartFormData.append(servicePhotoData.fileData, withName: "qualified_since_urls[\(serviceFileIndex)]", fileName: servicePhotoData.fullFileName, mimeType: "application/pdf")
                    }
                    else
                    {
                        multipartFormData.append(servicePhotoData.fileData, withName: "qualified_since_urls[\(serviceFileIndex)]", fileName: servicePhotoData.fullFileName, mimeType: "image/jpeg")
                    }
                    serviceFileIndex = serviceFileIndex + 1
                }
                
                var insuranceFileIndex = 0
                
                for insurancePhotoData in self.InsurancePhotoDatas
                {
                    if(insurancePhotoData.fileType.lowercased() == "pdf")
                    {
                        multipartFormData.append(insurancePhotoData.fileData, withName: "insurance_expirary_urls[\(insuranceFileIndex)]", fileName: insurancePhotoData.fullFileName, mimeType: "application/pdf")
                    }
                    else
                    {
                        multipartFormData.append(insurancePhotoData.fileData, withName: "insurance_expirary_urls[\(insuranceFileIndex)]", fileName: insurancePhotoData.fullFileName, mimeType: "image/jpeg")
                    }
                    insuranceFileIndex = insuranceFileIndex + 1
                }
                
                let contentDict = params

                for (key, value) in contentDict
                {
                    multipartFormData.append((value.data(using: .utf8)!), withName: key)
                }
            },
            to: ADD_SERVICE_API,
            usingThreshold: multipartFormDataEncodingMemoryThreshold,
            method: .post,
            headers: nil,
            interceptor: nil,
            fileManager: FileManager.default
        ).responseJSON { (response) in
            self.hideIndicator()
            switch response.result
            {
            case .success(let JSON):
                let res = JSON as! NSDictionary
                
                print(res)
                if let ok = res["result"] as? Bool
                {
                    if ok
                    {
                        let serviceDict = res["extra"] as! NSDictionary
                        let newServiceModel = QualifiedServiceModel(info: serviceDict)
                        
                        self.service_list.append(newServiceModel)
                        self.hideAddServiceViewAnimation(type: 1)
                    }
                    else
                    {
                        let msg = res["msg"] as? String ?? ""

                        if(msg == "")
                        {
                            self.showErrorVC(msg: "Update Business Account Failed.")
                        }
                        else
                        {
                            self.showErrorVC(msg: "Server returned the error message: " + msg)
                        }
                    }
                }
            case .failure(let error):
                print(error)
                self.showErrorVC(msg: "Update Business Account Failed.")
            }
        }
    }
    
    @IBAction func OnBtnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func OnBtnSave(_ sender: Any) {
        
        if(self.txtName.isEmpty())
        {
            self.showErrorVC(msg: "Please input business name.")
            return
        }
        
        if(self.txtProfileName.isEmpty())
        {
            self.showErrorVC(msg: "Please input business profile name.")
            return
        }

        if(self.txtWebsite.isEmpty())
        {
            self.showErrorVC(msg: "Please input business website url.")
            return
        }
        else
        {
            
            if (self.txtWebsite.text!.hasPrefix("http")) {
                if(self.txtWebsite.text!.isValidUrl == false)
                {
                    self.showErrorVC(msg: "Please input valid website url.")
                    return
                }
            } else {
                let urlWithHTTP = "https://" + self.txtWebsite.text!
                if(urlWithHTTP.isValidUrl == false)
                {
                    self.showErrorVC(msg: "Please input valid website url.")
                    return
                }
            }
        }

        if(self.service_list.count <= 0)
        {
            self.showErrorVC(msg: "Please add your qualified services.")
            return
        }

        if(!self.isEditSetting)
        {
            if(self.profilePhotoData == Data())
            {
                self.showErrorVC(msg: "Please add your business profile image.")
                return
            }
        }
        
        self.upgradeToBusinessAccount()
    }
    
    //Add Qualified Service View Section
    @IBAction func onBtnAddQualifiedFile(_ sender: UIButton) {
        self.showCameraActionChooser(nType: 1)
    }
    
    @IBAction func onBtnInsuranceFile(_ sender: UIButton) {
        self.showCameraActionChooser(nType: 2)
    }
    
    @IBAction func onBtnProfileImg(_ sender: UIButton) {
        self.showCameraActionChooser(nType: 0)
    }
    
    func showCameraActionChooser(nType:Int)
    {
        self.photoFlag = nType
        
        let alertController = UIAlertController(title: "", message: "What would you like to do?", preferredStyle: .actionSheet)
        
        var browserTitle = "Explore Files"
        var cameraTitle = "Take a Picture"

        if(photoFlag == 0)
        {
            browserTitle = "Pick a photo from Photo Library"
            self.photoPicker.allowsEditing = true
        }
        else
        {
            cameraTitle = "Take a photo from Camera"
            self.photoPicker.allowsEditing = false
        }
        
        let cameraActionButton = UIAlertAction(title: cameraTitle, style: .default) { action -> Void in
            self.photoPicker.sourceType = .camera
            self.photoPicker.cameraCaptureMode = .photo
            self.present(self.photoPicker, animated: true, completion: nil)
        }
        alertController.addAction(cameraActionButton)
        
        let browserActionButton = UIAlertAction(title: browserTitle, style: .default) { action -> Void in
            if(nType == 0)
            {
                self.photoPicker.sourceType = .photoLibrary
                self.photoPicker.mediaTypes = ["public.image"]
                self.present(self.photoPicker, animated: true, completion: nil)
            }
            else
            {
                let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF), String(kUTTypePNG), String(kUTTypeJPEG)], in: .import)
                importMenu.delegate = self
                self.present(importMenu, animated: true, completion: nil)
            }
        }
        
        alertController.addAction(browserActionButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        })
        
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    func calcAddServiceViewHeightAndApply()
    {
        heightQualifiedFiles.constant =  CGFloat(self.ServicePhotoDatas.count * 50)
        heightInsuranceFiles.constant =  CGFloat(self.InsurancePhotoDatas.count * 50)
        
        self.addServiceContainerHeightConstraint.constant = self.txtWebsite.frame.height * 8 + 150 + 85 + heightQualifiedFiles.constant + heightInsuranceFiles.constant
        self.view.layoutIfNeeded()
    }
    
    func upgradeToBusinessAccount()
    {
        let params = [
            "token" : g_myToken,
            "business_name" : txtName.text!,
            "business_website" : txtWebsite.text!,
            "business_profile_name" : txtProfileName.text!,
            "id" : g_myInfo.business_profile.ID
        ]
        
        var api_url = CREATE_BUSINESS_API
        
        if(self.isEditSetting)
        {
            api_url = UPDATE_BUSINESS_API
        }
        
        self.showIndicator()
        //Upload Service Files and Create Business Profile
        ATB_Alamofire.shareInstance.upload(
            multipartFormData: { (multipartFormData) in
                if(self.profilePhotoData != Data())
                {
                    multipartFormData.append(self.profilePhotoData, withName: "avatar", fileName: "business_profileimg.jpg", mimeType: "image/jpeg")
                }

                let contentDict = params

                for (key, value) in contentDict
                {
                    multipartFormData.append((value.data(using: .utf8)!), withName: key)
                }
            },
            to: api_url,
            usingThreshold: multipartFormDataEncodingMemoryThreshold,
            method: .post,
            headers: nil,
            interceptor: nil,
            fileManager: FileManager.default
        ).responseJSON { (response) in
            self.hideIndicator()
            switch response.result
            {
            case .success(let JSON):
                let res = JSON as! NSDictionary
                print(res)
                if let ok = res["result"] as? Bool
                {
                    if ok
                    {
                        let businessInfo = res["extra"] as! NSDictionary
                        let businessInfoModel = BusinessModel(info: businessInfo)
                        g_myInfo.accountType = 1
                        g_myInfo.business_profile = businessInfoModel
                        if(self.isEditSetting)
                        {
                            self.showSuccessVC(msg: "Business account was updated successfully.")
                        }
                        else
                        {
//                            ATBBrainTreeManager.getBraintreeClientToken(){ (result, msg) in
//                                if(result)
//                                {
//                                    self.showDropIn(clientTokenOrTokenizationKey: msg)
//                                }
//                                else
//                                {
//                                    self.showErrorVC(msg: "Server returned the error message: " + msg)
//                                }
//                            }
                        }
                    }
                    else
                    {
                        let msg = res["msg"] as? String ?? ""

                        if(msg == "")
                        {
                            if(self.isEditSetting)
                            {
                                self.showErrorVC(msg: "Update business account Failed.")
                            }
                            else
                            {
                                self.showErrorVC(msg: "Create business account Failed.")
                            }
                        }
                        else
                        {
                            self.showErrorVC(msg: "Server returned the error message: " + msg)
                        }
                    }
                }
            case .failure(let error):
                print(error)
                if(self.isEditSetting)
                {
                    self.showErrorVC(msg: "Update business account Failed.")
                }
                else
                {
                    self.showErrorVC(msg: "Create business account Failed.")
                }
            }
        }
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        request.vaultManager = true
//        request.amount = "4.99"
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil)
            {
                self.showErrorVC(msg: error?.localizedDescription ?? "Payment Error!")
                
                controller.dismiss(animated: true, completion: nil)
            }
            else if (result?.isCancelled == true)
            {
                print("Cancelled")
                
                controller.dismiss(animated: true, completion: nil)
            }
            else if let result = result
            {
                let paymentNonce = result.paymentMethod?.nonce
                print(paymentNonce)
                controller.dismiss(animated: true, completion: nil)
                
                let alertView = UIAlertController(title: "Subscription Confirmation", message: "Would you like to subscribe to this app with this payment method?", preferredStyle: .actionSheet)
                
                alertView.addAction(UIAlertAction(title: "NO", style: .cancel, handler: { (alertAction) -> Void in
                    
                }))
                
                alertView.addAction(UIAlertAction(title: "YES", style: .default, handler: { (alertAction) -> Void in
                    switch result.paymentOptionType
                    {
                    case BTUIKPaymentOptionType.payPal :
                        print("payPal integration")
                        self.addSubscription(paymentMethod: "Paypal", paymentNonce: paymentNonce!)
                    case BTUIKPaymentOptionType.masterCard,
                         BTUIKPaymentOptionType.AMEX,
                         BTUIKPaymentOptionType.dinersClub,
                         BTUIKPaymentOptionType.discover,
                         BTUIKPaymentOptionType.JCB,
                         BTUIKPaymentOptionType.maestro,
                         //BTUIKPaymentOptionType.laser,
                    //BTUIKPaymentOptionType.solo,
                    //BTUIKPaymentOptionType.unionPay,
                    //BTUIKPaymentOptionType.venmo,
                    //BTUIKPaymentOptionType.ukMaestro,
                    //BTUIKPaymentOptionType.switch,
                    BTUIKPaymentOptionType.visa :
                        print("card integration")
                        self.addSubscription(paymentMethod: "Card", paymentNonce: paymentNonce!)
                    default:
                        break
                    }
                }))
                
                UIApplication.shared.delegate?.window!!.rootViewController?.present(alertView, animated: true, completion: nil)
            }
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func addSubscription(paymentMethod:String, paymentNonce:String)
    {
        let params = [
            "token" : g_myToken,
            "customerId" : g_myInfo.bt_customer_id,
            "paymentMethodNonce" : paymentNonce,
            "paymentMethod" : paymentMethod
        ]
        
        _ = ATB_Alamofire.POST(ADD_PP_SUB, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            self.view.isUserInteractionEnabled = true
            print(responseObject)
            
            if(result)
            {
                let subscriptionID = responseObject.object(forKey: "msg") as? String ?? ""
                print(subscriptionID)
                
                if(subscriptionID != "")
                {
                    g_myInfo.business_profile.paid = "1"
                    
                    let alert = UIAlertController(title: "Complete", message: "Business account was submitted successfully. A member of the ATB admin team will review your business account shortly.", preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { action in
                        let mainNav = self.storyboard?.instantiateViewController(withIdentifier: "MainNav") as! UINavigationController
                        UIApplication.shared.keyWindow?.rootViewController = mainNav
                    }))
                    self.navigationController?.present(alert, animated: true)
                    
                    NotificationCenter.default.post(name: .onAccountUpgrade, object: g_myInfo)
                }
            }
            else
            {
                let msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if(msg == "")
                {
                    self.showErrorVC(msg: "Server Connection Error!")
                }
                else
                {
                    self.showErrorVC(msg: "Server returned the error message: " + msg)
                }
            }
        }
    }
}

extension CreateBusinessVC:ServiceCellDelegate, FileCellDelegate{
    
    func ServiceCellExtended(index: Int, extended: Bool) {
        if(extended)
        {
            self.service_extended.append(self.service_list[index].Service_Name)
        }
        else
        {
            self.service_extended = self.service_extended.filter{$0 != self.service_list[index].Service_Name}
        }
        
        self.displayServiceList()
    }
    
    func OnServiceViewClicked(index: Int) {
        let serviceFiles = self.service_list[index].Qualified_Files
        self.showPopUpMenu(menuFor: "Service", fileList: serviceFiles)
    }
    
    func OnInsuranceViewClicked(index: Int) {
        let insuranceFiles = self.service_list[index].Insurance_Expiry_Files
        self.showPopUpMenu(menuFor: "Insurance", fileList: insuranceFiles)
    }
    
    func ServiceRemoveClicked(index: Int)
    {
        let alert = UIAlertController(title: "Alert", message: "Do you want to remove this service from the business?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            let params = [
                "token" : g_myToken,
                "id" : self.service_list[index].Service_ID
            ]
            
            _ = ATB_Alamofire.POST(REMOVE_SERVICE_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
                (result, responseObject) in
                self.view.isUserInteractionEnabled = true
                print(responseObject)
                
                if(result)
                {
                    self.showSuccessVC(msg: "Service removed successfully!")
                    
                    if(self.service_extended.contains(self.service_list[index].Service_Name))
                    {
                        self.service_extended = self.service_extended.filter{$0 != self.service_list[index].Service_Name}
                    }
                    
                    self.service_list.remove(at: index)
                    self.displayServiceList()
                }
                else
                {
                    let msg = responseObject.object(forKey: "msg") as? String ?? ""
                    
                    if(msg == "")
                    {
                        self.showErrorVC(msg: "Remove service error!")
                    }
                    else
                    {
                        self.showErrorVC(msg: "Server returned the error message: " + msg)
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            
        }))
        self.navigationController?.present(alert, animated: true)
    }
    
    func fileDeleted(index: Int, tableViewType: Int) {
        let alert = UIAlertController(title: "Alert", message: "Do you want to deselect this file?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            if(tableViewType == 0)
            {
                self.ServicePhotoDatas.remove(at: index)
                self.tblQualifiedFiles.reloadData()
            }
            else if(tableViewType == 1)
            {
                self.InsurancePhotoDatas.remove(at: index)
                self.tblInsuranceFiles.reloadData()
            }
            
            self.calcAddServiceViewHeightAndApply()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            
        }))
        self.navigationController?.present(alert, animated: true)
    }
}

//Camera Features
extension CreateBusinessVC:UIImagePickerControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if(self.photoFlag == 0)
        {
            if let chosenImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            {
                let imgdata = chosenImage.jpegData(compressionQuality: 1.0)
                self.profilePhotoData = imgdata!
                imgViewProfile.image = chosenImage
                iconAddProfileImage.isHidden = true
            }
        }
        else
        {
            if let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            {
                let imgdata = chosenImage.jpegData(compressionQuality: 1.0)
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
                
                let formattedDate = dateFormatter.string(from: date)
                print(formattedDate)
                var fileNameStr = formattedDate.replacingOccurrences(of: ":", with: "")
                fileNameStr = fileNameStr.replacingOccurrences(of: ".", with: "")
                fileNameStr = fileNameStr.replacingOccurrences(of: " ", with: "")

                let newfileModel = FileModel()
                newfileModel.fileName = "img_" + fileNameStr
                newfileModel.fileData = imgdata!
                newfileModel.fileType = "jpg"
                newfileModel.fullFileName = newfileModel.fileName + "." + newfileModel.fileType
                
                if(self.photoFlag == 1)
                {
                    self.ServicePhotoDatas.append(newfileModel)
                    self.tblQualifiedFiles.reloadData()
                }
                else if(self.photoFlag == 2)
                {
                    self.InsurancePhotoDatas.append(newfileModel)
                    self.tblInsuranceFiles.reloadData()
                }
                
                if(self.photoFlag == 1 || self.photoFlag == 2)
                {
                    self.calcAddServiceViewHeightAndApply()
                }
            }
        }
        
        picker.dismiss(animated: true, completion: nil);
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//File pick up Features
extension CreateBusinessVC:UIDocumentPickerDelegate
{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("URL: \(urls[0])")
        let strFileName = urls[0].lastPathComponent
        let strFileExtension = urls[0].pathExtension
        let fileName = strFileName.replacingLastOccurrenceOfString("." + strFileExtension, with: "")
        let newFileModel = FileModel()
        newFileModel.fullFileName = strFileName
        newFileModel.fileType = strFileExtension.lowercased()
        newFileModel.fileName = fileName

        let fileData = try! Data(contentsOf: urls[0].asURL())
        newFileModel.fileData = fileData

        if(self.photoFlag == 1)
        {
            self.ServicePhotoDatas.append(newFileModel)
            self.tblQualifiedFiles.reloadData()
        }
        else if(self.photoFlag == 2)
        {
            self.InsurancePhotoDatas.append(newFileModel)
            self.tblInsuranceFiles.reloadData()
        }
        
        if(self.photoFlag == 1 || self.photoFlag == 2)
        {
            self.calcAddServiceViewHeightAndApply()
        }
        
        controller.dismiss(animated: true, completion: nil)
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//Qualified Service Table
extension CreateBusinessVC:UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.tblServices)
        {
            return self.service_list.count
        }
        else if(tableView == self.tblQualifiedFiles)
        {
            return self.ServicePhotoDatas.count
        }
        else
        {
            return self.InsurancePhotoDatas.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == self.tblServices)
        {
            let serviceCell = tableView.dequeueReusableCell(withIdentifier: "ServiceListTableViewCell",
                                                            for: indexPath) as! ServiceListTableViewCell
            serviceCell.serviceCellDelegate = self
            
            let serviceData = self.service_list[indexPath.row]
            var extended = false
            if(self.service_extended.contains(serviceData.Service_Name))
            {
                extended = true
            }
            
            serviceCell.configureWithData(index: indexPath.row, extended: extended, serviceData: serviceData, isFromOtherProfile: false)
            
            return serviceCell
        }
        else if(tableView == self.tblQualifiedFiles)
        {
            let serviceFileData = self.ServicePhotoDatas[indexPath.row]
            let serviceFileCell = tableView.dequeueReusableCell(withIdentifier: "UploadedFileTableViewCell", for: indexPath) as! UploadedFileTableViewCell
            serviceFileCell.configureWithData(index: indexPath.row, fileData: serviceFileData, tableViewType: 0)
            serviceFileCell.fileCellDelegate = self
            
            return serviceFileCell
        }
        else
        {
            let insuranceFileData = self.InsurancePhotoDatas[indexPath.row]
            let insuranceFileCell = tableView.dequeueReusableCell(withIdentifier: "UploadedFileTableViewCell", for: indexPath) as! UploadedFileTableViewCell
            insuranceFileCell.configureWithData(index: indexPath.row, fileData: insuranceFileData, tableViewType: 1)
            insuranceFileCell.fileCellDelegate = self
            
            return insuranceFileCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == self.tblServices)
        {
            if(self.service_extended.contains(self.service_list[indexPath.row].Service_Name))
            {
                return 345
            }
            
            return 70
        }
        else
        {
            return 50
        }
    }
}

extension CreateBusinessVC:UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == self.txtDepositAmount)
        {
            if string.isEmpty { return true }
            
            let currentText = textField.text ?? ""
            let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
            return replacementText.isValidDouble(maxDecimalPlaces: 2)
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if(textField == self.txtDepositAmount)
        {
            var currentText = textField.text ?? "0.00"
            
            if(textField.text == "")
            {
                currentText = "0.00"
            }
            
            let dblCurrentText = Double(currentText)
            let formatted = String(format: "%.2f", dblCurrentText!)
            textField.text = formatted
        }
        
        return true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField == self.txtQualifiedDate)
        {
            self.pickUpDate(self.txtQualifiedDate)
        }
        else if(textField == self.txtInsuranceDate)
        {
            self.pickUpDate(self.txtInsuranceDate)
        }
        return true
    }
    
    func pickUpDate(_ textField : UITextField){
        // DatePicker
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePicker.Mode.date
        textField.inputView = self.datePicker
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick(sender:)))
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action:
            #selector(cancelClick(sender:)))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
        if(textField == self.txtQualifiedDate)
        {
            doneButton.tag = 100
            cancelButton.tag = 100
        }
        
        if(textField == self.txtInsuranceDate)
        {
            doneButton.tag = 101
            cancelButton.tag = 101
        }
    }
    
    func getReadableDate(strDate:String)->String
    {
        //4th May 2020
        let dateComponents = strDate.components(separatedBy: " ")
        if(dateComponents.count > 0)
        {
            var dayStr = dateComponents[0]
            let monthStr = dateComponents[1]
            let yearStr = dateComponents[2]
            
            let modVal = Int(dayStr)! % 10
            
            var suffixStr:String = "th"
            if(modVal == 1)
            {
                suffixStr = "st"
            }
            else if(modVal == 2)
            {
                suffixStr = "nd"
            }
            else if(modVal == 3)
            {
                suffixStr = "rd"
            }
            
            dayStr = dayStr + suffixStr
            
            return dayStr + " " + monthStr + " " + yearStr
        }
        else
        {
            return strDate
        }
    }
    
    @objc func doneClick(sender:UIBarButtonItem) {
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateStyle = .medium
        dateFormatter1.timeStyle = .none
        dateFormatter1.dateFormat = "d MMMM yyyy"
        let dateStr = dateFormatter1.string(from: datePicker.date)
        let readableDateStr = self.getReadableDate(strDate: dateStr)
        
        if(sender.tag == 100)
        {
            txtQualifiedDate.text = readableDateStr
            txtQualifiedDate.resignFirstResponder()
        }
        else if(sender.tag == 101)
        {
            txtInsuranceDate.text = readableDateStr
            txtInsuranceDate.resignFirstResponder()
        }
    }
    
    @objc func cancelClick(sender:UIBarButtonItem) {
        print(sender.tag)
        if(sender.tag == 100)
        {
            txtQualifiedDate.text = ""
            txtQualifiedDate.resignFirstResponder()
        }
        else if(sender.tag == 101)
        {
            txtInsuranceDate.text = ""
            txtInsuranceDate.resignFirstResponder()
        }
    }
    
    func showPopUpMenu(menuFor:String, fileList: [FileModel])
    {
        let fileListNav = self.storyboard?.instantiateViewController(withIdentifier: "FileListNav") as! UINavigationController
        fileListNav.modalTransitionStyle = .crossDissolve
        fileListNav.modalPresentationStyle = .overCurrentContext
        
        let fileVC = fileListNav.viewControllers.first as! FileListVC
        if(menuFor == "Service")
        {
            fileVC.titleString = "Qualified Since"
        }
        else
        {
            fileVC.titleString = "Insurance Expiry"
        }
        
        fileVC.fileList = fileList
        
        if(self.isEditSetting)
        {
            self.present(fileListNav, animated: true, completion: nil)
        }
        else
        {
            let parentVC = self.navigationController?.parent as? MainTabBarVC
            if(parentVC == nil)
            {
                self.navigationController?.present(fileListNav, animated: true, completion: nil)
            }
            else
            {
                parentVC!.present(fileListNav, animated: true, completion: nil)
            }
        }
    }
}
