//
//  BackButton.swift
//  ATB
//
//  Created by mobdev on 2019/5/13.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class BackButton:BouncingButton
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setTitle("back", for: .normal)
        self.setTitleColor(UIColor.textFieldPlaceHolderColor, for: .normal)
        let imageSize:CGSize = CGSize(width: 24, height: 24)
        self.setImage(UIImage(named: "back-arrow"), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: (self.frame.size.height - imageSize.height) / 2, left: 0, bottom: (self.frame.size.height - imageSize.height) / 2, right: self.frame.size.width - 24)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
        self.imageView?.contentMode = .scaleAspectFill
    }
}

class MainBackButton: UIButton
{
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setTitle("Back", for: .normal)
        self.setTitleColor(UIColor.primaryButtonColor, for: .normal)
        let imageSize:CGSize = CGSize(width: 13, height: 24)
        self.setImage(UIImage(named: "Back"), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: (self.frame.size.height - imageSize.height) / 2, left: 0, bottom: (self.frame.size.height - imageSize.height) / 2, right: self.frame.size.width - 13)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -13, bottom: 0, right: 0)
        self.imageView?.contentMode = .scaleAspectFill
    }
}
