//
//  CommentViewModel.swift
//  ATB
//
//  Created by YueXi on 4/13/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

// MARK: - @Protocol: CommentDisplayable
protocol CommentDisplayable {
    var imageUrl: String { get }
    var likeDisplay: String { get }
    var userNameDisplay: String { get }
    var commentDisplay: String { get }
}

class ReplyModel: Codable {
    let id: String
    let commentID: String
    let replyUserId: String
    let replyType: String
    let reply: String
    let mediaUrls: [String]
    let createdTimeMilliSeconds: String
    let created: String
    let userImageUrl: String?
    var liked: Bool?
    let likes: Int?
    var userName: String?
    var hidden: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case commentID = "comment_id"
        case replyUserId = "reply_user_id"
        case replyType = "reply_type"
        case reply
        case mediaUrls = "data"
        case createdTimeMilliSeconds = "created_at"
        case created = "read_created"
        case userImageUrl = "user_img"
        case liked
        case likes = "like_count"
        case userName = "user_name"
        case hidden = "hidden"
    }
}

// MARK: - Extension: ReplyDisplayable
extension ReplyModel: CommentDisplayable {
    var imageUrl: String {
        return userImageUrl ?? ""
    }
    
    var likeDisplay: String {
        if let likes = likes, likes > 0 {
            return likes == 1 ? "\(likes) like" : "\(likes) likes"
 
        } else {
            return ""
        }
    }
    
    var userNameDisplay: String {
        return userName ?? ""
    }
    
    var commentDisplay: String {
        return reply.decodedString
    }
}

class CommentViewModel: Codable  {
    let id: String
    let postID: String
    let comment: String
    let commentUserId: String
    let commentType: String
    let mediaUrls: [String]
    let level: String
    let parentUserID: String?
    let parentCommentID: String?
    let parentUsername: String?
    let createdTimeMilliSeconds: String
    let userImageUrl: String?
    let replies: [ReplyModel]
    let created: String
    var liked: Bool?
    var hidden: Bool?
    let likes: Int?
    var userName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case postID = "post_id"
        case comment
        case commentUserId = "commenter_user_id"
        case commentType = "comment_type"
        case mediaUrls = "data"
        case level
        case parentUserID = "parent_user_id"
        case parentCommentID  = "parent_comment_id"
        case parentUsername = "parent_user_name"
        case createdTimeMilliSeconds = "created_at"
        case userImageUrl = "user_img"
        case replies
        case created = "read_created"
        case likes = "like_count"
        case liked
        case hidden
        case userName = "user_name"
    }
}

// MARK: - Extension: CommentDisplayable
extension CommentViewModel: CommentDisplayable {
    var imageUrl: String {
        return userImageUrl ?? ""
    }
    
    var likeDisplay: String {
        if let likes = likes, likes > 0 {
           return likes == 1 ? "\(likes) like" : "\(likes) likes"

       } else {
           return ""
       }
   }
    
    var userNameDisplay: String {
        return userName ?? ""
    }
    
    var commentDisplay: String {
        return comment.decodedString
    }
}
