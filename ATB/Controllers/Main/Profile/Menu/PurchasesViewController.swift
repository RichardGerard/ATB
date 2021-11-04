//
//  PurchasesViewController.swift
//  ATB
//
//  Created by YueXi on 10/13/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class PurchasesViewController: BaseViewController {
    
    static let kStoryboardID = "PurchasesViewController"
    class func instance() -> PurchasesViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: PurchasesViewController.kStoryboardID) as? PurchasesViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvProfile: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnOK: UIButton!
    
    @IBOutlet weak var vTopRoundContainer: UIView!
    
    @IBOutlet weak var tblPurchases: UITableView!
    
    var purchases: [String: [TransactionHistoryModel]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        getPurchases()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        vTopRoundContainer.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
    }
    
    private func setupViews() {
        /// add gradient layer
        self.view.addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 42, alphaValue: 1.0)
        
        imvProfile.layer.cornerRadius = 24
        imvProfile.layer.masksToBounds = true
        imvProfile.contentMode = .scaleAspectFill
        
        let url = g_myInfo.profileImage
        imvProfile.loadImageFromUrl(url, placeholder: "profile.placeholder")
        
        lblTitle.text = "Purchases"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 26)
        lblTitle.textColor = .white
        
        btnOK.setTitle("OK", for: .normal)
        btnOK.setTitleColor(.white, for: .normal)
        btnOK.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        
        vTopRoundContainer.backgroundColor = .colorGray14
        
        tblPurchases.backgroundColor = .colorGray14
        tblPurchases.tableFooterView = UIView()
        tblPurchases.separatorStyle = .none
        tblPurchases.showsVerticalScrollIndicator = false
                
        tblPurchases.register(ItemListHeaderView.self, forHeaderFooterViewReuseIdentifier: ItemListHeaderView.reuseIdentifier)
        
        tblPurchases.dataSource = self
        tblPurchases.delegate = self
    }
    
    private func getPurchases() {
        showIndicator()
        
        let params = [
            "token" : g_myToken
        ]
        
        _ = ATB_Alamofire.POST(GET_PURCHASES, parameters: params as [String: AnyObject], completionHandler: { (result, response) in
            self.hideIndicator()
            
            guard result,
                  let responseDicts = response.object(forKey: "msg") as? [NSDictionary] else {
                self.showErrorVC(msg: "It's been failed to load purchase history!")
                return
            }
            
            guard responseDicts.count > 0 else {
                self.showInfoVC("ATB", msg: "No any purchases yet!")
                return
            }
            
            for responseDict in responseDicts {
                // transaction date & product is a must
                guard let createdAt = responseDict.object(forKey: "created_at") as? String,
                      !createdAt.isEmpty,
                      let productDicts = responseDict.object(forKey: "product") as? [NSDictionary],
                      productDicts.count > 0 else { continue }
                
                let purchase = TransactionHistoryModel()
                
                purchase.id = responseDict.object(forKey: "id") as? String ?? ""
                purchase.tid = responseDict.object(forKey: "transaction_id") as? String ?? ""
                purchase.uid = responseDict.object(forKey: "user_id") as? String ?? ""
                purchase.amount = (responseDict.object(forKey: "amount") as? String ?? "").floatValue
                purchase.quantity = (responseDict.object(forKey: "quantity") as? String ?? "").intValue
                purchase.date = createdAt
                
                let product = PostModel(info: productDicts[0])
                purchase.item = product
                
                let date = Date(timeIntervalSince1970: createdAt.doubleValue)
                let sectionKeyDate = date.toString("LLL yyyy", timeZone: .current)
                
                if let _ = self.purchases.firstIndex(where: { $0.key == sectionKeyDate }) {
                    self.purchases[sectionKeyDate]?.append(purchase)
                    
                } else {
                    self.purchases[sectionKeyDate] = [purchase]
                }
            }
            
            self.tblPurchases.reloadData()
        })
    }
    
    @IBAction func didTapOk(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension PurchasesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return purchases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let keyIndex = purchases.index(purchases.startIndex, offsetBy: section)
        return purchases[purchases.keys[keyIndex]]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PurchaseItemViewCell.reuseIdentifier, for: indexPath) as! PurchaseItemViewCell
        // configure the cell
        let keyIndex = purchases.index(purchases.startIndex, offsetBy: indexPath.section)
        cell.configureCell(withPurchase: purchases[purchases.keys[keyIndex]]![indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ItemListHeaderView.reuseIdentifier) as? ItemListHeaderView else { return nil }
        
        // configure section view
        let keyIndex = purchases.index(purchases.startIndex, offsetBy: section)
        headerView.titleLabel.text = purchases.keys[keyIndex]
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
