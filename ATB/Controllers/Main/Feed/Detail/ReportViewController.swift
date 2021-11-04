//
//  ReportViewController.swift
//  ATB
//
//  Created by mobdev on 21/8/19.
//  Updated by YueXi on 22/5/2021.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

enum REPORT_TYPE: String {
    case USER, PRODUCT, SERVICE, POST, COMMENT
}

class ReportViewController: BaseViewController {
    
    static let kStoryboardID = "ReportViewController"
    class func instance() -> ReportViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: ReportViewController.kStoryboardID) as? ReportViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var txtReason: UITextField!
    @IBOutlet weak var txtReportDescription: RoundShadowTextView!
    @IBOutlet weak var btnSave: UIButton!
    
    var reportType: REPORT_TYPE = .POST
    var reportId: String = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.txtReportDescription.placeHolderText = "Write description here..."
        
        
        btnSave.layer.cornerRadius = 5.0
        txtReportDescription.layer.cornerRadius = 5.0
        txtReason.layer.cornerRadius = 5.0
        
        txtReason.layer.shadowOffset = CGSize(width: 1, height: 1)
        txtReason.layer.shadowColor = UIColor.lightGray.cgColor
        txtReason.layer.shadowOpacity = 0.6
        txtReason.layer.shadowRadius = 2.0
        
        txtReason.setLeftPaddingPoints(10.0)
        txtReason.setRightPaddingPoints(10.0)
    }
    
    func isValid() -> Bool {
        guard let reason = txtReason.text,
              !reason.isEmpty else {
            showErrorVC(msg: "Please input a report reason.")
            return false
        }
        
        guard let reportText = txtReportDescription.text,
              !reportText.isEmpty else {
            showErrorVC(msg: "Please input report description.")
            return false
        }
        
        return true
    }
    
    @IBAction func didTapReport(_ sender: Any) {
        guard isValid() else { return }
        
        showIndicator()
        APIManager.shared.postReport(g_myToken, reportType: self.reportType, reportId: self.reportId, reason: txtReason.text!.trimmedString, content: txtReportDescription.text!.trimmedString) { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                self.showInfoVC("ATB", msg: "It's been reported sucecssfully!")
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    @IBAction func didTapClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
