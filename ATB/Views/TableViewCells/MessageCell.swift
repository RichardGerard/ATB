//
//  MessageCell.swift
//  IosCustomUiSdk
//
//  Created by Sunil on 28/09/18.
//  Copyright © 2018 Applozic. All rights reserved.
//

import Foundation
import UIKit
import Applozic
import Kingfisher

public class MessageCell: UITableViewCell {
    
    var message = ALMessage()
    
    private let avatarView: ProfileView = {
        let profileView = ProfileView()
        profileView.borderWidth = 2
        profileView.borderColor = .colorPrimary
        return profileView
    }()
    
    private let onlineStatusView: UIView = {
        let view = UIView()
        view.backgroundColor = .colorGreen
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Font.SegoeUIBold, size: 16)
        label.textColor = .colorGray1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Font.SegoeUILight, size: 15)
        label.textColor = .colorGray5
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Font.SegoeUILight, size: 11)
        label.textColor = .colorGray16
        label.textAlignment = .right
        return label
    }()
    
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .colorPrimary
        label.font = UIFont(name: Font.SegoeUIBold, size: 14)
        label.text = "0"
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.layer.cornerRadius = 13
        label.layer.masksToBounds = true
        return label
    }()
    
    private var separateLine: UIView = {
        let view = UIView()
        view.backgroundColor = .colorGray17
        return view
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        setupSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func setupSubviews() {
        // avatar view
        addSubview(avatarView)
        addConstraintWithFormat("H:|-16-[v0(56)]", views: avatarView)
        addConstraintWithFormat("V:[v0(56)]-10-|", views: avatarView)
        
        addSubview(onlineStatusView)
        onlineStatusView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            onlineStatusView.rightAnchor.constraint(equalTo: avatarView.rightAnchor, constant: -2),
            onlineStatusView.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: -2),
            onlineStatusView.widthAnchor.constraint(equalToConstant: 16),
            onlineStatusView.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        // badge label - unread message count
        addSubview(badgeLabel)
        addConstraintWithFormat("H:[v0(26)]-16-|", views: badgeLabel)
        addConstraintWithFormat("V:[v0(26)]-16-|", views: badgeLabel)
        
        addSubview(timeLabel)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            timeLabel.bottomAnchor.constraint(equalTo: badgeLabel.topAnchor, constant: -6),
        ])
        
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leftAnchor.constraint(equalTo: avatarView.rightAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: 8),
            nameLabel.rightAnchor.constraint(equalTo: timeLabel.leftAnchor, constant: -8),
        ])
        
        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor),
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0),
            messageLabel.rightAnchor.constraint(equalTo: timeLabel.leftAnchor, constant: -8),
        ])
        
        addSubview(separateLine)
        addConstraintWithFormat("H:|-16-[v0]-16-|", views: separateLine)
        addConstraintWithFormat("V:[v0(1)]|", views: separateLine)
    }
    
    func update(viewModel: ALMessage) {
        self.message = viewModel
        
        var channel = ALChannel()
        var contact = ALContact ()
        if self.message.groupId != nil {
            channel = ALChannelService.sharedInstance().getChannelByKey(self.message.groupId) as ALChannel
            avatarView.loadImageFromUrl(channel.channelImageURL, placeholder: "profile.placeholder")
            
            nameLabel.text = channel.name
            
            if channel.unreadCount != nil {
                let unreadMsgCount = channel.unreadCount.intValue
                let numberText: String = (unreadMsgCount < 1000 ? "\(unreadMsgCount)" : "999+")
                let isHidden = (unreadMsgCount < 1)
                
                badgeLabel.isHidden = isHidden
                badgeLabel.text = numberText
                
            } else {
                badgeLabel.isHidden = true
            }
            
        } else {
            contact = ALContactDBService().loadContact(byKey: "userId", value: message.contactIds)
            avatarView.loadImageFromUrl(contact.contactImageUrl ?? "", placeholder: "profile.placeholder")
            
            // get unread count of message and set badgenumber
            print("user status: - \(contact.userStatus)")
            
            if(contact.unreadCount != nil){
                let unreadMsgCount = contact.unreadCount.intValue
                let numberText: String = (unreadMsgCount < 1000 ? "\(unreadMsgCount)" : "999+")
                let isHidden = (unreadMsgCount < 1)
                
                badgeLabel.isHidden = isHidden
                badgeLabel.text = numberText
                
            } else {
                badgeLabel.isHidden = true
            }
            
            nameLabel.text = contact.displayName != nil ? contact.displayName : contact.userId
        }
        
        if message.fileMeta != nil {
            messageLabel.text = "Attachment"
            
        } else {
            if message.message.first == "{" {
                messageLabel.text = "Location"
                
            } else {
                messageLabel.text = message.message
            }
        }
        
        // date & time
        let date = Date(timeIntervalSince1970: Double(message.createdAtTime.doubleValue/1000))
        timeLabel.text =  message.getCreatedAtTime(ALUtilityClass.isToday(date))
    }
}



