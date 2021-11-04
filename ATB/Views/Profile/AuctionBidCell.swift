//
//  AuctionBidCell.swift
//  ATB
//
//  Created by YueXi on 3/29/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit

class AuctionBidCell: UITableViewCell {
    
    static let reuseIdentifer = "AuctionBidCell"
    
    @IBOutlet weak var addContainer: RoundView!
    @IBOutlet weak var imvAdd: UIImageView!
    @IBOutlet weak var imvProfile: ProfileView!
    @IBOutlet weak var placeNumberContainer: RoundView!
    @IBOutlet weak var lblPlaceNumber: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var bidNumberContainer: UIView!
    @IBOutlet weak var lblBidNumber: UILabel!
    @IBOutlet weak var bidPriceContainer: UIView!
    @IBOutlet weak var priceTagContainer: UIView!
    @IBOutlet weak var imvPriceTag: UIImageView!
    @IBOutlet weak var bidPriceField: NoBorderTextField!
    @IBOutlet weak var btnBid: UIButton!
    
    var didTapBidNumber: (() -> Void)? = nil
    var didTapBid: (() -> Void)? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
        selectionStyle = .none
        
        setupSubviews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imvProfile.image = nil
    }
    
    private func setupSubviews() {
        addContainer.backgroundColor = .colorPrimary
        if #available(iOS 13.0, *) {
            imvAdd.image = UIImage(systemName: "plus.circle")
        } else {
            // Fallback on earlier versions
        }
        imvAdd.tintColor = .white
        
        imvProfile.borderWidth = 1
        imvProfile.borderColor = .colorPrimary
        
        placeNumberContainer.borderWidth = 1
        placeNumberContainer.borderColor = .white
        placeNumberContainer.backgroundColor = .colorGreen
        
        lblPlaceNumber.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblPlaceNumber.textColor = .white
        lblPlaceNumber.textAlignment = .center
        
        lblPrice.text = "£15.50"
        lblPrice.font = UIFont(name: Font.SegoeUISemibold, size: 22)
        lblPrice.textColor = .colorGray2
        lblPrice.minimumScaleFactor = 0.85
        lblPrice.adjustsFontSizeToFitWidth = true
        
        // add dash dots
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.colorPrimary.cgColor
        layer.lineDashPattern = [2, 2]
        layer.fillColor = nil
        layer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bidNumberContainer.bounds.width, height: bidNumberContainer.bounds.height), cornerRadius: 14).cgPath
        self.bidNumberContainer.layer.addSublayer(layer)
        
        lblBidNumber.layer.cornerRadius = 12
        lblBidNumber.backgroundColor = .colorPrimary
        lblBidNumber.layer.masksToBounds = true
        lblBidNumber.text = "12"
        lblBidNumber.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblBidNumber.textColor = .white
        lblBidNumber.textAlignment = .center        
        
        bidPriceContainer.layer.cornerRadius = 5
        bidPriceContainer.layer.borderWidth = 1
        bidPriceContainer.layer.borderColor = UIColor.colorGray17.cgColor
        bidPriceContainer.layer.masksToBounds = true
        
        priceTagContainer.layer.borderWidth = 1
        priceTagContainer.layer.borderColor = UIColor.colorGray17.cgColor
        priceTagContainer.backgroundColor = .colorGray14
        
        imvPriceTag.image = UIImage(named: "sterlingsign")?.withRenderingMode(.alwaysTemplate)
        imvPriceTag.tintColor = .colorGray17
        
        setupPriceField(bidPriceField)
        
        btnBid.backgroundColor = .colorPrimary
        btnBid.layer.cornerRadius = 5
        btnBid.setTitle("Bid", for: .normal)
        btnBid.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        btnBid.setTitleColor(.white, for: .normal)
    }
    
    private func setupPriceField(_ textField: NoBorderTextField) {
        textField.inputPadding = 4
        textField.font = UIFont(name: Font.SegoeUILight, size: 18)
        textField.textColor = .colorGray2
        textField.tintColor = .colorGray2
        textField.placeholder = "0.00"
        textField.textAlignment = .center
        textField.keyboardType = .decimalPad
    }
    
    func configureCell(_ auction: AuctionModel?, position: Int) {
        lblPlaceNumber.text = "\(position + 1)"
        
        if let top = auction {
            addContainer.isHidden = true
            
            if let user = top.user {
                let businessProfile = user.business_profile
                imvProfile.loadImageFromUrl(businessProfile.businessPicUrl, placeholder: "profile.placeholder")
            }
            
            lblPrice.text = "£" + top.price.priceString
            bidNumberContainer.isHidden = false
            lblBidNumber.text = "\(top.totalBids)"
            
            bidPriceField.text = (top.price + 0.5).priceString
            
        } else {
            addContainer.isHidden = false
            lblPrice.text = "£5.00"
//            lblBidNumber.text = "0"
            bidNumberContainer.isHidden = true
            
            bidPriceField.text = (5.0).priceString
        }
    }
    
    func configureCell(_ ranking: Int) {
        addContainer.isHidden = true
        
        imvProfile.image = UIImage(named: "prototype.manicure.logo")
        
        lblPlaceNumber.text = "\(ranking)"
        
        bidPriceField.text = "5.50"
    }
    
    func setTextFieldDelegate(_ delegate: UITextFieldDelegate, indexPath: IndexPath) {
        bidPriceField.delegate = delegate
    }
    
    @IBAction func didTapBidNumber(_ sender: Any) {
        didTapBidNumber?()
    }
    
    @IBAction func didTapBid(_ sender: Any) {
        didTapBid?()
    }
}


