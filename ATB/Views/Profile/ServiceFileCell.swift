//
//  ServiceFileCell.swift
//  ATB
//
//  Created by YueXi on 9/6/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class ServiceFileCell: UITableViewCell {
    
    static let reuseIdentifier = "ServiceFileCell"
        
    static let rowHeight: CGFloat = 76

    @IBOutlet weak var vContainer: UIView! { didSet {
        vContainer.layer.cornerRadius = 5
        vContainer.layer.masksToBounds = true
        }}
    @IBOutlet weak var imvLogo: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvLogo.image = UIImage(systemName: "checkmark.seal.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvLogo.tintColor = .colorPrimary
        imvLogo.contentMode = .center
        }}
    @IBOutlet weak var lblName: UILabel! { didSet {
        lblName.font = UIFont(name: "SegoeUI-Semibold", size: 18)
        lblName.textColor = .colorGray19
        }}
    @IBOutlet weak var lblExpiry: UILabel! { didSet {
        lblExpiry.font = UIFont(name: "SegoeUI-Semibold", size: 15)
        lblExpiry.textColor = .colorPrimary
        }}
    @IBOutlet weak var imvDelete: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvDelete.image = UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvDelete.tintColor = .colorRed1
        imvDelete.contentMode = .center
        }}
    
    var deleted: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ serviceFile: ServiceFileModel) {
        lblName.text = serviceFile.name
        lblExpiry.text = (serviceFile.isInsurance ? "Insurance Until " : "Qualified Since ") + serviceFile.expiry
    }

    @IBAction func didTapDelete(_ sender: UIButton) {
        deleted?()
    }
}
