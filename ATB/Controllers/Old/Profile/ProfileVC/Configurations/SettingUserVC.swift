//
//  SettingUserVC.swift
//  ATB
//
//  Created by mobdev on 2019/5/23.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Alamofire

class SettingUserVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imgProfile: RoundImageView!
    @IBOutlet weak var btnMale: RoundedBouncingCheckButton!
    @IBOutlet weak var btnFemale: RoundedBouncingCheckButton!
    
    let photoPicker = UIImagePickerController()
    var photoData:Data! = Data()
    
    @IBOutlet weak var txtUserName: FocusTextField!
    @IBOutlet weak var txtFirstName: FocusTextField!
    @IBOutlet weak var txtLastName: FocusTextField!
    @IBOutlet weak var txtEmail: FocusTextField!
    @IBOutlet weak var txtLocation: FocusTextField!
    @IBOutlet weak var txtBirthday: FocusTextField!
    
    var user_gender:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.photoPicker.allowsEditing = true
        self.photoPicker.delegate = self
        
        self.displayUserInfo()
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
    
    func displayUserInfo()
    {
        if(g_myInfo.profileImage != "")
        {
            let url = URL(string: DOMAIN_URL + g_myInfo.profileImage)
            self.imgProfile.kf.setImage(with: url)
        }
        
        self.txtUserName.text = g_myInfo.userName
        self.txtFirstName.text = g_myInfo.firstName
        self.txtLastName.text = g_myInfo.lastName
        self.txtEmail.text = g_myInfo.emailAddress
        self.txtLocation.text = g_myInfo.address
        self.txtBirthday.text = g_myInfo.birthDay
        
        if(g_myInfo.gender == 0)
        {
            self.btnFemale.setChecked(checkVal: true)
        }
        else
        {
            self.btnMale.setChecked(checkVal: true)
        }
    }
    
    @IBAction func OnBtnUpdate(_ sender: UIButton) {
        if(self.txtUserName.isEmpty())
        {
            self.showErrorVC(msg: "Please input user name.")
            return
        }
        
        if(self.txtFirstName.isEmpty())
        {
            self.showErrorVC(msg: "Please input first name.")
            return
        }
        
        if(self.txtLastName.isEmpty())
        {
            self.showErrorVC(msg: "Please input last name.")
            return
        }
        
        if(self.txtEmail.isEmpty())
        {
            self.showErrorVC(msg: "Please input email.")
            return
        }
        
        if(!self.txtEmail.text!.isValidEmail())
        {
            self.showErrorVC(msg: "Please input correct email address.")
            return
        }
        
        if(self.txtLocation.isEmpty())
        {
            self.showErrorVC(msg: "Please input location.")
            return
        }
        
        if(self.txtBirthday.isEmpty())
        {
            self.showErrorVC(msg: "Please input birth date.")
            return
        }
        
        var gender:Int = 1
        if(self.btnFemale.isChecked)
        {
            gender = 0
        }
        
        let params = [
            "user_name" : txtUserName.text!,
            "first_name" : txtFirstName.text!,
            "last_name" : txtLastName.text!,
            "user_email" : txtEmail.text!,
            "country" : txtLocation.text!,
            "birthday" : txtBirthday.text!,
            "gender" : String(gender),
            "token" : g_myToken
            ]
        
        self.showIndicator()
        ATB_Alamofire.shareInstance.upload(
            multipartFormData: { (multipartFormData) in
                if(self.photoData != Data())
                {
                    multipartFormData.append(self.photoData, withName: "pic", fileName: "profileimg.jpg", mimeType: "image/jpeg")
                }
                
                let contentDict = params
                
                for (key, value) in contentDict
                {
                    multipartFormData.append((value.data(using: .utf8)!), withName: key)
                }
            },
            to: UPDATE_PROFILE_API,
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
                if let ok = res["result"] as? Bool
                {
                    if ok
                    {
                        let userInfo = res["msg"] as! NSDictionary
                        g_myInfo = User(info: userInfo)
                        
                        let alert = UIAlertController(title: "Success", message: "User settings were updated successfully.", preferredStyle: .actionSheet)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            switch action.style{
                            case .default:
                                self.navigationController?.popViewController(animated: true)
                                self.dismiss(animated: true, completion: nil)
                            case .cancel:
                                print("cancel")
                            case .destructive:
                                print("destructive")
                            }}))
                        self.navigationController?.present(alert, animated: true)
                    }
                    else
                    {
                        let msg = res["msg"] as? String ?? ""
                        
                        if(msg == "")
                        {
                            self.showErrorVC(msg: "Update User Setting Failed. Please try again")
                        }
                        else
                        {
                            self.showErrorVC(msg: "Server returned the error message: " + msg)
                        }
                    }
                }
            case .failure(let error):
                print(error)
                self.showErrorVC(msg: "Update User Setting Failed. Please try again")
            }
        }
    }

    
    @IBAction func OnClickGender(_ sender: UIButton) {
        if(sender.tag == 10)
        {
            self.btnFemale.setChecked(checkVal: false)
            self.user_gender = 1
        }
        else
        {
            self.btnMale.setChecked(checkVal: false)
            self.user_gender = 0
        }
        print(self.user_gender)
    }
    
    @IBAction func OnBtnCamera(_ sender: UIButton) {
        self.photoActionController()
    }
    
    func photoActionController()
    {
        let alertController = UIAlertController(title: "", message: "What would you like to do?", preferredStyle: .actionSheet)
        
        let cameraTitle = "Take a photo from Camera."
        let libraryTitle = "Pick a photo from Photo Library"
        
        
        let cameraActionButton = UIAlertAction(title: cameraTitle, style: .default) { action -> Void in
            self.photoPicker.sourceType = .camera
            self.photoPicker.cameraCaptureMode = .photo
            self.present(self.photoPicker, animated: true, completion: nil)
        }
        
        alertController.addAction(cameraActionButton)
        
        let photoLibraryActionButton = UIAlertAction(title: libraryTitle, style: .default) { action -> Void in
            self.photoPicker.sourceType = .photoLibrary
            self.photoPicker.mediaTypes = ["public.image"]
            self.present(self.photoPicker, animated: true, completion: nil)
        }
        alertController.addAction(photoLibraryActionButton)
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        })
        alertController.addAction(cancelButton)
        
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let chosenImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            let imgdata = chosenImage.jpegData(compressionQuality: 1.0)
            self.photoData = imgdata!
            self.imgProfile.image = chosenImage
        }
        dismiss(animated: true, completion: nil);
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
