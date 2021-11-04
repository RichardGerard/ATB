//
//  CommentTableViewCell.swift
//  ATB
//
//  Created by mobdev on 2019/5/22.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import ReadMoreTextView

protocol CommentTableViewCellDelegate {
    func onClickReply(index:Int)
    func onClickViewReplies(index:Int)
}

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblCommentorName: UILabel!
    @IBOutlet weak var lblCommentTime: UILabel!
    @IBOutlet weak var txtComment: ReadMoreTextView!
    @IBOutlet weak var lblReplyCount: UILabel!
    @IBOutlet weak var imgShowHide: UIImageView!
    @IBOutlet weak var lblReply: UILabel!
    @IBOutlet weak var btnReply: UIButton!
    @IBOutlet weak var btnShowReplies: UIButton!
    
    var commentCellDelegate:CommentTableViewCellDelegate!
    var commentData:CommentModel = CommentModel()
    var index:Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
    
    func configureWithData(model:CommentModel, index:Int)
    {
        self.commentData = model
        self.index = index
    }
    
    @IBAction func onBtnShowHide(_ sender: UIButton) {
        self.commentCellDelegate.onClickViewReplies(index:self.index)
    }
    
    @IBAction func onBtnReply(_ sender: UIButton) {
        self.commentCellDelegate.onClickReply(index:self.index)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        txtComment.onSizeChange = { _ in }
        txtComment.shouldTrim = true
    }
}
