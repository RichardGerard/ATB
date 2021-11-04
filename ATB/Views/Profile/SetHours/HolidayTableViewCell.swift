//
//  HolidayTableViewCell.swift
//  ATB
//
//  Created by YueXi on 11/7/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class HolidayTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "HolidayTableViewCell"
    
    @IBOutlet weak var shadowView: CardView! { didSet {
        shadowView.cornerRadius = 5
        shadowView.shadowOffsetHeight = 1.5
        shadowView.shadowRadius = 3
        shadowView.shadowOpacity = 0.22
    }}
    
    @IBOutlet weak var containerView: UIView! { didSet {
        containerView.layer.cornerRadius = 5
        containerView.layer.masksToBounds = true
    }}
    
    @IBOutlet weak var lblDate: UILabel! { didSet {
        lblDate.textColor = .colorPrimary
    }}
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 21)
        lblTitle.textColor = .colorGray2
        lblTitle.minimumScaleFactor = 0.85
        lblTitle.adjustsFontSizeToFitWidth = true
        lblTitle.lineBreakMode = .byTruncatingTail
    }}
    
    @IBOutlet weak var imvDelete: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvDelete.image = UIImage(systemName: "trash")
        } else {
            // Fallback on earlier versions
        }
        imvDelete.tintColor = .colorRed1
    }}
    
    var deleted: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ holiday: Holiday) {
        lblTitle.text = holiday.name

        guard let unixTimestamp = Double(holiday.dayOff) else {
            lblDate.text = ""
            return
        }
        
        let date = Date(timeIntervalSince1970: unixTimestamp)

        let dateString = date.toString("d'\(date.daySuffix())'", timeZone: .current)
        let monthString = date.toString("MMM", timeZone: .current)

        let dateText = dateString + "\n" + monthString
        let attributedDateText = NSMutableAttributedString(string: dateText)

        let dateRange = (dateText as NSString).range(of: dateString)
        attributedDateText.addAttributes([
            .font: UIFont(name: Font.SegoeUISemibold, size: 23)!
        ], range: dateRange)

        let monthRange = (dateText as NSString).range(of: monthString)
        attributedDateText.addAttributes([
            .font: UIFont(name: Font.SegoeUISemibold, size: 19)!
        ], range: monthRange)

        lblDate.attributedText = attributedDateText
        lblDate.numberOfLines = 2
        lblDate.setLineSpacing(lineHeightMultiple: 0.8)
        lblDate.textAlignment = .center
    }
    
    @IBAction func didTapDelete(_ sender: Any) {
        deleted?()
    }

}
