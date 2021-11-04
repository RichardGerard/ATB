//
//  WriteCommentVC.swift
//  ATB
//
//  Created by mobdev on 29/8/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class WriteCommentVC: UIViewController{
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtComment: RoundShadowTextView!
    @IBOutlet weak var btnSave: RoundedShadowButton!
 
    var selectedPost:PostDetailModel = PostDetailModel()
    var parentVC:PostDetailViewController!
    
    var parentCommentorID:String = ""
    var parentCommentorName:String = ""
    var parentCommentID:String = ""
    var parentCommentIndex:Int = 0
    
    var isReply:Bool = false
    var isOpening:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if(isReply)
        {
            self.lblTitle.text = "Reply"
            self.txtComment.placeHolderText = "Write your reply here..."
        }
        else
        {
            self.lblTitle.text = "Comment"
            self.txtComment.placeHolderText = "Write your comment here..."
        }
        
        self.txtComment.cornerHeight = 25.0
        self.txtComment.textInnerSpace = 20.0
        self.txtComment.setManualCorner = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.view.layoutIfNeeded()
    }
    
    @IBAction func OnBtnSave(_ sender: UIButton) {
        if(self.isReply)
        {
            if(self.txtComment.isEmpty())
            {
                self.showErrorVC(msg: "Please input your reply.")
                return
            }
            
            let params = [
                "token" : g_myToken,
                "post_id" : self.selectedPost.Post_Summerize.Post_ID,
                "user_id" : self.selectedPost.Poster_Info.ID,
                "comment" : self.txtComment.text!,
                "parent_comment_id" : self.parentCommentID,
                "parent_user_id" : self.parentCommentorID,
                "parent_user_name" : self.parentCommentorName
            ]
            
            _ = ATB_Alamofire.POST(REPLY_COMMENT_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
                (result, responseObject) in
                self.view.isUserInteractionEnabled = true
                print(responseObject)
                
                if(result)
                {
                    if(self.isOpening)
                    {
                        let commentDict = responseObject.object(forKey: "extra") as! NSDictionary
                        
                        //
                        var commentID = commentDict.object(forKey: "id") as? String ?? ""
                        if(commentID == "")
                        {
                            let nCommentID = commentDict.object(forKey: "id") as? Int ?? 0
                            commentID = String(nCommentID)
                        }
                        let timedescription = commentDict.object(forKey: "read_created") as? String ?? ""
                        //
                        let newlyAddedComment = CommentModel()
                        newlyAddedComment.Comment_Text = self.txtComment.text!
                        newlyAddedComment.ID = commentID
                        newlyAddedComment.Comment_Time_Description = timedescription
                        //
                        let commentor = UserModel()
                        commentor.user_name = g_myInfo.userName
                        commentor.email_address = g_myInfo.emailAddress
                        commentor.ID = g_myInfo.ID
                        newlyAddedComment.Commentor_Info = commentor
                        
                        let parentCommentor = UserModel()
                        parentCommentor.user_name = self.parentCommentorName
                        parentCommentor.ID = self.parentCommentorID
                        newlyAddedComment.Parent_Commentor = parentCommentor
                        //
                        newlyAddedComment.Level = "1"
                        newlyAddedComment.Parent_Comment_ID = self.parentCommentID
                        
                        self.parentVC.comment_array.insert(newlyAddedComment, at: self.parentCommentIndex + 1)
                        let commentData = self.parentVC.comment_array[self.parentCommentIndex]
                        commentData.Reply_Count = String(Int(commentData.Reply_Count)! + 1)
                    }
                    else
                    {
                        let commentData = self.parentVC.comment_array[self.parentCommentIndex]
                        commentData.Reply_Count = String(Int(commentData.Reply_Count)! + 1)
                    }
                    
                    self.navigationController?.popViewController(animated: true)
                    
                    self.showSuccessVC(msg: "Your reply posted successfully!")
                }
                else
                {
                    let msg = responseObject.object(forKey: "msg") as? String ?? ""
                    
                    if(msg == "")
                    {
                        self.showErrorVC(msg: "Failed to post reply please try again")
                    }
                    else
                    {
                        self.showErrorVC(msg: "Server returned the error message: " + msg)
                    }
                }
            }
        }
        else
        {
            if(self.txtComment.isEmpty())
            {
                self.showErrorVC(msg: "Please input your comment.")
                return
            }
            
            let params = [
                "token" : g_myToken,
                "post_id" : self.selectedPost.Post_Summerize.Post_ID,
                "user_id" : self.selectedPost.Poster_Info.ID,
                "comment" : self.txtComment.text!,
            ]
            
            _ = ATB_Alamofire.POST(WRITE_COMMENT_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
                (result, responseObject) in
                self.view.isUserInteractionEnabled = true
                print(responseObject)
                
                if(result)
                {
                    let commentDict = responseObject.object(forKey: "extra") as! NSDictionary
                    
                    var commentID = commentDict.object(forKey: "id") as? String ?? ""
                    if(commentID == "")
                    {
                        let nCommentID = commentDict.object(forKey: "id") as? Int ?? 0
                        commentID = String(nCommentID)
                    }
                    let timedescription = commentDict.object(forKey: "read_created") as? String ?? ""
                    
                    let newlyAddedComment = CommentModel()
                    newlyAddedComment.Comment_Text = self.txtComment.text!
                    newlyAddedComment.ID = commentID
                    newlyAddedComment.Comment_Time_Description = timedescription
                    
                    let commentor = UserModel()
                    commentor.user_name = g_myInfo.userName
                    commentor.email_address = g_myInfo.emailAddress
                    commentor.ID = g_myInfo.ID
                    newlyAddedComment.Commentor_Info = commentor
                    
                    self.parentVC.comment_array.insert(newlyAddedComment, at: 0)
                    self.navigationController?.popViewController(animated: true)
                    self.showSuccessVC(msg: "Your comment posted successfully!")
                }
                else
                {
                    let msg = responseObject.object(forKey: "msg") as? String ?? ""
                    
                    if(msg == "")
                    {
                        self.showErrorVC(msg: "Failed to post comment, please try again")
                    }
                    else
                    {
                        self.showErrorVC(msg: "Server returned the error message: " + msg)
                    }
                }
            }
        }
    }
    
    @IBAction func OnBtnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
