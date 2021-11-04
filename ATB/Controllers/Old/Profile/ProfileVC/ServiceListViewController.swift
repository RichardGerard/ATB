//
//  ServiceListViewController.swift
//  ATB
//
//  Created by mobdev on 11/28/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class ServiceListViewController: UIViewController {
    
    @IBOutlet weak var tbl_Service: UITableView!
    
    var service_list:[QualifiedServiceModel] = []
    var service_extended:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tableViewInsets:UIEdgeInsets = UIEdgeInsets(top: 13.0, left: 0.0, bottom: 13.0, right: 0.0)
        tbl_Service.contentInset = tableViewInsets
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.view.layoutIfNeeded()
    }
    
    func displayServiceList()
    {
        tbl_Service.reloadData()

        self.view.layoutIfNeeded()
    }
}

extension ServiceListViewController:UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.service_list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let serviceCell = tableView.dequeueReusableCell(withIdentifier: "ServiceListTableViewCell",
                                                        for: indexPath) as! ServiceListTableViewCell
        serviceCell.serviceCellDelegate = self
        
        let serviceData = self.service_list[indexPath.row]
        var extended = false
        if(self.service_extended.contains(serviceData.Service_Name))
        {
            extended = true
        }
        
        serviceCell.configureWithData(index: indexPath.row, extended: extended, serviceData: serviceData, isFromOtherProfile: true)
        
        return serviceCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(self.service_extended.contains(self.service_list[indexPath.row].Service_Name))
        {
            return 345
        }
        
        return 70
    }
}

extension ServiceListViewController:ServiceCellDelegate{
    func ServiceRemoveClicked(index: Int) {
        //Do Service Booking Action Here.
        //Do Service Booking Action Here.
        //Do Service Booking Action Here.
    }
    
    func OnServiceViewClicked(index: Int) {
        return
    }
    
    func OnInsuranceViewClicked(index: Int) {
        return
    }
    
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
}
