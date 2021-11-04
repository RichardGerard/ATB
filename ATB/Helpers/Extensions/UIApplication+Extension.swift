//
//  UIApplication+Extension.swift
//  ATB
//
//  Created by YueXi on 2/21/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import Foundation

// MARK: - UIApplication Extension
extension UIApplication {
    
    class func safeAreaBottom() -> CGFloat {
        let window = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first
        let bottomPadding: CGFloat
        if #available(iOS 11.0, *) {
            bottomPadding = window?.safeAreaInsets.bottom ?? 0.0
        } else {
            bottomPadding = 0.0
        }
        return bottomPadding
    }

    class func safeAreaTop() -> CGFloat {
        let window = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first
        let topPadding: CGFloat
        if #available(iOS 11.0, *) {
            topPadding = window?.safeAreaInsets.top ?? 0.0
        } else {
            topPadding = 0.0
        }
        return topPadding
    }
    
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }

        if let slide = viewController as? SlideMenuController {
            return topViewController(slide.mainViewController)
        }

        return viewController
    }
}
