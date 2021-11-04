//
//  ScrollViewWithButtons.swift
//  ATB
//
//  Created by mobdev on 2019/5/13.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class ScrollViewWithButtons: UIScrollView {
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIButton {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}
