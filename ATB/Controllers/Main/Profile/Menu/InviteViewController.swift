//
//  InviteViewController.swift
//  ATB
//
//  Created by YueXi on 4/23/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Social

class InviteViewController: BaseViewController {
    
    static let kStoryboardID = "InviteViewController"
    class func instance() -> InviteViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: InviteViewController.kStoryboardID) as? InviteViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var btnBack: UIButton! { didSet {
        btnBack.tintColor = .white
        btnBack.setTitleColor(.white, for: .normal)
        btnBack.titleLabel?.font = UIFont(name: "SegoeUI-Light", size: 17)
        btnBack.setTitle(" Back", for: .normal)
        if #available(iOS 13.0, *) {
            btnBack.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        
        }}
    @IBOutlet weak var lblInvite: UILabel!
    @IBOutlet weak var lblShowMoreOptions: UILabel!
    
    @IBOutlet weak var lblInviteCode: UILabel! { didSet {
        lblInviteCode.font = UIFont(name: "SegoeUI-Bold", size: 26)!
        lblInviteCode.textColor = .colorGray9
        lblInviteCode.textAlignment = .center
        lblInviteCode.text = g_myInfo.invite_code
        }}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblInvite.setLineSpacing(lineHeightMultiple: 0.75)
        lblInvite.textAlignment = .center
        
        let attachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            attachment.image = UIImage(systemName: "square.and.arrow.up")?.withTintColor(.white)
            attachment.setImageHeight(height: 24, verticalOffset: -4.0)
        } else {
            // Fallback on earlier versions
        }
        
        let attrShowMoreOptions = NSMutableAttributedString(string: "Show More Options ")
        attrShowMoreOptions.append(NSAttributedString(attachment: attachment))
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Light", size: 20)!,
            .foregroundColor: UIColor.white,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.white
        ]
        attrShowMoreOptions.addAttributes(attributes, range: NSRange(location: 0, length: attrShowMoreOptions.length))
        lblShowMoreOptions.attributedText = attrShowMoreOptions
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(didTapShowMoreOptions))
        tapGesture.numberOfTouchesRequired = 1
        lblShowMoreOptions.isUserInteractionEnabled = true
        lblShowMoreOptions.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapInvite(_ sender: Any) {
        UIPasteboard.general.string = INVITE_URL + g_myInfo.invite_code
        showSuccessVC(msg: "Invite URL has been copied to your clipboard")
    }
    
    @objc private func didTapShowMoreOptions() {
        guard let shareUrl = URL(string: INVITE_URL + g_myInfo.invite_code) else { return }
        
        let items = [shareUrl]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        present(ac, animated: true)
    }
    
    @IBAction func didTapSocialMedias(_ sender: UIButton) {
        guard let shareUrl = URL(string: INVITE_URL + g_myInfo.invite_code) else { return }
        
        let selected = sender.tag - 240
        
        switch selected {
        case 0:
            if let composeVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
                composeVC.add(shareUrl)
                composeVC.setInitialText("Join me on the brand new ATB app!")
                present(composeVC, animated: true, completion: nil)
            }
            break
            
        case 1:
            //twitter
            if let composeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
                composeVC.add(shareUrl)
                composeVC.setInitialText("Join me on the brand new ATB app!")
                present(composeVC, animated: true, completion: nil)
            }
            break
            
        case 2:
            InstagramManager.sharedManager.postImageToInstagramWithCaption(imageInstagram: UIImage(named: "ATB-Insta")!, instagramCaption: "Join me on the brand new ATB app!", view: self.view)
            break
        default:
            break
        }
    }
}

// MARK: - NSTextAttachment Extension
extension NSTextAttachment {
    func setImageHeight(height: CGFloat, verticalOffset: CGFloat = 0.0) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height

        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y + verticalOffset, width: ratio * height, height: height)
    }
}

