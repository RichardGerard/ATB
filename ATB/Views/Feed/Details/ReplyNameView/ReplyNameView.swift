//
//  ReplyNameView.swift
//  ATB
//
//  Created by YueXi on 4/16/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

protocol ReplyNameViewDelegate {
    func didTapClose()
}

class ReplyNameView: UIView {
    
    @IBOutlet weak var lblUserName: UILabel!
    
    var delegate: ReplyNameViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        delegate?.didTapClose()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}

