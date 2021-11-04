//
//  SoldItemsViewController.swift
//  ATB
//
//  Created by YueXi on 10/13/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import NBBottomSheet

class SoldItemsViewController: BaseViewController {
    
    static let kStoryboardID = "SoldItemsViewController"
    class func instance() -> SoldItemsViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: SoldItemsViewController.kStoryboardID) as? SoldItemsViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvProfile: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnOK: UIButton!
    
    @IBOutlet weak var vArrowContainer: UIView!
    @IBOutlet weak var imvUpDownArrow: UIImageView! { didSet {
        imvUpDownArrow.layer.cornerRadius = 11
        imvUpDownArrow.layer.masksToBounds = true
        if #available(iOS 13.0, *) {
            imvUpDownArrow.image = UIImage(systemName: "arrow.up.arrow.down.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvUpDownArrow.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var vTopRoundContainer: UIView!
    
    @IBOutlet weak var tblItems: UITableView!
    
    // represents whether to show items for 'Business' or 'Normal' profile
    var isBusiness = false
    
    var soldItems: [String: [TransactionHistoryModel]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        getSoldItems(forBusiness: isBusiness)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        vTopRoundContainer.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
    }
    
    private func setupViews() {
        /// add gradient layer
        view.addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 42, alphaValue: 1.0)
        
        imvProfile.layer.cornerRadius = 24
        imvProfile.layer.masksToBounds = true
        imvProfile.contentMode = .scaleAspectFill
        
        updateUserSelection()
        
        lblTitle.text = "Items Sold"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 26)
        lblTitle.textColor = .white
        
        btnOK.setTitle("OK", for: .normal)
        btnOK.setTitleColor(.white, for: .normal)
        btnOK.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        
        vTopRoundContainer.backgroundColor = .colorGray14
        
        vArrowContainer.isHidden = !g_myInfo.isBusiness
        
        tblItems.backgroundColor = .colorGray14
        tblItems.tableFooterView = UIView()
        tblItems.separatorStyle = .none
        tblItems.showsVerticalScrollIndicator = false
                
        tblItems.register(ItemListHeaderView.self, forHeaderFooterViewReuseIdentifier: ItemListHeaderView.reuseIdentifier)
        
        tblItems.dataSource = self
        tblItems.delegate = self
    }
    
    private func updateUserSelection() {
        let url = isBusiness ? g_myInfo.business_profile.businessPicUrl : g_myInfo.profileImage
        imvProfile.loadImageFromUrl(url, placeholder: "profile.placeholder")
    }
    
    // transitioningDelgegate is a weak property
    // for dismissed protocol, we need to make it a class variable
    let sheetTransitioningDelegate = NBBottomSheetTransitioningDelegate()
    
    // switch between normal and business user profile
    // only valid/visible for only business users & own profile
    @IBAction func didTapProfile(_ sender: Any) {
        // check validation
        var users = [UserModel]()
        
        let normalUser = UserModel()
        normalUser.ID = g_myInfo.ID
        normalUser.user_type = "User"
        normalUser.user_name = g_myInfo.userName
        normalUser.profile_image = g_myInfo.profileImage
        users.append(normalUser)
        
        if g_myInfo.isBusiness {
            // if business profile is approved
            let businessUser = UserModel()
            businessUser.ID = g_myInfo.business_profile.ID
            businessUser.user_type = "Business"
            businessUser.user_name = g_myInfo.business_profile.businessProfileName
            businessUser.profile_image = g_myInfo.business_profile.businessPicUrl
            users.append(businessUser)
        }
        
        guard users.count > 1 else { return }
        
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35
        configuruation.sheetDirection = .top
        
        let heightForOptionSheet: CGFloat =  243 // (233 + 10 - cornerRaidus addition value)
        
        configuruation.sheetSize = .fixed(heightForOptionSheet)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        
        let topSheetController = NBBottomSheetController(configuration: configuruation, transitioningDelegate: sheetTransitioningDelegate)
        
        /// show action sheet with options (Edit or Delete)
        let selectVC = ProfileSelectViewController.instance()
        selectVC.users = users
        selectVC.selectedIndex = isBusiness ? 1 : 0
        selectVC.delegate = self
        
        topSheetController.present(selectVC, on: self)
    }
    
    private func getSoldItems(forBusiness business: Bool) {
        self.showIndicator()
        
        let params = [
            "token" : g_myToken,
            "is_business": business ? "1" : "0"
        ]
        
        _ = ATB_Alamofire.POST(GET_ITEMS_SOLD, parameters: params as [String: AnyObject], completionHandler: { (result, response) in
            self.hideIndicator()
            
            guard result,
                  let responseDicts = response.object(forKey: "msg") as? [NSDictionary] else {
                self.showErrorVC(msg: "It's been failed to load purchase history!")
                return
            }
            
            guard responseDicts.count > 0 else {
                self.showInfoVC("ATB", msg: "No any sold items yet!")
                return
            }
            
            for responseDict in responseDicts {
                // transaction date & product is a must
                guard let createdAt = responseDict.object(forKey: "created_at") as? String,
                      !createdAt.isEmpty,
                      let productDicts = responseDict.object(forKey: "product") as? [NSDictionary],
                      productDicts.count > 0 else { continue }
                
                let sold = TransactionHistoryModel()
                
                sold.id = responseDict.object(forKey: "id") as? String ?? ""
                sold.tid = responseDict.object(forKey: "transaction_id") as? String ?? ""
                sold.uid = responseDict.object(forKey: "user_id") as? String ?? ""
                sold.amount = (responseDict.object(forKey: "amount") as? String ?? "").floatValue
                sold.quantity = (responseDict.object(forKey: "quantity") as? String ?? "").intValue
                sold.date = createdAt
                
                let product = PostModel(info: productDicts[0])
                sold.item = product
                
                let date = Date(timeIntervalSince1970: createdAt.doubleValue)
                let sectionKeyDate = date.toString("LLL yyyy", timeZone: .current)
                
                if let _ = self.soldItems.firstIndex(where: { $0.key == sectionKeyDate }) {
                    self.soldItems[sectionKeyDate]?.append(sold)
                    
                } else {
                    self.soldItems[sectionKeyDate] = [sold]
                }
            }
            
            self.tblItems.reloadData()
        })
    }
    
    @IBAction func didTapOk(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: ProfileSelectDelegate
extension SoldItemsViewController: ProfileSelectDelegate  {
    
    func profileSelected(_ selectedIndex: Int) {
        isBusiness = !isBusiness
        
        updateUserSelection()
        
        // remove existing items and reload
        if soldItems.count > 0 {
            soldItems.removeAll()
            tblItems.reloadData()
        }
        
        getSoldItems(forBusiness: isBusiness)
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension SoldItemsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return soldItems.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let keyIndex = soldItems.index(soldItems.startIndex, offsetBy: section)
        return soldItems[soldItems.keys[keyIndex]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SoldItemViewCell.reuseIdentifier, for: indexPath) as! SoldItemViewCell
        // configure the cell
        let keyIndex = soldItems.index(soldItems.startIndex, offsetBy: indexPath.section)
        cell.configureCell(withSold: soldItems[soldItems.keys[keyIndex]]![indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ItemListHeaderView.reuseIdentifier) as? ItemListHeaderView else { return nil }
        // configure section view
        let keyIndex = soldItems.index(soldItems.startIndex, offsetBy: section)
        headerView.titleLabel.text = soldItems.keys[keyIndex]
        return headerView
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = .clear
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
