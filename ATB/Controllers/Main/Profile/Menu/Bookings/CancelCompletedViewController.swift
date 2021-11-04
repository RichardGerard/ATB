//
//  CancelCompletedViewController.swift
//  ATB
//
//  Created by YueXi on 10/19/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class CancelCompletedViewController: BaseViewController {
    
    static let kStoryboardID = "CancelCompletedViewController"
    class func instance() -> CancelCompletedViewController {
        let storyboard = UIStoryboard(name: "Bookings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: CancelCompletedViewController.kStoryboardID) as? CancelCompletedViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var heightForContainer: NSLayoutConstraint!
        
    @IBOutlet weak var imvCancel: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    var backtoBookingsBlock: (() -> Void)? = nil
    
    var isBusiness: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        heightForContainer.constant = SCREEN_HEIGHT
        setupViews()
    }
    
    private func setupViews() {
        if #available(iOS 13.0, *) {
            imvCancel.image = UIImage(systemName: "multiply.circle")
        } else {
            // Fallback on earlier versions
        }
        imvCancel.tintColor = .colorRed1
        
        lblTitle.text = "This booking has been\ncanceled"
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 25)
        lblTitle.textColor = .colorGray1
        lblTitle.numberOfLines = 0
        lblTitle.setLineSpacing(lineHeightMultiple: 0.75)
        lblTitle.textAlignment = .center
        
        lblDescription.text = isBusiness ? "Due to you do have cancel this booking,\nthe user will be having a full refund." : "You cancel this booking in the refund time, all\nthe payment will be refund."
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray5
        lblDescription.textAlignment = .center
        lblDescription.numberOfLines = 0
        
        if isBusiness {
            btnBack.setTitle("  Go back to bookings", for: .normal)
            btnBack.setTitleColor(.colorPrimary, for: .normal)
            btnBack.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 18)
            if #available(iOS 13.0, *) {
                btnBack.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            btnBack.tintColor = .colorPrimary
            btnBack.layer.cornerRadius = 5
            btnBack.layer.borderWidth = 1
            btnBack.layer.borderColor = UIColor.colorGray4.cgColor
            
        } else {
            let attributedTitle = NSAttributedString(string: "Go back to my bookings", attributes: [
                .foregroundColor: UIColor.colorPrimary,
                .font: UIFont(name: Font.SegoeUILight, size: 20)!,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor.colorPrimary
            ])
            btnBack.setAttributedTitle(attributedTitle, for: .normal)
        }
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        dismiss(animated: true) {
            self.backtoBookingsBlock?()
        }
    }
}
