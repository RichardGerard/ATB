//
//  AddQServiceViewController.swift
//  ATB
//
//  Created by YueXi on 5/23/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

protocol AddQServiceDelegate {
    
    func serviceAdded(_ service: QualifiedServiceModel)
}

class AddQServiceViewController: BaseViewController {
    
    static let kStoryboardID = "AddQServiceViewController"
    class func instance() -> AddQServiceViewController {
        let storyboard = UIStoryboard(name: "OutdatedProfile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: AddQServiceViewController.kStoryboardID) as? AddQServiceViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    var delegate: AddQServiceDelegate?
    
    // Navigation
    @IBOutlet weak var imvTitleLogo: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView! { didSet {
        scrollView.showsVerticalScrollIndicator = false
        }}
    @IBOutlet weak var txfServiceName: RoundRectTextField!
    
    var isDepositRequired: Bool = false
    @IBOutlet weak var lblDepositRequired: UILabel!
    @IBOutlet weak var swDepositRequired: UISwitch!
    @IBOutlet weak var vDepositAmount: UIView!
    @IBOutlet weak var lblAmountRequired: UILabel!
    @IBOutlet weak var txfAmountRequired: RoundRectTextField!
    
    enum DocumentType: Int {
        case Qualification
        case Insurance
    }
    
    var documentType: DocumentType = .Qualification
    var qualificationFileUrl: String = ""
    
    @IBOutlet weak var txfQualifiedSince: RoundRectTextField!
    @IBOutlet weak var imvQualification: UIImageView!
    @IBOutlet weak var lblQualification: UILabel!
    
    @IBOutlet weak var txfInsuranceCompany: RoundRectTextField!
    
    @IBOutlet weak var txfInsuranceNumber: RoundRectTextField!
    
    var insuranceExpiryFileUrl: String = ""
    @IBOutlet weak var txfInsuranceExpiry: RoundRectTextField!
    @IBOutlet weak var imvInsuraceExpirty: UIImageView!
    @IBOutlet weak var lblInsuranceExpiry: UILabel!
    
    @IBOutlet weak var btnSave: GradientButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        self.view.backgroundColor = .colorGray7
        
        // Navigation
        imvTitleLogo.contentMode = .scaleAspectFit
        if #available(iOS 13.0, *) {
            imvTitleLogo.image = UIImage(systemName: "checkmark.seal.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvTitleLogo.tintColor = .colorPrimary
                
        lblTitle.numberOfLines = 0
        lblTitle.text = "Add a\nQualified Service"
        lblTitle.font = UIFont(name: "SegoeUI-Semibold", size: 26)
        lblTitle.textColor = .colorGray2
        lblTitle.setLineSpacing(lineSpacing: 0, lineHeightMultiple: 0.8)
        
        if #available(iOS 13.0, *) {
            btnClose.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnClose.tintColor = .colorGray3
        
        // input fields
        setupInputField(txfServiceName, placeholder: "Service", imageName: "chevron.down")
        
        lblDepositRequired.text = "Deposit Required NO/YES"
        lblDepositRequired.textColor = .colorGray19
        lblDepositRequired.font = UIFont(name: "SegoeUI-Semibold", size: 18)
        swDepositRequired.setOn(false, animated: false)
        swDepositRequired.onTintColor = .colorPrimary
        
        lblAmountRequired.text = "Amount Required (£)"
        lblAmountRequired.font = UIFont(name: "SegoeUI-Light", size: 18)
        lblAmountRequired.textColor = .colorGray19
        setupInputField(txfAmountRequired, placeholder: "0.00", imageName: "ico_paymentblue", isRight: false)
        txfAmountRequired.keyboardType = .decimalPad
        vDepositAmount.isHidden = !isDepositRequired
        
        setupInputField(txfQualifiedSince, placeholder: "Qualified since", imageName: "chevron.down")
        // date picker
        // create a UIDatePicker
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 216))
        datePicker.datePickerMode = .date
        datePicker.backgroundColor = .colorGray7
        datePicker.setValue(UIColor.colorGray19, forKey: "textColor")
        txfQualifiedSince.inputView = datePicker
        
        // create a tool bar and assign it to inputAccessoryView
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        toolbar.barTintColor = .colorGray7
        toolbar.layer.borderWidth = 1
        toolbar.layer.borderColor = UIColor.colorGray17.cgColor
        toolbar.clipsToBounds = true
        
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Semibold", size: 18)!,
            .foregroundColor: UIColor.colorGray19
        ]
        
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Light", size: 18)!,
            .foregroundColor: UIColor.colorGray19
        ]
        
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nibName, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dateSelected))
        doneButton.setTitleTextAttributes(boldAttrs, for: .normal)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dateCancelled))
        cancelButton.setTitleTextAttributes(normalAttrs, for: .normal)
        toolbar.setItems([cancelButton, flexible, doneButton], animated: false)
        txfQualifiedSince.inputAccessoryView = toolbar
        
        if #available(iOS 13.0, *) {
            imvQualification.image = UIImage(systemName: "paperclip")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvQualification.tintColor = .white
        lblQualification.text = "Add a file"
        lblQualification.textColor = .white
        lblQualification.font = UIFont(name: "SegoeUI-Light", size: 18)
        
        setupInputField(txfInsuranceCompany, placeholder: "Insurance Company", imageName: "chevron.down")
        setupInputField(txfInsuranceNumber, placeholder: "Insurance Number")
        txfInsuranceNumber.autocapitalizationType = .allCharacters
        setupInputField(txfInsuranceExpiry, placeholder: "Insurance Expiry", imageName: "chevron.down")
        
        txfInsuranceExpiry.inputView = datePicker
        txfInsuranceExpiry.inputAccessoryView = toolbar
        if #available(iOS 13.0, *) {
            imvInsuraceExpirty.image = UIImage(systemName: "paperclip")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvInsuraceExpirty.tintColor = .white
        lblInsuranceExpiry.text = "Add a file"
        lblInsuranceExpiry.textColor = .white
        lblInsuranceExpiry.font = UIFont(name: "SegoeUI-Light", size: 18)
        
        // Save Button
        btnSave.setTitle("Save and Add", for: .normal)
        btnSave.setTitleColor(.white, for: .normal)
        btnSave.titleLabel?.font = UIFont(name: "SegoeUI-Bold", size: 18)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        scrollView.addGestureRecognizer(tapGesture)
        scrollView.keyboardDismissMode = .interactive
        
    }
    
    private func setupInputField(_ textField: RoundRectTextField, placeholder: String, imageName: String? = nil, isRight: Bool = true) {
        textField.backgroundColor = .white
        textField.borderColor = .colorGray17
        textField.borderWidth = 1
        textField.iconTintColor = .colorPrimary
        if let imageName = imageName {
            if isRight {
                textField.rightPadding = 12
                textField.rightViewMode = .always
                
                if #available(iOS 13.0, *) {
                    //textField.rightImage = UIImage(systemName: imageName)
                } else {
                    // Fallback on earlier versions
                }
                
            } else {
                textField.leftPadding = 12
                textField.leftViewMode = .always
                textField.leftImage = UIImage(named: imageName)
            }
        }
        
        textField.placeholder = placeholder
        textField.autocapitalizationType = .sentences
        textField.tintColor = .colorGray19
        textField.textColor = .colorGray19
        textField.font = UIFont(name: "SegoeUI-Light", size: 18)
        textField.inputPadding = 16
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        
    }
    
    @objc func dateSelected() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "d MMM yyyy"
        
        if txfQualifiedSince.isFirstResponder {
            guard let datePicker = txfQualifiedSince.inputView as? UIDatePicker else {
                return
            }
            
            txfQualifiedSince.text = dateFormatter.string(from: datePicker.date)
            txfQualifiedSince.resignFirstResponder()
            
            // using a common picker
            // set picker date as current date, whenever it's open, it will show today
            datePicker.date = Date()
            
        } else {
            guard let datePicker = txfInsuranceExpiry.inputView as? UIDatePicker else {
                return
            }
            
            txfInsuranceExpiry.text = dateFormatter.string(from: datePicker.date)
            txfInsuranceExpiry.resignFirstResponder()
            
            // using a common picker
            // set picker date as current date, whenever it's open, it will show today
            datePicker.date = Date()
        }
    }
    
    @objc func dateCancelled() {
        if txfQualifiedSince.isFirstResponder {
            txfQualifiedSince.text = ""
            txfQualifiedSince.resignFirstResponder()
            
        } else {
            txfInsuranceExpiry.text = ""
            txfInsuranceExpiry.resignFirstResponder()
        }
        
    }
    
    // you can update this validation
    func isValid() -> Bool {
        if txfServiceName.isEmpty() {
            showErrorVC(msg: "Please enter your service name.")
            return false
        }
        
        if txfQualifiedSince.isEmpty() {
            showErrorVC(msg: "Please enter your service qualified date.")
            return false
        }
        
        if txfInsuranceCompany.isEmpty() {
            showErrorVC(msg: "Please enter the insurance company name.")
            return false
        }
        
        if txfInsuranceNumber.isEmpty() {
            showErrorVC(msg: "Please enter the insurance number.")
            return false
        }
        
        if txfInsuranceExpiry.isEmpty() {
            showErrorVC(msg: "Please enter the insurance expiry date")
            return false
        }
        
        return true
    }
    
    @IBAction func depositRequired(_ sender: UISwitch) {
        isDepositRequired = sender.isOn
        
        UIView.animate(withDuration: 0.5) {
            self.vDepositAmount.isHidden = !self.isDepositRequired
        }
        
    }
    
    @IBAction func didTapAddQualification(_ sender: Any) {
        documentType = .Qualification
        
        openDocumentPicker()
    }
    
    @IBAction func didTapAddInsurance(_ sender: Any) {
        documentType = .Insurance
        
        openDocumentPicker()
    }
    
    private func openDocumentPicker() {
//        let documentPicker = UIDocumentPickerViewController(documentTypes: ["PDF", "com.adobe.pdf"], in: .import)
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.text", "com.apple.iwork.pages.pages", "public.data"], in: .import)
        documentPicker.delegate = self
        self.present(documentPicker, animated: true)
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        guard isValid() else { return }
        
        let service = QualifiedServiceModel()
        service.Service_Name = txfServiceName.text!
        service.Deposit_Required = isDepositRequired
        service.Qualified_Date = txfQualifiedSince.text!
        service.Insurance_Company = txfInsuranceCompany.text!
        service.Insurance_Number = txfInsuranceNumber.text!
        service.Insurance_Expiry = txfInsuranceExpiry.text!
        
        
        
            
        self.addServiceToBusiness(service: service)
       
        
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func addServiceToBusiness(service: QualifiedServiceModel)
    {
        let serviceName = service.Service_Name
        let isRequireDeposit = service.Deposit_Required
        var depositAmount:Double = service.Deposit_Amount
        
        var is_deposit_required:Int = 0
        if(isRequireDeposit)
        {
            is_deposit_required = 1
        }
        
        let serviceDate = (service.Qualified_Date == "") ? "na" : service.Qualified_Date
        let insuranceCompany = (service.Insurance_Company == "") ? "na" : service.Insurance_Company
        let insuranceNumber = (service.Insurance_Number == "") ? "na" : service.Insurance_Number
        let insuranceDate = (service.Insurance_Expiry == "") ? "na" : service.Insurance_Expiry
        
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
                
                for servicePhotoData in service.Qualified_Files
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
                
                for insurancePhotoData in service.Insurance_Expiry_Files
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
                        self.delegate?.serviceAdded(service)
                        self.dismiss(animated: true)
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
}

// MARK: - UIDocumentPickerDelegeate
extension AddQServiceViewController: UIDocumentPickerDelegate  {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard urls.count > 0 else { return }
        
        let fileURL = urls.first!
        
        if documentType == .Qualification {
            qualificationFileUrl = fileURL.absoluteString
            lblQualification.text = fileURL.lastPathComponent
            
        } else {
            insuranceExpiryFileUrl = fileURL.absoluteString
            lblInsuranceExpiry.text = fileURL.lastPathComponent
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
        
        if documentType == .Qualification {
            qualificationFileUrl = ""
            lblQualification.text = "Add a file"
            
        } else {
            insuranceExpiryFileUrl = ""
            lblInsuranceExpiry.text = "Add a file"
        }
    }
}

// MARK: - UITextFieldDelegate
extension AddQServiceViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txfInsuranceCompany {
            txfInsuranceNumber.becomeFirstResponder()
        }
        
        textField.resignFirstResponder()
        
        return true
    }
}


// View UI model
// you can make your own model while implementing( create a new one or add new variables to)
struct QServiceModel {
    var serviceName: String = ""
    var isDepositRequired: Bool = false
    var quialifiedSince: String = ""
    var insuranceCompany: String = ""
    var insuranceNumber: String = ""
    var insuranceExpiry: String = ""
}
