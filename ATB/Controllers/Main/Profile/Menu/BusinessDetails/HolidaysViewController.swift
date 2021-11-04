//
//  HolidaysViewController.swift
//  ATB
//
//  Created by YueXi on 11/2/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import PopupDialog

class HolidaysViewController: BaseViewController {
    
    @IBOutlet weak var tblHoldiays: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
        tblHoldiays.backgroundColor = .clear
        tblHoldiays.showsVerticalScrollIndicator = false
        tblHoldiays.tableFooterView = UIView()
        tblHoldiays.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 114, right: 0)
        tblHoldiays.separatorStyle = .none
        
        tblHoldiays.register(UINib(nibName: "HolidaysTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: HolidaysTableHeaderView.reuseIdentifier)
        
        tblHoldiays.dataSource = self
        tblHoldiays.delegate = self
    }

    func openAddHolidayPopup() {
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius = 16
        containerAppearance.backgroundColor = .clear

        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color = .black

        let addHolidayVC = AddHolidayViewController(nibName: "AddHolidayViewController", bundle: nil)
        addHolidayVC.delegate = self

        let popup = PopupDialog(viewController: addHolidayVC, buttonAlignment: .horizontal, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: true, panGestureDismissal: true, hideStatusBar: false, completion: nil)

        present(popup, animated: true)
    }
    
    private func deleteHoliday(_ selected: Int) {
        showIndicator()
        
        let holidayID = g_myInfo.business_profile.holidays[selected].id
        APIManager.shared.deleteHoliday(g_myToken, id: holidayID) { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                g_myInfo.business_profile.holidays.remove(at: selected)
                self.tblHoldiays.reloadData()
                self.showSuccessVC(msg: "The holiday has been deleted!")
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension HolidaysViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return g_myInfo.business_profile.holidays.count + 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if g_myInfo.business_profile.holidays.count > 0 {
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: HolidaysTableHeaderView.reuseIdentifier)
            return headerView
            
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= g_myInfo.business_profile.holidays.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: AddHolidayTableViewCell.reuseIdentifier, for: indexPath) as! AddHolidayTableViewCell
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: HolidayTableViewCell.reuseIdentifier, for: indexPath) as! HolidayTableViewCell
            // configure the cell
            cell.configureCell(g_myInfo.business_profile.holidays[indexPath.row])
            cell.deleted = {
                self.deleteHoliday(indexPath.row)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row >= g_myInfo.business_profile.holidays.count else { return }
        
        openAddHolidayPopup()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if g_myInfo.business_profile.holidays.count > 0 {
            return 60
            
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension HolidaysViewController: AddHolidayDelegate {
    
    func didAddHoliday(_ added: Holiday) {
        g_myInfo.business_profile.holidays.append(added)
        
        tblHoldiays.reloadData()
    }
}
