//
//  ReportProblemViewController.swift
//  ATB
//
//  Created by YueXi on 11/2/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

protocol ReportProblemDelegate {
    
    func didReportProblem()
}

class ReportProblemViewController: BaseViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet var btnProblems: [UIButton]!
    private let baseTag = 500
    
    private let problems = [
        "The Business was closed",
        "I did not get the service",
        "Not what I expected",
        "Is a scam"
    ]
    
    var selectedBooking: BookingModel!
    
    var delegate: ReportProblemDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        lblTitle.text = "What was the problem?"
        lblTitle.textAlignment = .center
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 29)
        lblTitle.textColor = .colorPrimary
        lblTitle.minimumScaleFactor = 0.75
        lblTitle.adjustsFontSizeToFitWidth = true
        
        for i in  0 ..< 4 {
            btnProblems[i].setTitle(problems[i], for: .normal)
            btnProblems[i].titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 18)
            btnProblems[i].contentHorizontalAlignment = .left
            btnProblems[i].setTitleColor(.colorGray2, for: .normal)
        }
    }
    
    @IBAction func didTapSelect(_ sender: Any) {
        guard let button = sender as? UIButton else { return }
        let index = button.tag - baseTag
        
        guard let service = selectedBooking.service,
              let business = selectedBooking.business else { return }
        
        let problem = problems[index]
        let bid = selectedBooking.id
        let buid = business.ID
        let sid = service.Post_ID
        
        showIndicator()
        APIManager.shared.reportBooking(g_myToken, bid: bid, sid: sid, buid: buid, problem: problem) { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                self.dismiss(animated: true) {
                    self.delegate?.didReportProblem()
                }
            
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
}
