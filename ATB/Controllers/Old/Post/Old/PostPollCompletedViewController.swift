//
//  PostPollCompletedViewController.swift
//  ATB
//
//  Created by YueXi on 5/3/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import YLProgressBar

class PostPollCompletedViewController: UIViewController {
    
    static let kStoryboardID = "PostPollCompletedViewController"
    class func instance() -> PostPollCompletedViewController {
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: PostPollCompletedViewController.kStoryboardID) as? PostPollCompletedViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var lblPageTitle: UILabel! { didSet  {
        lblPageTitle.font = UIFont(name: "SegoeUI-Semibold", size: 28)
        lblPageTitle.numberOfLines = 0
        lblPageTitle.textColor = .white
        }}
    @IBOutlet weak var lblPageSubtitle: UILabel!
    
    @IBOutlet weak var imvProfile: UIImageView!
    @IBOutlet weak var lblUsername: UILabel! { didSet {
        lblUsername.font = UIFont(name: "SegoeUI-Semibold", size: 15)
        lblUsername.textColor = .colorGray2
        }}
    @IBOutlet weak var imvPostTag: UIImageView! { didSet {
        imvPostTag.contentMode = .center
        imvPostTag.image = UIImage(named: "tag.poll")
        }}
    
    @IBOutlet weak var lblPollQuestion: UILabel! { didSet {
        lblPollQuestion.font = UIFont(name: "SegoeUI-Semibold", size: 19)
        lblPollQuestion.textColor = .colorGray13
        }}
    @IBOutlet weak var imvPollAttachment: UIImageView! { didSet {
        imvPollAttachment.contentMode = .scaleAspectFill
        }}
    
    @IBOutlet var vPollOptions: [UIView]!
    @IBOutlet var vProgressBars: [YLProgressBar]!
    @IBOutlet var lblPollOptions: [UILabel]!
    
    @IBOutlet weak var imvLikes: UIImageView!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var imvComments: UIImageView!
    @IBOutlet weak var lblComments: UILabel!
    
    @IBOutlet weak var lblShareOrExplore: UILabel!
    
    let ratioForMediaContainer: CGFloat = 150/350.0
    @IBOutlet weak var heightForPollAttachment: NSLayoutConstraint!
    
    var isImageAttached: Bool = true
    
    var pollOptions = [String]()
    var optionCategory = ""
    var pollTitle = ""
    var postMedia:UIImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if isImageAttached {
            let width = SCREEN_WIDTH - 40 // minus left and right margin
            heightForPollAttachment.constant = width * ratioForMediaContainer
            self.view.layoutIfNeeded()
            
        } else {
            heightForPollAttachment.constant = 0
            self.view.layoutIfNeeded()
        }
        
        setupPageTitles()
        
        setupShareLabel()
        
        setupPollOptionsView()
    }
    
    private func setupPollOptionsView() {
        if (isImageAttached){
            imvPollAttachment.image = postMedia
        }
        
        let url = URL(string: DOMAIN_URL + g_myInfo.profileImage)
        self.imvProfile.kf.setImage(with: url)
        
        lblUsername.text = g_myInfo.firstName + " " + g_myInfo.lastName
        
        for i in 0 ..< 5 {
            vProgressBars[i].trackTintColor = .colorGray14
            vProgressBars[i].progressTintColor = .colorGray4
            vProgressBars[i].uniformTintColor = true
            vProgressBars[i].progressStretch = false
            vProgressBars[i].hideStripes = true
            vProgressBars[i].hideGloss = true
            vProgressBars[i].progressBarInset = 0.0
            vProgressBars[i].progress = 0
            vProgressBars[i].indicatorTextDisplayMode = .none
            
            lblPollOptions[i].font = UIFont(name: "SegoeUI-Light", size: 18)
            lblPollOptions[i].textColor = .colorGray2
            
            vPollOptions[i].isHidden = pollOptions[i] == ""
            if i < pollOptions.count {
                lblPollOptions[i].text = pollOptions[i]
            }
        }
        
        if #available(iOS 13.0, *) {
            imvLikes.image = UIImage(systemName: "suit.heart.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvLikes.tintColor = .colorGray2
        lblLikes.font = UIFont(name: "SegoeUI-Light", size: 16)
        lblLikes.textColor = .colorGray2
        lblLikes.text = "0"
        
        if #available(iOS 13.0, *) {
            imvComments.image = UIImage(systemName: "bubble.left.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvComments.tintColor = .colorGray2
        lblComments.font = UIFont(name: "SegoeUI-Light", size: 16)
        lblComments.textColor = .colorGray2
        lblComments.text = "0"
    }
    
    private func setupPageTitles() {
        lblPageTitle.text = "Your Poll\nhas been posted!"
        
        // subtitle
        let category = optionCategory
        let attrSubtitle = NSMutableAttributedString(string: "in \(category) category >")
        
        let semiboldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Semibold", size: 18)!,
            .foregroundColor: UIColor.white
        ]
        
        let underLineAttrs: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.white
        ]
        
        attrSubtitle.addAttributes(semiboldAttrs, range: NSRange(location: 0, length: attrSubtitle.length))
        attrSubtitle.addAttributes(underLineAttrs, range: NSRange(location: 0, length: attrSubtitle.length - 2))
        lblPageSubtitle.attributedText = attrSubtitle
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(browseCategory))
        tap.numberOfTouchesRequired = 1
        lblPageSubtitle.isUserInteractionEnabled = true
        lblPageSubtitle.addGestureRecognizer(tap)
    }
    
    private func setupShareLabel() {
        // share
        let lightAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Light", size: 18)!,
            .foregroundColor: UIColor.white
        ]
        
        let underLineAttrs: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.white
        ]
        
        let attrShare = NSMutableAttributedString(string: "Your product has been posted, share this new post or ", attributes: lightAttrs)
        let suffix = NSMutableAttributedString(string: "explore the category", attributes: lightAttrs)
        suffix.addAttributes(underLineAttrs, range: NSRange(location: 0, length: suffix.length))

        attrShare.append(suffix)
        lblShareOrExplore.attributedText = attrShare
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(browseCategory))
        tap.numberOfTouchesRequired = 1
        lblShareOrExplore.isUserInteractionEnabled = true
        lblShareOrExplore.addGestureRecognizer(tap)
    }
    
    @objc private func browseCategory(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainNav = storyboard.instantiateViewController(withIdentifier: "MainNav") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = mainNav
    }
    
    @IBAction func didTapShare(_ sender: UIButton) {
        let index = sender.tag - 470
        
        switch index {
        case 0:
            // facebook
            break
        case 1:
            // twitter
            break
        case 2:
            // instagram
            break
        default:
            // youtube
            break
        }
    }
}
