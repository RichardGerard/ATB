//
//  CommentModel.swift
//  ATB
//
//  Created by mobdev on 2019/5/21.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation

class CommentModel {
    
    var ID:String = ""
    var Comment_Text:String = ""
    var Comment_Time_Description:String = ""
    var Commentor_Info:UserModel = UserModel()
    var Reply_Count:String = ""
    var Level:String = ""
    var Parent_Commentor:UserModel = UserModel()
    var isReplyOpening:Bool = false
    var Parent_Comment_ID:String = ""
    
    var parentIndex:Int = 0
    
    init(info:NSDictionary) {
        var strID = info.object(forKey: "id") as? String ?? ""
        if(strID == "")
        {
            let nID = info.object(forKey: "id") as? Int ?? 0
            strID = String(nID)
        }
        self.ID = strID
        let strComment = info.object(forKey: "comment") as? String ?? ""
        self.Comment_Text = strComment
        let strCommentTime = info.object(forKey: "read_created") as? String ?? ""
        self.Comment_Time_Description = strCommentTime
        
        self.Commentor_Info = UserModel()
        var strCommentorID = info.object(forKey: "commenter_user_id") as? String ?? ""
        if(strCommentorID == "")
        {
            let nCommentorID = info.object(forKey: "commenter_user_id") as? Int ?? 0
            strCommentorID = String(nCommentorID)
        }
        self.Commentor_Info.ID = strCommentorID
        
        let commentorName = info.object(forKey: "user_name") as? String ?? ""
        self.Commentor_Info.user_name = commentorName
        
        self.Parent_Commentor = UserModel()
        var strParentCommentorID = info.object(forKey: "parent_user_id") as? String ?? ""
        if(strParentCommentorID == "")
        {
            let nParentCommentorID = info.object(forKey: "parent_user_id") as? Int ?? 0
            strParentCommentorID = String(nParentCommentorID)
        }
        self.Parent_Commentor.ID = strParentCommentorID
        
        let parentCommentorName = info.object(forKey: "parent_user_name") as? String ?? ""
        self.Parent_Commentor.user_name = parentCommentorName
        
        var strReplyCount = info.object(forKey: "count_child") as? String ?? ""
        if(strReplyCount == "")
        {
            let nReplyCount = info.object(forKey: "count_child") as? Int ?? 0
            strReplyCount = String(nReplyCount)
        }
        self.Reply_Count = strReplyCount
        
        var strLevel = info.object(forKey: "level") as? String ?? ""
        if(strLevel == "")
        {
            let nLevel = info.object(forKey: "level") as? Int ?? 0
            strLevel = String(nLevel)
        }
        self.Level = strLevel
        self.isReplyOpening = false
        
        var strParentCommentID = info.object(forKey: "parent_comment_id") as? String ?? ""
        if(strParentCommentID == "")
        {
            let nParentCommentID = info.object(forKey: "parent_comment_id") as? Int ?? 0
            strParentCommentID = String(nParentCommentID)
        }
        self.Parent_Comment_ID = strParentCommentID
    }
    
    init()
    {
        self.ID = ""
        self.Comment_Text = ""
        self.Comment_Time_Description = ""
        self.Commentor_Info = UserModel()
        self.Parent_Commentor = UserModel()
        self.Level = "0"
        self.Reply_Count = "0"
        self.isReplyOpening = false
        self.Parent_Comment_ID = ""
    }
}
