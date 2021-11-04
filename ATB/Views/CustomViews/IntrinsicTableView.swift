//
//  IntrinsicTableView.swift
//  ATB
//
//  Created by YueXi on 2/19/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit

class IntrinsicTableView: UITableView {
    
    var maxHeight: CGFloat = SCREEN_HEIGHT * 2.0
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        let height = maxHeight > 0 ? min(contentSize.height, maxHeight) : contentSize.height
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
}
