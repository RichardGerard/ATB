//
//  ProfileViewController.swift
//  ATB
//
//  Created by YueXi on 4/22/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import CarbonKit
import Cosmos
import MaterialComponents.MaterialButtons
import VisualEffectView
import NBBottomSheet

class ProfileViewController: BaseViewController {
    
    static let kStoryboardID = "ProfileViewController"
    class func instance() -> ProfileViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: ProfileViewController.kStoryboardID) as? ProfileViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    let circularTransition = CircularTransition()
    
    /// Navigation
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        
        imvBack.tintColor = .colorPrimary
        imvBack.contentMode = .scaleAspectFit
        }}
    
    @IBOutlet weak var imvProfile: UIImageView!
    @IBOutlet weak var vArrowContainer: UIView!
    @IBOutlet weak var imvUpDownArrow: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUsername: UILabel! // website link for business user
    
    @IBOutlet weak var vUpgradeBusiness: UIView!
    @IBOutlet weak var imvUpgradeBusiness: UIImageView!
    
    @IBOutlet weak var starView: UIView!
    @IBOutlet weak var vStarRate: CosmosView!
    
    @IBOutlet weak var vChat: UIView!
    @IBOutlet weak var imvChat: UIImageView!
    
    @IBOutlet weak var vDrawer: UIView!
    @IBOutlet weak var imvDrawer: UIImageView!
    
    /// Followers, Followings, Posts, Notification
    @IBOutlet weak var lblFollowers: InsetLabel!
    @IBOutlet weak var lblFollowings: InsetLabel!
    
    @IBOutlet weak var followStatusContainer: UIView!
    @IBOutlet weak var imvFollowStatus: UIImageView!
    @IBOutlet weak var lblFollowStatus: UILabel!
    
    @IBOutlet weak var vNotification: UIView!
    @IBOutlet weak var lblOnOff: UILabel!
    @IBOutlet weak var imvNotification: UIImageView!
    
    /// Bio
    @IBOutlet weak var lblBio: UILabel!
    
    /// Social Links for business account
    @IBOutlet weak var vFBContainer: UIView!
    @IBOutlet weak var imvFBLogo: UIImageView!
    @IBOutlet weak var vInstaContainer: UIView!
    @IBOutlet weak var imvInstaLogo: UIImageView!
    @IBOutlet weak var vTwitterContainer: UIView!
    @IBOutlet weak var imvTwitterLogo: UIImageView!
    
    @IBOutlet weak var vCarbonTab: UIView!

    // represents that the move button is move to bottom right corner
    // so label is hidden, no need to show anymore
    private var isAddMoved: Bool = false
    // Material button has rectangle view
    @IBOutlet weak var vGradientBackground: UIView!
    @IBOutlet weak var btnAddProductService: MDCFloatingButton!
    @IBOutlet weak var lblAddProductService: UILabel!
    @IBOutlet weak var centerXAddProductService: NSLayoutConstraint!
    @IBOutlet weak var centerYAddProductService: NSLayoutConstraint!
    
    // common for normal user & business user
    lazy var postGridVC: PostGridViewController = { return PostGridViewController.instance() }()
    
    // normal user
    lazy var postListVC: PostListViewController = { return PostListViewController.instance() }()
    
    // business user
    lazy var businessStoreVC: BusinessStoreViewController = { return BusinessStoreViewController.instance() }()

    var isOwnProfile = true
    var viewingUser: UserModel? = nil
    
    // represents whether to show 'Business' or 'Normal' profile
    var isBusiness: Bool = false
    
    // represents whether the user is a 'Business' or 'Normal' user
    var isBusinessUser: Bool = false
    
    var ratings: [RatingDetailModel] = []
    
    // (Followers, Followings, Posts)
    var likeDetails: (Int, Int, Int) = (0, 0, 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        // make sure to initialize this before setting up pager
        // PostGridViewController is common for normal & business users
        postGridVC.isBusiness = isBusiness
        postGridVC.viewingUser = viewingUser
        
        if isBusiness {
            // only required storeVC
            businessStoreVC.viewingUser = viewingUser
            businessStoreVC.isOwnProfile = isOwnProfile
            
            // Store Product Load Delegate
            businessStoreVC.delegate = self
            
            loadBusinesProfile()
            
        } else {
            // list vc will only be initialized when you are browsing 'Normal' profile
            postListVC.viewingUser = viewingUser
            
            loadUserProfile()
        }
         
        // initialize like details
        if let viewingUser = viewingUser {
            // other profile
            // like details (followers, followings, and posts count)
            likeDetails = (viewingUser.followerCount, viewingUser.followCount, viewingUser.postCount)
            
        } else {
            // own profile
            // like details (followers, followings, and posts count)
            likeDetails = (g_myInfo.followerCount, g_myInfo.followCount, g_myInfo.postCount)
            
            // isOwnProfile is 'true'
            let defaultCenter = NotificationCenter.default
            defaultCenter.addObserver(self, selector: #selector(socialLinksUpdated(_:)), name: .Social_Links_Updated, object: nil)
            defaultCenter.addObserver(self, selector: #selector(bioUpdated(_:)), name: .BioUpdated, object: nil)
            defaultCenter.addObserver(self, selector: #selector(followUpdated(_:)), name: .FollowUpdated, object: nil)
            defaultCenter.addObserver(self, selector: #selector(didUpdateBusinessProfile(_:)), name: .DidUpdateBusinessProfile, object: nil)
            defaultCenter.addObserver(self, selector: #selector(didUpdateUserSettings(_:)), name: .DidUpdateUserSettings, object: nil)
        }
        
        // update like details
        updateLikeDetails()
        
        setupPager()
    }
    
    private func setupViews() {
        imvProfile.layer.cornerRadius = 24
        imvProfile.layer.masksToBounds = true
        imvProfile.contentMode = .scaleAspectFill
        
        imvUpDownArrow.layer.cornerRadius = 11
        imvUpDownArrow.layer.masksToBounds = true
        if #available(iOS 13.0, *) {
            imvUpDownArrow.image = UIImage(systemName: "arrow.up.arrow.down.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvUpDownArrow.tintColor = .colorPrimary
        vArrowContainer.isHidden = (!isOwnProfile || !isBusinessUser)
        
        if isBusiness {
            lblName.font = UIFont(name: "SegoeUI-Semibold", size: 24)
            
            lblUsername.font = UIFont(name: "SegoeUI-Light", size: 16)
            lblUsername.textColor = .colorPrimary
            
        } else {
            lblName.font = UIFont(name: "SegoeUI-Semibold", size: 26)
            
            lblUsername.font = UIFont(name: "SegoeUI-Light", size: 20)
            lblUsername.textColor = .colorGray11
        }
        
        lblName.textColor = .colorGray2
        
        // upgrade business
        if #available(iOS 13.0, *) {
            imvUpgradeBusiness.image = UIImage(systemName: "briefcase.fill")?.withRenderingMode(.alwaysTemplate)
            imvUpgradeBusiness.tintColor = .colorPrimary
        } else {
            // Fallback on earlier versions
        }
        imvUpgradeBusiness.contentMode = .scaleAspectFit
        vUpgradeBusiness.isHidden = (!isOwnProfile || isBusinessUser)
        
        /// Star rating -  Cosmos setting
        vStarRate.settings.emptyBorderColor = .colorPrimary
        vStarRate.settings.emptyColor = .clear
        vStarRate.settings.emptyBorderWidth = 2
        vStarRate.settings.filledColor = .colorPrimary
        vStarRate.settings.filledBorderColor = .colorPrimary
        vStarRate.settings.filledBorderWidth = 2
        vStarRate.settings.fillMode = .precise
        vStarRate.settings.totalStars = 1
        vStarRate.settings.updateOnTouch = false
        vStarRate.settings.filledImage = UIImage(named: "star.profile.fill")
        vStarRate.settings.emptyImage = UIImage(named: "star.profile.empty")
        
        vStarRate.rating = 0
        starView.isHidden = !isBusiness
        
        // Chat
        if #available(iOS 13.0, *) {
            imvChat.image = UIImage(systemName: "message.fill")
        } else {
            // Fallback on earlier versions
        }
        imvChat.tintColor = .colorPrimary
        imvChat.contentMode = .scaleAspectFit
        vChat.isHidden = isOwnProfile
        
        imvDrawer.image = UIImage(named: "drawer.off")
        imvDrawer.contentMode = .scaleAspectFit
        vDrawer.isHidden = !isOwnProfile
        
        lblFollowers.layer.cornerRadius = 12
        lblFollowers.layer.masksToBounds = true
        lblFollowers.backgroundColor = .colorGray7
        lblFollowers.textColor = .colorGray12
        lblFollowers.contentInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        lblFollowers.textAlignment = .center
        // Followers, Followings, Posts
        let followerTapGesture = UITapGestureRecognizer(target: self, action: #selector(followerlabelTapped(_:)))
        followerTapGesture.numberOfTapsRequired = 1
        followerTapGesture.numberOfTouchesRequired = 1
        lblFollowers.addGestureRecognizer(followerTapGesture)
        lblFollowers.isUserInteractionEnabled = true
        
        lblFollowings.layer.cornerRadius = 12
        lblFollowings.layer.masksToBounds = true
        lblFollowings.backgroundColor = .colorGray7
        lblFollowings.textColor = .colorGray12
        lblFollowings.contentInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        lblFollowings.textAlignment = .center
        let followingTapGesture = UITapGestureRecognizer(target: self, action: #selector(followinglabelTapped(_:)))
        followingTapGesture.numberOfTapsRequired = 1
        followingTapGesture.numberOfTouchesRequired = 1
        lblFollowings.addGestureRecognizer(followingTapGesture)
        lblFollowings.isUserInteractionEnabled = true
        
        // Follow Status View
        followStatusContainer.layer.cornerRadius = 12
        followStatusContainer.layer.masksToBounds = true
        
        imvFollowStatus.contentMode = .scaleAspectFit
        
        lblFollowStatus.font = UIFont(name: Font.SegoeUISemibold, size: 12)
        
        isFollowing = false
        followStatusContainer.isHidden = isOwnProfile
                
        // Notification On/Off View
        // Hide notification view when user see their own profile
        vNotification.layer.cornerRadius = 12
        vNotification.layer.masksToBounds = true
        
        imvNotification.contentMode = .scaleAspectFit
        
        lblOnOff.font = UIFont(name: Font.SegoeUILight, size: 12)
        
        isNotificationOn = false
        vNotification.isHidden = true
        vNotification.alpha = 0
        
        lblBio.font = UIFont(name: "SegoeUI-Light", size: 13)
        lblBio.textColor = .colorGray2
        lblBio.numberOfLines = 0
        
        /// Social Link Icons
        imvFBLogo.image = UIImage(named: "invite-facebook")?.withRenderingMode(.alwaysTemplate)
        imvFBLogo.tintColor = .colorPrimary
        imvFBLogo.contentMode = .scaleAspectFit
        
        imvInstaLogo.image = UIImage(named: "invite-instagram")?.withRenderingMode(.alwaysTemplate)
        imvInstaLogo.tintColor = .colorPrimary
        imvInstaLogo.contentMode = .scaleAspectFit
        
        imvTwitterLogo.image = UIImage(named: "invite-twitter")?.withRenderingMode(.alwaysTemplate)
        imvTwitterLogo.tintColor = .colorPrimary
        imvTwitterLogo.contentMode = .scaleAspectFit
        
        vFBContainer.isHidden = !isBusiness
        vInstaContainer.isHidden = !isBusiness
        vTwitterContainer.isHidden = !isBusiness
        
        vGradientBackground.layer.cornerRadius = 39
        vGradientBackground.layer.masksToBounds = true
        vGradientBackground.addGradientLayer(UIColor.colorPrimary, endColor: UIColor.colorBlue3, angle: 47)
        
        btnAddProductService.backgroundColor = .clear
        btnAddProductService.inkColor = UIColor.colorPrimary.withAlphaComponent(0.8)
        if #available(iOS 13.0, *) {
            btnAddProductService.setImage(UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnAddProductService.setImageTintColor(.white, for: .normal)
        btnAddProductService.tintColor = .white
        
        let addProductServiceStr = "No Products/Services Yet\nAdd your first!"
        lblAddProductService.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblAddProductService.textColor = .colorGray2
        lblAddProductService.textAlignment = .center
        
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUIBold, size: 20)!
        ]
        
        let addProductServiceAttributedStr = NSMutableAttributedString(string: addProductServiceStr)
        let addRange = (addProductServiceStr as NSString).range(of: "Add your first!")
        addProductServiceAttributedStr.addAttributes(boldAttrs, range: addRange)
        lblAddProductService.attributedText = addProductServiceAttributedStr
        lblAddProductService.numberOfLines = 2
        
        btnAddProductService.isHidden = !(isBusiness && isOwnProfile)
        lblAddProductService.isHidden = !(isBusiness && isOwnProfile)
        vGradientBackground.isHidden = !(isBusiness && isOwnProfile)
    }
    
    private func setupPager() {
        var tabSwipeNavigation = CarbonTabSwipeNavigation()
        
        if isBusiness {
            if #available(iOS 13.0, *) {
                let items = [iconWithTextImage("Store", font: UIFont(name: Font.SegoeUISemibold, size: 18)!, imageName: "tag.fill"), iconWithTextImage("Posts", font: UIFont(name: Font.SegoeUISemibold, size: 18)!, imageName: "rectangle.grid.2x2.fill")]

                tabSwipeNavigation = CarbonTabSwipeNavigation(items: items, delegate: self)
            } else {

                let items = ["Store", "Posts"]
                tabSwipeNavigation = CarbonTabSwipeNavigation(items: items, delegate: self)
            }

        } else {
            if #available(iOS 13.0, *) {
                var items  = [UIImage]()
                items.append(UIImage(systemName: "rectangle.grid.2x2.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                items.append(UIImage(systemName: "list.bullet.below.rectangle")?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                tabSwipeNavigation = CarbonTabSwipeNavigation(items: items, delegate: self)

            } else {
                let items = ["Grid", "List"]
                tabSwipeNavigation = CarbonTabSwipeNavigation(items: items, delegate: self)
            }
        }
        
        vCarbonTab.backgroundColor = .colorGray7
        tabSwipeNavigation.insert(intoRootViewController: self, andTargetView: vCarbonTab)
        
        // style
        tabSwipeNavigation.setIndicatorColor(.colorPrimary)
        tabSwipeNavigation.setIndicatorHeight(2.0)
        tabSwipeNavigation.setSelectedColor(.colorPrimary)
        tabSwipeNavigation.setNormalColor(.colorGray10)
        tabSwipeNavigation.toolbar.isTranslucent = false
        tabSwipeNavigation.toolbar.clipsToBounds = true
        tabSwipeNavigation.toolbar.tintColor = .white
        tabSwipeNavigation.carbonSegmentedControl?.setWidth(SCREEN_WIDTH/2.0, forSegmentAt: 0)
        tabSwipeNavigation.carbonSegmentedControl?.setWidth(SCREEN_WIDTH/2.0, forSegmentAt: 1)
        tabSwipeNavigation.setCurrentTabIndex(0, withAnimation: false)
    }
    
    private func loadBusinesProfile() {
        let businessProfile = isOwnProfile ? g_myInfo.business_profile : viewingUser!.business_profile
        
        // top profile information
        imvProfile.loadImageFromUrl(businessProfile.businessPicUrl, placeholder: "profile.placeholder")
        lblName.text = businessProfile.businessName
        lblUsername.text = businessProfile.businessWebsite
        lblBio.text = businessProfile.businessBio
        
        updateSocialLinks(with: businessProfile)
        
        getRatings(businessProfile.ID)

        guard !isOwnProfile else { return }
        
        // get followers for notificaiton settings
        getFollowers()
    }
    
    private func updateSocialLinks(with businessProfile: BusinessModel) {
        imvFBLogo.tintColor = businessProfile.fbUsername.isEmpty ? .colorGray10 : .colorPrimary
        imvInstaLogo.tintColor = businessProfile.instaUsername.isEmpty ? .colorGray10 : .colorPrimary
        imvTwitterLogo.tintColor = businessProfile.twitterUsername.isEmpty ? .colorGray10 : .colorPrimary
    }
    
    private func getRatings(_ business_id: String) {
        ratings.removeAll()
        
        let params = [
            "token" : g_myToken,
            "business_id": business_id
        ]
        
        _ = ATB_Alamofire.POST(GET_BUSINESS_REVIEWS, parameters: params as [String : AnyObject]) { (result, response) in
            guard result,
                  let ratingDicts = response.object(forKey: "msg") as? [NSDictionary] else { return }
            
            for ratingDict in ratingDicts {
                let review = RatingDetailModel()
                
                let unixTimestamp = ratingDict.object(forKey: "created_at") as? String ?? ""
                let date = Date(timeIntervalSince1970: Double(unixTimestamp)!)
                review.created = date.timeAgoSinceDate()
                review.Rating_Value = ratingDict.object(forKey: "rating") as? String ?? "0"
                review.Rating_Text = ratingDict.object(forKey: "review") as? String ?? ""
                
                guard let raterDict = ratingDict.object(forKey: "rater") as? NSDictionary else { continue }
                
                let rater = UserModel()
                
                rater.ID = raterDict.object(forKey: "id") as? String ?? ""
                rater.profile_image = raterDict.object(forKey: "pic_url") as? String ?? ""
                rater.user_name = raterDict.object(forKey: "user_name") as? String ?? ""
                rater.account_name = raterDict["first_name"] as! String + " " + (raterDict["last_name"] as! String)
                rater.firstName = raterDict.object(forKey: "first_name") as? String ?? ""
                rater.lastName = raterDict.object(forKey: "last_name") as? String ?? ""
                rater.description = raterDict.object(forKey: "description") as? String ?? ""
                
                review.Rater_Info = rater
                
                self.ratings.append(review)
            }
 
            self.updateBusinessRating()
        }
    }
    
    private func updateBusinessRating() {
        guard ratings.count > 0 else {
            vStarRate.rating = 0
            return
        }
        
        var totalRating: Double = 0.0
        for rating in ratings {
            totalRating += rating.Rating_Value.doubleValue
        }
        
        vStarRate.rating = totalRating/Double(ratings.count)
    }
    
    private func loadUserProfile() {
        if let viewingUser = viewingUser {
            imvProfile.loadImageFromUrl(viewingUser.profile_image, placeholder: "profile.placeholder")
            lblName.text = viewingUser.firstName + " " + viewingUser.lastName
            lblUsername.text = "@" + viewingUser.account_name
            lblBio.text = viewingUser.description
            
        } else {
            let ownUser = g_myInfo
            imvProfile.loadImageFromUrl(ownUser.profileImage, placeholder: "profile.placeholder")
            lblName.text = ownUser.firstName + " " + ownUser.lastName
            lblUsername.text = "@" + ownUser.userName
            lblBio.text = ownUser.description
        }
        
        guard !isOwnProfile else { return }
        
        getFollowers()
    }
    
    // get followers for the viewing user
    // check if me is in the follower list
    private var isFollowing: Bool = false { didSet {
        self.updateFollowStatus(isFollowing)
    }}
    private func updateFollowStatus(_ following: Bool) {
        followStatusContainer.backgroundColor = following ? .colorPrimary : .colorGray7
        
        if #available(iOS 13.0, *) {
            imvFollowStatus.image = following ? UIImage(systemName: "person.crop.circle.badge.checkmark") : UIImage(systemName: "person.crop.circle.badge.plus")
        } else {
            
        }
        imvFollowStatus.tintColor = following ? .white : .colorGray12
        
        lblFollowStatus.text = following ? "Following" : "Follow"
        lblFollowStatus.textColor = following ? .white : .colorGray12
        
        if following {
            vNotification.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.vNotification.alpha = 1
            })
            
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.vNotification.alpha = 0
            }, completion: {_ in
                self.vNotification.isHidden = true
                self.isNotificationOn = false
            })
        }
    }
    
    private func getFollowers() {
        guard let viewingUser = viewingUser else { return }
        
        let params = [
            "token": g_myToken,
            "follower_user_id": viewingUser.ID,
            "follower_business_id": "0"
        ]
        
        _ = ATB_Alamofire.POST(GET_FOLLOWER, parameters: params as [String: AnyObject], completionHandler: { (result, response) in
            guard result,
                  let postDicts = response.object(forKey: "msg")  as? [NSDictionary] else { return }
            
            for postDict in postDicts {
                if let follow_user_id = postDict["follow_user_id"] as? String,
                   follow_user_id == g_myInfo.ID {
                    self.isFollowing = true
                    break
                }
            }
            
            guard self.isFollowing else { return }
            
            let params = [
                "token": g_myToken,
                "follower_user_id": viewingUser.ID,
                "follow_user_id": g_myInfo.ID
            ]
            
            _ = ATB_Alamofire.POST(HAS_LIKE_NOTIFICATIONS, parameters: params as [String: AnyObject], completionHandler: { (result, response) in
                guard result else { return }
                
                if let hasNotifications = response.object(forKey: "msg") as? String,
                   hasNotifications == "1" {
                    self.isNotificationOn = true
                }
            })
        })
    }
    
    private func updateLikeDetails() {
        let boldAttrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "SegoeUI-Bold", size: 14)!]
        let normalAttrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "SegoeUI-Light", size: 13)!]
        
        let followerCount = likeDetails.0
        let followerText = followerCount > 1 ? " followers" : " follower"
        let followerNumberText = "\(followerCount)"

        let attrFollowers = NSMutableAttributedString(string: followerNumberText + followerText)
        attrFollowers.addAttributes(boldAttrs, range: NSRange(location: 0, length: followerNumberText.count))
        attrFollowers.addAttributes(normalAttrs, range: NSRange(location: followerNumberText.count, length: followerText.count))
        self.lblFollowers.attributedText = attrFollowers

        let followingCount = likeDetails.1
        let followingText = followingCount > 1 ? " followings" : " following"
        let followingNumberText = "\(followingCount)"

        let attrFollowings = NSMutableAttributedString(string: followingNumberText + followingText)
        attrFollowings.addAttributes(boldAttrs, range: NSRange(location: 0, length: followingNumberText.count))
        attrFollowings.addAttributes(normalAttrs, range: NSRange(location: followingNumberText.count, length: followingText.count))
        self.lblFollowings.attributedText = attrFollowings
    }
    
    @objc private func followinglabelTapped(_ sender: UITapGestureRecognizer) {
        let likesListVC = LikesListViewController.instance()
        
        likesListVC.isBusiness = isBusiness
        likesListVC.viewingUser = self.viewingUser
        likesListVC.isFollowers = false
        likesListVC.hidesBottomBarWhenPushed = true
        // This should be updated including these details in profile general info
        likesListVC.likeDetails = likeDetails

        self.navigationController?.pushViewController(likesListVC, animated: true)
    }
    
    @objc private func followerlabelTapped(_ sender: UITapGestureRecognizer) {
        let likesListVC = LikesListViewController.instance()

        likesListVC.viewingUser = viewingUser
        likesListVC.isFollowers = true
        likesListVC.isBusiness = isBusiness
        likesListVC.likeDetails = likeDetails
        likesListVC.hidesBottomBarWhenPushed = true

        self.navigationController?.pushViewController(likesListVC, animated: true)
    }
    
    // MARK: Notification Handlers
    @objc private func didUpdateBusinessProfile(_ notification: Notification) {
        guard isBusiness,
              isOwnProfile else { return }
        
        DispatchQueue.main.async {
            let businessProfile = g_myInfo.business_profile
            self.imvProfile.loadImageFromUrl(businessProfile.businessPicUrl, placeholder: "profile.placeholder")
            self.lblName.text = businessProfile.businessName
            self.lblUsername.text = businessProfile.businessWebsite
            self.lblBio.text = businessProfile.businessBio
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func didUpdateUserSettings(_ notification: Notification) {
        guard isOwnProfile,
              !isBusiness else { return }
        
        DispatchQueue.main.async {
            let ownUser = g_myInfo
            self.imvProfile.loadImageFromUrl(ownUser.profileImage, placeholder: "profile.placeholder")
            self.lblName.text = ownUser.firstName + " " + ownUser.lastName
            self.lblUsername.text = "@" + ownUser.userName
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func bioUpdated(_ notificaiton: Notification) {
        DispatchQueue.main.async {
            if self.isBusiness {
                self.lblBio.text = g_myInfo.business_profile.businessBio
                
            } else {
                self.lblBio.text = g_myInfo.description
            }
            
            UIView.animate(withDuration: 0.35) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func followUpdated(_ notification: Notification) {
        guard isOwnProfile else { return }
        
        // like details (followers, followings, and posts count)
        likeDetails = (g_myInfo.followerCount, g_myInfo.followCount, g_myInfo.postCount)
        
        updateLikeDetails()
    }
    
    @objc func socialLinksUpdated(_ notification: Notification) {
        // when you get here
        // the social names have been updated already
        
        DispatchQueue.main.async {
            self.updateSocialLinks(with: g_myInfo.business_profile)
        }
    }
    
    // transitioningDelgegate is a weak property
    // for dismissed protocol, we need to make it a class variable
    let sheetTransitioningDelegate = NBBottomSheetTransitioningDelegate()
    @IBAction func didTapProfile(_ sender: Any) {
        guard isOwnProfile else { return }
        
        var users = [UserModel]()
        
        let normalUser = UserModel()
        normalUser.ID = g_myInfo.ID
        normalUser.user_type = "User"
        normalUser.user_name = g_myInfo.userName
        normalUser.profile_image = g_myInfo.profileImage
        users.append(normalUser)
        
        if g_myInfo.isBusiness {
            // if business profile is approved
            let businessUser = UserModel()
            businessUser.ID = g_myInfo.business_profile.ID
            businessUser.user_type = "Business"
            businessUser.user_name = g_myInfo.business_profile.businessProfileName
            businessUser.profile_image = g_myInfo.business_profile.businessPicUrl
            users.append(businessUser)
        }
        
        // check profile switch validation
        guard users.count > 1 else { return }
        
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35
        configuruation.sheetDirection = .top
        
        let heightForOptionSheet: CGFloat =  243 // (233 + 10 - cornerRaidus addition value)
        
        configuruation.sheetSize = .fixed(heightForOptionSheet)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        
        let topSheetController = NBBottomSheetController(configuration: configuruation, transitioningDelegate: sheetTransitioningDelegate)
        
        /// show action sheet with options (Edit or Delete)
        let selectVC = ProfileSelectViewController.instance()
        selectVC.users = users
        selectVC.selectedIndex = isBusiness ? 1 : 0
        selectVC.delegate = self
        
        topSheetController.present(selectVC, on: self)
    }
    
    @IBAction func didTapFollow(_ sender: Any) {
        guard let follower = viewingUser else { return }
        let url = isFollowing ? DELETE_FOLLOWER : ADD_FOLLOW
        
        // follow - always me, follower - always others
        let followUserID = g_myInfo.ID
        let followerUserID = follower.ID
        
        var params = [
            "token": g_myToken,
            "follow_user_id": followUserID,
            "follower_user_id": followerUserID
        ]
        
        if !isFollowing {
            params["follow_business_id"] = "0"
            params["follower_business_id"] = "0"
        }
        
        showIndicator()
        _ = ATB_Alamofire.POST(url, parameters: params as [String: AnyObject], completionHandler: { (result, response) in
            self.hideIndicator()
            
            if self.isFollowing {
                if result {
                    self.isFollowing = false
                    g_myInfo.followCount = ((g_myInfo.followCount - 1) > 0 ? (g_myInfo.followCount - 1) : 0)
                    
                    follower.followerCount = ((follower.followerCount - 1) > 0 ? (follower.followerCount - 1) : 0)
                    // like details (followers, followings, and posts count)
                    self.likeDetails.0 = follower.followerCount
                    
                    self.updateLikeDetails()
                    
                } else {
                    self.showErrorVC(msg: "Failed to remove the follow, please try again later.")
                }
                
            } else {
                if result {
                    self.isFollowing = true
                    g_myInfo.followCount += 1
                    
                    follower.followerCount += 1
                    // like details (followers, followings, and posts count)
                    self.likeDetails.0 = follower.followerCount
                    
                    self.updateLikeDetails()
                    
                } else {
                    self.showErrorVC(msg: "Failed to add the follow, please try again later.")
                }
            }
        })
    }
    
    private var isNotificationOn: Bool = false { didSet {
        self.updateNotificationView(isNotificationOn)
    }}
    @IBAction func didTapNotiButton(_ sender: Any) {
        let notifications = isNotificationOn ? "0" : "1"
        
        guard let viewingUser = viewingUser else { return }
        
        let params = [
            "token": g_myToken,
            "follower_user_id": viewingUser.ID,
            "follow_user_id": g_myInfo.ID,
            "notifications": notifications
        ]
        
        showIndicator()
        _ = ATB_Alamofire.POST(LIKE_NOTIFICATIONS, parameters: params as [String: AnyObject], completionHandler: { (result, _) in
            self.hideIndicator()
            
            guard result else { return }
            
            self.isNotificationOn = !self.isNotificationOn
            self.showNotificationMessage(self.isNotificationOn)
        })
    }
        
    private func showNotificationMessage(_ isOn: Bool) {
        let toastView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 32, height: 65))
        toastView.backgroundColor = .clear
        toastView.layer.cornerRadius = 5
        toastView.layer.masksToBounds = true
        
        let blurEffectView = VisualEffectView()
        blurEffectView.frame = toastView.frame
        blurEffectView.colorTint = UIColor.black
        blurEffectView.colorTintAlpha = 0.35
        blurEffectView.blurRadius = 6
        blurEffectView.scale = 1
        toastView.insertSubview(blurEffectView, at: 0)
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        toastView.addSubview(imageView)
        toastView.addSubview(label)
    
        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: toastView.leftAnchor, constant: 20),
            imageView.centerYAnchor.constraint(equalTo: toastView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30),
            label.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 20),
            label.rightAnchor.constraint(equalTo: toastView.rightAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
        ])
        
        if isOn {
            if #available(iOS 13.0, *) {
                imageView.image = UIImage(systemName: "bell.fill")
            } else {
                // Fallback on earlier versions
            }

            label.text = "The notification are now\nActive for this account"

        } else {
            if #available(iOS 13.0, *) {
                imageView.image = UIImage(systemName: "bell.slash.fill")
            } else {
                // Fallback on earlier versions
            }

            label.text = "The notification have been\nDisabled for this user"
        }
        
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        
        label.font = UIFont(name: Font.SegoeUILight, size: 18)
        label.textColor = .white
        label.numberOfLines = 0
        
        showToast(toastView, position: .bottom)
    }
     
    private func updateNotificationView(_ isOn: Bool) {
        vNotification.backgroundColor = isOn ? .colorPrimary : .colorGray7
        
        if #available(iOS 13.0, *) {
            imvNotification.image = isOn ? UIImage(systemName: "bell.fill") : UIImage(systemName: "bell.slash.fill")
        } else {
            // Fallback on earlier versions
        }
        imvNotification.tintColor = isOn ? .white : .colorGray12
        
        lblOnOff.text = isOn ? "ON" : "OFF"
        lblOnOff.textColor = isOn ? .white : .colorGray12
    }
    
    @IBAction func didTapUpgradeBusiness() {
        let businessVC = BusinessSignViewController.instance()
        
        let nvc = UINavigationController(rootViewController: businessVC)
        nvc.modalPresentationStyle = .overFullScreen
        nvc.isNavigationBarHidden = true
        
        present(nvc, animated: true, completion: nil)
    }
    
    @IBAction func didTapRating(_ sender: Any) {
        guard isBusiness else { return }
        
        let ratingDetailsVC = RatingDetailsViewController.instance()
        ratingDetailsVC.ratings = ratings
        ratingDetailsVC.viewingUser = viewingUser
        ratingDetailsVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(ratingDetailsVC, animated: true)
    }
    
    @IBAction func didTapChat(_ sender: Any) {
        guard let viewingUser = viewingUser else { return }
        
        let conversationVC = ConversationViewController()
        if isBusiness && isBusinessUser {
            conversationVC.userId = viewingUser.business_profile.ID + "_" + viewingUser.ID
            
        } else {
            conversationVC.userId = viewingUser.ID
        }
        
        conversationVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(conversationVC, animated: true)
    }
    
    @IBAction func didTapDrawer(_ sender: Any) {
        self.slideMenuController()?.openRight()
    }
        
    @IBAction func didTapFacebook(_ sender: Any) {
        let businessProfile = isOwnProfile ? g_myInfo.business_profile : viewingUser!.business_profile
        
        guard !businessProfile.fbUsername.isEmpty else { return }
        
        let username = businessProfile.fbUsername
        guard let appURL = URL(string: "fb://profile/\(username)") else {
            showErrorVC(msg: "Facebook profile link is invalid")
            return
        }
        
        let application = UIApplication.shared
        if application.canOpenURL(appURL) {
            application.open(appURL, options: [:], completionHandler: nil)
            
        } else {
            guard let webURL = URL(string: "https://www.facebook.com/\(username)") else {
                showErrorVC(msg: "Facebook profile link is invalid")
                return
            }
            
            application.open(webURL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func didTapInstagram(_ sender: Any) {
        let businessProfile = isOwnProfile ? g_myInfo.business_profile : viewingUser!.business_profile
        
        guard !businessProfile.instaUsername.isEmpty else { return }
        
        let username = businessProfile.instaUsername
        guard let appURL = URL(string: "instagram://user?username=/\(username)") else {
            showErrorVC(msg: "Instgram profile link is invalid.")
            return
        }
        
        let application = UIApplication.shared
        if application.canOpenURL(appURL) {
            application.open(appURL, options: [:], completionHandler: nil)
            
        } else {
            guard let webURL = URL(string: "https://instagram.com/\(username)") else {
                showErrorVC(msg: "Instgram profile link is invalid.")
                return
            }
            
            application.open(webURL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func didTapTwitter(_ sender: Any) {
        let businessProfile = isOwnProfile ? g_myInfo.business_profile : viewingUser!.business_profile
        
        guard !businessProfile.twitterUsername.isEmpty else { return }
        
        let username = businessProfile.twitterUsername
        guard let appURL = URL(string: "twitter://user?screen_name/\(username)") else {
            showErrorVC(msg: "Twitter profile link is invalid.")
            return
        }
        
        let application = UIApplication.shared
        if application.canOpenURL(appURL) {
            application.open(appURL, options: [:], completionHandler: nil)
            
        } else {
            guard let webURL = URL(string: "https://twitter.com/\(username)") else {
                showErrorVC(msg: "Twitter profile link is invalid.")
                return
            }
            
            application.open(webURL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func didTapAddProductService(_ sender: Any) {
        let selectVC = AddSelectViewController.instance()
        // set the delegate and AddSelectViewController will send over this delegate
        // we will get each update called in here
        selectVC.delegate = self
        
        //
        let nvc = UINavigationController(rootViewController: selectVC)
        nvc.isNavigationBarHidden = true
        
        nvc.transitioningDelegate = self
        nvc.modalPresentationStyle = .custom
        
        self.present(nvc, animated: true)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - CarbonTabSwipeNavigationDelegate
extension ProfileViewController: CarbonTabSwipeNavigationDelegate {
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        if index == 0 {
            return isBusiness ? businessStoreVC : postGridVC
            
        } else {
            return isBusiness ? postGridVC : postListVC
        }
    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, willMoveAt index: UInt) {
        guard isBusiness,
            isOwnProfile else {
            return
        }
        
        if index == 0 {
            vGradientBackground.isHidden = false
            btnAddProductService.isHidden = false
            
            guard !isAddMoved else {
                return
            }
            
            lblAddProductService.isHidden = false
            
        } else {
            vGradientBackground.isHidden = true
            btnAddProductService.isHidden = true
            
            guard !isAddMoved else {
                return
            }
            
            lblAddProductService.isHidden = true
        }
    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, didMoveAt index: UInt) {
        
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension ProfileViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        circularTransition.transitionMode = .dismiss
        circularTransition.startingPoint = btnAddProductService.center
        circularTransition.circleColor = UIColor.colorPrimary.withAlphaComponent(0.8)
        
        return circularTransition
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        circularTransition.transitionMode = .present
        circularTransition.startingPoint = btnAddProductService.center
        circularTransition.circleColor = UIColor.colorPrimary.withAlphaComponent(0.8)
        
        return circularTransition
    }
}

// MARK: - StoreLoadDelegate
extension ProfileViewController: StoreLoadDelegate {
    
    func didLoadStoreProducts(_ hasProducts: Bool) {
        guard hasProducts,
            isBusiness,
            isOwnProfile,
            !isAddMoved else {
            return
        }
        
        moveAddButton(true)
    }
    
    private func moveAddButton(_ animated: Bool) {
        lblAddProductService.isHidden = true
        isAddMoved = true

        if animated {
            centerXAddProductService.constant = SCREEN_WIDTH / 2.0 - 75
            centerYAddProductService.constant = vCarbonTab.bounds.height / 2.0 - 75
            
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
            }
            
        } else {
            centerXAddProductService.constant = SCREEN_WIDTH / 2.0 - 75
            centerYAddProductService.constant = vCarbonTab.bounds.height / 2.0 - 75
        }
    }
}

// MARK: - BusinessAddDelegate
extension ProfileViewController: BusinessAddDelegate {
    
    func didAddNewProducts(_ items: [PostToPublishModel]) {
        // no need to check this
        // delegate will be dispatched in case of business
        // for safe run
        guard isBusiness else { return }
        
        businessStoreVC.loadStoreItems()
    }
    
    func didAddNewService(_ item: PostToPublishModel) {
        // no need to check this
        // delegate will be dispatched in case of business
        // for safe run
        guard isBusiness else { return }
        
        businessStoreVC.loadStoreItems()
    }
}

//MARK: - ProfileSelectDelegate
extension ProfileViewController: ProfileSelectDelegate {
    
    // This will be called only when profile has been switched/changed
    func profileSelected(_ selectedIndex: Int) {
        guard var viewControllers = self.navigationController?.viewControllers,
              viewControllers.count > 1 else {
            return
        }
        
        // pop the current/last view controller which is 'ProfileViewController'
        viewControllers.removeLast()
        
        SlideMenuOptions.contentViewScale = 1.0
        SlideMenuOptions.leftViewWidth = SCREEN_WIDTH - 104
        // profile controller
        let newProfileVC = ProfileViewController.instance()
        newProfileVC.isBusiness = (selectedIndex == 1)
        newProfileVC.isBusinessUser = g_myInfo.isBusiness
        
        // menu controller
        let menuVC = ProfileMenuViewController.instance()
        menuVC.isBusiness = (selectedIndex == 1)
        menuVC.isBusinessUser = g_myInfo.isBusiness

        let slideController = ExSlideMenuController(mainViewController: newProfileVC, rightMenuViewController: menuVC)
        
        viewControllers.append(slideController)
        
        self.navigationController?.setViewControllers(viewControllers, animated: true)
    }
}
