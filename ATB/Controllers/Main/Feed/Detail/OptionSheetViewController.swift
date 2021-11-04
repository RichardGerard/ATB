//
//  OptionSheetViewController.swift
//  ATB
//
//  Created by YueXi on 9/8/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

protocol OptionSheetDelegate {
    // options for others posts
    func didTapReport()
    func didTapBlock()
    func didTapFollow()
    
    // options for the own user
    func didTapSold()
    func didTapDelete()
    func didTapEdit()
    
    // common
    func didTapCopyLink()
    func didTapShare()
}

class OptionSheetViewController: BaseViewController {
    
    static let kStoryboardID = "OptionSheetViewController"
    class func instance() -> OptionSheetViewController {
        let storyboard = UIStoryboard(name: "Sheet", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: OptionSheetViewController.kStoryboardID) as? OptionSheetViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    // Height
    // 15 + MaterialTabView(4)
    // buttons(60)
    // Separator View (betweeen others and cancel - 17)
    // cancel(60)
    // bottom(60)
    
    @IBOutlet weak var vContainer: UIView!
    
    @IBOutlet weak var vMaterialTab: UIView! { didSet {
        vMaterialTab.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        vMaterialTab.layer.cornerRadius = 2
        vMaterialTab.layer.masksToBounds = true
        }}
    
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var btnBlock: UIButton!
    @IBOutlet weak var btnFollow: UIButton!
    
    @IBOutlet weak var btnSold: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var btnCopyLink: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    
    @IBOutlet weak var btnCancel: UIButton!
    
    
    var isOwnPost: Bool = false
    
    var isPoll: Bool = false
    
    var isSale: Bool = false
    var isSoldOut: Bool = false
    
    var isFollowing: Bool = false
    
    var delegate: OptionSheetDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupOptions()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        vContainer.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 24)
    }
    
    private func setupOptions() {
        if isOwnPost {
            btnReport.isHidden = true
            btnBlock.isHidden = true
            btnFollow.isHidden = true
            
            btnEdit.isHidden = isPoll
            
            if isSale {
                btnSold.setTitle(isSoldOut ? " Re-list" : " Sold Out", for: .normal)
                btnSold.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 18)
                if #available(iOS 13.0, *) {
                    btnSold.setImage(UIImage(systemName: "tag"), for: .normal)
                } else {
                    // Fallback on earlier versions
                }
                btnSold.setTitleColor(UIColor.colorRed1, for: .normal)
                btnSold.tintColor = .colorRed1
                
            } else {
                btnSold.isHidden = true
            }
            
            btnDelete.setTitle(" Delete", for: .normal)
            btnDelete.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 18)
            if #available(iOS 13.0, *) {
                btnDelete.setImage(UIImage(systemName: "trash"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            btnDelete.setTitleColor(UIColor.colorRed1, for: .normal)
            btnDelete.tintColor = .colorRed1
            
            btnEdit.setTitle(" Edit", for: .normal)
            btnEdit.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 18)
            if #available(iOS 13.0, *) {
                btnEdit.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            btnEdit.setTitleColor(UIColor.colorGray1, for: .normal)
            btnEdit.tintColor = .colorGray1
            
        } else {
            btnSold.isHidden = true
            btnDelete.isHidden = true
            btnEdit.isHidden = true
            
            btnReport.setTitle(" Report", for: .normal)
            btnReport.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 18)
            if #available(iOS 13.0, *) {
                btnReport.setImage(UIImage(systemName: "info.circle"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            btnReport.setTitleColor(UIColor.colorRed1, for: .normal)
            btnReport.tintColor = .colorRed1
            
            btnBlock.setTitle(" Block User", for: .normal)
            btnBlock.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 18)
            if #available(iOS 13.0, *) {
                btnBlock.setImage(UIImage(systemName: "minus.circle"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            btnBlock.setTitleColor(UIColor.colorGray1, for: .normal)
            btnBlock.tintColor = .colorGray1
            
            btnFollow.setTitle(isFollowing ? " Unfollow" : " Follow", for: .normal)
            btnFollow.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 18)
            if #available(iOS 13.0, *) {
                btnFollow.setImage(UIImage(systemName: isFollowing ? "person.badge.minus" : "person.badge.plus"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            btnFollow.setTitleColor(UIColor.colorGray1, for: .normal)
            btnFollow.tintColor = .colorGray1
        }
        
//        btnCopyLink.setTitle(" Copy Link to Post", for: .normal)
//        btnCopyLink.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 18)
//        if #available(iOS 13.0, *) {
//            btnCopyLink.setImage(UIImage(systemName: "link"), for: .normal)
//        } else {
//            // Fallback on earlier versions
//        }
//        btnCopyLink.setTitleColor(UIColor.colorGray1, for: .normal)
//        btnCopyLink.tintColor = .colorGray1
        
        btnShare.setTitle(" Share", for: .normal)
        btnShare.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 18)
        if #available(iOS 13.0, *) {
            btnShare.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnShare.setTitleColor(UIColor.colorGray1, for: .normal)
        btnShare.tintColor = .colorGray1        
        
        btnCancel.setTitle("Cancel", for: .normal)
        btnCancel.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 18)
        btnCancel.setTitleColor(UIColor.colorPrimary, for: .normal)
    }
    
    @IBAction func didTapReport(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didTapReport()
        }
        
    }
    
    @IBAction func didTapBlock(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didTapBlock()
        }
    }
    
    @IBAction func didTapFollow(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didTapFollow()
        }
    }
    
    @IBAction func didTapSold(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didTapSold()
        }
    }
    
    @IBAction func didTapDelete(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didTapDelete()
        }
    }
    
    @IBAction func didTapEdit(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didTapEdit()
        }
    }
    
    @IBAction func didTapCopyLink(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didTapCopyLink()
        }
    }
    
    @IBAction func didTapShare(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didTapShare()
        }
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true)
    }
}
