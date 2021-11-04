//
//  ProfileAuctionViewController.swift
//  ATB
//
//  Created by YueXi on 3/17/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import NBBottomSheet
import EasyTipView
import PopupDialog
import SwiftCSVExport
import ActionSheetPicker_3_0

class ProfileAuctionViewController: BaseViewController {
    
    static let kStoryboardID = "ProfileAuctionViewController"
    class func instance() -> ProfileAuctionViewController {
        let storyboard = UIStoryboard(name: "BusinessBoost", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: ProfileAuctionViewController.kStoryboardID) as? ProfileAuctionViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var btnClose: UIButton! { didSet {
        if #available(iOS 13.0, *) {
            btnClose.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnClose.tintColor = UIColor.white.withAlphaComponent(0.3)
    }}
    
    @IBOutlet weak var imvProfilePin: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var navBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var lblWhere: UILabel!
    @IBOutlet weak var lblGroup: UILabel!
    @IBOutlet weak var imvGroupDownArrow: UIImageView!
    
    @IBOutlet weak var tblAuction: UITableView!
    
    @IBOutlet weak var auctionEndsView: UIView!
    @IBOutlet weak var lblAuctionEnds: UILabel!
    
    @IBOutlet weak var timerContainer: UIView!
    
    @IBOutlet weak var daysContainer: UIView!
    @IBOutlet weak var daysLeftLabel: UILabel!
    @IBOutlet weak var hoursLeftLabel: UILabel!
    @IBOutlet weak var minutesLeftLabel: UILabel!
    @IBOutlet weak var secondsLeftLabel: UILabel!
    @IBOutlet weak var daysHoursSeparator: InsetLabel!
    @IBOutlet weak var hoursMinutesSeparator: InsetLabel!
    @IBOutlet weak var minutesSecondsSeparator: InsetLabel!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    
    @IBOutlet weak var btnReturn: UIButton!
    
    private var selectedGroup: String = "Beauty"
    private var selectedCountry: String = "United Kingdom"
    private var selectedCounty: String = "Essex"
    private var selectedRegion: String = "Brentwood"
    
    private var profileAuctions = [AuctionModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        
        setupViews()
        
        timeEnd = Date().endOfWeek
        
        scheduleTimer()
        
        loadStates()
        
        getProfilePinAuctions()
    }
    
    private func initData() {
        let locations = g_myInfo.address.split(separator: ",")
        selectedCountry = "United Kingdom"
        
        if locations.count > 1,
           !locations[1].isEmpty {
            selectedCounty = String(locations[1]).trimmedString
        }
        
        if locations.count > 0,
           !locations[0].isEmpty {
            selectedRegion = String(locations[0]).trimmedString
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray23
        containerView.backgroundColor = .colorGray23
        
        imvProfilePin.image = UIImage(named: "profile.pin")
        
        lblTitle.text = "Profile\nPin"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 29)
        lblTitle.textColor = .white
        lblTitle.numberOfLines = 2
        lblTitle.setLineSpacing(lineHeightMultiple: 0.75)
        
        if UIApplication.safeAreaTop() <= 20 {
            navBottomConstraint.constant = -20
        }
        
        // container view
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.layer.cornerRadius = 20
        
        lblWhere.text = "Where would you like to pin your profile?"
        lblWhere.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblWhere.textColor = .colorGray2
        lblWhere.textAlignment = .center
        
        lblGroup.text = selectedGroup
        lblGroup.font = UIFont(name: Font.SegoeUILight, size: 22)
        lblGroup.textColor = .colorPrimary
        
        if #available(iOS 13.0, *) {
            imvGroupDownArrow.image = UIImage(systemName: "chevron.down")
        } else {
            // Fallback on earlier versions
        }
        imvGroupDownArrow.tintColor = .colorPrimary
        
        tblAuction.showsVerticalScrollIndicator = false
        tblAuction.separatorStyle = .none
        tblAuction.tableFooterView = UIView()
        tblAuction.rowHeight = 70
        tblAuction.backgroundColor = .clear
        tblAuction.keyboardDismissMode = .interactive
        
        tblAuction.register(ProfileAuctionHeader.self, forHeaderFooterViewReuseIdentifier: ProfileAuctionHeader.reuseIdentifier)
        
        tblAuction.dataSource = self
        tblAuction.delegate = self
        
        auctionEndsView.backgroundColor = .colorBlue10
        lblAuctionEnds.text = "Auctuation ends in:"
        lblAuctionEnds.font = UIFont(name: Font.SegoeUILight, size: 17)
        lblAuctionEnds.textColor = .white
        
        setupTimerComponents()
        
        btnReturn.setTitle("Return to my profile ", for: .normal)
        btnReturn.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 17)
        btnReturn.setTitleColor(.white, for: .normal)
        if #available(iOS 13.0, *) {
            btnReturn.setImage(UIImage(systemName: "person.crop.circle"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnReturn.tintColor = .white
        // make sure to set this after setting icon and title
        if let imageView = btnReturn.imageView,
           let titleLabel = btnReturn.titleLabel {
            btnReturn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageView.frame.size.width, bottom: 0, right: imageView.frame.size.width)
            btnReturn.imageEdgeInsets = UIEdgeInsets(top: 0, left: titleLabel.frame.size.width, bottom: 0, right: -titleLabel.frame.size.width)
        }
        btnReturn.backgroundColor = .colorBlue5
        btnReturn.layer.cornerRadius = 5
    }
    
    // set-up timer UI components
    private func setupTimerComponents() {
        timerContainer.backgroundColor = .colorPrimary
        
        let separatorLabels = [daysHoursSeparator!, hoursMinutesSeparator!, minutesSecondsSeparator!]
        for separatorLabel in separatorLabels {
            separatorLabel.text = ":"
            separatorLabel.font = UIFont(name: Font.SegoeUILight, size: 50)
            separatorLabel.textColor = .colorBlue13
            separatorLabel.setLineSpacing(lineHeightMultiple: 0.75)
        }
        
        let componentLeftLabels = [daysLeftLabel!, hoursLeftLabel!, minutesLeftLabel!, secondsLeftLabel!]
        for (index, componentLeftLabel) in componentLeftLabels.enumerated() {
            componentLeftLabel.text = index > 0 ? "00" : "0"
            componentLeftLabel.font = UIFont(name: Font.SegoeUISemibold, size: 50)
            componentLeftLabel.textColor = .white
            componentLeftLabel.setLineSpacing(lineHeightMultiple: 0.75)
        }
        
        let componentLabels = [daysLabel!, hoursLabel!, minutesLabel!, secondsLabel!]
        let components = ["Days", "Hours", "Minutes", "Seconds"]
        for (index, componentLabel) in componentLabels.enumerated() {
            componentLabel.text = components[index].uppercased()
            componentLabel.font = UIFont(name: Font.SegoeUILight, size: 14)
            componentLabel.textColor = .white
        }
    }
    
    private var timeEnd: Date?
    @objc private func setTimeLeft() {
        guard let timeEnd = self.timeEnd else {
            invalidateTimer()
            return
        }
        
        let timeNow = Date()
        guard timeEnd.compare(timeNow) == .orderedDescending else {
            invalidateTimer()
            return
        }
        
        let interval = timeEnd.timeIntervalSince(timeNow)
        
        let days =  (interval / (24*60*60)).rounded(.down)
        let daysRemainder = interval.truncatingRemainder(dividingBy: 24*60*60)
        let hours = (daysRemainder / (60 * 60)).rounded(.down)
        let hoursRemainder = daysRemainder.truncatingRemainder(dividingBy: 60 * 60).rounded(.down)
        let minutes  = (hoursRemainder / 60).rounded(.down)
        let minutesRemainder = hoursRemainder.truncatingRemainder(dividingBy: 60).rounded(.down)
        let seconds = minutesRemainder.truncatingRemainder(dividingBy: 60).rounded(.down)
        
        daysLeftLabel.text = "\(Int(days))"
        hoursLeftLabel.text = Int(hours).stringWithLeadingZeros
        minutesLeftLabel.text = Int(minutes).stringWithLeadingZeros
        secondsLeftLabel.text = Int(seconds).stringWithLeadingZeros
    }
    
    var countdownTimer: Timer?
    private func scheduleTimer() {
        setTimeLeft()
        
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setTimeLeft), userInfo: nil, repeats: true)
    }
    
    private func invalidateTimer() {
        countdownTimer?.invalidate()
        
        let componentLeftLabels = [daysLeftLabel!, hoursLeftLabel!, minutesLeftLabel!, secondsLeftLabel!]
        for (index, componentLeftLabel) in componentLeftLabels.enumerated() {
            componentLeftLabel.text = index > 0 ? "00" : "0"
        }
    }
    
    // load states and cities from CSV
    // this will take few secs to load all cities
    private var towns = [TownModel]()
    private var counties = [String]()
    private func loadStates() {
        guard let filePath = Bundle.main.path(forResource: "uk-towns", ofType: "csv") else {
            showErrorVC(msg: "It's been failed to load counties and regions, please try again later!")
            return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let townsCSV = CSVExport.readCSV(filePath)
            
            for row in townsCSV.rows {
                guard let townDict =  row as? NSDictionary else { continue }
                
                let town = TownModel(with: townDict)
                self.towns.append(town)
                
                let county = town.county.trimmedString
                if !self.counties.contains(county) {
                    self.counties.append(county)
                }
            }
            
            self.counties.sort(by: { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending })
        }
    }
    
    @IBAction func didTapSelectGroup(_ sender: Any) {
        let configuration = NBBottomSheetConfiguration()
        configuration.animationDuration = 0.35
        configuration.sheetSize = .fixed(60+480+8+56+8)
        configuration.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        
        let sheetController = NBBottomSheetController(configuration: configuration)
        
        let toVC = SelectGroupViewController.instance()
        toVC.selected = selectedGroup
        toVC.delegate = self
        
        sheetController.present(toVC, on: self)
    }
    
    private func didTapSelectCountry() {
        
    }
    
    private func didSelectCounty(_ selected: String) {
        guard selectedCounty != selected else { return }
        
        selectedCounty = selected
        
        let townsInTheCounty = towns.filter({ $0.county == selectedCounty })
        var regions = [String]()
        for town in townsInTheCounty {
            let region = town.region.trimmedString
            if !regions.contains(region) {
                regions.append(region)
            }
        }
        
        regions.sort(by: { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending })
        selectedRegion = regions.count > 0 ? regions.first! : ""
        
        tblAuction.performBatchUpdates {
            self.tblAuction.reloadSections([1, 2], with: .fade)
            
        } completion: { _ in
            self.getProfilePinAuctions()
        }
    }
    
    private func didTapSelectCounty(_ sender: Any) {
        guard counties.count > 0 else {
            showInfoVC("ATB", msg: "Please wait while loading counties...")
            return }

        var selectedCountyIndex = 0
        if !selectedCounty.isEmpty,
           let foundIndex = counties.firstIndex(where: { $0 == selectedCounty }) {
            selectedCountyIndex = foundIndex
        }
                
        let picker = ActionSheetStringPicker(title: "Select a County", rows: counties, initialSelection: selectedCountyIndex, doneBlock: { (picker, index, value) in
            self.didSelectCounty(value as! String)

        }, cancel: nil, origin: sender)

        picker?.tapDismissAction = .cancel

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        picker?.pickerTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: Font.SegoeUILight, size: 17)!,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: UIColor.colorGray1
        ]

        picker?.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: Font.SegoeUIBold, size: 19)!,
            NSAttributedString.Key.foregroundColor: UIColor.colorPrimary
        ]
        picker?.pickerBackgroundColor = .colorGray23
        picker?.toolbarBackgroundColor = .white

        // custom done button
        let doneButton = UIButton()
        doneButton.setTitle("Select", for: .normal)
        doneButton.titleLabel?.font
            = UIFont(name: Font.SegoeUISemibold, size: 18)
        doneButton.setTitleColor(.colorPrimary, for: .normal)
        let customDoneButton = UIBarButtonItem.init(customView: doneButton)
        picker?.setDoneButton(customDoneButton)

        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font
            = UIFont(name: Font.SegoeUISemibold, size: 18)
        cancelButton.setTitleColor(.colorRed1, for: .normal)
        let customCancelButton = UIBarButtonItem.init(customView: cancelButton)
        picker?.setCancelButton(customCancelButton)

        picker?.show()
    }
    
    private func didSelectRegion(_ selected: String) {
        guard selectedRegion != selected else { return }
        
        selectedRegion = selected
        tblAuction.performBatchUpdates {
            self.tblAuction.reloadSections([2], with: .fade)
            
        } completion: { _ in
            self.getProfilePinAuctions()
        }
    }
    
    private func didTapSelectRegion(_ sender: Any) {
        guard towns.count > 0 else {
            showInfoVC("ATB", msg: "Please wait while loading regions...")
            return }
        
        let townsInTheCounty = towns.filter({ $0.county == selectedCounty })
        var regions = [String]()
        for town in townsInTheCounty {
            let region = town.region.trimmedString
            if !regions.contains(region) {
                regions.append(region)
            }
        }
        
        regions.sort(by: { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending })

        var selecedRegionIndex = 0
        if !selectedRegion.isEmpty,
           let index = regions.firstIndex(where: { $0 == selectedRegion }) {
            selecedRegionIndex = index
        }
                
        let picker = ActionSheetStringPicker(title: "Select a Region", rows: regions, initialSelection: selecedRegionIndex, doneBlock: { (picker, index, value) in
            self.didSelectRegion(value as! String)

        }, cancel: nil, origin: sender)

        picker?.tapDismissAction = .cancel

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        picker?.pickerTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: Font.SegoeUILight, size: 17)!,
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor: UIColor.colorGray1
        ]

        picker?.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: Font.SegoeUIBold, size: 19)!,
            NSAttributedString.Key.foregroundColor: UIColor.colorPrimary
        ]
        picker?.pickerBackgroundColor = .colorGray23
        picker?.toolbarBackgroundColor = .white

        // custom done button
        let doneButton = UIButton()
        doneButton.setTitle("Select", for: .normal)
        doneButton.titleLabel?.font
            = UIFont(name: Font.SegoeUISemibold, size: 18)
        doneButton.setTitleColor(.colorPrimary, for: .normal)
        let customDoneButton = UIBarButtonItem.init(customView: doneButton)
        picker?.setDoneButton(customDoneButton)

        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font
            = UIFont(name: Font.SegoeUISemibold, size: 18)
        cancelButton.setTitleColor(.colorRed1, for: .normal)
        let customCancelButton = UIBarButtonItem.init(customView: cancelButton)
        picker?.setCancelButton(customCancelButton)

        picker?.show()
    }
    
    private func getProfilePinAuctions(showLoading: Bool = true, message: String? = nil) {
        if showLoading {
            showIndicator()
        }
        
        APIManager.shared.getAuctions(g_myToken, type: "0", category: selectedGroup, country: selectedCountry, county: selectedCounty, region: selectedRegion) { result in
            self.hideIndicator()
                        
            switch result {
            case .success(let auctions):
                self.profileAuctions.removeAll()
                self.profileAuctions.append(contentsOf: auctions)
                
                self.tblAuction.reloadData()
                
                if let message = message {
                    self.showInfoVC("ATB", msg: message)
                }
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    weak var easyTipView: EasyTipView?
    private func didTapBidNumber(_ anchor: UIView) {
        if let tipView = easyTipView {
            tipView.dismiss()
        }
        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.backgroundColor = .colorBlue10
        preferences.drawing.foregroundColor = .white
        preferences.drawing.textAlignment = .center
        preferences.drawing.arrowPosition = .bottom
        preferences.positioning.maxWidth = SCREEN_WIDTH - 40
        
        let personsAttachment = NSTextAttachment()
        if #available(iOS 13.0, *) {
            personsAttachment.image = UIImage(systemName: "person.3")?.withTintColor(.white)
            personsAttachment.setImageHeight(height: 18)
            
        } else {
            // Fallback on earlier versions
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let attributedText = NSMutableAttributedString(string: "\nCurrent Bids")
        attributedText.insert(NSAttributedString(attachment: personsAttachment), at: 0)
        attributedText.addAttributes(
            [.font: UIFont(name: Font.SegoeUISemibold, size: 10)!,
             .foregroundColor: UIColor.white,
             .paragraphStyle: paragraphStyle],
            range: NSRange(location: 0, length: attributedText.length))
        
        let tipView = EasyTipView(text: attributedText, preferences: preferences)
        tipView.show(forView: anchor)
        easyTipView = tipView
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            tipView.dismiss()
        })
    }
    
    // on - 0: country, 1: county, 2: region
    // position - 0, 1
    private func confirmBid(_ on: Int, position: Int, price: String?) {
        guard let priceString = price,
              !priceString.isEmpty else {
            showInfoVC("ATB", msg: "Please enter a valid bid amount!")
            return
        }
        
        let priceValue = priceString.floatValue
        guard priceValue >= 5.0 else {
            showInfoVC("ATB", msg: "Every auction starts at £5.00!")
            return
        }
        
        if let auction = getProfileAuction(forCategory: selectedGroup, bidOn: on, position: position),
           priceValue - auction.price < 0.5 {
            showInfoVC("ATB", msg: "Bids must be higher than the current bid and must be in increments of £0.50!")
            return
        }
        
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius = 14
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color = .black
        overlayAppearance.alpha = 0.5
        overlayAppearance.blurRadius = 8
        
        let confirmVC = ConfirmBidViewController()
        let confirmDialog = PopupDialog(viewController: confirmVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 100, tapGestureDismissal: true, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        let confirmButton = DefaultButton(title: "I Understand, Place Bid", height: 44, action: {
            self.placeBid(on, position: position, price: priceValue)
        })
        confirmButton.titleColor = .colorPrimary
        confirmButton.titleFont = UIFont(name: Font.SegoeUISemibold, size: 17)
        confirmButton.backgroundColor = .colorGray14
        confirmDialog.addButton(confirmButton)
        
        present(confirmDialog, animated: true, completion: nil)
    }
    
    private var bidMessage = ""
    private func placeBid(_ on: Int, position: Int, price: Float) {
        showIndicator()
        APIManager.shared.placeBid(g_myToken, type: "0", category: selectedGroup, position: position, price: price.priceString, country: on == 0 ? selectedCountry : nil, county: on == 1 ? selectedCounty : nil, region: on == 2 ? selectedRegion : nil) { (result, message, approvalLink) in
            self.hideIndicator()

            guard result,
                  let approvalLink = approvalLink else {
                self.showInfoVC("ATB", msg: message)
                return
            }

            self.bidMessage = message
            let authorizeVC = AuthorizeViewController()
            authorizeVC.approvalLink = approvalLink
            authorizeVC.delegate = self
            
            let navController = NavigationController(rootViewController: authorizeVC)
            navController.modalPresentationStyle = .overFullScreen
                self.present(navController, animated: true, completion: nil)
        }
    }
    
    // go to profile
    @IBAction func didTapReturnToProfile(_ sender: Any) {
        guard let navigationController = self.navigationController else { return }
        
        var setControllers = [UIViewController]()
        let currentViewControllers = navigationController.viewControllers
        
        guard currentViewControllers.count > 0 else { return }
        
        if let index = currentViewControllers.firstIndex(where: {
            $0 is ExSlideMenuController
        }) {
            for i in 0 ... index {
                setControllers.append(currentViewControllers[i])
            }
            
        } else {
            setControllers.append(currentViewControllers.first!)
            
            SlideMenuOptions.contentViewScale = 1.0
            SlideMenuOptions.leftViewWidth = SCREEN_WIDTH - 104
            let profileVC = ProfileViewController.instance()
            profileVC.isBusiness = true
            profileVC.isBusinessUser = g_myInfo.isBusiness
            profileVC.isOwnProfile = true
            
            let menuVC = ProfileMenuViewController.instance()
            menuVC.isBusiness = true
            menuVC.isBusinessUser = g_myInfo.isBusiness
            
            let slideController = ExSlideMenuController(mainViewController: profileVC, rightMenuViewController: menuVC)
            
            setControllers.append(slideController)
        }
        
        navigationController.setViewControllers(setControllers, animated: true)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        countdownTimer?.invalidate()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ProfileAuctionViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProfileAuctionHeader.reuseIdentifier) as? ProfileAuctionHeader else { return nil }
        // configure header
        var selected = ""
        switch section {
        case 0: selected = "United Kingdom"
        case 1: selected = selectedCounty.isEmpty ? "Select a County" : selectedCounty
        case 2: selected = selectedRegion.isEmpty ? "Select a Region" : selectedRegion
        default:  break
        }
        
        headerView.configureHeader(section, selected: selected)
        headerView.didTapSelect = {
            switch section {
            case 0: self.didTapSelectCountry()
            case 1: self.didTapSelectCounty(headerView.dropdownButton)
            case 2: self.didTapSelectRegion(headerView.dropdownButton)
            default: break
            }
        }
        
        return headerView
    }
    
    private func getProfileAuction(forCategory category: String, bidOn: Int, position: Int) -> AuctionModel? {
        guard profileAuctions.count > 0,
              let auction = profileAuctions.first(where: {
                $0.category == category && $0.bidOn == bidOn && $0.position == position
              }) else { return nil }
        
        return auction
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AuctionBidCell.reuseIdentifer, for: indexPath) as! AuctionBidCell
        // configure the cell
        cell.configureCell(getProfileAuction(forCategory: selectedGroup, bidOn: indexPath.section, position: indexPath.row), position: indexPath.row)
        
        cell.didTapBidNumber = {
            guard let anchorView = cell.bidNumberContainer else { return }
            self.didTapBidNumber(anchorView)
        }
        
        cell.didTapBid = {
            let priceString = cell.bidPriceField.text
            self.confirmBid(indexPath.section, position: indexPath.row, price: priceString)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let auctionCell = cell as? AuctionBidCell else { return }
        auctionCell.setTextFieldDelegate(self, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = .clear
    }
}

// MARK: - UITextFieldDelegate
extension ProfileAuctionViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let currentText = textField.text ?? "0.00"
        textField.text = currentText.doubleValue.priceString
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldText = textField.text, let r = Range(range, in: oldText) else { return true }

        let newText = oldText.replacingCharacters(in: r, with: string)
        let isNumeric = newText.isEmpty || (Double(newText) != nil)
        let numberOfDots = newText.components(separatedBy: ".").count - 1

        let numberOfDecimalDigits: Int
        if let dotIndex = newText.firstIndex(of: ".") {
            numberOfDecimalDigits = newText.distance(from: dotIndex, to: newText.endIndex) - 1
            
        } else {
            numberOfDecimalDigits = 0
        }

        return isNumeric && numberOfDots <= 1 && numberOfDecimalDigits <= 2
    }
}

// MARK: - SelectCategoryDelegate
extension ProfileAuctionViewController: SelectGroupDelegate {
    
    func didSelectGroup(_ selected: String) {
        selectedGroup = selected
        
        lblGroup.text = selected
        
        getProfilePinAuctions()
    }
}

// MARK: - ProfileAuctionHeader
class ProfileAuctionHeader: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "ProfileAuctionHeader"
    
    private let bidByTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Font.SegoeUIBold, size: 19)
        label.textColor = .white
        return label
    }()
    
    private let bidByLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Font.SegoeUILight, size: 22)
        label.textColor = .white
        return label
    }()
    
    private let downArrowImageView: UIImageView = {
        let imageView = UIImageView()
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: "chevron.down")
        } else {
            // Fallback on earlier versions
        }
        imageView.tintColor = .white
        return imageView
    }()
    
    let dropdownButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didTapSelect(_:)), for: .touchUpInside)
        return button
    }()
    
    var didTapSelect: (() -> Void)? = nil
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func setupSubviews() {
        let bgView = UIView()
        bgView.backgroundColor = .colorPrimary
        contentView.addSubview(bgView)
        addConstraintWithFormat("H:|[v0]|", views: bgView)
        addConstraintWithFormat("V:|[v0]|", views: bgView)
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = -6
        stackView.alignment = .center
        stackView.distribution = .fill
        
        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
        
        stackView.addArrangedSubview(bidByTitleLabel)
        
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(bidByLabel)
        view.addSubview(downArrowImageView)
        view.addConstraintWithFormat("H:|[v0]-8-[v1(24)]|", views: bidByLabel, downArrowImageView)
        view.addConstraintWithFormat("V:|[v0]|", views: bidByLabel)
        
        NSLayoutConstraint.activate([
            bidByLabel.centerYAnchor.constraint(equalTo: downArrowImageView.centerYAnchor),
            downArrowImageView.heightAnchor.constraint(equalToConstant: 24),
        ])
        stackView.addArrangedSubview(view)
        
        contentView.addSubview(dropdownButton)
        addConstraintWithFormat("H:|[v0]|", views: dropdownButton)
        addConstraintWithFormat("V:|[v0]|", views: dropdownButton)
    }
    
    func configureHeader(_ index: Int, selected: String) {
        switch index {
        case 0: bidByTitleLabel.text = "Bid By Country"
            
        case 1: bidByTitleLabel.text = "Bid By County"
            
        case 2: bidByTitleLabel.text = "Bid By Region"
            
        default: break
        }
        
        bidByLabel.text = selected
    }
    
    @objc private func didTapSelect(_ sender: Any) {
        didTapSelect?()
    }
}

// MARK: - PaymentAuthorizationDelegate
extension ProfileAuctionViewController: PaymentAuthorizationDelegate {
    
    func didAuthorizePayment() {
        getProfilePinAuctions(showLoading: true, message: bidMessage)
    }
    
    func didCancelAuthorization() {
        showInfoVC("ATB", msg: "Payment authorization has been cancelled!")
    }
}
