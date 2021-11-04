//
//  PinPointViewController.swift
//  ATB
//
//  Created by YueXi on 3/17/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import SkeletonView

class PinPointViewController: BaseViewController {
    
    static let kStoryboardID = "PinPointViewController"
    class func instance() -> PinPointViewController {
        let storyboard = UIStoryboard(name: "BusinessBoost", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: PinPointViewController.kStoryboardID) as? PinPointViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")
        } else {
            // Fallback on earlier versions
        }
        imvBack.tintColor = .white
    }}
    
    @IBOutlet weak var backHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var containerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    // search container
    @IBOutlet weak var searchContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var lblSearchFor: UILabel!
    @IBOutlet weak var imvRightArrow: UIImageView!
    
    // looking for container
    @IBOutlet weak var lookingContainer: UIView!
    @IBOutlet weak var imvSearch: UIImageView!
    @IBOutlet weak var lblLookingFor: UILabel!
    
    // container view is not required, but this is to animate & keep the circle while transforming
    private lazy var circleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        let clickAnimationView = RoundView(frame: CGRect(x: 0, y: 0, width: 86, height: 86))
        clickAnimationView.backgroundColor = .black
        view.addSubview(clickAnimationView)
        
        return view
    }()
//    @IBOutlet weak var circleContainer: UIView!
//    @IBOutlet weak var clickAnimationView: RoundView!
    
    @IBOutlet weak var serviceView: RoundView!
    @IBOutlet weak var imvServiceTag: UIImageView!
    @IBOutlet weak var imvProfile: ProfileView!
    @IBOutlet weak var saleView: RoundView!
    @IBOutlet weak var imvSaleTag: UIImageView!
    
    @IBOutlet weak var highlightedContainer: UIView!
    @IBOutlet weak var highlightedContainerWidth: NSLayoutConstraint!
    @IBOutlet var highlightedItemViews: [UIView]!
    
    @IBOutlet weak var highlightedSkeletonContainer: UIView!
    @IBOutlet var highlightedSkeletonViews: [UIView]!
    
    @IBOutlet weak var lblOtherResults: UILabel!
    @IBOutlet var lineSeparatorViews: [UIView]!
    
    @IBOutlet weak var otherResultContainer: UIView!
    @IBOutlet weak var otherResultTableView: UITableView!
        
    @IBOutlet weak var txvInformation: UITextView!
    @IBOutlet weak var fadeView: UIView!
    @IBOutlet weak var btnTake: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        showClickCircle()
    }
    
    private func setupViews() {
        lblTitle.text = "Pin Point"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 29)
        lblTitle.textColor = .white
        
        if SCREEN_HEIGHT <= 568 {
            // iPhone SE 1st generation
            backHeightConstraint.constant = 1.02 * SCREEN_HEIGHT
            
        } else if SCREEN_HEIGHT <= 667 {
            // iPhone SE 2nd generation, 6, 6s, 7, 8
            backHeightConstraint.constant = 0.99 * SCREEN_HEIGHT
            
        } else if SCREEN_HEIGHT <= 736 {
            // iPhone 6 Plus, 7 Plus, 8 Plus
            backHeightConstraint.constant = 0.96 * SCREEN_HEIGHT
            
        } else if SCREEN_HEIGHT <= 844 {
            // iPhone 12 Pro, 12, 12 mini, 11 Pro, Xs, X
            backHeightConstraint.constant = 0.87 * SCREEN_HEIGHT
            
        } else { //896
            // above iPhone X, Xs Max, 11, 11 Pro Max, 12 Pro Max
            backHeightConstraint.constant = 0.85 * SCREEN_HEIGHT
        }
        
        // container view
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.layer.cornerRadius = 30
        containerWidthConstraint.constant = SCREEN_WIDTH - 36
        
        // search view
        searchContainer.backgroundColor = .colorGray23
        searchContainer.layer.cornerRadius = 5
        searchContainer.layer.masksToBounds = true
        
        lblSearchFor.text = "Search for..."
        lblSearchFor.font = UIFont(name: Font.SegoeUILight, size: 21)
        lblSearchFor.textColor = .colorGray8

        if #available(iOS 13.0, *) {
            imvRightArrow.image = UIImage(systemName: "chevron.down")
        } else {
            // Fallback on earlier versions
        }
        imvRightArrow.tintColor = .colorPrimary
        
        searchContainerWidthConstraint.constant = (SCREEN_WIDTH - 36 - 36)
        imvRightArrow.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2.0)
  
        // looking container
        if #available(iOS 13.0, *) {
            imvSearch.image = UIImage(systemName: "magnifyingglass")
        } else {
            // Fallback on earlier versions
        }
        imvSearch.tintColor = .colorGray6
        imvSearch.contentMode = .scaleAspectFit
        
        lblLookingFor.text = "Looking for something?"
        lblLookingFor.font = UIFont(name: Font.SegoeUIBold, size: 22)
        lblLookingFor.textColor = .colorGray6
        
        // click animation circle
        containerView.addSubview(circleContainer)
        containerView.addConstraintWithFormat("H:[v0(86)]-4-|", views: circleContainer)
        NSLayoutConstraint.activate([
            circleContainer.centerYAnchor.constraint(equalTo: lookingContainer.bottomAnchor, constant: 46), // top(18) + search height(56)/2
            circleContainer.heightAnchor.constraint(equalToConstant: 86)
        ])
        circleContainer.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        circleContainer.alpha = 0
        circleContainer.isHidden = true
        
        searchContainer.transform = CGAffineTransform(translationX: 0, y: 148)
        
        // Tag Views
        setupTagView(serviceView, tagView: imvServiceTag, imageName: "tag.service.medium")
        setupTagView(saleView, tagView: imvSaleTag, imageName: "tag.sale.medium")
        
        let business = g_myInfo.business_profile
        imvProfile.borderWidth = 1.5
        imvProfile.borderColor = .colorPrimary
        imvProfile.loadImageFromUrl(business.businessPicUrl, placeholder: "profile.placeholder")
        
        for highlightedItemView in highlightedItemViews {
            highlightedItemView.layer.cornerRadius = 5
            highlightedItemView.layer.backgroundColor = UIColor.colorPrimary.cgColor
        }
        highlightedContainer.alpha = 0
        highlightedContainerWidth.constant = 0
        
        for highlightedSkeletonView in highlightedSkeletonViews {
            highlightedSkeletonView.isSkeletonable = true
            
            highlightedSkeletonView.layer.cornerRadius = 5
            highlightedSkeletonView.backgroundColor = .colorBlue13
            highlightedSkeletonView.layer.masksToBounds = true
        }
        
        highlightedSkeletonContainer.isSkeletonable = true
        highlightedSkeletonContainer.transform = CGAffineTransform(translationX: -highlightedSkeletonContainer.bounds.width, y: 0)
        highlightedSkeletonContainer.alpha = 0.0
        
        lblOtherResults.text = "Other results"
        lblOtherResults.font = UIFont(name: Font.SegoeUILight, size: 22)
        lblOtherResults.textColor = .colorGray4
        lblOtherResults.isHiddenWhenSkeletonIsActive = false
        
        lineSeparatorViews[0].backgroundColor = .colorGray4
        lineSeparatorViews[0].isHiddenWhenSkeletonIsActive = false
        lineSeparatorViews[1].backgroundColor = .colorGray4
        lineSeparatorViews[1].isHiddenWhenSkeletonIsActive = false
        
        otherResultTableView.showsVerticalScrollIndicator = false
        otherResultTableView.separatorStyle = .none
        otherResultTableView.tableFooterView = UIView()
        otherResultTableView.isSkeletonable = true
        otherResultTableView.rowHeight = 86
        
        otherResultTableView.dataSource = self
        otherResultTableView.delegate = self
        
        otherResultContainer.isSkeletonable = true
        otherResultContainer.transform = CGAffineTransform(translationX: 0, y: otherResultContainer.bounds.height)
                
        // information
        let pinPointText = "Pin Point gives business users the opportunity to promote their business via Pin Point Tag words and Phrases.\n\nHow does this work?\n\nATB users can use the search feature to find businesses or posts relevant to the keyword or phrase they are looking for.\n\nThe user has the option to search through two databases - Either the Post database or the Business Directory database.\n\nOnce the user has submitted their request they will be presented with all posts or businesses relevant to that keyword/phrase search.\n\nA post search will show all posts relevant to that keywords/phrase search(The algorithm can be viewed elsewhere).\n\n A business directory search will bring up all businesses that have used that tag word or phrase during the set-up of their business profile or via the PinPoint feature within the Business Boost Page.\n\nOnce the search is complete the immediate view will show ten business profiles. The first 5 will be allocated to paid slots, with the top three being pinned. The next 5 will be location based(ie closest to ther users defined location). Excluding the top three which are pinned, the user will be able to view the remaining businesses by scrolling down the page.\n\nAs with the Profile Pin, Pin Point is also via an auction process. Each week all keywords and phrases become available for businesses to promote themselves via the PinPoint auction process.\n\nBids begin on Monday at 00:00 with each word or phrase starting at £5.00 with the auction process lasting for one week, during this time all businesses can bid for any word or phrase they deem relevant to their business.\n\nOnce bidding processs has completed, the 5 businesses with the highest bids will be seen at the top of the search page in the order detailed above.\n\nOnce the auction process for the week has completed, it will be reset back to £5.00 giving all business equal opportunity to promote their business.\n\nAll buninesses will be given access to the top 10 keywords or phrases and associated search stats for each group so they can see the value in each word or phrase and the amount of traffic each one generates."
        
        let attributedText = NSMutableAttributedString(string: pinPointText)
        // to the entire text
        attributedText.addAttributes(
            [.font : UIFont(name: Font.SegoeUILight, size: 15)!,
             .foregroundColor: UIColor.colorGray1],
            range: NSRange(location: 0, length: pinPointText.count))
        attributedText.addAttributes(
            [.font: UIFont(name: Font.SegoeUIBold, size: 20)!,
             .foregroundColor: UIColor.colorPrimary],
            range: (pinPointText as NSString).range(of: "How does this work?"))
        let primaryColorAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUISemibold, size: 16)!,
            .foregroundColor: UIColor.colorPrimary
        ]
        attributedText.addAttributes(primaryColorAttrs,
            range: (pinPointText as NSString).range(of: "00:00"))
        attributedText.addAttributes(primaryColorAttrs,
            range: (pinPointText as NSString).range(of: "£5.00"))
        attributedText.addAttributes(primaryColorAttrs,
            range: (pinPointText as NSString).range(of: "the 5 businesses"))
        
        txvInformation.attributedText = attributedText
        txvInformation.showsVerticalScrollIndicator = false
        txvInformation.isEditable = false
        txvInformation.isSelectable = false
        txvInformation.isHidden = true
        txvInformation.textContainerInset = UIEdgeInsets(top: 0, left: 16, bottom: 150, right: 16)
        
        txvInformation.transform = CGAffineTransform(translationX: 0, y: txvInformation.bounds.height - 100)
        
        fadeView.fadeOut(style: .top, percentage: 0.9)
        
        btnTake.setTitle("Take me to Pin Point ", for: .normal)
        btnTake.backgroundColor = .colorPrimary
        btnTake.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        btnTake.setTitleColor(.white, for: .normal)
        if #available(iOS 13.0, *) {
            btnTake.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        
        // make sure to set this after setting icon and title
        if let imageView = btnTake.imageView,
           let titleLabel = btnTake.titleLabel {
            btnTake.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageView.frame.size.width, bottom: 0, right: imageView.frame.size.width)
            btnTake.imageEdgeInsets = UIEdgeInsets(top: 0, left: titleLabel.frame.size.width, bottom: 0, right: -titleLabel.frame.size.width)
        }
        
        btnTake.layer.cornerRadius = 5
        btnTake.tintColor = .white
        btnTake.alpha = 0
        
        btnTake.transform = CGAffineTransform(translationX: 0, y: 90)
        
        view.isUserInteractionEnabled = false
    }
    
    private func setupTagView(_ container: RoundView, tagView: UIImageView, imageName: String) {
        container.borderWidth = 1.5
        container.borderColor = .colorPrimary
        
        tagView.image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        tagView.tintColor = .colorPrimary
        tagView.contentMode = .scaleAspectFit
    }
    
    private func showClickCircle() {
        circleContainer.isHidden = false
        UIView.animate(withDuration: 0.55, delay: 0.75, animations: {
            self.circleContainer.alpha = 0.2
            self.circleContainer.transform = .identity
            
        }, completion: { _ in
            self.extendContainerView()
        })
            
    }
    
    // multiple animations will be excuted
    private func extendContainerView() {
        // 1. extend container & search bar, make their corner radius to zero
        containerWidthConstraint.constant = SCREEN_WIDTH
        searchContainerWidthConstraint.constant = SCREEN_WIDTH
        UIView.animate(withDuration: 0.95, animations: {
            self.containerView.layer.cornerRadius = 0
            self.searchContainer.layer.cornerRadius = 0
            
            self.view.layoutIfNeeded()
        })
        
        // 2. move search bar to the top & rotate the arrow
        UIView.animate(withDuration: 0.95, animations: {
            self.searchContainer.transform = .identity
            self.imvRightArrow.transform = .identity
        })
        
        // 3. hide search icon & looking for - looking container
        UIView.animate(withDuration: 0.65, delay: 0.25, animations: {
            self.lookingContainer.alpha = 0.0

        }, completion: { _ in
            self.lookingContainer.isHidden = true
        })
        
        // 4. scale & hide cirlce on search view
        UIView.animate(withDuration: 0.95, animations: {
            self.circleContainer.alpha = 0.0
            self.circleContainer.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)

        }, completion: { _ in
            self.circleContainer.isHidden = true
        })
        
        // 5. highlighted search result
        highlightedContainerWidth.constant = SCREEN_WIDTH - 40
        UIView.animate(withDuration: 0.95, animations: {
            self.highlightedContainer.alpha = 1.0
            self.view.layoutIfNeeded()
        })
        
        // 6. transit tag views
        for i in 0 ..< 3 {
            let convertedFrameTo = highlightedItemViews[i].convert(highlightedItemViews[i].bounds, to: containerView)
            var convertedFrameFrom = CGRect()
            switch i {
            case 0:
                convertedFrameFrom = serviceView.convert(serviceView.bounds, to: containerView)

            case 1:
                convertedFrameFrom = imvProfile.convert(imvProfile.bounds, to: containerView)

            default:
                convertedFrameFrom = saleView.convert(saleView.bounds, to: containerView)
            }
            
            var tx = convertedFrameTo.origin.x - convertedFrameFrom.origin.x + 8
            let ty = convertedFrameTo.origin.y - convertedFrameFrom.origin.y + (highlightedItemViews[2].bounds.height - convertedFrameFrom.height)/2.0
            
            var identity = CGAffineTransform.identity
            let scaleBy = (convertedFrameTo.height - 16)/convertedFrameFrom.height
            tx -= (convertedFrameFrom.width - convertedFrameFrom.width*scaleBy)/2.0
            identity = identity.translatedBy(x: tx, y: ty)
            identity = identity.scaledBy(x: scaleBy, y: scaleBy)
            
            UIView.animate(withDuration: 0.95, animations: {
                switch i {
                case 0:
                    self.serviceView.transform = identity
                    self.serviceView.borderColor = .white
                    break

                case 1:
                    self.imvProfile.transform = identity
                    self.imvProfile.borderColor = .white
                    break

                default:
                    self.saleView.transform = identity
                    self.saleView.borderColor = .white
                }
            })
        }
        
        // skeleon view
        UIView.animate(withDuration: 0.95, delay: 0.1, options: .curveEaseInOut, animations: {
            self.highlightedSkeletonContainer.alpha = 1.0
            self.highlightedSkeletonContainer.transform = .identity
            
        }, completion: { _ in
            self.highlightedSkeletonContainer.showAnimatedSkeleton(usingColor: .colorBlue13)
        })
        
        UIView.animate(withDuration: 0.85, delay: 0.2, animations: {
            self.otherResultContainer.transform = .identity
            
        }, completion: { _ in
            self.otherResultContainer.showAnimatedSkeleton(usingColor: .colorGray7)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                self.autoScrollTextView()
            })
        })
    }
    
    private func autoScrollTextView() {
        highlightedSkeletonContainer.hideSkeleton()
        otherResultContainer.hideSkeleton()

        UIView.animate(withDuration: 0.8, animations: {
            self.otherResultContainer.alpha = 0.0

        }, completion: {_ in
            self.otherResultContainer.isHidden = true

        })

        txvInformation.isHidden = false
        UIView.animate(withDuration: 0.8, animations: {
            self.txvInformation.transform = .identity

            self.btnTake.transform = .identity
            self.btnTake.alpha = 1.0

        }, completion: { _ in
            self.view.isUserInteractionEnabled = true
        })
    }
    
    @IBAction func didTapTake(_ sender: Any) {
        let toVC = PointAuctionViewController.instance()
        navigationController?.pushViewController(toVC, animated: true)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension PinPointViewController: SkeletonTableViewDataSource, UITableViewDelegate {
    
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(otherResultTableView.bounds.height / 86.0) + 1
    }
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return PinOtherResultCell.reuseIdentifier
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(otherResultTableView.bounds.height / 86.0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PinOtherResultCell.reuseIdentifier, for: indexPath)
        return cell
    }
}

// MARK: - PinOtherResultCell
class PinOtherResultCell: UITableViewCell {
    
    static let reuseIdentifier = "PinOtherResultCell"
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var profileView: RoundView!
    @IBOutlet var skeletonViews: [UIView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        
        isSkeletonable = true
        
        container.layer.cornerRadius = 5
        container.backgroundColor = .colorGray4
        container.isSkeletonable = true
        
        profileView.isHiddenWhenSkeletonIsActive = false
        
        for skeletonView in skeletonViews {
            skeletonView.isSkeletonable = true
            skeletonView.layer.cornerRadius = 5
            skeletonView.layer.masksToBounds = true
            skeletonView.backgroundColor = .colorGray7
        }
    }
}

