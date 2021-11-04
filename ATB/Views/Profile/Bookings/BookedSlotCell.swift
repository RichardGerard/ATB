//
//  BookedSlotCell.swift
//  ATB
//
//  Created by YueXi on 10/25/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class BookedSlotCell: UITableViewCell {
    
    static let reuseIdentifier = "BookedSlotCell"
    
    // for shadow effect
    @IBOutlet weak var vCard: CardView! { didSet {
        vCard.cornerRadius = 4
        vCard.shadowOffsetHeight = 2
        vCard.shadowRadius = 2
        vCard.shadowOpacity = 0.22
    }}
    
    @IBOutlet weak var lblTime: UILabel! { didSet {
        lblTime.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblTime.textColor = .colorGray11
    }}
    
    @IBOutlet weak var vContainer: UIView! { didSet {
        vContainer.backgroundColor = .colorPrimary
        vContainer.layer.cornerRadius = 5
        vContainer.layer.masksToBounds = true
    }}
    
    @IBOutlet weak var imvProfile: ProfileView!
    @IBOutlet weak var lblServiceTitle: UILabel! { didSet {
        lblServiceTitle.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        lblServiceTitle.textColor = .white
    }}
    @IBOutlet weak var lblUsername: UILabel! { didSet {
        lblUsername.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblUsername.textColor = .white
    }}
    
    @IBOutlet weak var imvRightArrow: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvRightArrow.image = UIImage(systemName: "chevron.right")
        } else {
            // Fallback on earlier versions
        }
        imvRightArrow.tintColor = .white
    }}
    
    private let disabledView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(disabledView)
        bringSubviewToFront(disabledView)
        
        addConstraintWithFormat("H:|-16-[v0]-16-|", views: disabledView)
        addConstraintWithFormat("V:[v0(72)]-5-|", views: disabledView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ slot: BookingSlot, isEnabled: Bool = true) {
        disabledView.isHidden = isEnabled
        
        lblTime.text = slot.time.toDate("h:mm a")?.toString("h:mm a", timeZone: .current)
        
        guard let booking = slot.booking,
              let bookedUser = booking.user,
              let service = booking.service else { return }
        
        lblServiceTitle.text = service.Post_Title.capitalizingFirstLetter
        
        imvProfile.loadImageFromUrl(bookedUser.profile_image, placeholder: "profile.placeholder")
        
        if bookedUser.isNoneATBUser {
            lblUsername.text = bookedUser.name
            
        } else {
            let fullname = bookedUser.fullname + " . " + bookedUser.user_name
            let username = bookedUser.user_name
            let underlineAttrs: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor.white
            ]
            
            let underlineRange = (fullname as NSString).range(of: username)
            let attributedName = NSMutableAttributedString(string: fullname)
            attributedName.addAttributes(underlineAttrs, range: underlineRange)
            lblUsername.attributedText = attributedName
        }
    }
}
