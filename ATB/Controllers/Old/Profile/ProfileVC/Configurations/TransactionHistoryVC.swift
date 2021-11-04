//
//  TransactionHistoryVC.swift
//  ATB
//
//  Created by mobdev on 2019/5/23.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class TransactionHistoryVC: UIViewController {
    
    @IBOutlet weak var tbl_trasaction: UITableView!
    
    var transactions:[PPTransactionModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadList()
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
    
    func loadList(){
        transactions.removeAll()
        tbl_trasaction.reloadData()
        
        var user_id  = g_myInfo.ID
        
        let params = [
            "token" : g_myToken,
            "user_id":user_id
        ]
        
        _ = ATB_Alamofire.POST(GET_PP_TRANSACTIONS, parameters: params as [String : AnyObject],showLoading: false,showSuccess: false,showError: false){
            (result, responseObject) in
            
            let postDicts = responseObject.object(forKey: "msg")  as? [NSDictionary] ?? []
            
            print(postDicts)
            
            for postDict in postDicts
            {
                let transaction = PPTransactionModel()
                transaction.amount = postDict.object(forKey: "amount") as? String ?? ""
                transaction.transactionID = postDict.object(forKey: "transaction_id") as? String ?? ""
                transaction.transactionType = postDict.object(forKey: "transaction_type") as? String ?? ""
                transaction.ID = postDict.object(forKey: "id") as? String ?? ""
                
                var strPost_date = postDict.object(forKey: "created_at") as? String ?? ""
                if(strPost_date != "")
                {
                    let date = Date(timeIntervalSince1970: Double(strPost_date) as! TimeInterval)
                    
                    let dateFormatter = DateFormatter()
                    //            dateFormatter.timeStyle = DateFormatter.Style.short //Set time style
                    //            dateFormatter.dateStyle = DateFormatter.Style.medium
                    dateFormatter.dateFormat = "dd/MM/yy HH:mm"
                    dateFormatter.timeZone = .current
                    let localDate = dateFormatter.string(from: date)
                    
//                    transaction.date = localDate
                }
                
                let post = PostDetailModel()
                let post_sum = PostModel()
                
                if(transaction.transactionType != "Subscription")
                {
                    post_sum.Post_ID = postDict.object(forKey: "target_id") as? String ?? ""
                }
                
                post.Post_Summerize = post_sum
                transaction.post = post
                
                self.transactions.append(transaction)
                
            }
            
            self.tbl_trasaction.reloadData()
        }
    }
}

extension TransactionHistoryVC:UITableViewDelegate, UITableViewDataSource{
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transaction = self.transactions[indexPath.row]
        
        let transactionCell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTableViewCell",
                                                     for: indexPath) as! TransactionHistoryTableViewCell
        
        if (transaction.post.Post_Summerize.Post_ID == "") {
            if(g_myInfo.profileImage != "")
            {
                let url = URL(string: DOMAIN_URL + g_myInfo.profileImage)
                transactionCell.imgService.kf.setImage(with: url)
            }
            
            transactionCell.lblServiceTitle.text = "Business account subscription"
            transactionCell.lblEmail.text = ""
            transactionCell.lblUsername.text = g_myInfo.firstName + " " + g_myInfo.lastName
            
        } else if (transaction.post.Post_Summerize.Post_Text == ""){
            let postdetailmodel = PostDetailModel()
            
            let params = [
                "token" : g_myToken,
                "post_id" : transaction.post.Post_Summerize.Post_ID
            ]
            _ = ATB_Alamofire.POST(GET_POST_DETAIL_API, parameters: params as [String : AnyObject],showLoading: false,showSuccess: false,showError: false){
                (result, responseObject) in
                self.view.isUserInteractionEnabled = true
                print(responseObject)
                
                if(result)
                {
                    let postDetailDict = responseObject.object(forKey: "extra") as! NSDictionary
                    let userArray = postDetailDict.object(forKey: "user") as! NSArray
                    let userDict = userArray[0] as! NSDictionary
                    
                    // let businessDict = userDict["business_info"]
                    
                    let postDetails = PostModel(info: postDetailDict)
                    postdetailmodel.Post_Summerize = postDetails
                    
                    let posterInfo:UserModel = UserModel()
                
                    
                    var strUserId = postDetailDict.object(forKey: "user_id") as? String ?? ""
                    if(strUserId == "")
                    {
                        let nUserId = postDetailDict.object(forKey: "user_id") as? Int ?? 0
                        strUserId = String(nUserId)
                    }
                    posterInfo.ID = strUserId
                    
                    posterInfo.account_name = userDict.object(forKey: "user_name") as? String ?? ""
                    posterInfo.email_address = userDict.object(forKey: "user_email") as? String ?? ""
                    posterInfo.profile_image = userDict.object(forKey: "pic_url") as? String ?? ""
                    posterInfo.firstName = userDict.object(forKey: "first_name") as? String ?? ""
                    posterInfo.lastName = userDict.object(forKey: "last_name") as? String ?? ""
                    posterInfo.description = userDict.object(forKey: "description") as? String ?? ""
                    
                    postdetailmodel.Poster_Info = posterInfo
                    
                    transaction.post = postdetailmodel
                    
                    if(transaction.post.Post_Summerize.Post_Media_Type == "Text")
                    {
                        transactionCell.imgService.isHidden = true
                        self.view.layoutIfNeeded()
                    }
                    else {
                        let url = URL(string: DOMAIN_URL + transaction.post.Post_Summerize.Post_Media_Urls[0])
                        transactionCell.imgService.kf.setImage(with: url)
                        transactionCell.imgService.isHidden = false
                        self.view.layoutIfNeeded()
                    }
                    
                    transactionCell.lblServiceTitle.text = transaction.post.Post_Summerize.Post_Title
                    transactionCell.lblEmail.text = ""
                    transactionCell.lblUsername.text = transaction.post.Poster_Info.firstName + " " + transaction.post.Poster_Info.lastName
                    
                }
                else
                {
                    let msg = responseObject.object(forKey: "msg") as? String ?? ""
                    
                    if(msg == "")
                    {
                        self.showErrorVC(msg: "Failed to get the details about this post, please try again")
                    }
                    else
                    {
                        self.showErrorVC(msg: "Server returned the error message: " + msg)
                    }
                }
            }
            
        } else {
            if(transaction.post.Post_Summerize.Post_Media_Type == "Text")
            {
                transactionCell.imgService.isHidden = true
                self.view.layoutIfNeeded()
            }
            else {
                let url = URL(string: DOMAIN_URL + transaction.post.Post_Summerize.Post_Media_Urls[0])
                transactionCell.imgService.kf.setImage(with: url)
                transactionCell.imgService.isHidden = false
                self.view.layoutIfNeeded()
            }
            
            transactionCell.lblServiceTitle.text = transaction.post.Post_Summerize.Post_Title
            transactionCell.lblEmail.text = ""
            transactionCell.lblUsername.text = transaction.post.Poster_Info.firstName + " " + transaction.post.Poster_Info.lastName
        }
        
        var price = Double(transaction.amount)
        var priceString = "£" + transaction.amount
        if(price! < 0.00)
        {
            price = -price!
            priceString = "-£" + String(price!)
        }
        
        transactionCell.lblPrice.text = priceString
        
        return transactionCell
    }
    
}
