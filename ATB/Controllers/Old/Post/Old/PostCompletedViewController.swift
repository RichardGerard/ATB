//
//  PostCompletedViewController.swift
//  ATB
//
//  Created by mobdev on 2019/5/31.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class PostCompletedViewController: BaseViewController {
    
    static let kStoryboardID = "PostCompletedViewController"
    class func instance() -> PostCompletedViewController {
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: PostCompletedViewController.kStoryboardID) as? PostCompletedViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imgHeightRatio: NSLayoutConstraint!
    @IBOutlet weak var lblCategoryTitle: UILabel!
    @IBOutlet weak var postImgView: UIImageView!
    @IBOutlet weak var postTypeImgView: UIImageView!
    @IBOutlet weak var lblPostBrief: UILabel!
    @IBOutlet weak var lblExplorerGuide: UILabel!
    
    var postCategory:String = ""
    var postType:String = ""
    var postContent:String = ""
    var mediaType:String = ""
    var postMedia:UIImage = UIImage()
    var postCreateDelegate:PostCreateDelegate!
    
    override func viewDidLoad() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainNav = storyboard.instantiateViewController(withIdentifier: "MainNav") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = mainNav
        
        
        // Do any additional setup after loading the view, typically from a nib.
        if(self.mediaType == "Video" || self.mediaType == "Image")
        {
            self.imgHeightRatio.constant = 16/9
            postImgView.contentMode = .scaleAspectFill
            postImgView.image = self.postMedia
        }
        else
        {
            self.imgHeightRatio.constant = 10000
        }
        
        setupCategoryTitleAttributeText()
        setupPostContent()
        setupExplorerGuideAttributeText()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.layoutIfNeeded()
    }
    
    func setupCategoryTitleAttributeText()
    {
        let titleText = "in " + self.postCategory + " category"
        let categoryTitle = titleText + " >"
        let underlineAttributeString = NSMutableAttributedString(string: categoryTitle)
        
        underlineAttributeString.addAttribute(.font, value:  UIFont(name: "SegoeUI-Light", size: 18.0)!, range: NSMakeRange(0, underlineAttributeString.length))
        
        let underlineRange = (categoryTitle as NSString).range(of: titleText)
        
        underlineAttributeString.addAttribute(NSAttributedString.Key.underlineStyle, value:NSUnderlineStyle.single.rawValue, range: underlineRange)
        
        self.lblCategoryTitle.attributedText = underlineAttributeString
        self.lblCategoryTitle.isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.TapOnLblCategory(sender:)))
        self.lblCategoryTitle.addGestureRecognizer(recognizer)
    }
    
    @objc func TapOnLblCategory(sender:UITapGestureRecognizer) {
        let text = (lblCategoryTitle.text)!
        let titleText = "in " + self.postCategory + " category"
        let titleRange = (text as NSString).range(of: titleText)
        
        if sender.didTapAttributedTextInLabel(label: lblCategoryTitle, inRange: titleRange) {
            self.gotoCategory()
        }
    }
    
    func setupPostContent()
    {
        let postText = g_myInfo.userName + " " + self.postContent
        let boldText = g_myInfo.userName
        
        let boldAttributedString = NSMutableAttributedString(string: postText)
        let boldRange = (postText as NSString).range(of: boldText)
        
        boldAttributedString.addAttribute(.font, value: UIFont(name: "SegoeUI-Bold", size: 18.0)!, range: boldRange)
        self.lblPostBrief.attributedText = boldAttributedString
    }
    
    func setupExplorerGuideAttributeText()
    {
        let guideText = "Your product has been posted.\nShare this new post or explore the category."
        let underlineText = "explore the category"
        let underlineAttributeString = NSMutableAttributedString(string: guideText)
        
        underlineAttributeString.addAttribute(.font, value:  UIFont(name: "SegoeUI-Light", size: 18.0)!, range: NSMakeRange(0, underlineAttributeString.length))
        
        let underlineRange = (guideText as NSString).range(of: underlineText)
        
        underlineAttributeString.addAttribute(NSAttributedString.Key.underlineStyle, value:NSUnderlineStyle.single.rawValue, range: underlineRange)
        self.lblExplorerGuide.attributedText = underlineAttributeString
        self.lblExplorerGuide.isUserInteractionEnabled = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.TapOnLblGuide(sender:)))
        self.lblExplorerGuide.addGestureRecognizer(recognizer)
    }
    
    @objc func TapOnLblGuide(sender:UITapGestureRecognizer) {
        let text = (lblExplorerGuide.text)!
        let underlinedText = "explore the category"
        let underlinedRange = (text as NSString).range(of: underlinedText)
        
        if sender.didTapAttributedTextInLabel(label: lblExplorerGuide, inRange: underlinedRange) {
            self.gotoCategory()
        }
    }
    
    func gotoCategory()
    {
        /*let mainVC = self.navigationController?.presentingViewController as! MainTabBarVC
        self.postCreateDelegate = mainVC
        let selectedCategory = FeedModel()
        
        let categoryID = g_StrFeeds.firstIndex(of: self.postCategory)
        if(categoryID != nil)
        {
            selectedCategory.ID = String(categoryID! + 1)
        }
        selectedCategory.Title = self.postCategory
        self.postCreateDelegate.newPostCreated(selectedCategory: selectedCategory)*/
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBtnClose(_ sender: Any) {
        /*let mainVC = self.navigationController?.presentingViewController as! MainTabBarVC
        if(mainVC.selectedIndex == 0)
        {
            self.postCreateDelegate = mainVC
            let selectedCategory = FeedModel()
            
            let categoryID = g_StrFeeds.firstIndex(of: self.postCategory)
            if(categoryID != nil)
            {
                selectedCategory.ID = String(categoryID! + 1)
            }
            selectedCategory.Title = self.postCategory
            self.postCreateDelegate.newPostCreated(selectedCategory: selectedCategory)
        }*/
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func OnBtnFB(_ sender: UIButton) {
        
    }
}
