//
//  ReplyTableViewCell.swift
//  ATB
//
//  Created by mobdev on 7/9/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import ReadMoreTextView

protocol ReplyTableViewCellDelegate {
    func onReplyonReply(parentIndex:Int, index:Int)
}

class ReplyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblReplierName: UILabel!
    @IBOutlet weak var lblReplyTime: UILabel!
    @IBOutlet weak var txtReply: ReadMoreTextView!
    @IBOutlet weak var btnReplyTitle: UILabel!
    @IBOutlet weak var btnReply: UIButton!
    
    var replyDeleagte:ReplyTableViewCellDelegate!
    var replyData:CommentModel = CommentModel()
    var index:Int = 0
    var parentCommentIndex:Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureWithData(model:CommentModel, index:Int)
    {
        self.replyData = model
        self.index = index
    }
    
    @IBAction func onBtnReply(_ sender: UIButton) {
        self.replyDeleagte.onReplyonReply(parentIndex: self.parentCommentIndex, index: self.index)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        txtReply.onSizeChange = { _ in }
        txtReply.shouldTrim = true
    }
}
