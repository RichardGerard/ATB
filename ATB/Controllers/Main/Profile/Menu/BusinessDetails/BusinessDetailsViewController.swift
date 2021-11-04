//
//  BusinessDetailsViewController.swift
//  ATB
//
//  Created by YueXi on 5/21/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import BraintreeDropIn
import Braintree
import WSTagsField
import SemiModalViewController
import PopupDialog
import EasyTipView

import FacebookLogin
import FacebookCore
import Applozic

// Business Details
// open up to update to a business account or
// show the business profile
class BusinessDetailsViewController: BaseViewController {
    
    static let kStoryboardID = "BusinessDetailsViewController"
    class func instance() -> BusinessDetailsViewController {
        let storyboard = UIStoryboard(name: "BusinessDetails", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: BusinessDetailsViewController.kStoryboardID) as? BusinessDetailsViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! { didSet {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        }}
    
    @IBOutlet weak var imvBAIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var imvStarIcon: UIImageView! // no appropriate asset
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var imvBusinessLogo: UIImageView! { didSet {
        imvBusinessLogo.contentMode = .scaleAspectFill
        }}
    @IBOutlet weak var lblLogoTitle: UILabel!
    @IBOutlet weak var lblLogoDescription: UILabel!
    
    @IBOutlet weak var txfBusinessName: RoundRectTextField!
    @IBOutlet weak var txfBusinessWebsite: RoundRectTextField!
    @IBOutlet weak var txvBusinessInfo: RoundRectTextView!
    
    // Set Operating Hours
    @IBOutlet weak var lblSetTitle: UILabel!
    @IBOutlet weak var lblSetDescription: UILabel!
    @IBOutlet weak var setHoursContainer: UIView!
    @IBOutlet weak var lblSetOperatingHours: UILabel!
    @IBOutlet weak var lblNoSet: UILabel!
    @IBOutlet weak var imvArrowForSet: UIImageView!
    
    @IBOutlet weak var lblInsurance: UILabel!
    @IBOutlet weak var lblInsuranceDescription: UILabel!
    
    @IBOutlet weak var heightForQualificationsTableView: NSLayoutConstraint!
    @IBOutlet weak var tblQualifications: UITableView!
    @IBOutlet weak var btnAddCertification: UIButton!
    @IBOutlet weak var heightForInsurancesTableView: NSLayoutConstraint!
    @IBOutlet weak var tblInsurances: UITableView!
    @IBOutlet weak var btnAddInsurance: UIButton!
    
    // link social media accounts
    @IBOutlet weak var lblLinkSocialMedia: UILabel!
    // Facebook
    @IBOutlet weak var vFacebookCheckbox: CheckBox!
    @IBOutlet weak var imvFacebookLogo: UIImageView!
    @IBOutlet weak var lblSocialFacebook: UILabel!
    
    // Instagram
    @IBOutlet weak var vInstagramCheckbox: CheckBox!
    @IBOutlet weak var imvInstagramLogo: UIImageView!
    @IBOutlet weak var lblSocialInstagram: UILabel!
    
    @IBOutlet weak var vInstagramName: UIView!
    @IBOutlet weak var txfInstagramName: RoundRectTextField!
    @IBOutlet weak var btnLinkInstagram: UIButton!
    
    // Twitter
    @IBOutlet weak var vTwitterCheckbox: CheckBox!
    @IBOutlet weak var imvTwitterLogo: UIImageView!
    @IBOutlet weak var lblSocialTwitter: UILabel!
    
    @IBOutlet weak var vTwitterName: UIView!
    @IBOutlet weak var txfTwitterName: RoundRectTextField!
    @IBOutlet weak var btnLinkTwitter: UIButton!
    
    // Add Tags
    @IBOutlet weak var lblAddTags: UILabel!
    @IBOutlet weak var imvAddTagsInfo: UIImageView!
    @IBOutlet weak var lblAddTagsInfo: UILabel!
        
    @IBOutlet weak var vTagsField: WSTagsField!
    
    @IBOutlet weak var btnSave: UIButton!
        
    // represents that the user update their business profile
    // false - they are just setting up their business profile
    var isUpdating: Bool = false
    
    // represents that the user gets to this page from profile
    // if the user gets to this page from profile, upgrade to a business has more steps to add services and products or just skip it
    var isFromProfile: Bool = true
    
    var selectedBusinessLogo: Data? = nil
    
    var qualifications = [ServiceFileModel]()
    var insurances = [ServiceFileModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()

        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image"]

        if isUpdating {
            loadBusinessInfo()
            
            getUserTags()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSetOperatingHour(_:)), name: .DidSetOperatingHour, object: nil)
    }
    
    private func setupViews() {
        /// add gradient layer
        self.view.addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 47, alphaValue: 1.0)
        
        /// icon
        imvBAIcon.contentMode = .scaleAspectFill
        imvBAIcon.image = #imageLiteral(resourceName: "ic_business_mark")
        
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Semibold", size: 26)!,
            .foregroundColor: UIColor.white
        ]
        
        let boldAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Bold", size: 26)!
        ]
        
        let upgrade = "Upgrade to\n"
        let businessAccount = "Business Account"
                
        let attrString = NSMutableAttributedString(string: upgrade + businessAccount)
        attrString.addAttributes(normalAttrs, range: NSRange(location: 0, length: attrString.length))
        attrString.addAttributes(boldAttr, range: NSRange(location: upgrade.count, length: businessAccount.count))
        
        lblTitle.numberOfLines = 0
        lblTitle.attributedText = attrString
        lblTitle.setLineSpacing(lineSpacing: 0, lineHeightMultiple: 0.8)
        
        if #available(iOS 13.0, *) {
            btnClose.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnClose.tintColor = UIColor.white.withAlphaComponent(0.3)
        
        if #available(iOS 13.0, *) {
            imvStarIcon.image = UIImage(systemName: "star.fill")
        } else {
            // Fallback on earlier versions
        }
        imvStarIcon.contentMode = .scaleAspectFit
        imvStarIcon.tintColor = .white
        
        lblLogoTitle.text = "Upload Business Logo"
        lblLogoTitle.font = UIFont(name: "SegoeUI-Semibold", size: 18)
        lblLogoTitle.textColor = .white
        
        lblLogoDescription.text = "Will recommend you to use your business logo"
        + " you can use any emails related to your business,"
        + " this will be visible next to your post"
        lblLogoDescription.font = UIFont(name: "SegoeUI-Light", size: 14)
        lblLogoDescription.textColor = .white
        lblLogoDescription.numberOfLines = 0
        
        /// setup inputTextField
        setupInputField(txfBusinessName, placeholder: "Set a business name")
        setupInputField(txfBusinessWebsite, placeholder: "Add your website")
        
        txvBusinessInfo.font = UIFont(name: Font.SegoeUILight, size: 18)
        txvBusinessInfo.textColor = .colorGray19
        txvBusinessInfo.tintColor = .colorGray19
        txvBusinessInfo.placeholder = "Tell us about your business"
        txvBusinessInfo.delegate = self
        
        setupOperatingHours()
        
        /// Add Insurances And Qualifications
        let insuranceAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            insuranceAttachment.image = UIImage(systemName: "checkmark.seal.fill")?.withTintColor(.white)
            insuranceAttachment.setImageHeight(height: 26, verticalOffset: -6)
        } else {
            // Fallback on earlier versions
        }
        
        let whiteSemiboldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUISemibold, size: 18)!,
            .foregroundColor: UIColor.white
        ]
        
        let attrAddInsuranceStr = NSMutableAttributedString(string: " Add Insurances And Qualifications")
        attrAddInsuranceStr.insert(NSAttributedString(attachment: insuranceAttachment), at: 0)
        attrAddInsuranceStr.addAttributes(whiteSemiboldAttrs, range: NSRange(location: 0, length: attrAddInsuranceStr.length))
        lblInsurance.attributedText = attrAddInsuranceStr
        
        lblInsuranceDescription.text = "Add your qualifications here in case some of your services requires insurances or certificates. You can do this later."
        lblInsuranceDescription.textColor = .white
        lblInsuranceDescription.font = UIFont(name: Font.SegoeUILight, size: 14)
        lblInsuranceDescription.numberOfLines = 0
        
        setupAddButton(btnAddCertification, title: "  Add Certification")
        setupAddButton(btnAddInsurance, title: "  Add Insurance")
        
        heightForQualificationsTableView.constant = 0
        heightForInsurancesTableView.constant = 0
        
        setupTableView(tblQualifications)
        setupTableView(tblInsurances)
        
        let businessProfile = g_myInfo.business_profile
        
        /// Link social media
        lblLinkSocialMedia.text = "Link Your Social Media"
        lblLinkSocialMedia.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblLinkSocialMedia.textColor = .white
        
        setupSocialLink(vFacebookCheckbox, imageView: imvFacebookLogo, imageName: "social_fb", label: lblSocialFacebook, labelTitle: "Facebook")
        vFacebookCheckbox.isChecked = !businessProfile.fbUsername.isEmpty
        
        setupSocialLink(vInstagramCheckbox, imageView: imvInstagramLogo, imageName: "social_insta", label: lblSocialInstagram, labelTitle: "Instagram")
        setupInputField(txfInstagramName, placeholder: "Type your username")
        setupLinkButton(btnLinkInstagram)
        
        if businessProfile.instaUsername.isEmpty {
            vInstagramName.isHidden = true
            vInstagramName.alpha = 0
            
        } else {
            txfInstagramName.text = businessProfile.instaUsername
            btnLinkInstagram.isHidden = true
            
            txfInstagramName.isUserInteractionEnabled = false
            
            vInstagramCheckbox.isChecked = true
        }
        
        setupSocialLink(vTwitterCheckbox, imageView: imvTwitterLogo, imageName: "social_twitter", label: lblSocialTwitter, labelTitle: "Twitter")
        setupInputField(txfTwitterName, placeholder: "Type your username")
        setupLinkButton(btnLinkTwitter)
        
        if businessProfile.twitterUsername.isEmpty {
            vTwitterName.isHidden = true
            vTwitterName.alpha = 0
            
        } else {
            txfTwitterName.text = businessProfile.twitterUsername
            btnLinkTwitter.isHidden = true
            
            txfTwitterName.isUserInteractionEnabled = false
            
            vTwitterCheckbox.isChecked = true
        }
        
        /// Add Tags
        let tagsAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            if let tagImage = UIImage(systemName: "tag.fill"),
                let cgImage = tagImage.cgImage {
                let flipped = UIImage(cgImage: cgImage, scale: 1.0, orientation: .leftMirrored)
                tagsAttachment.image = flipped.withTintColor(.white)
                tagsAttachment.setImageHeight(height: 22, verticalOffset: -4)
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        let attrAddTagsStr = NSMutableAttributedString(string: " Add Tags For Your Business")
        attrAddTagsStr.insert(NSAttributedString(attachment: tagsAttachment), at: 0)
        attrAddTagsStr.addAttributes(whiteSemiboldAttrs, range: NSRange(location: 0, length: attrAddTagsStr.length))
        lblAddTags.attributedText = attrAddTagsStr
        
        if #available(iOS 13.0, *) {
            imvAddTagsInfo.image = UIImage(systemName: "info.circle.fill")?.withTintColor(.white)
           
        } else {
            // Fallback on earlier versions
        }
        imvAddTagsInfo.tintColor = .white
        
        lblAddTagsInfo.text = "This will help users to find your post and products easily."
        lblAddTagsInfo.font = UIFont(name: Font.SegoeUILight, size: 14)
        lblAddTagsInfo.textColor = .white
        lblAddTagsInfo.numberOfLines = 2
        
        setupTagsView()

        btnSave.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        btnSave.layer.cornerRadius = 5.0
        updateSaveButton(isUpdating)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    private func loadBusinessInfo() {
        let businessProfile = g_myInfo.business_profile
        
        imvBusinessLogo.loadImageFromUrl(businessProfile.businessPicUrl, placeholder: "profile.placeholder")
        txfBusinessName.text = businessProfile.businessName
        txfBusinessWebsite.text = businessProfile.businessWebsite
        txvBusinessInfo.text = businessProfile.businessBio
        
        getServiceFiles()
    }
    
    private func getServiceFiles() {
        insurances.removeAll()
        qualifications.removeAll()
        
        showIndicator()
        
        APIManager.shared.getServiceFiles(g_myToken) { (result, message, serviceFiles) in
            self.hideIndicator()
            
            guard result,
                  let serviceFiles = serviceFiles  else { return }
            
            for serviceFile in serviceFiles {
                if serviceFile.isInsurance {
                    self.insurances.append(serviceFile)
                    
                } else {
                    self.qualifications.append(serviceFile)
                }
            }
            
            if self.insurances.count > 0 {
                UIView.animate(withDuration: 0.35, animations: {
                    self.heightForInsurancesTableView.constant += (76 * CGFloat(self.insurances.count))
                    
                }) { _ in
                    self.tblInsurances.reloadData()
                }
            }
            
            if self.qualifications.count > 0 {
                UIView.animate(withDuration: 0.35, animations: {
                    self.heightForQualificationsTableView.constant += (76 * CGFloat(self.qualifications.count))
                    
                }) { _ in
                    self.tblQualifications.reloadData()
                }
            }
            
            self.didFinishLoadBusinessProfile()
        }
    }
    
    private func didFinishLoadBusinessProfile() {
        let business = g_myInfo.business_profile
        if business.isPaid {
            guard !business.isApproved else { return }
            
            alertForBusinessStatus(isPending: business.isPending)
            
        } else {
            // The user hasn't subscribed yet!
            alertToSubscribeBusiness()
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
        let title = "You have not subscribed for your business account yet!\nWould you like to subscribe now?"
        let alert = UIAlertController(title: title, message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            // subscribe
            self.gotoSubscribe()
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default))
        alert.view.tintColor = .colorPrimary
        self.present(alert, animated: true)
    }
    
    /// Setup input textfield
    private func setupInputField(_ textField: RoundRectTextField, placeholder: String, image: String? = nil) {
        textField.backgroundColor = .white
        textField.borderColor = .colorGray17
        textField.borderWidth = 1
       
        textField.placeholder = placeholder
        textField.tintColor = .colorGray19
        textField.textColor = .colorGray19
        textField.font = UIFont(name: "SegoeUI-Light", size: 18) // 23 (design size) looks little weird
        textField.inputPadding = 16
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
    }
    
    private func setupOperatingHours() {
        let clockAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            clockAttachment.image = UIImage(systemName: "clock")?.withTintColor(.white)
            clockAttachment.setImageHeight(height: 26, verticalOffset: -6)
        } else {
            // Fallback on earlier versions
        }
        
        let setAttributedTitle = NSMutableAttributedString(string: " Set Operating Hours")
        setAttributedTitle.insert(NSAttributedString(attachment: clockAttachment), at: 0)
        lblSetTitle.attributedText = setAttributedTitle
        lblSetTitle.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblSetTitle.textColor = .white
        
        lblSetDescription.text = "This will let to people know where to book for a service"
        lblSetDescription.font = UIFont(name: Font.SegoeUILight, size: 14)
        lblSetDescription.minimumScaleFactor = 0.75
        lblSetDescription.adjustsFontSizeToFitWidth = true
        lblSetDescription.textColor = .white
        
        setHoursContainer.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        setHoursContainer.layer.cornerRadius = 5.0
        setHoursContainer.layer.masksToBounds = true
        
        lblSetOperatingHours.text = "Set Operating Hours"
        lblSetOperatingHours.font = UIFont(name: Font.SegoeUIBold, size: 18)
        lblSetOperatingHours.textColor = .white
        
        let businessProfile = g_myInfo.business_profile
        lblNoSet.isHidden = !(businessProfile.weekdays.count == 0)
        lblNoSet.text = "Not Set Yet"
        lblNoSet.font = UIFont(name: Font.SegoeUILight, size: 18)
        lblNoSet.textColor = .white
        
        if #available(iOS 13.0, *) {
            imvArrowForSet.image = UIImage(systemName: "chevron.right")
        } else {
            // Fallback on earlier versions
        }        
        imvArrowForSet.tintColor = .white
    }
    
    private var weekdays = [Weekday]()
    @objc private func didSetOperatingHour(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let week = object["week"] as? [Weekday] else { return }
        
        weekdays = week
        
        DispatchQueue.main.async {
            self.lblNoSet.isHidden = !(week.count == 0)
        }
    }
    
    // Setup Add Certificates & Insurances
    private func setupAddButton(_ button: UIButton, title: String) {
        button.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 18)
        button.setTitle(title, for: .normal)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.tintColor = .white
        button.layer.cornerRadius = 5.0
        
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    
    // Setup Qualitifications & Insurances TableView
    private func setupTableView(_ tableView: UITableView) {
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(UINib(nibName: "ServiceFileCell", bundle: nil), forCellReuseIdentifier: ServiceFileCell.reuseIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    /// Setup Social Links
    private func setupSocialLink(_ checkbox: CheckBox, imageView: UIImageView, imageName: String, label: UILabel, labelTitle: String) {
        checkbox.borderStyle = .rounded
        checkbox.style = .tick
        checkbox.borderWidth = 2
        checkbox.tintColor = .white
        checkbox.uncheckedBorderColor = .white
        checkbox.checkedBorderColor = .white
        checkbox.checkmarkSize = 0.8
        checkbox.checkmarkColor = .white
        checkbox.isUserInteractionEnabled = false
        
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: imageName)
        
        label.text = labelTitle
        label.font = UIFont(name: Font.SegoeUILight, size: 18)
        label.textColor = .white
    }
    
    /// Setup Social Link button
    private func setupLinkButton(_ button: UIButton) {
        button.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 18)
        button.setTitle(" Link", for: .normal)
        button.setImage(UIImage(named: "add_link"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 5.0
    }
    
    /// Setup Tags InputView
    private var userTags = [TagModel]()
    private func setupTagsView() {
        vTagsField.layer.cornerRadius = 5
        vTagsField.layer.masksToBounds = true
        
        vTagsField.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        vTagsField.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        vTagsField.spaceBetweenLines = 6.0
        vTagsField.spaceBetweenTags = 10.0
        vTagsField.font = UIFont(name: Font.SegoeUILight, size: 18)
        vTagsField.textColor = .white
        vTagsField.tintColor = .colorPrimary
        
        vTagsField.textField.tintColor = .colorGray19
        
        vTagsField.selectedColor = .colorRed1
        vTagsField.selectedTextColor = .white
        
        vTagsField.delimiter = ","
        vTagsField.isDelimiterVisible = false
        
        vTagsField.placeholder = "Add a Tag"
        vTagsField.placeholderColor = UIColor.placeholderColor
        vTagsField.placeholderAlwaysVisible = true
        vTagsField.textField.returnKeyType = .next
        vTagsField.acceptTagOption = .space
        
        // Events
        vTagsField.onDidAddTag = { field, tag in
//            print("DidAddTag", tag.text)
            guard !self.userTags.contains(where: {
                $0.name.localizedCaseInsensitiveCompare(tag.text) == .orderedSame
            }) else { return }
            
            self.addTag(tag.text)
        }
        
        vTagsField.onDidRemoveTag = { field, tag in
            self.deleteTag(tag.text)
        }
        
        vTagsField.onDidChangeText = { _, text in }
        
        vTagsField.onDidChangeHeightTo = { _, height in }
        
        vTagsField.onValidateTag = { tag, tags in
            // custom validations, called before tag is added to tags list
            return tag.text != "#" && !tags.contains(where: { $0.text.localizedCaseInsensitiveCompare(tag.text) == .orderedSame })
        }
        
        vTagsField.onShouldAcceptTag = { field in return true }
    }
    
    private func getUserTags() {
        APIManager.shared.getUserTags(g_myToken) { result in
            switch result {
            case .success(let tags):
                guard tags.count > 0 else { return }
                
                self.userTags.removeAll()
                
                var tagStrings = [String]()
                for tag in tags {
                    self.userTags.append(tag)
                    tagStrings.append(tag.name)
                }
                
                self.vTagsField.addTags(tagStrings)
                
            case .failure(_):
                break
            }
        }
    }
    
    private func addTag(_ tag: String) {
        APIManager.shared.addTag(g_myToken, tag: tag) { result in
            switch result {
            case .success(let new):
                self.userTags.append(new)
                
            case .failure(_): break
            }
        }
    }
    
    private func deleteTag(_ tag: String) {
        guard let deleteIndex = userTags.firstIndex(where: {
            $0.name.localizedCaseInsensitiveCompare(tag) == .orderedSame
        }) else { return }
        
        let deleteTagId = userTags[deleteIndex].id
        userTags.remove(at: deleteIndex)
        
        APIManager.shared.deleteTag(g_myToken, tagId: deleteTagId) { result in
            switch result {
            case .success(_): break
            case .failure(_): break
            }
        }
    }
    
    private func checkValidation() {
        guard !txfBusinessName.isEmpty(),
            let websiteLink = txfBusinessWebsite.text,
            !websiteLink.isEmpty,
            websiteLink.trimmedString.isValidUrl,
            !txvBusinessInfo.isEmpty else {
                updateSaveButton(false)
                
                return
        }
        
        // enable Save button
        updateSaveButton(selectedBusinessLogo != nil || isUpdating)
//        updateSaveButton(true)
    }
    
    /// TextFieldDidChanged - called when text is changed
    /// always check validation and update 'Save Business Details' button
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // update validation here whenever text is changed or just call this on DidEndEditing if you want
        checkValidation()
    }
    
    private func updateSaveButton(_ isEnabled: Bool) {
        if isEnabled {
            btnSave.backgroundColor = .colorBlue5
            btnSave.setTitleColor(.white, for: .normal)
            if #available(iOS 13.0, *) {
                btnSave.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            btnSave.setTitle("Save Business Details ", for: .normal)
            btnSave.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            btnSave.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            btnSave.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            btnSave.tintColor = .white
            
        } else {
            btnSave.backgroundColor = UIColor.colorBlue5.withAlphaComponent(0.5)
            btnSave.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
            btnSave.setImage(nil, for: .normal)
            btnSave.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            btnSave.titleLabel?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            btnSave.imageView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            btnSave.setTitle("Save Business Details", for: .normal)
        }
    }
    
    @IBAction func didTapBusinessLogo(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: "What would you like to do?", preferredStyle: .actionSheet)
        
        if let camera = actionAction(for: .camera, title: "Take photo") {
            alertController.addAction(camera)
        }
        
        if let photoLibrary = actionAction(for: .photoLibrary, title: "Photo Library") {
            alertController.addAction(photoLibrary)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.view.tintColor = .colorPrimary        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func actionAction(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.imagePicker.sourceType = type
            
            DispatchQueue.main.async {
                // make sure to call this present explicitly on the main thread
                self.present(self.imagePicker, animated: true)
            }
        }
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        if isUpdating {
            self.navigationController?.popViewController(animated: true)
            
        } else {
            // to dismiss two view controllers at once (BusinessSign & BusinessDetails)
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapSetHours(_ sender: Any) {
        let hoursVC = SetHoursContainerController.instance()
        hoursVC.isUpdating = isUpdating
        
        navigationController?.pushViewController(hoursVC, animated: true)
    }
    
    @IBAction func didTapAddCertification(_ sender: Any) {
        let serviceFileVC = AddServiceFileViewController.instance()
        serviceFileVC.isInsurance = false
        serviceFileVC.delegate = self
        
        serviceFileVC.view.frame.size.height = 454
        
        let options: [SemiModalOption : Any] = [
            SemiModalOption.pushParentBack: false,
            SemiModalOption.parentScale: 1.0,
            SemiModalOption.animationDuration: 0.35]
        
        presentSemiViewController(serviceFileVC, options: options)
    }
    
    @IBAction func didTapAddInsurance(_ sender: Any) {
        let serviceFileVC = AddServiceFileViewController.instance()
        serviceFileVC.isInsurance = true
        serviceFileVC.delegate = self
        
        serviceFileVC.view.frame.size.height = 454
        
        let options: [SemiModalOption : Any] = [
            SemiModalOption.pushParentBack: false,
            SemiModalOption.parentScale: 1.0,
            SemiModalOption.animationDuration: 0.35]
        
        presentSemiViewController(serviceFileVC, options: options)
    }
    
    // Link Social Medias
    @IBAction func didTapFacebook(_ sender: Any) {
        guard !vFacebookCheckbox.isChecked else {
            alertForDeleteSocial(ForType: "0")
            return
        }

        guard let currentToken = AccessToken.current else {
            // perform login
            let loginManager = LoginManager()
            loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { result in
                self.didCompleteFBLogin(result)
            }

            return
        }

        // request to get facebook profile via graphic API
        fetchFBUserProfile(currentToken.tokenString)
    }
    
    private func didCompleteFBLogin(_ result: LoginResult) {
        switch result {
        case .failed(let error):
            print(error)
            self.showErrorVC(msg: "Failed to fetch your FB profile.")
            break
            
        case .cancelled:
            self.showErrorVC(msg: "We were unable to fetch your profile as it's cancelled.")
            break
            
        case .success(_, _, let accessToken):
            print(accessToken)
            fetchFBUserProfile(accessToken.tokenString)
            break
        }
    }
    
    private func fetchFBUserProfile(_ token: String) {
        let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields" : "id, name, first_name, last_name, picture.width(480).height(480), link"], tokenString: token, version: nil, httpMethod: .get)
        
        graphRequest.start { (_, result, error) in
            guard error == nil,
                let fbResult = result as? [String: Any],
                let id = fbResult["id"] as? String else {
                    // here id is a kind of sensitive value
                self.showErrorVC(msg: "Failed to fetch your FB profile")
                return
            }
            
            let name = fbResult["name"] as? String ?? "" // full name
//            let firstName = fbResult["first_name"] as? String ?? ""
//            let lastName = fbResult["last_name"] as? String ?? ""
            let link = fbResult["link"] as? String ?? ""
            var profileLink = ""
            if let picture = fbResult["picture"] as? [String: Any],
               let pictureData = picture["data"] as? [String: Any] {
                profileLink = pictureData["url"] as? String ?? ""
            }
            
            self.openFBLinkPopup(with: id, name: name, profile: profileLink, link: link)
        }
    }
    
    private func openFBLinkPopup(with id: String, name: String, profile: String, link: String) {
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius = 30

        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color = .black

        let fbDetailsVC = FBDetailsViewController(nibName: "FBDetailsViewController", bundle: nil)
        fbDetailsVC.username = id
        fbDetailsVC.name = name
        fbDetailsVC.profileLink = profile
        fbDetailsVC.link = link
        
        fbDetailsVC.delegate = self

        let popup = PopupDialog(viewController: fbDetailsVC, buttonAlignment: .horizontal, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: true, panGestureDismissal: true, hideStatusBar: false, completion: nil)

        present(popup, animated: true)
    }
    
    @IBAction func didTapInstagram(_ sender: Any) {
        if vInstagramCheckbox.isChecked {
            alertForDeleteSocial(ForType: "1")
            
        } else {
            showLinkInputView(ForType: "1", show: vInstagramName.isHidden)
        }
    }
    
    @IBAction func didTapLinkInstagram(_ sender: Any) {
        guard let socialName = txfInstagramName.text,
            !socialName.isEmpty else {
                showErrorVC(msg: "Please enter your Instagram username.")
                return
        }
        
        showIndicator()
        APIManager.shared.addSocial(g_myToken, type: "1", name: socialName.trimmedString) { (result, message) in
            self.hideIndicator()
            
            if result {
                self.updateSocialLink(ForType: "1")
                
            } else {
                self.showErrorVC(msg: "There was an error to link your Instgram account in your profile. Please try again later")
            }
        }
    }
    
    @IBAction func didTapTwitter(_ sender: Any) {
        if vTwitterCheckbox.isChecked {
            alertForDeleteSocial(ForType: "2")
            
        } else {
            showLinkInputView(ForType: "2", show: vTwitterName.isHidden)
        }
    }
    
    @IBAction func didTapLinkTwitter(_ sender: Any) {
        guard let socialName = txfTwitterName.text,
            !socialName.isEmpty else {
                showErrorVC(msg: "Please enter your Twitter username.")
                return
        }
        
        showIndicator()
        APIManager.shared.addSocial(g_myToken, type: "2", name: socialName.trimmedString) { (result, message) in
            self.hideIndicator()
            
            if result {
                self.updateSocialLink(ForType: "2")
                
            } else {
                self.showErrorVC(msg: "There was an error to link your Twitter account in your profile. Please try again later")
            }
        }
    }
    
    private func showLinkInputView(ForType type: String, show: Bool) {
        let view = type == "1" ? vInstagramName! : vTwitterName!
        
        UIView.animate(withDuration: 0.35,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 1,
            options: [],
            animations: {
                view.isHidden = !show

                if show {
                    view.alpha = 1

                } else {
                    view.alpha = 0
                }

                self.view.layoutIfNeeded()
             },
        completion: nil)
    }
    
    private func updateSocialLink(ForType type: String, isLinked: Bool = true, animated: Bool = true) {
        if type == "0" {
            vFacebookCheckbox.isChecked = isLinked
            
            // facebook linked process in delegate
            guard !isLinked else { return }
            
            // facebook social profile removed
            g_myInfo.business_profile.fbUsername = ""
            
            guard isUpdating else { return }
            
            // only post notification when business update their profile
            NotificationCenter.default.post(name: .Social_Links_Updated, object: nil, userInfo: nil)
            
        } else if type == "1" {
            vInstagramCheckbox.isChecked = isLinked
            
            txfInstagramName.isUserInteractionEnabled = !isLinked
            
            if animated {
                UIView.animate(withDuration: 0.35) {
                    self.btnLinkInstagram.isHidden = isLinked
                }
                
            } else {
                self.btnLinkInstagram.isHidden = isLinked
            }
            
            // update my social info, instagram username
            g_myInfo.business_profile.instaUsername = isLinked ? txfInstagramName.text!.trimmedString : ""
            
            guard isUpdating else { return }
            
            // only post notification when business update their profile
            NotificationCenter.default.post(name: .Social_Links_Updated, object: nil, userInfo: nil)
            
        } else {
            vTwitterCheckbox.isChecked = isLinked
            
            txfTwitterName.isUserInteractionEnabled = !isLinked
            
            if animated {
                UIView.animate(withDuration: 0.35) {
                    self.btnLinkTwitter.isHidden = isLinked
                }
                
            } else {
                self.btnLinkTwitter.isHidden = isLinked
            }
            
            // update my social info, instagram username
            g_myInfo.business_profile.twitterUsername = isLinked ? txfTwitterName.text!.trimmedString : ""
            
            guard isUpdating else {
                return
            }
            
            // only post notification when business update their profile
            NotificationCenter.default.post(name: .Social_Links_Updated, object: nil, userInfo: nil)
        }
    }
    
    private func alertForDeleteSocial(ForType type: String) {
        var socialName = ""
        
        if type == "0" {
            socialName = "Facebook"
            
        } else if type == "1" {
            socialName = "Instgram"
            
        } else {
            socialName = "Twitter"
        }
        
        showAlert("ATB Warning!", message: "Are you going to remove \(socialName) account from your business profile?", positive: "Yes", positiveAction: { _ in
            self.deletSocial(ForType: type)
        }, negative: "No")
    }
    
    private func deletSocial(ForType type: String) {
        showIndicator()
        
        APIManager.shared.deleteSocial(g_myToken, type: type) { (result, message) in
            self.hideIndicator()
            
            if result {
                self.didRemoveSocialLink(type)
                
            } else {
                self.showErrorVC(msg: "We were unable to remove your social profile. Please try again later.")
            }
        }
        
    }
    
    private func didRemoveSocialLink(_ type: String) {
        updateSocialLink(ForType: type, isLinked: false)

        guard type != "0" else { return }

        showLinkInputView(ForType: type, show: false)

        if type == "1" {
            txfInstagramName.text = ""

        } else {
            txfTwitterName.text = ""
        }
    }
    
    weak var tagTipView: EasyTipView?
    @IBAction func didTapAddTagInfo(_ sender: UIButton) {
        if let tipView = tagTipView {
            tipView.dismiss()
            return
        }
        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        preferences.drawing.foregroundColor = UIColor.white
        preferences.drawing.textAlignment = NSTextAlignment.left
        preferences.drawing.font = UIFont(name: Font.SegoeUILight, size: 16)!
        preferences.drawing.arrowPosition = .bottom
        preferences.positioning.maxWidth = SCREEN_WIDTH - 40
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let tipView = EasyTipView(text: "Please add single word tags that best represent what your business is about, this will make it easier for customers to find you via the search page", preferences: preferences)
        tipView.show(forView: sender)
        tagTipView = tipView

        DispatchQueue.main .asyncAfter(deadline: DispatchTime.now() + 4.0) {
            tipView.dismiss()
        }
    }
    
    private func isValid() -> Bool {
        if selectedBusinessLogo == nil && !isUpdating {
            self.showErrorVC(msg: "Please add your business logo.")
            return false
        }
        
        if self.txfBusinessName.isEmpty() {
            self.showErrorVC(msg: "Please input business name.")
            return false
        }
        
        if let websiteLink = txfBusinessWebsite.text,
           !websiteLink.isEmpty {
            guard websiteLink.isValidUrl else {
                self.showErrorVC(msg: "Please input a valid website url.")
                return false
            }
        }
        
        if txvBusinessInfo.text.isEmpty {
            showErrorVC(msg: "Please add your business information.")
            return false
        }
        
        return true
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        guard isValid() else { return }

        updateBusiness()
    }
    
    // create a business
    private func updateBusiness() {
        let timezone = TimeZone.current.secondsFromGMT()/(60*60)
        var params = [
            "token" : g_myToken,
            "business_name" : txfBusinessName.text!.trimmedString,
            "business_website" : txfBusinessWebsite.text!.trimmedString,
            "business_profile_name" : txfBusinessName.text!.trimmedString,
            "business_bio": txvBusinessInfo.text!.trimmedString,
            "timezone": "\(timezone)"
        ]
        
        let url = isUpdating ? UPDATE_BUSINESS_API : CREATE_BUSINESS_API
        
        if isUpdating {
            params["id"] = g_myInfo.business_profile.ID
        }
        
        // let's get social usernames
        // it will be updated before these details updated
        // so need to get values, to assign after it's get updated
        let fbUsername = g_myInfo.business_profile.fbUsername
        let instaUsername = g_myInfo.business_profile.instaUsername
        let twitterUsername = g_myInfo.business_profile.twitterUsername
        
        showIndicator()
        ATB_Alamofire.shareInstance.upload(
            multipartFormData: { (multipartFormData) in
                if let businessLogo = self.selectedBusinessLogo {
                    multipartFormData.append(businessLogo, withName: "avatar", fileName: "business_profileimg.jpg", mimeType: "image/jpeg")
                }
                
                for param in params {
                    multipartFormData.append(param.value.data(using: .utf8)!, withName: param.key)
                }
            },
            to: url,
            usingThreshold: multipartFormDataEncodingMemoryThreshold,
            method: .post,
            headers: nil,
            interceptor: nil,
            fileManager: FileManager.default
        ).responseJSON { (response) in
            switch response.result {
            case .success(let JSON):
                guard let res = JSON as? NSDictionary,
                      let result = res["result"] as? Bool,
                      result else {
                    self.hideIndicator()
                    self.didFailUpdateBusiness()
                    return
                }
                
                let businessDict = res["extra"] as! NSDictionary
                let business = BusinessModel(info: businessDict)
                
                // update account type
                g_myInfo.accountType = 1
                g_myInfo.business_profile = business
                
                // assign social names
                g_myInfo.business_profile.fbUsername = fbUsername
                g_myInfo.business_profile.instaUsername = instaUsername
                g_myInfo.business_profile.twitterUsername = twitterUsername
                
                if self.isUpdating {
                    // The user has updated their business profile
                    self.hideIndicator()
                    self.didFinishUpdateBusiness()
                    
                } else {
                    // The user's business profile has been created!
                    let businessProfile = g_myInfo.business_profile

                    // create a business chat user
                    let alUser : ALUser =  ALUser()
                    let userId = businessProfile.ID + "_" + g_myInfo.ID
                    alUser.userId = userId
                    alUser.email = g_myInfo.emailAddress
                    alUser.imageLink = businessProfile.businessPicUrl
                    alUser.displayName = businessProfile.businessProfileName
                    alUser.password = userId
                    
                    // Saving these details
                    ALUserDefaultsHandler.setUserId(alUser.userId)
                    ALUserDefaultsHandler.setEmailId(alUser.email)
                    ALUserDefaultsHandler.setDisplayName(alUser.displayName)
                    
                    let chatManager = ALChatManager(applicationKey: "emtrac2ba61d90383c69a7fbc7db07725fa3e5b")
                    // make sure to logout before login with a new business chat user
                    if !ALUserDefaultsHandler.isLoggedIn() {
                        let registerUserClinetService = ALRegisterUserClientService()
                        registerUserClinetService.logout { (response, error) in
                            chatManager.connectUserWithCompletion(alUser, completion: { _, _ in })
                        }
                        
                    } else {
                        // Registering or Login in the User
                        chatManager.connectUserWithCompletion(alUser, completion: { _, _ in })
                    }
                    
                    // post a notification to notify that the user has upgraded their account to a business one
                    NotificationCenter.default.post(name: .DidUpgradeAccount, object: nil)
                    
                    if self.weekdays.count > 0 {
                        self.setOperatingHours()
                        
                    } else {
                        self.hideIndicator()
                        
                        self.gotoSubscribe()
                    }
                }
                
            case .failure(_):
                self.hideIndicator()
                self.didFailUpdateBusiness()
            }
        }
    }
    
    private func setOperatingHours() {
        var week = [Any]()
        for weekday in weekdays {
            let weekdayDict: [String: Any] = [
                "is_available": weekday.isAvailable ? "1" : "0",
                "day": weekday.day as Any,
                "start": weekday.start,
                "end": weekday.end
            ]
            
            week.append(weekdayDict)
        }
        
        APIManager.shared.updateWeek(g_myToken, week: week) { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                g_myInfo.business_profile.weekdays.removeAll()
                g_myInfo.business_profile.weekdays.append(contentsOf: self.weekdays)
                
            case .failure(_): break
            }
            
            self.gotoSubscribe()
        }
    }
    
    private func didFinishUpdateBusiness() {
        // post a notification to refersh business profile page
        NotificationCenter.default.post(name: .DidUpdateBusinessProfile, object: nil)
        
        let business = g_myInfo.business_profile
        if business.isPaid {
            showSuccessVC(msg: "Your business profile has been updated successfully.")
            
        } else {
            showAlert("ATB", message: "You have not subscribed for your business account yet!\nWould you like to subscribe now?", positive: "Yes", positiveAction: { _ in
                self.gotoSubscribe()
                
            }, negative: "No", negativeAction: nil, preferredStyle: .actionSheet)
        }
    }
    
    private func didFailUpdateBusiness() {
        if isUpdating {
            self.showErrorVC(msg: "It's been failed to update your business profile!")
            
        } else {
            self.showErrorVC(msg: "It's been failed to create your business account!")
        }
    }
    
    private func didCompleteBusinessSetup() {
        let completeVC = BusinessSetupCompletedViewController.instance()
        self.navigationController?.pushViewController(completeVC, animated: true)
    }
    
    private func gotoSubscribe() {
        let subscribeVC = SubscribeBusinessViewController.instance()
        subscribeVC.modalPresentationStyle = .overFullScreen
        subscribeVC.delegate = self
        
        self.present(subscribeVC, animated: true, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension BusinessDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[.editedImage] as? UIImage,
            let selectedImageData = selectedImage.jpegData(compressionQuality: 1.0) else {
            return
        }
        
        selectedBusinessLogo = selectedImageData
        
        imvBusinessLogo.image = selectedImage
        
        checkValidation()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension BusinessDetailsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txfBusinessName {
            txfBusinessWebsite.becomeFirstResponder()
            
        } else if textField == txfBusinessWebsite {
            txvBusinessInfo.becomeFirstResponder()
        }
        
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: - UITextViewDelegate
extension BusinessDetailsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        checkValidation()
    }
}

// MARK: AddServiceFileDelegate
extension BusinessDetailsViewController: AddServiceFileDelegate {
    
    func didAddServiceFile(_ added: ServiceFileModel) {
        if added.isInsurance {
            insurances.append(added)
            
            UIView.animate(withDuration: 0.35, animations: {
                self.heightForInsurancesTableView.constant += 76
                self.view.layoutIfNeeded()
                
            }) { _ in
                self.tblInsurances.reloadData()
            }
            
        } else {
            qualifications.append(added)
            
            UIView.animate(withDuration: 0.35, animations: {
                self.heightForQualificationsTableView.constant += 76
                self.view.layoutIfNeeded()
                
            }) { _ in
                self.tblQualifications.reloadData()
            }
        }
    }
    
    func didUpdateServiceFile(_ updated: ServiceFileModel) {
        var updatedIndex = -1
        
        if updated.isInsurance {
            for (index, insurance) in insurances.enumerated() {
                if insurance.id == updated.id {
                    updatedIndex = index
                    break
                }
            }
            
            guard updatedIndex > 0 else { return }
            
            insurances[updatedIndex].name = updated.name
            insurances[updatedIndex].reference = updated.reference
            insurances[updatedIndex].expiry = updated.expiry
            insurances[updatedIndex].fileName = updated.fileName
            
            tblInsurances.reloadData()
            
        } else {
            for (index, qualification) in qualifications.enumerated() {
                if qualification.id == updated.id {
                    updatedIndex = index
                    break
                }
            }
            
            guard updatedIndex > 0 else { return }
            
            qualifications[updatedIndex].name = updated.name
            qualifications[updatedIndex].reference = updated.reference
            qualifications[updatedIndex].expiry = updated.expiry
            qualifications[updatedIndex].fileName = updated.fileName
            
            tblQualifications.reloadData()
        }
    }
}

// MARK: FBConnectDelegate
extension BusinessDetailsViewController: FBConnectDelegate {
    
    func facebookConnected(_ username: String) {
        updateSocialLink(ForType: "0", isLinked: true)
        
        // need to set the username whenever it gets updated to always get updated
        // we will not get username on updateSocialLink, so update them here
        g_myInfo.business_profile.fbUsername = username
        
        guard isUpdating else {
            return
        }
        
        NotificationCenter.default.post(name: .Social_Links_Updated, object: nil, userInfo: nil)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension BusinessDetailsViewController: UITableViewDataSource, UITableViewDelegate {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblQualifications {
            return qualifications.count
            
        } else {
            return insurances.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ServiceFileCell.reuseIdentifier, for: indexPath) as! ServiceFileCell
        
        if tableView == tblQualifications {
            let qualification = qualifications[indexPath.row]
            cell.configureCell(qualification)
            cell.deleted = {
                self.deleteServiceFile(qualification)
            }
            
        } else {
            let insurance = insurances[indexPath.row]
            cell.configureCell(insurance)
            cell.deleted = {
                self.deleteServiceFile(insurance)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ServiceFileCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show edit popup
        let serviceFileVC = AddServiceFileViewController.instance()

        let isInsurance = (tableView == tblInsurances)
        serviceFileVC.isInsurance = isInsurance
        serviceFileVC.selectedFile = isInsurance ? insurances[indexPath.row] : qualifications[indexPath.row]
        serviceFileVC.delegate = self

        serviceFileVC.view.frame.size.height = 454

        let options: [SemiModalOption : Any] = [
            SemiModalOption.pushParentBack: false,
            SemiModalOption.parentScale: 1.0,
            SemiModalOption.animationDuration: 0.35]

        presentSemiViewController(serviceFileVC, options: options)
    }
    
    private func deleteServiceFile(_ deleted: ServiceFileModel) {
        showIndicator()
        
        APIManager.shared.deleteServieFile(g_myToken, id: deleted.id) { (result, message) in
            self.hideIndicator()
            
            if result {
                var deletedIndex = -1
                    
                if deleted.isInsurance {
                    for (index, insurance) in self.insurances.enumerated() {
                        if insurance.id == deleted.id {
                            deletedIndex = index
                            break
                        }
                    }
                    
                    guard deletedIndex >= 0 else { return }
            
                    self.insurances.remove(at: deletedIndex)
                    self.tblInsurances.reloadData()
                    
                    UIView.animate(withDuration: 0.35, animations: {
                        self.heightForInsurancesTableView.constant -= 76
                        self.view.layoutIfNeeded()
                    })
                    
                } else {
                    for (index, qualification) in self.qualifications.enumerated() {
                        if qualification.id == deleted.id {
                            deletedIndex = index
                            break
                        }
                    }
                    
                    guard deletedIndex >= 0 else { return }
                    
                    self.qualifications.remove(at: deletedIndex)
                    self.tblQualifications.reloadData()
                    
                    UIView.animate(withDuration: 0.35, animations: {
                        self.heightForQualificationsTableView.constant -= 76
                        self.view.layoutIfNeeded()
                    })
                }
                
            } else {
                if let message = message {
                    self.showErrorVC(msg: message)
                }
            }
        }
    }
}

// MARK: - SubscriptionDelegate
extension BusinessDetailsViewController: SubscriptionDelegate {
    
    func didCompleteSubscription() {
        self.showAlert("Subscription Complete!", message: "Your business subscription has been completed successfully. A member of ATB Admin will review your business account shortly.", negative: "Thanks", negativeAction: { _ in
            guard !self.isUpdating else { return }
            
            // The user has created their business account
            // subscription has been completed successfully
            if self.isFromProfile {
                // The user was upgrading their account to a business account from their profile page
                self.didCompleteBusinessSetup()
                
            } else {
                // The user has upgraded their account to a business account while posting
                // to dismiss two view controllers at once (BusinessSign & BusinessDetails)
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
            
        }, preferredStyle: .actionSheet)
    }
    
    func didIncompleteSubscription() {
        guard !isUpdating else { return }
        
        // The user has created their business account
        // subscription has been failed
        if isFromProfile {
            // The user was upgrading their account to a business account from their profile page
            self.didCompleteBusinessSetup()
            
        } else {
            // The user has upgraded their account to a business account while posting
            // to dismiss two view controllers at once (BusinessSign & BusinessDetails)
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - TagModel
class TagModel {
    
    var id = ""
    var name = ""
}
