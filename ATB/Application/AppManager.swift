//
//  AppManager.swift
//  ATB
//
//  Created by YueXi on 4/13/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift
import PopupDialog
import Toast_Swift

class AppManager {
    
    static let shared = AppManager()
    
    fileprivate init() {}
    
    func setup() {
        setupKeyboardHelper()
        
        setupOthers()
    }
    
    func setupKeyboardHelper() {
        IQKeyboardManager.shared.toolbarTintColor = .colorPrimary
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.disabledToolbarClasses = [
            PostDetailViewController.self,
            PostPollViewController.self,
            PostRangeViewController.self,
            LocationViewController.self,
            UserSettingsViewController.self,
            BusinessDetailsViewController.self,
            AddQServiceViewController.self,
            LoginViewController.self,
            RegisterViewController.self,
            CreateProfileViewController.self,
            SendRatingViewController.self,
            RateServiceViewController.self,
            CreateBookingViewController.self,
            CreateBookingDetailsViewController.self,
            RegularWeekViewController.self,
            AddHolidayViewController.self,
            ProfileAuctionViewController.self,
            PointAuctionViewController.self,
            SearchViewController.self
        ]
        
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [
            PostDetailViewController.self,
            ConversationViewController.self
        ]
    }
    
    private func setupOthers() {
        // General Popup Dialog Appearance
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius = 30
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color = .black
        overlayAppearance.alpha = 0.7
        overlayAppearance.blurRadius = 8
        
        ToastManager.shared.style.verticalPadding = 16
    }
}
