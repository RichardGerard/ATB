//
//  TransactionHistoryViewController.swift
//  ATB
//
//  Created by YueXi on 5/20/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class TransactionHistoryViewController: BaseViewController {
    
    static let kStoryboardID = "TransactionHistoryViewController"
    class func instance() -> TransactionHistoryViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: TransactionHistoryViewController.kStoryboardID) as? TransactionHistoryViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    // navigation
    @IBOutlet weak var imvTitle: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imvBack: UIImageView!
    
    @IBOutlet weak var tblHistory: UITableView!
    
    var history: [String : [PPTransactionModel]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        loadTransactions()
    }
    
    private func setupViews() {
        /// add gradient layer
        view.addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 42, alphaValue: 1.0)
        
        // navigation
        if #available(iOS 13.0, *) {
            imvTitle.image = UIImage(systemName: "clock")
        } else {
            // Fallback on earlier versions
        }
        imvTitle.tintColor = .white
        
        lblTitle.font = UIFont(name: "SegoeUI-Semibold", size:27)
        lblTitle.text = "Transactions"
        lblTitle.textColor = .white
        
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvBack.tintColor = .white
        
        // tableView
        tblHistory.backgroundColor = .colorGray7
        tblHistory.separatorStyle = .none
        tblHistory.showsVerticalScrollIndicator = false
        tblHistory.tableFooterView = UIView()
        tblHistory.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        tblHistory.register(UINib(nibName: "TransactionHistoryHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: TransactionHistoryHeader.reuseIdentifier)
        
        tblHistory.delegate = self
        tblHistory.dataSource = self
    }
    
    private func loadTransactions() {
        history.removeAll()
        
        let params = [
           "token": g_myToken,
           "user_id": g_myInfo.ID
        ]
           
        showIndicator()
        _ = ATB_Alamofire.POST(GET_PP_TRANSACTIONS, parameters: params as [String : AnyObject]) { (result, responseObject) in
            self.hideIndicator()
               
            let postDicts = responseObject.object(forKey: "msg")  as? [NSDictionary] ?? []
            for postDict in postDicts {
                guard let dateString = postDict.object(forKey: "created_at") as? String,
                      !dateString.isEmpty else { continue }
                
                let transaction = PPTransactionModel()
                
                transaction.ID = postDict.object(forKey: "id") as? String ?? ""
                transaction.transactionID = postDict.object(forKey: "transaction_id") as? String ?? ""
                transaction.transactionType = postDict.object(forKey: "transaction_type") as? String ?? ""
                transaction.amount = postDict.object(forKey: "amount") as? String ?? ""
                let transactionDate = Date(timeIntervalSince1970: dateString.doubleValue)
                transaction.date = transactionDate

                let post = PostDetailModel()
                let post_sum = PostModel()

                if transaction.transactionType != "Subscription" {
                    post_sum.Post_ID = postDict.object(forKey: "target_id") as? String ?? ""
                    post.Post_Summerize = post_sum
                    transaction.post = post
                }
                
                let keyDate = transactionDate.toString("LLLL yyyy", timeZone: .current)
                if let _ = self.history.firstIndex(where: { $0.key == keyDate }) {
                    self.history[keyDate]?.append(transaction)
                    
                } else {
                    self.history[keyDate] = [transaction]
                }
            }
            
            self.tblHistory.reloadData()
        }
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - UITableViewDataSource, UITableViewDelegate
extension TransactionHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let index = history.index(history.startIndex, offsetBy: section)
        return history[history.keys[index]]!.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TransactionHistoryHeader.reuseIdentifier) as? TransactionHistoryHeader else {
            return nil
        }
        
        let index = history.index(history.startIndex, offsetBy: section)
        headerView.lblDate.text = history.keys[index]
                
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionHistoryCell.reuseIdentifier, for: indexPath) as! TransactionHistoryCell
        // configure the cell
        let index = history.index(history.startIndex, offsetBy: indexPath.section)
        let isEnd = ((indexPath.row+1) == history[history.keys[index]]!.count)
        
        // configure the cell
        cell.configureCell(history[history.keys[index]]![indexPath.row], isFirst: indexPath.row == 0, isEnd: isEnd)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TransactionHistoryHeader.headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TransactionHistoryCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

class TransactionHistoryCell: UITableViewCell {
    
    static let reuseIdentifier = "TransactionHistoryCell"
    static let cellHeight: CGFloat = 92
    
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var imvBusiness: UIImageView! { didSet {
        imvBusiness.contentMode = .scaleAspectFill
        }}
    @IBOutlet weak var lblPrice: UILabel! { didSet {
        lblPrice.textColor = .colorGray21
        lblPrice.font = UIFont(name: "SegoeUI-Light", size: 25)
        }}
    @IBOutlet weak var lblBusinessName: UILabel!
    @IBOutlet weak var lblServiceName: UILabel! { didSet {
        lblServiceName.textColor = .colorGray6
        lblServiceName.font = UIFont(name: "SegoeUI-Light", size: 15)
        }}
    
    @IBOutlet weak var lblSeparator: UILabel!
    
    @IBOutlet weak var imvArrow: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvArrow.image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvArrow.contentMode = .scaleAspectFit
        imvArrow.tintColor = .colorPrimary
        }}
    
    let darkGrayAttrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "SegoeUI-Semibold", size: 15)!,
        .foregroundColor: UIColor.colorGray2
    ]
    
    let grayAttrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "SegoeUI-Light", size: 15)!,
        .foregroundColor: UIColor.colorGray6
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ history: PPTransactionModel, isFirst: Bool, isEnd: Bool) {
        
        if (history.post.Post_Summerize.Post_ID == "") {
            imvBusiness.loadImageFromUrl(g_myInfo.profileImage, placeholder: "profile.placeholder")
            
            let attributedStr = NSMutableAttributedString(string: g_myInfo.firstName + " " + g_myInfo.lastName)
            attributedStr.addAttributes(darkGrayAttrs, range: NSRange(location: 0, length: g_myInfo.firstName.count))
            attributedStr.addAttributes(grayAttrs, range: NSRange(location: g_myInfo.firstName.count + 1, length: g_myInfo.lastName.count))
            lblBusinessName.attributedText = attributedStr
                   
            lblServiceName.text = "Business account subscription"
                        
        } else if (history.post.Post_Summerize.Post_Text == "") {
            let postdetailmodel = PostDetailModel()
            
            let params = [
                "token" : g_myToken,
                "post_id" : history.post.Post_Summerize.Post_ID
            ]
            
            _ = ATB_Alamofire.POST(GET_POST_DETAIL_API, parameters: params as [String : AnyObject]) { (result, responseObject) in
                if result {
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
                    
                    history.post = postdetailmodel
                    
                          
                    if history.post.Post_Summerize.Post_Media_Urls.count > 0 {
                        self.imvBusiness.loadImageFromUrl(history.post.Post_Summerize.Post_Media_Urls[0], placeholder: "post.placeholder")
                    }
                    
                    let attributedStr = NSMutableAttributedString(string: history.post.Poster_Info.firstName + " " + history.post.Poster_Info.lastName)
                    attributedStr.addAttributes(self.darkGrayAttrs, range: NSRange(location: 0, length: history.post.Poster_Info.firstName.count))
                    attributedStr.addAttributes(self.grayAttrs, range: NSRange(location: history.post.Poster_Info.firstName.count + 1, length: history.post.Poster_Info.lastName.count))
                    self.lblBusinessName.attributedText = attributedStr
                           
                    self.lblServiceName.text = history.post.Post_Summerize.Post_Title
                }
            }
            
        } else {
            if history.post.Post_Summerize.Post_Media_Urls.count > 0 {
                self.imvBusiness.loadImageFromUrl(history.post.Post_Summerize.Post_Media_Urls[0], placeholder: "post.placeholder")
            }
            
            let attributedStr = NSMutableAttributedString(string: history.post.Poster_Info.firstName + " " + history.post.Poster_Info.lastName)
            attributedStr.addAttributes(self.darkGrayAttrs, range: NSRange(location: 0, length: history.post.Poster_Info.firstName.count))
            attributedStr.addAttributes(self.grayAttrs, range: NSRange(location: history.post.Poster_Info.firstName.count + 1, length: history.post.Poster_Info.lastName.count))
            self.lblBusinessName.attributedText = attributedStr
                   
            self.lblServiceName.text = history.post.Post_Summerize.Post_Title
        }
        
        let amount = history.amount.floatValue        
        lblPrice.text = "£" + (amount >= 0 ? amount.priceString : (-1*amount).priceString)
        
        lblSeparator.isHidden = isEnd
        
        if isFirst {
            vContainer.layer.cornerRadius = 5
            vContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
        } else if isEnd {
            vContainer.layer.cornerRadius = 5
            vContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
        } else {
            vContainer.layer.cornerRadius = 0
        }
        
        vContainer.clipsToBounds = true
    }
}
