//
//  UIImageView+Extension.swift
//  ATB
//
//  Created by YueXi on 4/12/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Kingfisher
import AVFoundation

typealias ImageViewActivityIndicator = Kingfisher.IndicatorType

private var downloadTaskIndentifier: UInt8 = 0

// MARK: - UIImageView Extension
extension UIImageView {
    
    var activityIndicator: ImageViewActivityIndicator {
           get {
               return self.kf.indicatorType
           }
           set {
               self.kf.indicatorType = newValue
           }
       }
       
       var activityIndicatorColor: UIColor? {
           get {
               return (self.kf.indicator?.view as? UIActivityIndicatorView)?.color
           }
           set {
               (self.kf.indicator?.view as? UIActivityIndicatorView)?.color = newValue
           }
       }
    
    func loadImageFromUrl(_ url: String, placeholder: String? = nil) {
        if let placeholder = placeholder {
            self.kf.setImage(with: URL(string: url), placeholder: UIImage(named: placeholder))
            
        } else {
           self.kf.setImage(with: URL(string: url))
        }
    }
    
    private var downloadTask: String? {
        get { return objc_getAssociatedObject(self, &downloadTaskIndentifier) as? String }
        
        set { objc_setAssociatedObject(self, &downloadTaskIndentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func loadThumbnailFromUrl(_ url: String?, placeholder: String? = nil) {
        guard let urlString = url else {
            if let placeholder = placeholder {
                self.image = UIImage(named: placeholder)
                
            } else {
                self.image = nil
            }
            
            self.downloadTask = nil
            return
        }
        
        if self.image == nil,
           let placeholder = placeholder {
            // set placeholder while there is no image
            self.image = UIImage(named: placeholder)
        }
        
        downloadTask = urlString
        
        let cache = ImageCache.default
        let hashKey = "\((urlString as NSString).hash)"
        if cache.isCached(forKey: hashKey) {
            cache.retrieveImage(forKey: hashKey) { result in
                switch result {
                case .success(let value):
                    switch value {
                    case .none:
                        self.getThumbnail(urlString, placeholder: placeholder)
                        
                    default:
                        DispatchQueue.main.async {
                            guard let videoDownloadTask = self.downloadTask,
                                  videoDownloadTask == url else {
                                self.image = nil
                                return
                            }
                            
                            let animation = CATransition()
                            animation.type = .fade
                            animation.duration = 0.25
                            self.layer.add(animation, forKey: "transition")
                            
                            self.image = value.image
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        } else {
            self.getThumbnail(urlString, placeholder: placeholder)
        }
    }
    
    private func getThumbnail(_ url: String, placeholder: String?) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let thumbnail = self?.createThumbnailFromUrl(url) else { return }
            
            ImageCache.default.store(thumbnail, forKey: "\((url as NSString).hash)")
            
            DispatchQueue.main.async {
                guard let videoDownloadTask = self?.downloadTask,
                      videoDownloadTask == url else {
                    self?.image = nil
                    return
                }
                
                let animation = CATransition()
                animation.type = .fade
                animation.duration = 0.3
                self?.layer.add(animation, forKey: "transition")
                
                self?.image = thumbnail
            }
        }
    }
    
    private func createThumbnailFromUrl(_ url: String) -> UIImage? {
        guard let videoURL = URL(string: url) else { return  nil}
        
        let asset = AVAsset(url: videoURL)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        // Can set this to improve performance if target size is known before hand
        // assetImgGenerate.maximumSize = CGSize(width: width, height: height)
        let time = CMTime(seconds: 1, preferredTimescale: 10)
        
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
