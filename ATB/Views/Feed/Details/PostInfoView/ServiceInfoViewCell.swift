//
//  ServiceInfoViewCell.swift
//  ATB
//
//  Created by YueXi on 9/11/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

// MARK: ServiceInfoViewDelegate
protocol ServiceInfoViewDelegate {
    
    func didTapDeposit()
    func didTapCancellations()
    func didTapArea()
    func didTapInsurance()
    func didTapQualification()
}

class ServiceInfoViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ServiceInfoViewCell"
    
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 23)
        lblTitle.textColor = .colorGray5
        lblTitle.numberOfLines = 0
        }}
    @IBOutlet weak var lblDescription: UILabel! { didSet {
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray5
        lblDescription.numberOfLines = 0
        }}
    
    @IBOutlet var vDetailContainers: [UIView]!
        
    @IBOutlet weak var lblPriceTitle: UILabel! { didSet {
        lblPriceTitle.text = "Price, starting from"
        lblPriceTitle.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblPriceTitle.textColor = .colorGray21
        }}
    @IBOutlet weak var lblPrice: UILabel! { didSet {
        lblPrice.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblPrice.textColor = .colorGray5
        }}

    @IBOutlet weak var lblDepositTitle: UILabel! { didSet {
        lblDepositTitle.text = ""
        lblDepositTitle.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDepositTitle.textColor = .colorGray21
        }}
    @IBOutlet weak var lblDeposit: UILabel! { didSet {
        lblDeposit.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblDeposit.textColor = .colorGray5
        }}

    @IBOutlet weak var lblCancellationsTitle: UILabel! { didSet {
        lblCancellationsTitle.text = ""
        lblCancellationsTitle.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblCancellationsTitle.textColor = .colorGray21
        }}
    @IBOutlet weak var lblCancellations: UILabel! { didSet {
        lblCancellations.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblCancellations.textColor = .colorGray5
        }}
    
    @IBOutlet weak var lblAreaTitle: UILabel! { didSet {
        lblAreaTitle.text = "Area Covered"
        lblAreaTitle.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblAreaTitle.textColor = .colorGray21
        }}
    @IBOutlet weak var lblArea: UILabel! { didSet {
        lblArea.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblArea.textColor = .colorPrimary
        lblArea.textAlignment = .right
        lblArea.lineBreakMode = .byTruncatingMiddle
        }}

    @IBOutlet weak var lblInsuranceTitle: UILabel! { didSet {
        lblInsuranceTitle.text = "Insured"
        lblInsuranceTitle.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblInsuranceTitle.textColor = .colorGray21
        }}
    @IBOutlet weak var lblInsurance: UILabel! { didSet {
        lblInsurance.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblInsurance.textColor = .colorGray5
        }}

    @IBOutlet weak var lblQualificationTitle: UILabel! { didSet {
        lblQualificationTitle.text = "Qualified"
        lblQualificationTitle.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblQualificationTitle.textColor = .colorGray21
        }}
    @IBOutlet weak var lblQualification: UILabel! { didSet {
        lblQualification.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblQualification.textColor = .colorGray5
        }}
    
    var delegate: ServiceInfoViewDelegate? = nil
    
    private let attributedYes: NSAttributedString = {
        var attributedString = NSMutableAttributedString(string: "Yes ")
        let sealAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            sealAttachment.image = UIImage(systemName: "checkmark.seal.fill")?.withTintColor(.colorGray5)
        } else {
            // Fallback on earlier versions
        }
        attributedString.append(NSAttributedString(attachment: sealAttachment))
        
        return attributedString
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        for view in vDetailContainers {
            view.backgroundColor = .colorGray4
            view.layer.cornerRadius = 7
            view.layer.masksToBounds = true
        }
        
        let infoAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            infoAttachment.image = UIImage(systemName: "info.circle")?.withTintColor(.colorGray21)
        } else {
            // Fallback on earlier versions
        }
        
        let attrDeposit = NSMutableAttributedString(string: "Needs a deposit of ")
        attrDeposit.append(NSAttributedString(attachment: infoAttachment))
        lblDepositTitle.attributedText = attrDeposit
        
        let attrCancellations = NSMutableAttributedString(string: "Cancellations Within ")
        attrCancellations.append(NSAttributedString(attachment: infoAttachment))
        lblCancellationsTitle.attributedText = attrCancellations
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        lblTitle.text = ""
        lblDescription.text = ""
        
        lblPrice.text = ""
        lblDeposit.text = ""
        lblCancellations.text = ""
        lblArea.text = ""
        lblInsurance.text = "No"
        lblQualification.text = "No"
    }
    
    func configureCell(_ post: PostModel) {
        lblTitle.text = post.Post_Title.capitalizingFirstLetter
        lblDescription.text = post.Post_Text
        lblPrice.text = "£" + post.Post_Price
        lblDeposit.text = "£" + post.Post_Deposit.floatValue.priceString
        lblCancellations.text = post.cancellations + " days"
        // to display only country name
        lblArea.attributedText = NSAttributedString(string: post.Post_Location, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
//        lblArea.text = post.Post_Location.components(separatedBy: ",").last!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if post.isInsured {
            lblInsurance.attributedText = attributedYes
            
        } else {
            lblInsurance.text = "No"
        }
        
        if post.isQualified {
            lblQualification.attributedText = attributedYes
            
        } else {
            lblQualification.text = "No"
        }        
    }
    
    @IBAction func didTapDeposit(_ sender: Any) {
        delegate?.didTapDeposit()
    }

    @IBAction func didTapCancellations(_ sender: Any) {
        delegate?.didTapCancellations()
    }
    
    @IBAction func didTapArea(_ sender: Any) {
        delegate?.didTapArea()
    }
    
    @IBAction func didTapInsurance(_ sender: Any) {
        delegate?.didTapInsurance()
    }
    
    @IBAction func didTapQualification(_ sender: Any) {
        delegate?.didTapQualification()
    }
    
    class func sizeForItem(_ post: PostModel) -> CGSize {
        let preferredWidth = SCREEN_WIDTH - 32
        // top padding
        var height: CGFloat = 10
        // title height
        height += post.Post_Title.heightForString(preferredWidth, font: UIFont(name: Font.SegoeUISemibold, size: 23)).height
        
        // description height
        // description top margin
        height += 4
        height += post.Post_Text.heightForString(preferredWidth, font: UIFont(name: Font.SegoeUILight, size: 15)).height
        // description bottom margin
        height += 8
        
        // attributes
        height += 280

        // separator
        height += 11
        
        height += 4 // an experienced value
        
        return CGSize(width: SCREEN_WIDTH, height: height)
    }
}
