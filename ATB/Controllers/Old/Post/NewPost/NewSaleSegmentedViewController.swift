//
//  NewSalePostViewController.swift
//  ATB
//
//  Created by YueXi on 4/27/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class NewSaleSegmentedViewController: BaseViewController {
    
    static let kStoryboardID = "NewSaleSegmentedViewController"
    class func instance() -> NewSaleSegmentedViewController {
        let storyboard = UIStoryboard(name: "OutdatedPost", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: NewSaleSegmentedViewController.kStoryboardID) as? NewSaleSegmentedViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.font = UIFont(name: "SegoeUI-Semibold", size: 26)
        lblTitle.textColor = .colorGray2
        lblTitle.text = "New Sale Post"
        }}
    
    @IBOutlet weak var imvProfile: RoundImageView! { didSet {
        imvProfile.contentMode = .scaleAspectFill
        }}
    @IBOutlet weak var vProfileContainer: RoundShadowView!
    
    var shadowBackView = UIView(frame: .zero)
    
    let segmentControl = WBSegmentControl()
    var pagesController: UIPageViewController!
    
    var viewPages = UIView()
    var pages = [UIViewController]()
    
//    private lazy var singlePostVC: NewSaleSinglePostViewController = {
//        let vc = NewSaleSinglePostViewController.instance()
//        vc.rootViewController = self
//
//        return vc
//    }()
//
//    private lazy var multiPostVC: NewSaleMultiPostViewController = {
//        let vc = NewSaleMultiPostViewController.instance()
//        vc.rootViewController = self
//
//        return vc
//    }()
    
    var users = [UserModel]()
    var selectedUser: UserModel = UserModel() { didSet {
//        singlePostVC.selectedUser = selectedUser
//        multiPostVC.selectedUser = selectedUser
        }}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = .colorGray3
        
        initUserOption()
        
        setupSubviews()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(accountUpgraded(_:)),
            name: .onAccountUpgrade,
            object: nil)
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//
//        NotificationCenter.default.removeObserver(self)
//    }
    
    private func setupSubviews() {
        setupSegmentControl()
        setupPageController()
        
        view.addSubview(segmentControl)
        view.addSubview(viewPages)
        viewPages.addSubview(pagesController.view)
        
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraintWithFormat("H:|[v0]|", views: segmentControl)
        view.addConstraintWithFormat("V:|-98-[v0(45)]", views: segmentControl)

        viewPages.backgroundColor = .colorGray7
        viewPages.gestureRecognizers = pagesController.gestureRecognizers
        viewPages.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[viewPages]|", options: .alignAllLeading, metrics: nil, views: ["viewPages": viewPages]))
        view.addConstraint(NSLayoutConstraint(item: viewPages, attribute: .top, relatedBy: .equal, toItem: segmentControl, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: viewPages, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))

        pagesController.view.translatesAutoresizingMaskIntoConstraints = false
        viewPages.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[pagesView]|", options: .alignAllLeading, metrics: nil, views: ["pagesView": pagesController.view!]))
        viewPages.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[pagesView]|", options: .alignAllFirstBaseline, metrics: nil, views: ["pagesView": pagesController.view!]))

        segmentControl.selectedIndex = 0
    }
    
    func setupSegmentControl() {
        segmentControl.segments = [
            TextSegment(text: "Single Product"),
            TextSegment(text: "Multiple Product"),
        ]
        segmentControl.separatorWidth = 0
        segmentControl.style = .rainbow
        segmentControl.segmentTextFontSize = 16
        segmentControl.segmentForegroundColor = .colorGray2
        segmentControl.segmentForegroundColorSelected = .colorPrimary
        segmentControl.segmentTextBold = true
        segmentControl.rainbow_colors = [.colorGray7, .colorGray7]
        segmentControl.delegate = self
    }
    
    private func setupPageController() {
        pagesController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
//        pagesController.dataSource = self
        pagesController.delegate = self

        segmentControl.segments.enumerated().forEach { (index, _) in
//            let vc = index == 0 ? singlePostVC : multiPostVC
//            pages.append(vc)
        }
    }
    
    @IBAction func didTapProfile(_ sender: Any) {
        showUserSelectView()
    }
    
    func initUserOption() {
        self.users.removeAll()
        
        let newuser = UserModel()
        newuser.user_type = "User"
        newuser.ID = g_myInfo.ID
        newuser.user_name = g_myInfo.userName
        newuser.profile_image = g_myInfo.profileImage
        users.append(newuser)
        
        // check for account type - business
        if(g_myInfo.accountType == 1) {
            // if business profile is approved
            if (g_myInfo.business_profile.approved == "1") {
                let businessUser = UserModel()
                businessUser.user_type = "Business"
                businessUser.ID = g_myInfo.business_profile.ID
                businessUser.user_name = g_myInfo.business_profile.businessProfileName
                businessUser.profile_image = g_myInfo.business_profile.businessPicUrl
                users.append(businessUser)
            }
        }
        
        self.selectedUser = newuser
        
        if(selectedUser.profile_image != "") {
            let url = URL(string: DOMAIN_URL + selectedUser.profile_image)
            self.imvProfile.kf.setImage(with: url)
        }
    }
    
    private func showUserSelectView() {
        var topPadding:CGFloat! = 0.0
        let window = UIApplication.shared.keyWindow
        
        if #available(iOS 11.0, *) {
            topPadding = window?.safeAreaInsets.top
        }
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        shadowBackView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        shadowBackView.backgroundColor = UIColor(displayP3Red: 50/255, green: 50/255, blue: 50/255, alpha: 0.8)
        shadowBackView.alpha = 0.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapOnAccountSelectorBack(_:)))
        shadowBackView.isUserInteractionEnabled = true
        shadowBackView.addGestureRecognizer(tap)
        shadowBackView.alpha = 0.0
        
        self.view.addSubview(shadowBackView)
        
        let accountSelectorWidth: CGFloat = 180
        let accountSelectorHeight: CGFloat = CGFloat(35 + users.count * 46)
        
        let yPos = topPadding + self.vProfileContainer.frame.origin.y - 22
        let xPos = self.vProfileContainer.frame.origin.x + self.vProfileContainer.frame.width - 180
        
        let accountSelectorViewFrame = CGRect(x: xPos, y: yPos, width: accountSelectorWidth, height: accountSelectorHeight)
        let accountSelectorView = ReportView(frame: accountSelectorViewFrame)
        
        accountSelectorView.cornerRadius = 5
        accountSelectorView.backgroundColor = UIColor.white
        
        let accountSelectorLabel = UILabel(frame: CGRect(x: 0, y: 8, width: accountSelectorWidth, height: 20))
        accountSelectorLabel.text = "Post As"
        accountSelectorLabel.textColor = UIColor.primaryButtonColor
        accountSelectorLabel.font = UIFont(name: "SegoeUI-Bold", size: 20.0)
        accountSelectorLabel.textAlignment = .center

        accountSelectorView.clipsToBounds = true
        accountSelectorView.addSubview(accountSelectorLabel)
        
        var index = 0
        for user in self.users
        {
            var isSelected = false
            if(user.ID == self.selectedUser.ID)
            {
                isSelected = true
            }
            
            self.addAccountMenuItmes(container: accountSelectorView, containerWidth: accountSelectorWidth, itemPos: index, isSelected: isSelected)
            
            index = index + 1
        }

        shadowBackView.addSubview(accountSelectorView)
        accountSelectorView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        
        UIView.animate(withDuration: 0.08, delay: 0, options: .curveLinear, animations: {
            self.shadowBackView.alpha = 1.0
            accountSelectorView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }) { _ in }
    }
    
    func addAccountMenuItmes(container:UIView, containerWidth:CGFloat, itemPos:Int, isSelected:Bool) {
        let accountMnuContainer = UIView(frame: CGRect(x: 0, y: itemPos * 46 + 35, width: Int(containerWidth), height: 46))
        
        let accountNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: containerWidth - 56, height: 46))
        accountNameLabel.font = UIFont(name: "SegoeUI-Light", size: 16.0)
        accountNameLabel.textColor = UIColor.lightGray
        accountNameLabel.text = users[itemPos].user_name
        accountNameLabel.textAlignment = .right
        accountNameLabel.numberOfLines = 2
        
        let accountMnuProfileContainer = UIView(frame: CGRect(x: containerWidth - 46, y: 5, width: 36, height: 36))
        accountMnuProfileContainer.backgroundColor = UIColor.primaryButtonColor
        accountMnuProfileContainer.layer.cornerRadius = 5
        accountMnuProfileContainer.backgroundColor = UIColor.lightGray
        
        let accountMnuProfileImage = UIImageView(frame: CGRect(x: 2, y: 2, width: 32, height: 32))
        accountMnuProfileImage.layer.cornerRadius = 5
        accountMnuProfileImage.layer.borderWidth = 1.0
        accountMnuProfileImage.layer.borderColor = UIColor.white.cgColor
        accountMnuProfileImage.clipsToBounds = true
        
        if(users[itemPos].profile_image != "")
        {
            let url = URL(string: DOMAIN_URL + users[itemPos].profile_image)
            accountMnuProfileImage.kf.setImage(with: url)
        }
        
        accountMnuProfileContainer.addSubview(accountMnuProfileImage)
        accountMnuContainer.addSubview(accountMnuProfileContainer)
        accountMnuContainer.addSubview(accountNameLabel)
        
        if(isSelected)
        {
            accountMnuContainer.backgroundColor = UIColor(displayP3Red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
        }
        else
        {
            accountMnuContainer.backgroundColor = UIColor.white
        }
        
        let accountSelectButton = UIButton(frame: accountMnuContainer.frame)
        accountSelectButton.setTitle("", for: .normal)
        accountSelectButton.tag = itemPos
        accountSelectButton.addTarget(self, action: #selector(AccountSelectorBtnClicked), for: .touchUpInside)

        container.addSubview(accountMnuContainer)
        container.addSubview(accountSelectButton)
    }
    
    func hideAccountSelectView(_ type: Int) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
            self.shadowBackView.subviews.first!.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            self.shadowBackView.alpha = 0.0
        }) { (isCompleted) in
            for subView in self.shadowBackView.subviews
            {
                subView.removeFromSuperview()
            }
            self.shadowBackView.removeFromSuperview()
            self.shadowBackView.frame = .zero
        }
    }
    
    @objc func tapOnAccountSelectorBack(_ sender: UITapGestureRecognizer) {
        hideAccountSelectView(0)
    }
    
    @objc func AccountSelectorBtnClicked(_ sender: UIButton) {
        self.selectUser(index: sender.tag)
//
//            if(self.optionMedia.getValue() != nil && self.optionMedia.getValue() != 0)
//            {
//                self.list_media.reloadData()
//                self.list_media.scroll(to: .top, animated: false)
//            }
        
        hideAccountSelectView(0)
    }
    
    func selectUser(index: Int) {
        self.selectedUser = self.users[index]
//        singlePostVC.selectedUser = selectedUser
//        multiPostVC.selectedUser = selectedUser
        if(selectedUser.profile_image != "") {
            let url = URL(string: DOMAIN_URL + self.selectedUser.profile_image)
            self.imvProfile.kf.setImage(with: url)
        }
    }
    
    @objc private func accountUpgraded(_ notification: NSNotification) {
        initUserOption()
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - WESegmentControlDelegate
extension NewSaleSegmentedViewController: WBSegmentControlDelegate {
    func segmentControl(_ segmentControl: WBSegmentControl, selectIndex newIndex: Int, oldIndex: Int) {
        let targetPages = [pages[newIndex]]
        let direction = ((newIndex > oldIndex) ? UIPageViewController.NavigationDirection.forward : UIPageViewController.NavigationDirection.reverse)
        
        pagesController.setViewControllers(targetPages, direction: direction, animated: true, completion: nil)
    }
}

// MARK: - UIPageControllerDataSource, UIPageViewControllerDelegate
extension NewSaleSegmentedViewController:  UIPageViewControllerDelegate {
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        guard let index = pages.firstIndex(of: viewController) else { return nil }
//
//        return index > 0 ? pages[index - 1] : nil
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        guard let index = pages.firstIndex(of: viewController) else { return nil }
//
//        return index < pages.count - 1 ? pages[index + 1] : nil
//    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed == false {
            guard let targetPage = previousViewControllers.first else {
                return
            }
            
            guard let targetIndex = pages.firstIndex(of: targetPage) else {
                return
            }
            segmentControl.selectedIndex = targetIndex
            
            pageViewController.setViewControllers(previousViewControllers, direction: .reverse, animated: true, completion: nil)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let targetPage = pendingViewControllers.first else {
            return
        }
        
        guard let targetIndex = pages.firstIndex(of: targetPage) else {
            return
        }
        
        segmentControl.selectedIndex = targetIndex
    }

}

