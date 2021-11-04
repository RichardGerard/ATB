//
//  PostExistingViewController.swift
//  ATB
//
//  Created by YueXi on 7/28/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import NBBottomSheet

class PostExistingViewController: BaseViewController {
    
    static let kStoryboardID = "PostExistingViewController"
    class func instance() -> PostExistingViewController {
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: PostExistingViewController.kStoryboardID) as? PostExistingViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var vNavigation: UIView!
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        
        imvBack.tintColor = .colorPrimary
        imvBack.contentMode = .scaleAspectFit
    }}
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var vProfileContainer: UIView!
    @IBOutlet weak var imvProfile: RoundImageView! { didSet {
        imvProfile.contentMode = .scaleAspectFill
        }}
    
    @IBOutlet weak var vAllCreatedContainer: UIView!
    @IBOutlet weak var lblAllCreated: UILabel!
    
    @IBOutlet weak var tblCreated: UITableView!
    
    @IBOutlet weak var vPublishAllCheckbox: CheckBox!
    @IBOutlet weak var lblPublishAll: UILabel!
    
    private lazy var calendarView: ScheduleCalendarView = {
        let view = ScheduleCalendarView.instantiate(autolayout: false)
        view.backgroundColor = .clear
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return view
    }()
    
    @IBOutlet weak var postBtnShadowContainer: UIView! { didSet {
        postBtnShadowContainer.backgroundColor = .clear
        postBtnShadowContainer.layer.shadowColor = UIColor.black.cgColor
        postBtnShadowContainer.layer.shadowRadius = 4
        postBtnShadowContainer.layer.shadowOpacity = 0.22
        postBtnShadowContainer.layer.shadowOffset = CGSize(width: 1, height: 2)
        postBtnShadowContainer.layer.cornerRadius = 5
    }}
    @IBOutlet weak var btnPostRightContraint: NSLayoutConstraint!
    @IBOutlet weak var btnPost: UIButton!
    
    @IBOutlet weak var scheduleShadowContainer: UIView! { didSet {
        scheduleShadowContainer.backgroundColor = .clear
        scheduleShadowContainer.layer.shadowColor = UIColor.black.cgColor
        scheduleShadowContainer.layer.shadowRadius = 4
        scheduleShadowContainer.layer.shadowOpacity = 0.22
        scheduleShadowContainer.layer.shadowOffset = CGSize(width: 1, height: 2)
        scheduleShadowContainer.layer.cornerRadius = 5
    }}
    @IBOutlet weak var scheduleContainer: UIView! { didSet {
        scheduleContainer.layer.cornerRadius = 5
        scheduleContainer.layer.masksToBounds = true
    }}
    @IBOutlet weak var scheduleContainerWidth: NSLayoutConstraint!
    @IBOutlet weak var imvCalendar: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvCalendar.image = UIImage(systemName: "calendar.badge.plus")
        } else {
            // Fallback on earlier versions
        }
        imvCalendar.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var scheduleBtnContainer: UIView!
    @IBOutlet weak var imvClose: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvClose.image = UIImage(systemName: "xmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvClose.tintColor = UIColor.white.withAlphaComponent(0.26)
    }}
    
    @IBOutlet weak var lblScheduleTitle: UILabel!
    
    @IBOutlet weak var profileSelectContainer: UIView!
    @IBOutlet weak var imvSelectArrow: UIImageView! { didSet {
        imvSelectArrow.layer.cornerRadius = 11
        imvSelectArrow.layer.masksToBounds = true
        if #available(iOS 13.0, *) {
            imvSelectArrow.image = UIImage(systemName: "arrow.up.arrow.down.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvSelectArrow.tintColor = .colorPrimary
    }}
    
    private var users = [UserModel]()
    private var selectedUser: UserModel!
    
    var isSales: Bool = true
    var postToPublish = [PostToPublishModel]()
    
    var postSelected = [Bool]()
    
    var scheduledDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        getUserPosts()
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
        lblTitle.text = isSales ? "Create a\nProduct Post" : "Post a Service"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 26)
        lblTitle.textColor = .colorGray2
        lblTitle.numberOfLines = isSales ? 2 : 1
        if isSales {
            lblTitle.setLineSpacing(lineHeightMultiple: 0.75)
        }
        
        vAllCreatedContainer.layer.cornerRadius = 5
        vAllCreatedContainer.layer.masksToBounds = true
        vAllCreatedContainer.backgroundColor = .colorPrimary
        
        lblAllCreated.text = isSales ? "All created your producuts" : "All your created services"
        lblAllCreated.font = UIFont(name: Font.SegoeUIBold, size: 16)
        lblAllCreated.textColor = .white
        
        lblPublishAll.text = "Publish all as post"
        lblPublishAll.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblPublishAll.textColor = .colorGray1
        
        vPublishAllCheckbox.borderStyle = .roundedSquare(radius: 2)
        vPublishAllCheckbox.style = .tick
        vPublishAllCheckbox.borderWidth = 2
        vPublishAllCheckbox.tintColor = .colorPrimary
        vPublishAllCheckbox.uncheckedBorderColor = .colorPrimary
        vPublishAllCheckbox.checkedBorderColor = .colorPrimary
        vPublishAllCheckbox.checkmarkSize = 0.8
        vPublishAllCheckbox.checkmarkColor = .colorPrimary
        vPublishAllCheckbox.checkboxBackgroundColor = .colorPrimary
        vPublishAllCheckbox.isUserInteractionEnabled = false
        
        let postTitle = isSales ? "Post selected Products" : "Post these services as post"
        btnPost.setTitle(postTitle, for: .normal)
        btnPost.setTitleColor(.white, for: .normal)
        btnPost.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        btnPost.backgroundColor = .colorPrimary
        btnPost.layer.cornerRadius = 5
        btnPost.layer.masksToBounds = true
        
        tblCreated.backgroundColor = .clear
        tblCreated.separatorStyle = .none
        tblCreated.tableFooterView = UIView()
        tblCreated.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tblCreated.rowHeight = ExistingPostCell.rowHeight
        tblCreated.dataSource = self
        tblCreated.delegate = self
        
        profileSelectContainer.isHidden = !(isSales && g_myInfo.isBusiness)
        initUserOption()
        
        scheduleBtnContainer.isHidden = true
        scheduleContainerWidth.constant = 78
        
        lblScheduleTitle.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblScheduleTitle.textColor = .white
        lblScheduleTitle.numberOfLines = 2
        lblScheduleTitle.minimumScaleFactor = 0.75
        lblScheduleTitle.adjustsFontSizeToFitWidth = true
        lblScheduleTitle.setLineSpacing(lineHeightMultiple: 0.75)
                
        updateScheduleTitle(withDate: scheduledDate)
    }
    
    private func updateScheduleTitle(withDate selected: Date) {
        let formattedDate = selected.toString("d'\(selected.daySuffix()) of 'MMMM - h:mm a", timeZone: .current)
        let scheduleTitle = "Schedule Post on:\n" + formattedDate
        let attributedScheduleTitle = NSMutableAttributedString(string: scheduleTitle)
        
        let dateRange = (scheduleTitle as NSString).range(of: formattedDate)
        attributedScheduleTitle.addAttributes([
            .font: UIFont(name: Font.SegoeUILight, size: 21)!
        ], range: dateRange)
        
        lblScheduleTitle.attributedText = attributedScheduleTitle
    }
    
    private func initUserOption() {
        users.removeAll()
        
        let normalUser = UserModel()
        normalUser.user_type = "User"
        normalUser.ID = g_myInfo.ID
        normalUser.user_name = g_myInfo.userName
        normalUser.profile_image = g_myInfo.profileImage
        users.append(normalUser)
        
        // check for account type - business
        if(g_myInfo.isBusiness) {
            let businessUser = UserModel()
            businessUser.user_type = "Business"
            businessUser.ID = g_myInfo.business_profile.ID
            businessUser.user_name = g_myInfo.business_profile.businessProfileName
            businessUser.profile_image = g_myInfo.business_profile.businessPicUrl
            users.append(businessUser)
        }
        
        if isSales {
            btnPostRightContraint.constant = 16
            scheduleContainer.isHidden = true
            
            selectedUser = users[0] // normal profile as default
            
        } else {
            selectedUser = users[1]
        }
        
        imvProfile.loadImageFromUrl(selectedUser.profile_image, placeholder: "profile.placeholder")
    }
    
    // transitioningDelgegate is a weak property
    // for dismissed protocol, we need to make it a class variable
    let sheetTransitioningDelegate = NBBottomSheetTransitioningDelegate()
    
    @IBAction func didTapProfile(_ sender: Any) {
        // posing a service is available for only business users
        guard isSales else { return }
        
        // show user selection when user has a business profile even if this is sales post
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
        selectVC.selectedIndex = selectedUser.isBusiness ? 1 : 0
        selectVC.delegate = self
        
        topSheetController.present(selectVC, on: self)
    }
    
    @IBAction func didTapPublishAll(_ sender: Any) {
        vPublishAllCheckbox.isChecked = !vPublishAllCheckbox.isChecked
        
        let isAllSelected = vPublishAllCheckbox.isChecked
        for i in 0 ..< postSelected.count {
            self.postSelected[i] = isAllSelected
        }
        
        tblCreated.reloadData()
    }
    
    private func isValidMakePost() -> Bool {
        guard selectedUser.isBusiness else { return true }
        
        let business = g_myInfo.business_profile
        guard business.isApproved else {
            if business.isPaid {
                alertForBusinessStatus(isPending: business.isPending)
                
            } else {
                alertToSubscribeBusiness()
            }
            
            return false
        }
        
        return true
    }
    
    private func alertForBusinessStatus(isPending: Bool) {
        let title = isPending ? "Pending!" : "Rejected!"
        var message = isPending ? "Your business account is currently pending for approval.\nATB admin will review your account and update soon!" : "Your business profile has been rejected!"
        
        let business = g_myInfo.business_profile
        if !isPending,
           !business.approvedReason.isEmpty {
            message += "\nReason: " + business.approvedReason
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // contact admin
        let contactAction = UIAlertAction(title: "Contact Admin", style: .default) { _ in
            let email = "support@myatb.co.uk"
            if let url = URL(string: "mailto:\(email)") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        alertController.addAction(contactAction)
        
        // close action
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel))
        alertController.view.tintColor = .colorPrimary
        self.present(alertController, animated: true, completion:nil)
    }
    
    private func alertToSubscribeBusiness() {
        let title = "You didn't subscribe for your business account yet!\nWould you like to subscribe now?"
        let alert = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            // subscribe
            self.gotoSubscribe()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default))
        alert.view.tintColor = .colorPrimary
        self.present(alert, animated: true)
    }
    
    private func gotoSubscribe() {
        let subscribeVC = SubscribeBusinessViewController.instance()
        subscribeVC.modalPresentationStyle = .overFullScreen
        subscribeVC.delegate = self
        
        self.present(subscribeVC, animated: true, completion: nil)
    }
    
    @IBAction func didTapPost(_ sender: Any) {
        preparePosts(withScheduled: false)
    }
    
    @IBAction func didTapSchedulePost(_ sender: Any) {
        preparePosts(withScheduled: true)
    }
    
    private func preparePosts(withScheduled scheduled: Bool) {
        var selectedPostToPublish = [PostToPublishModel]()
        
        for (index, selected) in postSelected.enumerated() {
            if selected {
                selectedPostToPublish.append(postToPublish[index])
            }
        }
        
        guard selectedPostToPublish.count > 0 else {
            showErrorVC(msg: "Please select a \(isSales ? "product" : "service") to post.")
            return
        }
        
        guard isValidMakePost() else { return }
        
        showIndicator()
        let schedule = "\(Int64(scheduledDate.timeIntervalSince1970))"
        
        print(schedule)
        
        // need to check if user is limited to post
        let url = isSales ? COUNT_SALE_POST : COUNT_SERVICE_POST
        let params = [
            "token": g_myToken
        ]
        
        _ = ATB_Alamofire.POST(url, parameters: params as [String: AnyObject], showLoading: false, showSuccess: false, showError: false, completionHandler: { (result, responseObject) in
            if result,
                let ok = responseObject["result"] as? Bool,
                ok {
                if selectedPostToPublish.count > 1 {
                    // post all selected posts as a multiple post
                    self.createMultiplePosts(selectedPostToPublish, scheduledOn: scheduled ? schedule : "")

                } else {
                    // post a single selected post
                    self.createPost(selectedPostToPublish[0], scheduledOn: scheduled ? schedule : "")
                }
                
            } else {
                self.hideIndicator()
                
                if self.isSales {
                    self.showErrorVC(msg: "You may only post 10 sales posts within 30 days.")
                    
                } else {
                    self.showErrorVC(msg: "You may only post 3 service posts a day.")
                }
            }
        })
    }
  
    private let calendarViewTag = 32345
    @IBAction func didTapCalendar(_ sender: Any) {
        scheduleContainer.backgroundColor = .colorPrimary
        
        imvCalendar.tintColor = .white
        
        scheduleShadowContainer.layer.cornerRadius = 13
        scheduleShadowContainer.layer.shadowRadius = 13
        
        scheduleContainer.layer.cornerRadius = 13
        scheduleContainer.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        scheduleContainerWidth.constant = SCREEN_WIDTH - 32
        
//        postBtnShadowContainer.isHidden = true
        
        scheduleBtnContainer.isHidden = false
        
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
            
        } completion: { _ in
            self.postBtnShadowContainer.isHidden = true
        }
        
        let heightForCalendarView: CGFloat = 400.0
        calendarView.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 32, height: heightForCalendarView)
        calendarView.tag = calendarViewTag
        calendarView.delegate = self
        
        view.addSubview(calendarView)
        calendarView.frame.origin.x = SCREEN_WIDTH
        calendarView.frame.origin.y = SCREEN_HEIGHT - (30 + 68 + 8 + heightForCalendarView)
        
        // Adding a shadow.
        calendarView.layer.shadowColor = UIColor.black.cgColor
        calendarView.layer.shadowRadius = 4
        calendarView.layer.shadowOpacity = 0.22
        calendarView.layer.cornerRadius = 13
        calendarView.layer.shadowOffset = CGSize(width: 1, height: -2)
        calendarView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        UIView.animate(withDuration: 0.35) {
            self.calendarView.transform = CGAffineTransform(translationX: -(SCREEN_WIDTH-16), y: 0)
        }
    }
    
    @IBAction func didTapScheduleClose(_ sender: Any) {
        postBtnShadowContainer.isHidden = false
        
        scheduleContainer.backgroundColor = .white
        
        imvCalendar.tintColor = .colorPrimary
        
        scheduleShadowContainer.layer.cornerRadius = 5
        scheduleShadowContainer.layer.shadowRadius = 5
        
        scheduleContainer.layer.cornerRadius = 5
        scheduleContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner,
                                                 .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        scheduleContainerWidth.constant = 78
        
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
            
        } completion: { _ in
            self.scheduleBtnContainer.isHidden = true
        }
        
        if let calendarView = view.viewWithTag(calendarViewTag) {
//            let slideToRight = CGAffineTransform(translationX: SCREEN_WIDTH, y: 0)
            UIView.animate(withDuration: 0.35) {
                calendarView.transform = .identity
                
            } completion: { _ in
                calendarView.removeFromSuperview()
            }
        }
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // This will get user's products or services
    // So 'id' in return will be the product or service id
    private func getUserPosts() {
        let isBusiness = isSales ? (selectedUser.isBusiness ? "1" : "0") : "1"
        let userID = g_myInfo.ID
        let url = isSales ? GET_USER_PRODUCTS : GET_USER_SERVICES
        
        var params = [
            "token" : g_myToken,
            "user_id": userID
        ]
        
        if isSales {
            params["is_business"] = isBusiness
        }
        
        showIndicator()
        _ = ATB_Alamofire.POST(url, parameters: params as [String : AnyObject], showLoading: false, showSuccess: false, showError: false) { (result, responseObject) in
            self.hideIndicator()

            self.postToPublish.removeAll()
            self.postSelected.removeAll()
            
            let postDicts = responseObject.object(forKey: self.isSales ? "msg" : "extra")  as? [NSDictionary] ?? []
            
            for postDict in postDicts {
                let item = PostModel(info: postDict) // This will be either a service or a product
                
                if item.isActive {
                    let itemToPublish = PostToPublishModel(item)
                    itemToPublish.type = self.isSales ? "2" : "3"
                    itemToPublish.profile_type = isBusiness
                
                    self.postToPublish.append(itemToPublish)
                    self.postSelected.append(false)
                }
            }
            
            self.tblCreated.reloadData()
        }
    }
    
    private func createPost(_ selectedPostToPublish: PostToPublishModel, scheduledOn: String = "") {
        let profileType = isSales ? (selectedUser.isBusiness ? "1" : "0") : "1"
        let mediaType = selectedPostToPublish.isVideo ? "2" : "1"
        let postType = isSales ? "2" : "3"
        
        var params = [
            "token" : g_myToken,
            "type" : postType,
            "media_type" : mediaType,
            "profile_type" : profileType,
            "title" : selectedPostToPublish.title,
            "description" : selectedPostToPublish.description,
            "brand" : selectedPostToPublish.brand,
            "price" : selectedPostToPublish.price,
            "category_title" : selectedPostToPublish.category_title,
            "post_condition": selectedPostToPublish.post_condition,
            "post_tags": selectedPostToPublish.post_tags,
            "item_title" : selectedPostToPublish.item_title,
            "payment_options" : selectedPostToPublish.payment_options,
            "location_id" : selectedPostToPublish.location_id,
            "delivery_option" : selectedPostToPublish.delivery_option,
            "delivery_cost" : selectedPostToPublish.deliveryCost,
            "deposit" : selectedPostToPublish.depositAmount,
            "lat" : selectedPostToPublish.lat,
            "lng" : selectedPostToPublish.lng,
            "is_multi" : "0"
        ]
        
        if !scheduledOn.isEmpty {
            params["scheduled"] = scheduledOn
        }
        
        if selectedPostToPublish.mediaUrls.count > 0 {
            var post_img_uris = ""
            for url in selectedPostToPublish.mediaUrls {
                post_img_uris += (url + ",")
            }
            
            post_img_uris = String(post_img_uris.dropLast())
            
            params["post_img_uris"] = post_img_uris
        }
        
        if isSales {
            params["product_id"] = selectedPostToPublish.id
            params["stock_level"] = selectedPostToPublish.stock_level
            
        } else {
            params["is_deposit_required"] = selectedPostToPublish.depositRequired
            params["cancellations"] = selectedPostToPublish.cancellations
            params["insurance_id"] = selectedPostToPublish.insuranceID
            params["qualification_id"] = selectedPostToPublish.qualificationID
            
            params["service_id"] = selectedPostToPublish.id
        }
        
        ATB_Alamofire.shareInstance.upload(multipartFormData: { multipartFormData in
            for (key, value) in params  {
                multipartFormData.append((value.data(using: .utf8)!), withName: key)
            }            
        }, to: CREATE_POST_API, usingThreshold: multipartFormDataEncodingMemoryThreshold, method: .post, headers: nil, interceptor: nil, fileManager: FileManager.default).responseJSON { (response) in
            self.hideIndicator()
            
            switch response.result {
            case .success(let JSON):
                let res = JSON as! NSDictionary
                if let ok = res["result"] as? Bool,
                    ok {
                        self.didCompletePost()
                    
                    } else  {
                        let msg = res["msg"] as? String ?? ""
                        
                        if msg == "" {
                            self.showErrorVC(msg: "Failed to create a new post, please try again")
                            
                        } else  {
                            self.showErrorVC(msg: "Server returned the error message: " + msg)
                        }
                    }
                
                break
                
            case .failure(_):
                self.showErrorVC(msg: "Failed to create post, please try again.")
                break
            }
        }
    }
    
    private func createMultiplePosts(_ selectedPostToPublish: [PostToPublishModel], scheduledOn: String = "") {
        var postedCount = 0
        
        let params = [
            "token" : g_myToken
        ]
        
        let profileType = isSales ? (selectedUser.isBusiness ? "1" : "0") : "1"
        let postType = isSales ? "2" : "3"
        
        _ = ATB_Alamofire.POST(GET_MULTI_GROUP_ID, parameters: params as [String : AnyObject], showLoading: false, showSuccess: false, showError: false) {
            (result, responseObject) in
            let groupId = responseObject.object(forKey: "msg") as? String ?? "\(responseObject.object(forKey: "msg") as! Int)"
            
            for (positionInGroup, post) in selectedPostToPublish.enumerated() {
                let mediaType = post.isVideo ? "2" : "1"
                
                var params = [
                    "token" : g_myToken,
                    "type" : postType,
                    "media_type" : mediaType,
                    "profile_type" : profileType,
                    "title" : post.title,
                    "description" : post.description,
                    "brand" : post.brand,
                    "price" : post.price,
                    "category_title" : post.category_title,
                    "post_condition": post.post_condition,
                    "post_tags": post.post_tags,
                    "item_title" : post.item_title,
                    "payment_options" : post.payment_options,
                    "location_id" : post.location_id,
                    "delivery_option" : post.delivery_option,
                    "delivery_cost" : post.deliveryCost,
                    "deposit" : post.depositAmount,
                    "lat" : post.lat,
                    "lng" : post.lng,
                    "is_multi" : "1",
                    "multi_pos" : "\(positionInGroup)",
                    "multi_group" : groupId]
                
                if !scheduledOn.isEmpty {
                    params["scheduled"] = scheduledOn
                }
                
                if post.mediaUrls.count > 0 {
                    var post_img_uris = ""
                    for url in post.mediaUrls {
                        post_img_uris += (url + " ,")
                    }
                    
                    post_img_uris = String(post_img_uris.dropLast(2))
                    
                    params["post_img_uris"] = post_img_uris
                }
                
                if self.isSales {
                    params["product_id"] = post.id
                    params["stock_level"] = post.stock_level
                    
                } else {
                    params["is_deposit_required"] = post.depositRequired
                    params["cancellations"] = post.cancellations
                    params["insurance_id"] = post.insuranceID
                    params["qualification_id"] = post.qualificationID
                    
                    params["service_id"] = post.id
                }
                
                let upload = ATB_Alamofire.shareInstance.upload(
                    multipartFormData: { (multipartFormData) in
                        for (key, value) in params  {
                            multipartFormData.append((value.data(using: .utf8)!), withName: key)
                        }
                },
                    to: CREATE_POST_API,
                    usingThreshold: multipartFormDataEncodingMemoryThreshold,
                    method: .post,
                    headers: nil,
                    interceptor: nil,
                    fileManager: FileManager.default)
                
                upload.responseJSON { (response) in
                    postedCount += 1
                    
                    switch response.result {
                    case .success(let JSON):
                        let res = JSON as! NSDictionary
                        if let ok = res["result"] as? Bool,
                            ok {
                            
                        } else {
                            self.hideIndicator()
                            
                            let msg = res["msg"] as? String ?? ""
                            if msg == "" {
                                self.showErrorVC(msg: "Failed to create post, please try again")
                                
                            } else {
                                self.showErrorVC(msg: "Server returned the error message: " + msg)
                            }
                            
                            return
                        }
                        
                    case .failure(_):
                        self.hideIndicator()
                        
                        self.showErrorVC(msg: "Failed to create post, please try again")
                        return
                    }
                    
                    if postedCount >= selectedPostToPublish.count {
                        self.hideIndicator()
                        
                        self.didCompletePost()
                    }
                }
            }
        }
    }
    
    private func didCompletePost() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainNav = storyboard.instantiateViewController(withIdentifier: "MainNav") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = mainNav
    }
}

// MARK: - ProfileSelectDelegate
extension PostExistingViewController: ProfileSelectDelegate  {
    
    func profileSelected(_ selectedIndex: Int) {
        let newSelected = users[selectedIndex]
        
        // delegate will be dispatched only when selection has been changed
        guard newSelected.ID != selectedUser.ID else { return }
        
        selectedUser = newSelected
        
        imvProfile.loadImageFromUrl(selectedUser.profile_image, placeholder: "profile.placeholder")
        
        // enable or disable scheduled post
        if selectedIndex > 0 {
            // business profile is selected
            // enable scheduling post
            scheduleContainer.isHidden = false

            btnPostRightContraint.constant = 106
            UIView.animate(withDuration: 0.35) {
                self.view.layoutIfNeeded()
            }

        } else {
            // normal profile is select
            // disable scheduling post
            scheduleContainer.isHidden = true

            btnPostRightContraint.constant = 16
            UIView.animate(withDuration: 0.35) {
                self.view.layoutIfNeeded()
            }
        }
        
        getUserPosts()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension PostExistingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postToPublish.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExistingPostCell.reuseIdentifier, for: indexPath) as! ExistingPostCell
        // configure the cell
        cell.configureCell(postToPublish[indexPath.row], isSelected: postSelected[indexPath.row])
        
        cell.didSelectPost = { isSelected in
            self.postSelected[indexPath.row] = isSelected
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: - ScheduleCalendarDelegate
extension PostExistingViewController: ScheduleCalendarDelegate {
    
    func dateSelected(_ date: Date) {
        // update the local date to be used when posting
        scheduledDate = date
        
        updateScheduleTitle(withDate: date)
    }
}

// MARK: - SubscriptionDelegate
extension PostExistingViewController: SubscriptionDelegate {
    
    func didCompleteSubscription() {
        
    }
    
    func didIncompleteSubscription() {
        
    }
}
