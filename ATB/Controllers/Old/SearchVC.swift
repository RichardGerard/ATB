//
//  SearchVC.swift
//  ATB
//
//  Created by mobdev on 2019/5/16.
//  Copyright © 2019 mobdev. All rights reserved.
//

// Updated by YueXi on 2021/3/31

import Foundation
import UIKit

class SearchVC: UIViewController {
    @IBOutlet weak var btnContainerWidth: NSLayoutConstraint!
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var viewLogo: RoundView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCategoryWidth: NSLayoutConstraint!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var viewSearchBox: SearchBoxView!
    @IBOutlet weak var viewSearchContainer: UIView!
    @IBOutlet weak var viewSearchResultContainer: UIView!
    @IBOutlet weak var viewSearchResultContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewSearchIconTop: NSLayoutConstraint!
    
    var topSpaceToSafeArea:CGFloat = 0.0
    var bottomSpaceToSafeArea:CGFloat = 0.0
    var screenHeight:CGFloat = 0.0
    var screenWidth:CGFloat = 0.0
    var keyboardHeight:CGFloat = 0.0
    let searchBoxTopWithTitle:CGFloat = 72
    let searchFieldHeight:CGFloat = 54
    let keyboardTop:CGFloat = 30
    let searchBoxLeftRightSpace:CGFloat = 40
    let imgWidthHeight:CGFloat = 54
    let searchFieldLeftIndent:CGFloat = 20
    var verticalCenterY:CGFloat = 0
    var categorytableviewHeight:CGFloat = 0
    var searchStatus:Int = 0
    
    @IBOutlet weak var tbl_searchResult: UITableView!
    var array_result: [PostModel] = []
    var selectedResult: FeedModel = FeedModel()
    
    @IBOutlet weak var collectionView_Category: UICollectionView!
    var selectedCategory:String = "My ATB"
    
    var feedGroups = [FeedGroup]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let window = UIApplication.shared.keyWindow
        
        if #available(iOS 11.0, *) {
            bottomSpaceToSafeArea = (window?.safeAreaInsets.bottom)!
            topSpaceToSafeArea = (window?.safeAreaInsets.top)!
        }
        screenWidth = UIScreen.main.bounds.width
        screenHeight = UIScreen.main.bounds.height
        
        self.initView()
        
        collectionView_Category.delegate = self
        collectionView_Category.dataSource = self
        
        tbl_searchResult.delegate = self
        tbl_searchResult.dataSource = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        self.txtSearch.delegate = self
        //self.viewCategoryContainer.isHidden = true
        
        self.txtSearch.attributedPlaceholder = NSAttributedString(string: "Search for...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.colorGray1])
        
        initGroups()
    }
    
    private func initGroups() {
        let groupIcons = ["addbtn", "group.beauty", "group.ladies.wear", "group.mens.wear", "group.hair", "group.kids", "group.garden", "group.home", "group.parties", "group.health", "group.seasonal"]
        
        let groupNames = ["My ATB", "Beauty", "Ladieswear", "Menswear", "Hair", "Kids", "General", "Home", "Events", "Health & Well-Being", "Seasonal"]
        
        for i in 0 ..< 11 {
            let feedGroup = FeedGroup(isSelected: false, icon: groupIcons[i], name: groupNames[i])
            
            feedGroups.append(feedGroup)
        }
    }
    
    @IBAction func OnBtnSearch(_ sender: UIButton) {
        if(self.searchStatus == 3)
        {
            self.txtSearch.becomeFirstResponder()
            initSearchInputView()
        }
        else if(self.searchStatus == 2)
        {
            initSearchView()
        }
        else if(self.searchStatus == 1)
        {
            self.txtSearch.becomeFirstResponder()
            initSearchInputView()
        }
    }
    
    func initView()
    {
        self.txtSearch.resignFirstResponder()
        self.imgArrow.image = UIImage(named: "btnarrow")
        self.imgArrow.transform = CGAffineTransform(rotationAngle: 0)
        self.lblCategory.text = ""
        
        //self.btnContainerWidth.constant = screenWidth - searchBoxLeftRightSpace
        
        self.viewSearchResultContainerHeight.constant = 0
        self.verticalCenterY = (self.screenHeight - self.topSpaceToSafeArea - self.bottomSpaceToSafeArea - 49) / 2 - 16 - 20 - 54
       
        self.lblTitle.isHidden = false
        self.viewLogo.isHidden = false
        
        self.viewSearchIconTop.constant = 150.0
        
        self.searchStatus = 1
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tbl_searchResult.reloadData()
    }
    
    func initSearchResultView()
    {
        self.txtSearch.resignFirstResponder()
        self.lblTitle.isHidden = true
        self.viewLogo.isHidden = true
        self.collectionView_Category.isHidden = true
        
        self.viewSearchIconTop.constant = -200
        self.imgArrow.image = UIImage(named: "btncheck")
        //lblCategoryWidth.constant = 86.0
        lblCategory.text = self.selectedCategory
        
        //btnContainerWidth.constant = self.screenWidth - 40
        
        self.imgArrow.transform = CGAffineTransform(rotationAngle: 0)
        //self.viewCategoryContainer.isHidden = true
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.viewSearchResultContainerHeight.constant = 680
            //self.viewSearchResultContainerHeight.constant = self.screenHeight - self.topSpaceToSafeArea - self.bottomSpaceToSafeArea - 49 - 20 - self.searchFieldHeight
            
            self.view.layoutIfNeeded()
            
        }) { (isCompleted) in
            self.searchStatus = 3
        }
    }
    
    func initSearchInputView()
    {
        self.categorytableviewHeight = self.screenHeight - self.topSpaceToSafeArea - searchBoxTopWithTitle - keyboardHeight - keyboardTop - searchFieldHeight
        

        self.lblCategory.text = ""
        self.lblCategoryWidth.constant = 0.0
        self.imgArrow.image = UIImage(named: "btnarrow")
        self.imgArrow.transform = CGAffineTransform(rotationAngle: .pi/2)
       
        self.txtSearch.becomeFirstResponder()
        

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.viewSearchResultContainerHeight.constant = 0
            
            //self.btnContainerWidth.constant = 54
            self.lblTitle.isHidden = false
            self.viewLogo.isHidden = true
            self.collectionView_Category.isHidden = false
            self.viewSearchIconTop.constant = -50.0
            
            self.view.layoutIfNeeded()
            
        }) { (isCompleted) in
            self.collectionView_Category.reloadData()
            //self.viewCategoryContainer.isHidden = false
            self.searchStatus = 2
        }
    }
    
    func initSearchView()
    {
        self.array_result = []
        self.tbl_searchResult.reloadData()
        
        //self.viewCategoryContainer.isHidden = true
        self.txtSearch.text = ""
        
        self.txtSearch.resignFirstResponder()
        self.imgArrow.image = UIImage(named: "btnarrow")
        self.imgArrow.transform = CGAffineTransform(rotationAngle: 0)
        self.lblCategory.text = ""
        
        //self.btnContainerWidth.constant = screenWidth - searchBoxLeftRightSpace
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.viewSearchResultContainerHeight.constant = 0
           
            self.view.layoutIfNeeded()
            
        }) { (isCompleted) in
            self.lblTitle.isHidden = false
            self.viewLogo.isHidden = false
            self.collectionView_Category.isHidden = true
            self.viewSearchIconTop.constant = 150.0
            self.searchStatus = 1
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.keyboardHeight = keyboardRectangle.height
        }
    }
    
    func searchDatas()
    {
        self.initSearchResultView()

        self.array_result = []

        var params:[String:String] = [:]
        var api_url:String = ""
        
        if(self.selectedCategory == "My ATB")
        {
            api_url = GET_ALL_FEED_API
            
            params = [
                "token" : g_myToken,
                "search_key" : self.txtSearch.text!
            ]
            
        }
        else
        {
            api_url = GET_SELECTED_FEED_API
            
            params = [
                "token" : g_myToken,
                "category_title" : self.selectedCategory,
                "search_key" : self.txtSearch.text!
            ]
        }
        
        _ = ATB_Alamofire.POST(api_url, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            self.view.isUserInteractionEnabled = true
            print(responseObject)
            
            if(result)
            {
                let postDicts = responseObject.object(forKey: "extra")  as? [NSDictionary] ?? []
                
                //get post model array and reload
                for postDict in postDicts
                {
                    let newPostModel = PostModel(info: postDict)
                    self.array_result.append(newPostModel)
                }
                self.tbl_searchResult.reloadData()
                self.tbl_searchResult.scroll(to: .top, animated: false)
            }
            else
            {
                let msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if(msg == "")
                {
                    self.showErrorVC(msg: "Getting posts error!")
                }
                else
                {
                    self.showErrorVC(msg: "Server returned the error message: " + msg)
                }
            }
        }
    }
}

extension SearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(self.txtSearch.text != "")
        {
            self.txtSearch.resignFirstResponder()
            return true
        }
        else
        {
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if(self.txtSearch.text != "")
        {
            self.searchDatas()
        }
        print("End!!!")
    }
}

extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SearchCategoryCellDelegate {
    
    func OnClickSearchCategory(index: Int) {
        self.selectedCategory = feedGroups[index].name
        feedGroups[index].isSelected = true
        
        
        
        for (innerIdx, element) in feedGroups.enumerated() {
            if element.name != feedGroups[index].name {
                feedGroups[innerIdx].isSelected = false
            }
        }
        
        self.collectionView_Category.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCategoryCollectionViewCell",
                                                          for: indexPath) as! SearchCategoryCollectionViewCell
        categoryCell.cellDelegate = self
        let strCategory = feedGroups[indexPath.row]
        
        categoryCell.configureWithData(categoryData: strCategory, index: indexPath.row, search:true)

        return categoryCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenHeight = collectionView.frame.height
        let cellHeight:CGFloat = 60
        let cellWidth = (screenWidth - searchBoxLeftRightSpace - 10) / 2
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10
    }
}

extension SearchVC: UITableViewDataSource, UITableViewDelegate, postTableCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array_result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postData = self.array_result[indexPath.row]
        
        if(postData.Post_Media_Type == "Text")
        {
            let txtPostCell = tableView.dequeueReusableCell(withIdentifier: "TextPostTableViewCell",
                                                            for: indexPath) as! TextPostTableViewCell
            txtPostCell.configureWithData(model: postData, index: indexPath.row)
            txtPostCell.cellDelegate = self
            return txtPostCell
        }
        else
        {
            let mediaPostCell = tableView.dequeueReusableCell(withIdentifier: "MediaPostTableViewCell",
                                                              for: indexPath) as! MediaPostTableViewCell
            mediaPostCell.configureWithData(model: postData, index: indexPath.row)
            mediaPostCell.cellDelegate = self
            return mediaPostCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var headerHeight:CGFloat = 0.0
        
        switch (section){
        case 0:
            headerHeight = 10.0
            break
        default:
            headerHeight = 0.0
            break
        }
        
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var footerHeight:CGFloat = 0.0
        
        switch (section){
        case 0:
            footerHeight = 10.0
            break
        default:
            footerHeight = 0.0
            break
        }
        
        return footerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 10))
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 10))
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        var cellHeight:CGFloat = 160.0
        
        if(self.array_result[indexPath.row].Post_Type == "Advice")
        {
            cellHeight = 140
        }
        
        if(self.array_result[indexPath.row].Post_Media_Type != "Text")
        {
            let imgHeight = ( screenWidth - 30 ) / 8 * 9
            cellHeight = cellHeight + CGFloat(imgHeight) + 10
        }
        
        return cellHeight
    }
    
    func clickedOnCell(postData: PostModel, index: Int) {
        self.getPostDetail(postData: postData)
    }
    
    func getPostDetail(postData: PostModel)
    {
        let postdetailmodel = PostDetailModel()
        postdetailmodel.Post_Summerize = postData
        
        let params = [
            "token" : g_myToken,
            "post_id" : postData.Post_ID
        ]
        print(params)
        _ = ATB_Alamofire.POST(GET_POST_DETAIL_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            self.view.isUserInteractionEnabled = true
            print(responseObject)
            
            if(result)
            {
                let postDetailDict = responseObject.object(forKey: "extra") as! NSDictionary
                let userArray = postDetailDict.object(forKey: "user") as! NSArray
                let userDict = userArray[0] as! NSDictionary
                // let businessDict = userDict["business_info"]
                
                let posterInfo:UserModel = UserModel()
                
                if (postData.Poster_Account_Type == "Business") {
                    let businessDict = userDict["business_info"] as! NSDictionary
                    let business = BusinessModel(info: businessDict)
                    
                    posterInfo.business_profile = business
                }
                
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
                
                let commentDicts = postDetailDict.object(forKey: "comments") as? [NSDictionary] ?? []
                
                var commentArray:[CommentModel] = []
                for commentDict in commentDicts
                {
                    let newComment = CommentModel(info: commentDict)
                    commentArray.append(newComment)
                }
                postdetailmodel.Comments = commentArray
                
                self.getComments(postId: postData.Post_ID, postdetailmodel: postdetailmodel)
            }
            else
            {
                let msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if(msg == "")
                {
                    self.showErrorVC(msg: "Failed to download the details of this post please try again")
                }
                else
                {
                    self.showErrorVC(msg: "Server returned the error message: " + msg)
                }
            }
        }
    }
    
    func getComments(postId: String, postdetailmodel: PostDetailModel) {
        
        APIManager.shared.getComments(forPost: postId, token: g_myToken) { status, message, allComments in
            
            guard let comments = allComments else {
                if let message = message {
                    self.showErrorVC(msg: "Server returned the error message: " + message)
                    
                } else {
                    self.showErrorVC(msg: "Failed to get comments for this post")
                }
                
                return
            }
            let toVC = PostDetailViewController()
            toVC.selectedPost = postdetailmodel
            toVC.comments = comments
            toVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(toVC, animated: true)
        }
    }
}


