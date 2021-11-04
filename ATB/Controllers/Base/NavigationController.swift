//
//  NavigationController.swift
//  ATB
//
//  Created by YueXi on 5/13/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let topVC = viewControllers.last {
            return topVC.preferredStatusBarStyle
        }
        
        return .default
    }
    
    private func setupNavigationBar() {
        navigationBar.tintColor = .colorPrimary
//        navigationBar.barTintColor = .
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: Font.SegoeUISemibold, size: 20)!,
            NSAttributedString.Key.foregroundColor: UIColor.colorPrimary
        ]
//        navigationBar.shadowImage = UIImage()
    }

}
