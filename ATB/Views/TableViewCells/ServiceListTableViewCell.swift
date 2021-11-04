//
//  ServiceListTableViewCell.swift
//  ATB
//
//  Created by mobdev on 2019/6/3.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class ServiceListTableViewCell: UITableViewCell {
    var extended:Bool = false
    var index:Int!
    var serviceCellDelegate:ServiceCellDelegate!
    var serviceData:QualifiedServiceModel = QualifiedServiceModel()
    
    @IBOutlet weak var lblInsuranceExpiryTitle: UILabel!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var lblServiceTitle: UILabel!
    @IBOutlet weak var lblServiceTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var viewExtra: UIView!
    
    @IBOutlet weak var lblRequireDeposit: UILabel!
    @IBOutlet weak var lblServiceDate: UILabel!
    @IBOutlet weak var lblInsuranceCompany: UILabel!
    @IBOutlet weak var lblInsuranceExpiry: UILabel!
    
    var isFromOtherProfile:Bool = false
    
    @IBOutlet weak var btnViewQualified: UIButton!
    @IBOutlet weak var btnViewInsuranceExpiry: UIButton!
    @IBOutlet weak var img_btnRemove: UIImageView!
    @IBOutlet weak var lbl_btnRemove: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureWithData(index:Int, extended:Bool, serviceData:QualifiedServiceModel, isFromOtherProfile:Bool)
    {
        self.isFromOtherProfile = isFromOtherProfile
        self.serviceData = serviceData
        self.index = index
        self.extended = extended
        
        if(extended)
        {
            self.lblServiceTitle.font = UIFont(name: "SegoeUI-Bold", size: 22.0)
            self.lblServiceTitleHeight.constant = 35.0
            self.lblInsuranceExpiryTitle.isHidden = true
            self.lblServiceTitle.text = self.serviceData.Service_Name
            self.lblInsuranceExpiryTitle.text = "Insurance Until " + self.serviceData.Insurance_Expiry
            
            if(serviceData.Deposit_Required)
            {
                let strDeposit = String(self.serviceData.Deposit_Amount)
                self.lblRequireDeposit.text = "£ \(strDeposit)"
                //self.lblRequireDeposit.text = "Active"
            }
            else
            {
                self.lblRequireDeposit.text = "£ 0.0"
            }
            
            self.lblServiceDate.text = self.serviceData.Qualified_Date
            self.lblInsuranceCompany.text = self.serviceData.Insurance_Company
            self.lblInsuranceExpiry.text = self.serviceData.Insurance_Expiry
            
            self.viewExtra.isHidden = false
            self.imgArrow.transform = CGAffineTransform(rotationAngle: .pi/2)
        }
        else
        {
            self.lblServiceTitle.font = UIFont(name: "SegoeUI-Light", size: 20.0)
            self.lblServiceTitleHeight.constant = 22.0
            self.lblInsuranceExpiryTitle.isHidden = false
            self.lblServiceTitle.text = self.serviceData.Service_Name
            self.lblInsuranceExpiryTitle.text = "Insurance Until " + self.serviceData.Insurance_Expiry
            
            self.viewExtra.isHidden = true
            self.imgArrow.transform = CGAffineTransform(rotationAngle: 0)
        }
        
        if(isFromOtherProfile)
        {
            self.btnViewQualified.isHidden = true
            self.btnViewInsuranceExpiry.isHidden = true
            self.lbl_btnRemove.text = "Book Service"
            self.img_btnRemove.image = UIImage(named: "booking")
        }
        else
        {
            self.btnViewQualified.isHidden = false
            self.btnViewInsuranceExpiry.isHidden = false
            self.lbl_btnRemove.text = "Remove Service"
            self.img_btnRemove.image = UIImage(named: "file_trash")
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    @IBAction func OnCellExtendClick(_ sender: UIButton) {
        self.serviceCellDelegate.ServiceCellExtended(index: index, extended: !extended)
    }
    
    @IBAction func onBtnRemoveService(_ sender: UIButton) {
        self.serviceCellDelegate.ServiceRemoveClicked(index: index)
    }
    
    @IBAction func onClickServiceView(_ sender: UIButton) {
        self.serviceCellDelegate.OnServiceViewClicked(index: index)
    }
    
    @IBAction func onClickInsuranceView(_ sender: UIButton) {
        self.serviceCellDelegate.OnInsuranceViewClicked(index: index)
    }
}
