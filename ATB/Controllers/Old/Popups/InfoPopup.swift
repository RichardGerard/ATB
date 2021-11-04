//
//  InfoPopup.swift
//  The Motor App
//
//  Created by Zachary Powell on 14/05/2018.
//  Copyright © 2018 Motor App. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog

class InfoPopup {
    static func presentPopup(infoText: String, header: String, backgroundColour: UIColor, view: UIViewController){
        let infoPopup = InfoPopupViewController(nibName: "InfoPopupViewController", bundle: nil)
        infoPopup.text = infoText
        infoPopup.header = header
        infoPopup.backgroundColour = backgroundColour
        let popup = PopupDialog(viewController: infoPopup, buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: true)
        infoPopup.presentedPopup = popup
        view.present(popup, animated: true, completion: nil)
    }
}
