//
//  PostProductViewController.swift
//  ATB
//
//  Created by YueXi on 7/26/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import SemiModalViewController
import BetterSegmentedControl
import NBBottomSheet

class PostProductViewController: BaseViewController {
    
    static let kStoryboardID = "PostProductViewController"
    class func instance() -> PostProductViewController {
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: PostProductViewController.kStoryboardID) as? PostProductViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var topRoundView: UIView!
    
    @IBOutlet weak var vPostNavigation: UIView!
    @IBOutlet weak var imvPostBack: UIImageView!
    @IBOutlet weak var lblPostTitle: UILabel!
    @IBOutlet weak var imvPostProfile: UIImageView!
    
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
    
    @IBOutlet weak var vAddNavigation: UIView!
    @IBOutlet weak var imvAddTag: UIImageView!
    @IBOutlet weak var lblAddTitle: UILabel!
    @IBOutlet weak var btnAddClose: UIButton!
    
    @IBOutlet weak var vSegmentContainer: UIView!
    @IBOutlet weak var segmentedControl: BetterSegmentedControl!
    
    @IBOutlet weak var vSingleContainer: UIView!
    @IBOutlet weak var vMultipleContainer: UIView!
    
    private var singlePostVC: PostSingleProductViewController?
    private var multiplePostVC: PostMultipleProductsViewController?
        
    var isPosting: Bool = true
    private var users = [UserModel]()
    private var selectedUser: UserModel! { didSet {
        singlePostVC?.postingUser = selectedUser
        multiplePostVC?.postingUser = selectedUser
        }}
    
    var isFromBusinessStore = false
    var delegate: BusinessAddDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !isPosting {
            topRoundView.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 34)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpgradeAccount(_:)), name: .DidUpgradeAccount, object: nil)
    }
    
    private func setupViews() {
        view.backgroundColor = isPosting ? .colorGray14 : .clear
        topRoundView.backgroundColor =  isPosting ? .clear : .colorGray14
        
        vSegmentContainer.layer.masksToBounds = false
        vSegmentContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        vSegmentContainer.layer.shadowRadius = 4.0
        vSegmentContainer.layer.shadowColor = UIColor.gray.cgColor
        vSegmentContainer.layer.shadowOpacity = 0.4
        
        vPostNavigation.isHidden = !isPosting
        vAddNavigation.isHidden = isPosting
        
        if isPosting {
            if #available(iOS 13.0, *) {
                imvPostBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
            } else {
                // Fallback on earlier versions
            }
            
            imvPostBack.tintColor = .colorPrimary
            imvPostBack.contentMode = .scaleAspectFit
            
            lblPostTitle.text = "Create a\nNew Product Post"
            lblPostTitle.font = UIFont(name: Font.SegoeUISemibold, size: 26)
            lblPostTitle.textColor = .colorGray2
            lblPostTitle.numberOfLines = 2
            lblPostTitle.setLineSpacing(lineHeightMultiple: 0.75)
            
            initUserOption()
            imvPostProfile.contentMode = .scaleAspectFill
            
            
        } else {
            imvAddTag.image = UIImage(named: "tag.sale")?.withRenderingMode(.alwaysTemplate)
            imvAddTag.contentMode = .scaleAspectFit
            imvAddTag.tintColor = .colorPrimary
            
            lblAddTitle.text = "Add a\nProduct"
            lblAddTitle.font = UIFont(name: Font.SegoeUISemibold, size: 26)
            lblAddTitle.textColor = .colorGray2
            lblAddTitle.numberOfLines = 2
            lblAddTitle.setLineSpacing(lineHeightMultiple: 0.75)
            
            if #available(iOS 13.0, *) {
                btnAddClose.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            
            btnAddClose.tintColor = .colorGray20
        }
                
        segmentedControl.segments = LabelSegment.segments(withTitles: ["Single Product", "Multiple Products"],
                                                        normalBackgroundColor: .colorGray17,
                                                        normalFont: UIFont(name: Font.SegoeUILight, size: 16),
                                                        normalTextColor: .colorGray2,
                                                        selectedBackgroundColor: .colorPrimary,
                                                        selectedFont: UIFont(name: Font.SegoeUIBold, size: 16),
                                                        selectedTextColor: .white)
        segmentedControl.cornerRadius = 5
        segmentedControl.indicatorViewInset = 0
        segmentedControl.panningDisabled = true
        segmentedControl.animationDuration = 0.3
        segmentedControl.animationSpringDamping = 0.85
//        segmentedControl.options = [
//            .indicatorViewInset(0),
//            .panningDisabled(true),
//            .animationDuration(0.3),
//            .animationSpringDamping(0.85)
//        ]
                
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        segmentedControl.setIndex(0, animated: false)
        selectView(0, animated: false)
    }

    @objc func segmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        if isPosting {
            lblPostTitle.text = sender.index == 0 ? "Create a\nNew Product Post" : "Create Multiple\nProducts Post"
            
        } else {
            lblAddTitle.text = sender.index == 0 ? "Add a\nProduct" : "Add Multiple\nProducts"
        }
        
        selectView(sender.index)
    }
    
    private func selectView(_ selected: Int, animated: Bool = true) {
        if animated {
            if selected == 0 {
                UIView.animate(withDuration: 0.35) {
                    self.vSingleContainer.alpha = 1
                    self.vMultipleContainer.alpha = 0
                }
                
            } else {
                UIView.animate(withDuration: 0.35) {
                    self.vSingleContainer.alpha = 0
                    self.vMultipleContainer.alpha = 1
                }
            }
            
        } else {
            if selected == 0 {
                self.vSingleContainer.alpha = 1
                self.vMultipleContainer.alpha = 0
                
            } else {
                self.vSingleContainer.alpha = 0
                self.vMultipleContainer.alpha = 1
            }
        }
    }
    
    @objc private func didUpgradeAccount(_ notification: Notification) {
        DispatchQueue.main.async {
            self.initUserOption()
        }
    }
    
    private func initUserOption() {
        users.removeAll()
        
        let normalUser = UserModel()
        normalUser.user_type = "User"
        normalUser.ID = g_myInfo.ID
        normalUser.user_name = g_myInfo.userName
        normalUser.profile_image = g_myInfo.profileImage
        users.append(normalUser)
        
        // check if the user is a business user
        if g_myInfo.isBusiness {
            let businessUser = UserModel()
            businessUser.user_type = "Business"
            businessUser.ID = g_myInfo.business_profile.ID
            businessUser.user_name = g_myInfo.business_profile.businessProfileName
            businessUser.profile_image = g_myInfo.business_profile.businessPicUrl
            users.append(businessUser)
        }
        
        profileSelectContainer.isHidden = !g_myInfo.isBusiness
        
//        selectedUser = normalUser
        
        // to avoid momery reference issue
        selectedUser = UserModel()
        
        selectedUser.ID = normalUser.ID
        selectedUser.user_type = normalUser.user_type
        selectedUser.user_name = normalUser.user_name
        selectedUser.profile_image = normalUser.profile_image
        
        imvPostProfile.loadImageFromUrl(selectedUser.profile_image, placeholder: "profile.placeholder")
    }
    
    // transitioningDelgegate is a weak property
    // for dismissed protocol, we need to make it a class variable
    let sheetTransitioningDelegate = NBBottomSheetTransitioningDelegate()
    
    @IBAction func didTapProfile(_ sender: Any) {
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
    
    @IBAction func didTapBack(_ sender: Any) {
        guard isPosting else { return }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        guard !isPosting else { return }
        
        dismissSemiModalView()
    }
    
    // this will be called by sub viewcontrollers(single/multiple sales postview controller)
    func didAddNewProducts(_ items: [PostToPublishModel]) {
        // what to dismiss should be different where this is came from
        if isFromBusinessStore {
            dismiss(animated: true) {
                self.delegate?.didAddNewProducts(items)
            }
            
        } else {
            dismissSemiModalViewWithCompletion {
                self.delegate?.didAddNewProducts(items)
            }
        }
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PostProduct2Single" {
            guard let singlePostVC = segue.destination as? PostSingleProductViewController else {
                return
            }
            
            singlePostVC.rootViewController = self
            singlePostVC.isPosting = isPosting
            
            self.singlePostVC = singlePostVC
            
        } else if segue.identifier == "PostProduct2Multiple" {
            guard let multiplePostVC = segue.destination as? PostMultipleProductsViewController else {
                return
            }
            
            multiplePostVC.rootViewController = self
            multiplePostVC.isPosting = isPosting
            
            self.multiplePostVC = multiplePostVC
        }
    }
}

// MARK: ProfileSelectDelegate
extension PostProductViewController: ProfileSelectDelegate  {
    
    func profileSelected(_ selectedIndex: Int) {
        selectUser(selectedIndex, checkValidation: true)
    }
    
    // profile switch validation
    private func isValidToSwitchProfile(selected: UserModel) -> Bool {
        guard selected.isBusiness else { return true }
        
        // business profile has been selected
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
    
    func selectUser(_ selected: Int, checkValidation: Bool = false) {
        let newSelected = users[selected]
        
        if checkValidation {
            guard isValidToSwitchProfile(selected: newSelected) else { return }
        }
        
        // to get the profile automatically get updated on adding a product to post multiple sales product
        // just replace values rather than replace a model with new one
        selectedUser.ID = newSelected.ID
        selectedUser.user_type = newSelected.user_type
        selectedUser.user_name = newSelected.user_name
        selectedUser.profile_image = newSelected.profile_image
        
        singlePostVC?.didSelectUser()
        
        DispatchQueue.main.async {
            self.imvPostProfile.loadImageFromUrl(self.selectedUser.profile_image, placeholder: "profile.placeholder")
        }
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
}

// MARK: - SubscriptionDelegate
extension PostProductViewController: SubscriptionDelegate {
    
    func didCompleteSubscription() {
        
    }
    
    func didIncompleteSubscription() {
        
    }
}
