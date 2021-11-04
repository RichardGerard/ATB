//
//  MyFeedSelectionVC.swift
//  ATB
//
//  Created by mobdev on 2019/5/14.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import RAMAnimatedTabBarController

class MyFeedSelectionVC: UIViewController, UITableViewDataSource, UITableViewDelegate, FeedCellDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblFeeds: UITableView!
    @IBOutlet weak var btnConfirm: RoundedShadowButton!
    
    var FeedItems:[FeedModel] = []
    var isLoading:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initViews()
        
        let strFeeds:[String] = ["Beauty", "Ladieswear", "Menswear", "Hair", "Kids", "Home", "Events", "Health & Well-Being", "Seasonal", "General"]
        
        for i in 0..<10
        {
            let newATBModel = FeedModel()
            newATBModel.Title = strFeeds[i]
            newATBModel.ID = String(i + 1)
            newATBModel.Checked = false
            
            self.FeedItems.append(newATBModel)
        }
        self.tblFeeds.reloadData()
    }
    
    func initViews()
    {
        self.btnConfirm.isHidden = true
        let instructionText = (lblTitle.text)!
        let boldAttributeString = NSMutableAttributedString(string: instructionText)
        let attributableRange = (instructionText as NSString).range(of: "ATB feed")

        boldAttributeString.addAttribute(.font, value: UIFont(name: "SegoeUI-SemiBold", size: 25.0)!, range: attributableRange)
        lblTitle.attributedText = boldAttributeString
        
        //color and font change
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isLoading = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if(isLoading)
        {
            self.showAnimateTable()
        }
    }
    
    @IBAction func onClickConfirm(_ sender: RoundedShadowButton) {
        let selectedItems = self.FeedItems.filter{$0.Checked == true}
        
        if(selectedItems.count >= 1)
        {
            let selectedItems = self.FeedItems.filter{$0.Checked == true}
            
            var feeds:String = ""
            for selectedItem in selectedItems
            {
                if(feeds == "")
                {
                    feeds = selectedItem.ID
                }
                else
                {
                    feeds = feeds + "," + selectedItem.ID
                }
            }
            
            self.UpdateFeed(feedString:feeds)
        }
    }
    
    func UpdateFeed(feedString:String)
    {
        let params = [
            "token" : g_myToken,
            "feeds" : feedString
            ] as [String : Any]
        
        _ = ATB_Alamofire.POST(UPDATE_FEED_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            self.view.isUserInteractionEnabled = true
            print(responseObject)
            
            if(result)
            {
                self.btnConfirm.isHidden = true
                self.hideAnimateTable()
            }
            else
            {
                let msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if(msg == "")
                {
                    self.showErrorVC(msg: "Update feed error!")
                }
                else
                {
                    self.showErrorVC(msg: "Server returned the error message: " + msg)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.FeedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tblCell = tableView.dequeueReusableCell(withIdentifier: "MyFeedTableViewCell", for: indexPath) as! MyFeedTableViewCell
        
        tblCell.configureWithData(model: self.FeedItems[indexPath.row], index: indexPath.row)
        tblCell.feedcellDelegate = self
        
        return tblCell
    }
    
    func clickedOnFeedCell(index: Int, selected: Bool) {
        self.FeedItems[index].Checked = selected
        
        let selectedItems = self.FeedItems.filter{$0.Checked == true}
        var btnTitle = ""
        
        if(selectedItems.count == 0)
        {
            btnTitle = "Confirm Selection"
        }
        else
        {
            btnTitle = "Confirm " + String(selectedItems.count) + " Selection"
        }

        UIView.animate(withDuration: 0.05, delay: 0, options: .curveLinear, animations: {
            self.btnConfirm.setTitle(btnTitle, for: .normal)
        }) { (isCompleted) in
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 0.08 + 10
    }
    
    func showAnimateTable()
    {
        self.tblFeeds.reloadData()
        
        let cells = tblFeeds.visibleCells

        let tableWidth = tblFeeds.frame.size.width
        
        for i in cells
        {
            let cell:UITableViewCell = i
            cell.transform = CGAffineTransform(translationX: tableWidth, y: 0)
        }
        
        var index = 0
        
        for a in cells
        {
            let cell:UITableViewCell = a
            index = index + 1
            
            UIView.animate(withDuration: 0.3, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .transitionFlipFromRight, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
            }) { _ in
                self.btnConfirm.isHidden = false
                self.isLoading = false
            }
        }
    }
    
    func hideAnimateTable()
    {
        let cells = tblFeeds.visibleCells
        let tableWidth = tblFeeds.frame.size.width
        var index = 0
        var completed = 0
        for a in cells
        {
            let cell:UITableViewCell = a
            index = index + 1
            
            UIView.animate(withDuration: 0.2, delay: 0.05 * Double(index), usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .transitionFlipFromRight, animations: {
                cell.transform = CGAffineTransform(translationX: -tableWidth, y: 0)
            }) { _ in
                completed = completed + 1
                if(completed == cells.count)
                {
                    let mainNav = self.storyboard?.instantiateViewController(withIdentifier: "MainNav") as! UINavigationController
                    UIApplication.shared.keyWindow?.rootViewController = mainNav
                }
            }
        }
    }
}

