//
//  CustomBMPlayer.swift
//  ATB
//
//  Created by mobdev on 14/8/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import BMPlayer

class BMPlayerCustomControlView: BMPlayerControlView {
    /**
     Override if need to customize UI components
     */
    override func customizeUIComponents() {
        backButton.removeFromSuperview()
        //bottomMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        //        timeSlider.setThumbImage(UIImage(named: "custom_slider_thumb"), for: .normal)
        fullscreenButton.isHidden = false
        BMPlayerConf.shouldAutoPlay = false
    }

    override func controlViewAnimation(isShow: Bool) {
        self.isMaskShowing = isShow
        UIApplication.shared.setStatusBarHidden(!isShow, with: .fade)
        
        UIView.animate(withDuration: 0.24, animations: {
            self.bottomMaskView.snp.remakeConstraints {
                $0.bottom.equalTo(self.mainMaskView).offset(isShow ? 0 : 50)
                $0.left.right.equalTo(self.mainMaskView)
                $0.height.equalTo(50)
            }
            self.layoutIfNeeded()
        }) { (_) in
            self.autoFadeOutControlViewWithAnimation()
        }
    }
}
