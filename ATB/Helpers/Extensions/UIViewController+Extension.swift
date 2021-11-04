//
//  UIViewController+Extension.swift
//  ATB
//
//  Created by mobdev on 11/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import Toast_Swift
import Photos

extension UIViewController {
    
    func showInfoVC(_ title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        alertController.view.tintColor = .colorPrimary
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showSuccessVC(msg:String) {
        let alertController = UIAlertController(title: nil, message: msg, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        alertController.view.tintColor = .colorPrimary
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertVC(msg:String) {
        let alertController = UIAlertController(title: "Alert", message: msg, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        alertController.view.tintColor = .colorPrimary
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showErrorVC(msg:String) {
        let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        alertController.view.tintColor = .colorPrimary
        self.present(alertController, animated: true, completion: nil)
    }
    
    // fake indicator that adds a shadow view to disable user interaction
    func showFakeIndicator() {
        let curframe = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        loadingView = UIView(frame: curframe)
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
        
        UIApplication.shared.keyWindow?.isUserInteractionEnabled = false
        
        if loadingView.superview == nil,
            let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.addSubview(loadingView)
        }
    }
    
    func hideFakeIndicator() {
        guard loadingView.superview != nil else { return }
        
        UIApplication.shared.keyWindow?.isUserInteractionEnabled = true
        loadingView.removeFromSuperview()
    }
    
    func showIndicator() {
        curviewcontroller = self
        
//        let curframe = curviewcontroller?.view.frame
        let curframe = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
//        loadingView = UIView(frame: (curviewcontroller?.view.frame)!)
        loadingView = UIView(frame: curframe)
        loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0)
//        loadingAcitivity = NVActivityIndicatorView(frame: CGRect(x: (curframe?.width)!/2 - 18, y: (curframe?.height)!/2 - 18, width: 36, height: 36), type: .ballRotateChase, color: self.UIColorFromHex(0xEC644B), padding: CGFloat(0))
        loadingAcitivity = NVActivityIndicatorView(frame: CGRect(x: (curframe.width)/2 - 18, y: (curframe.height)/2 - 18, width: 36, height: 36), type: .ballRotateChase, color: self.UIColorFromHex(0xEC644B), padding: CGFloat(0))
        loadingAcitivity!.startAnimating()
        loadingView.addSubview(loadingAcitivity!)
        
        KEYWINDOW?.isUserInteractionEnabled = false
        
        if loadingView.superview == nil,
            let keyWindow = UIApplication.shared.keyWindow {
//            UIApplication.topViewController()?.view.addSubview(loadingView)
//            self.view.addSubview(loadingView)
            keyWindow.addSubview(loadingView)
        }
    }
    
    /// show an alert with action buttons
    func showAlert(_ title: String?, message: String?, positive: String? = nil, positiveAction: ((_ positiveAction: UIAlertAction) -> Void)? = nil, negative: String? = nil, negativeAction: ((_ negativeAction: UIAlertAction) -> Void)? = nil, preferredStyle: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        if negative != nil {
            let negAction = UIAlertAction(title: negative, style: .cancel, handler: negativeAction)
            alert.addAction(negAction)
        }
        
        if positive != nil {
            let posAction = UIAlertAction(title: positive, style: .default, handler: positiveAction)
            alert.addAction(posAction)
        }
        
        /// change title font & color
//        alert.setTitle(UIFont(name: Config.CookieRunBold, size: 18))
//        alert.setMessage(UIFont(name: Config.CookieRunRegular, size: 14))
         
        // button color
        alert.view.tintColor = .colorPrimary
        
        present(alert, animated: true)
    }
    
    func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func hideIndicator(){
        if loadingView.superview != nil{
            loadingAcitivity!.stopAnimating()
            KEYWINDOW?.isUserInteractionEnabled = true
            loadingView.removeFromSuperview()
        }
    }
    
    func generateImage(for view: UIView) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
    
    func iconWithTextImage(_ title: String, font: UIFont, imageName: String) -> UIImage {
        let button = UIButton()
        
        if #available(iOS 13.0, *) {
            let icon = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate)
            button.setImage(icon, for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.titleLabel?.font = font
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 10)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10)
        button.sizeToFit()
        
        return generateImage(for: button) ?? UIImage()
    }
    
    /// show toast
    func showToast(_ view: UIView? = nil, message: String = "", position: ToastPosition = .bottom, point: CGPoint? = nil, didTap: ((Bool) -> Void)? = nil) {
        if let toastView = view {
            self.view.hideAllToasts()
            
            if let point = point {
                self.view.showToast(toastView, duration: 2.0, point: point, completion: didTap)
                
            } else {
                self.view.showToast(toastView, duration: 2.0, position: position, completion: didTap)
            }
            
            
        } else {
            guard !message.isEmpty else {
                return
            }
            
            var style = ToastStyle()
            style.messageFont = UIFont(name: Font.SegoeUILight, size: 18.0)!
            
            if let point = point {
                // immediately hides all toast views
                self.view.hideAllToasts()
                
                self.view.makeToast(message, point: point, title: nil, image: nil, style: style, completion: nil)
                
            } else {
                // immediately hides all toast views
                self.view.hideAllToasts()
                
                self.view.makeToast(message, style: style)
            }
        }
    }
    
    // MARK: - Helper: getAssetThumbnail
    func getAssetThumbnail(_ asset: PHAsset, size: CGFloat) -> UIImage {
        let retinaScale = UIScreen.main.scale
        let retinaSquare = CGSize(width: retinaScale*size, height: retinaScale*size)
        let cropSizeLength = min(asset.pixelWidth, asset.pixelHeight)
        let square = CGRect(x: 0, y: 0, width: CGFloat(cropSizeLength), height: CGFloat(cropSizeLength))
        let cropRect = square.applying(CGAffineTransform(scaleX: 1.0/CGFloat(asset.pixelWidth), y: 1.0/CGFloat(asset.pixelHeight)))
        
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        var thumbnail = UIImage()
        
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.normalizedCropRect = cropRect
        
        manager.requestImage(for: asset, targetSize: retinaSquare, contentMode: .aspectFit, options: options) { result, info in
            if let image = result {
                thumbnail = image
            }
        }
        
        return thumbnail
    }
}
