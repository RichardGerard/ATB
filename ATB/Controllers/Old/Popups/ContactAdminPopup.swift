//
//  ContactAdminPopup.swift
//  ATB
//
//  Created by administrator on 14/04/2020.
//  Copyright © 2020 mobdev. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog

class ContactAdminPopup {
    static func presentPopup(infoText: String, header: String, view: UIViewController){
        let contactAdminPopup = ContactAdminPopupViewController(nibName: "ContactAdminPopupViewController", bundle: nil)
        contactAdminPopup.text = infoText
        contactAdminPopup.header = header
        let popup = PopupDialog(viewController: contactAdminPopup, buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: true)
        contactAdminPopup.presentedPopup = popup
        view.present(popup, animated: true, completion: nil)
    }
}
