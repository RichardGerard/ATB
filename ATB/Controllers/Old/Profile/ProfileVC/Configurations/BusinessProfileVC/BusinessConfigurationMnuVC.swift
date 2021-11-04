//
//  BusinessConfigurationMnuVC.swift
//  ATB
//
//  Created by mobdev on 13/8/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class BusinessConfigurationMnuVC: UIViewController{
    
    var mnu_array = ["Create/Amend Business Bio", "Set Post Range", "Business Settings"]
    @IBOutlet weak var tbl_mnu: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tbl_mnu.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.view.layoutIfNeeded()
    }
    
    @IBAction func OnBtnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension BusinessConfigurationMnuVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mnu_array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let confCell = tableView.dequeueReusableCell(withIdentifier: "ConfigurationTableViewCell",
                                                     for: indexPath) as! ConfigurationTableViewCell
        confCell.lblTitle.text = self.mnu_array[indexPath.row]
        if(indexPath.row == 2)
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
//            setBioVC.isForBusiness = true
//            self.navigationController?.pushViewController(setBioVC, animated: true)
            break
        case 2:
        
            break
        case 3:
            let businessSettingVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateBusinessVC") as! CreateBusinessVC
            businessSettingVC.modalTransitionStyle = .crossDissolve
            businessSettingVC.isEditSetting = true
            let parentVC = self.navigationController?.parent as! MainTabBarVC
            parentVC.navigationController?.pushViewController(businessSettingVC, animated: true)
            break
        default:
            break
        }
    }
}
