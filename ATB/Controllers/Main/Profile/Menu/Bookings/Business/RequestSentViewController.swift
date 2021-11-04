//
//  RequestSentViewController.swift
//  ATB
//
//  Created by YueXi on 11/2/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class RequestSentViewController: BaseViewController {
    
    static let kStoryboardID = "RequestSentViewController"
    class func instance() -> RequestSentViewController {
        let storyboard = UIStoryboard(name: "Bookings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: RequestSentViewController.kStoryboardID) as? RequestSentViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var vContainer: UIView!
    
    @IBOutlet weak var imvCheck: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    
    var isPaymentRequest: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        vContainer.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
    }
    
    private func setupViews() {
        view.backgroundColor = .clear
        
        if #available(iOS 13.0, *) {
            imvCheck.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvCheck.tintColor = .colorGreen
        
        lblTitle.text = "Request Sent"
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 25)
        lblTitle.textColor = .colorGray1
        
        lblDescription.text = isPaymentRequest ? "The request has been sent. We will inform you when the payment is done by the user." : "The request has been sent. We will inform you when it's confirmed by the user."
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray5
        lblDescription.numberOfLines = 0
        
        btnOk.setTitle(" OK ", for: .normal)
        btnOk.setTitleColor(.colorPrimary, for: .normal)
        btnOk.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 26)
    }
    
    @IBAction func didTapOk(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
