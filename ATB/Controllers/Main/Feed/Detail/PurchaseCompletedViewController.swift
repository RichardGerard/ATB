//
//  PurchaseCompletedViewController.swift
//  ATB
//
//  Created by YueXi on 11/15/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Kingfisher

protocol PurchaseCompleteDelegate: class {
    
    func viewPurchases()
    func keepBuying()
}

class PurchaseCompletedViewController: BaseViewController {
    
    var delegate: PurchaseCompleteDelegate?
    
    @IBOutlet weak var imvProduct: UIImageView!
    @IBOutlet weak var imvComplete: UIImageView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var btnViewPurchases: UIButton!
    @IBOutlet weak var btnKeepBuying: UIButton!
    
    var purchasedItem: PostModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
    }
    
    private func initView() {
        imvProduct.layer.cornerRadius = 5
        imvProduct.layer.masksToBounds = true
        imvProduct.contentMode = .scaleAspectFill
        
        let url = purchasedItem.Post_Media_Urls.count > 0 ? purchasedItem.Post_Media_Urls[0] : ""
        if purchasedItem.isVideoPost {
            // set placeholder
            imvProduct.image = UIImage(named: "post.placeholder")
            
            if ImageCache.default.imageCachedType(forKey: url).cached {
                ImageCache.default.retrieveImage(forKey: url) { result in
                    switch result {
                    case .success(let cacheResult):
                        if let image = cacheResult.image {
                            let animation = CATransition()
                            animation.type = .fade
                            animation.duration = 0.25
                            self.imvProduct.layer.add(animation, forKey: "transition")
                            self.imvProduct.image = image
                        }
                        
                        break
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                }
                
            } else {
                // thumbnail is not cached, get thumbnail from video url
                Utils.shared.getThumbnailImageFromVideoUrl(url) { thumbnail in
                    if let thumbnail = thumbnail {
                        let animation = CATransition()
                        animation.type = .fade
                        animation.duration = 0.3
                        self.imvProduct.layer.add(animation, forKey: "transition")
                        self.imvProduct.image = thumbnail
                        
                        ImageCache.default.store(thumbnail, forKey: url)
                    }
                }
            }
            
        } else {
            imvProduct.loadImageFromUrl(url, placeholder: "post.placeholder")
        }
        
        if #available(iOS 13.0, *) {
            imvComplete.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvComplete.tintColor = .colorGreen
        
        lblTitle.text = "You have purchased\nthis product"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 23)
        lblTitle.textColor = .colorGray5
        lblTitle.textAlignment = .center
        
        lblDescription.text = "The seller has been notified and will delivering at your specified address."
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray5
        lblDescription.numberOfLines = 2
        lblDescription.textAlignment = .center
        
        btnViewPurchases.setTitle("See my purchases ", for: .normal)
        btnViewPurchases.backgroundColor = .colorPrimary
        btnViewPurchases.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        btnViewPurchases.setTitleColor(.white, for: .normal)
        if #available(iOS 13.0, *) {
            btnViewPurchases.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnViewPurchases.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        btnViewPurchases.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        btnViewPurchases.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        btnViewPurchases.layer.cornerRadius = 5
        btnViewPurchases.tintColor = .white
        
        btnKeepBuying.setTitle(" Keep buying", for: .normal)
        btnKeepBuying.backgroundColor = .colorGray14
        btnKeepBuying.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        btnKeepBuying.setTitleColor(.colorPrimary, for: .normal)
        btnKeepBuying.layer.cornerRadius = 5
        btnKeepBuying.layer.borderWidth = 1
        btnKeepBuying.layer.borderColor = UIColor.colorGray17.cgColor
        
        if #available(iOS 13.0, *) {
            btnKeepBuying.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnKeepBuying.tintColor = .colorPrimary
    }
    
    @IBAction func didTapViewPurchases(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.viewPurchases()
        }
    }
    
    @IBAction func didTapKeepBuying(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.keepBuying()
        }
    }
}
