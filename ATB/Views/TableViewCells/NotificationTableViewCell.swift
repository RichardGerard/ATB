//  NotificationTableViewCell.swift
//  ATB
//
//  Created by mobdev on 2019/5/23.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    var notification:NotificationModel = NotificationModel()
    
    @IBOutlet weak var imgProfileVIew: RoundImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var notificationDetail: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    func configureCell(_ notification: NotificationModel) {
        imgProfileVIew.loadImageFromUrl(notification.profile_image, placeholder: "profile.placeholder")
        notificationDetail.text = notification.text
        lblTime.text = notification.created
        lblName.text = notification.name
    }
}
