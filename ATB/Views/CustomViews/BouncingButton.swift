//
//  BouncingButton.swift
//  ATB
//
//  Created by mobdev on 2019/5/13.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class BouncingButton: UIButton
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        self.addTarget(self, action: #selector(buttonUp), for: [.touchUpInside, .touchUpOutside])
    }
    
    @objc func buttonDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.05, delay: 0, options: .curveLinear, animations: {
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }) { (isCompleted) in
            
        }
    }
    
    @objc func buttonUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.03, delay: 0, options: .curveLinear, animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (isCompleted) in
            
        }
    }
}
