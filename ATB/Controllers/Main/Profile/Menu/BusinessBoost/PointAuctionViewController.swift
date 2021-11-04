//
//  PointAuctionViewController.swift
//  ATB
//
//  Created by YueXi on 3/17/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import NBBottomSheet
import EasyTipView
import PopupDialog

class PointAuctionViewController: BaseViewController {
    
    static let kStoryboardID = "PointAuctionViewController"
    class func instance() -> PointAuctionViewController {
        let storyboard = UIStoryboard(name: "BusinessBoost", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: PointAuctionViewController.kStoryboardID) as? PointAuctionViewController {
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
    
    @IBOutlet weak var imvPinPoint: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var navBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var lblWhere: UILabel!
    @IBOutlet weak var lblGroup: UILabel!
    @IBOutlet weak var imvGroupDownArrow: UIImageView!
    
    @IBOutlet weak var lblTypeTag: UILabel!
    @IBOutlet weak var tagContainer: UIView!
    @IBOutlet weak var tagTextField: TagInputField!
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        timeEnd = Date().endOfWeek
        
        scheduleTimer()
        
        getPinPointAuctions()
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray23
        containerView.backgroundColor = .colorGray23
        
        imvPinPoint.image = UIImage(named: "pin.point")
        
        lblTitle.text = "Pin\nPoint"
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
        
        if #available(iOS 13.0, *) {
            imvGroupDownArrow.image = UIImage(systemName: "chevron.down")
        } else {
            // Fallback on earlier versions
        }
        imvGroupDownArrow.tintColor = .colorPrimary
        
        lblGroup.text = selectedGroup
        lblGroup.font = UIFont(name: Font.SegoeUILight, size: 22)
        lblGroup.textColor = .colorPrimary
        
        lblTypeTag.text = "Please type in a tag word or phrase you would like to bid on"
        lblTypeTag.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblTypeTag.textColor = .colorGray2
        lblTypeTag.setLineSpacing(lineHeightMultiple: 0.75)
        lblTypeTag.textAlignment = .center
        lblTypeTag.numberOfLines = 2
        
        tagContainer.layer.borderWidth = 1
        tagContainer.layer.borderColor = UIColor.colorGray17.cgColor
        
        tagTextField.inputPadding = 4
        tagTextField.font = UIFont(name: Font.SegoeUILight, size: 19)
        tagTextField.textColor = .colorPrimary
        tagTextField.tintColor = .colorPrimary
        tagTextField.textAlignment = .center
        tagTextField.attributedText = NSAttributedString(string: "#")
        tagTextField.returnKeyType = .done
        
        tagTextField.tagInputFieldDelegate = self
        
        tblAuction.showsVerticalScrollIndicator = false
        tblAuction.separatorStyle = .none
        tblAuction.tableFooterView = UIView()
        tblAuction.rowHeight = 70
        tblAuction.backgroundColor = .clear
        tblAuction.keyboardDismissMode = .interactive
        
        tblAuction.register(PointAuctionHeader.self, forHeaderFooterViewReuseIdentifier: PointAuctionHeader.reuseIdentifier)
        
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
    
    private func didTapCurrentBidInfo(_ anchor: UIView) {
        if let tipView = easyTipView {
            tipView.dismiss()
        }
        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.backgroundColor = .colorBlue10
        preferences.drawing.foregroundColor = .white
        preferences.drawing.textAlignment = .center
        preferences.drawing.arrowPosition = .bottom
        preferences.positioning.maxWidth = SCREEN_WIDTH - 40
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 1, left: 10, bottom: 1, right: 10)
        
        let infoText = "CURRENT BID\n\nThe current bid is the highest bid so far for the current period. The profile picture to the left of the current bid is the current highest bidder for that particular tag word/phrase. The Blue circle to the right of the current bid is the number of bids that have been made for that particular tag word or phrase."
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let attributedText = NSMutableAttributedString(string: infoText)
        attributedText.addAttributes(
            [.font: UIFont(name: Font.SegoeUISemibold, size: 10)!,
             .foregroundColor: UIColor.white,
             .paragraphStyle: paragraphStyle],
            range: NSRange(location: 0, length: attributedText.length))
        attributedText.addAttributes(
            [.font: UIFont(name: Font.SegoeUIBold, size: 13)!],
            range: (infoText as NSString).range(of: "CURRENT BID"))
        
        let tipView = EasyTipView(text: attributedText, preferences: preferences)
        tipView.show(forView: anchor)
        easyTipView = tipView
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            tipView.dismiss()
        })
    }
    
    private func didTapYourBidInfo(_ anchor: UIView) {
        if let tipView = easyTipView {
            tipView.dismiss()
        }
        
        var preferences = EasyTipView.Preferences()
        preferences.drawing.backgroundColor = .colorBlue10
        preferences.drawing.foregroundColor = .white
        preferences.drawing.textAlignment = .center
        preferences.drawing.arrowPosition = .bottom
        preferences.positioning.maxWidth = SCREEN_WIDTH - 40
        preferences.positioning.bubbleInsets = UIEdgeInsets(top: 1, left: 10, bottom: 1, right: 10)
        
        let infoText = "YOUR BID\n\nYour bid is the amount you wish to place for that tag word or phrase. There are 5 places that can bid on for each particular tag word or phrase and are shown in order of how they will be seen when an ATB member looks for that specific tag word or phrase 1 being at the top and 5 being at the bottom. The top three spots hold special prominence as they are pinned to the op with remaining two, along with any other search results becoming scroll-able.\n\nBids must be higher then the current bid for that spot and must be in incresements of £0.50.\n\nYou cannot bid on more than spot, although that does not stop you from having multiple businesses set-up.\n\nOnce a bid has been placed it cannot be reversed!"
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let attributedText = NSMutableAttributedString(string: infoText)
        attributedText.addAttributes(
            [.font: UIFont(name: Font.SegoeUISemibold, size: 10)!,
             .foregroundColor: UIColor.white,
             .paragraphStyle: paragraphStyle],
            range: NSRange(location: 0, length: attributedText.length))
        attributedText.addAttributes(
            [.font: UIFont(name: Font.SegoeUIBold, size: 13)!],
            range: (infoText as NSString).range(of: "YOUR BID"))
        
        let tipView = EasyTipView(text: attributedText, preferences: preferences)
        tipView.show(forView: anchor)
        easyTipView = tipView
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8, execute: {
            tipView.dismiss()
        })
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
        tipView.addGradientLayer(.colorBlue15, endColor: .colorBlue3, angle: 0)
        tipView.show(forView: anchor)
        easyTipView = tipView
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            tipView.dismiss()
        })
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
    
    private var pointAuctions = [AuctionModel]()
    private func getPinPointAuctions(showLoading: Bool = true, message: String? = nil) {
        var tag = tagTextField.text!.trimmedString
        tag = String(tag.suffix(tag.count - 1))
        
        if showLoading {
            showIndicator()
        }
        
        APIManager.shared.getAuctions(g_myToken, type: "1", category: selectedGroup, tag: tag) { result in
            self.hideIndicator()
            
            switch result {
            case .success(let auctions):
                self.pointAuctions.removeAll()
                self.pointAuctions.append(contentsOf: auctions)
                
                self.tblAuction.reloadData()
                
                if let message = message {
                    self.showInfoVC("ATB", msg: message)
                }
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    // position in 0 ... 4
    private func confirmBid(_ position: Int, price: String?) {
//        guard let tag = textField.text,
//              tag.count > 1 else {
//            showInfoVC("ATB", msg: "Please type-in a tag word or phrase.")
//            return true
//        }
        
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
        
        if let auction = getPinPointAuction(forCategory: selectedGroup, position: position),
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
            self.placeBid(position, price: priceValue)
        })
        confirmButton.titleColor = .colorPrimary
        confirmButton.titleFont = UIFont(name: Font.SegoeUISemibold, size: 17)
        confirmButton.backgroundColor = .colorGray14
        confirmDialog.addButton(confirmButton)
        
        present(confirmDialog, animated: true, completion: nil)
    }
    
    private var bidMessage = ""
    private func placeBid(_ position: Int, price: Float) {
        var tag = tagTextField.text!.trimmedString
        tag = String(tag.suffix(tag.count - 1))
        
        showIndicator()
        APIManager.shared.placeBid(g_myToken, type: "1", category: selectedGroup, position: position, price: price.priceString, tag: tag) { (result, message, approvalLink) in
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
extension PointAuctionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: PointAuctionHeader.reuseIdentifier) as? PointAuctionHeader else { return nil }
        
        headerView.didTapCurrentBidBlock = { sender in
            guard let anchorView = sender as? UIView else { return }
            self.didTapCurrentBidInfo(anchorView)
        }
        
        headerView.didTapYourBidBlock = { sender in
            guard let anchorView = sender as? UIView else { return }
            self.didTapYourBidInfo(anchorView)
        }
        
        return headerView
    }
    
    private func getPinPointAuction(forCategory category: String, position: Int) -> AuctionModel? {
        guard pointAuctions.count > 0,
              let auction = pointAuctions.first(where: {
                $0.category == category && $0.position == position
              }) else { return nil }
        
        return auction
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AuctionBidCell.reuseIdentifer, for: indexPath) as! AuctionBidCell
        // configure the cell
        cell.configureCell(getPinPointAuction(forCategory: selectedGroup, position: indexPath.row), position: indexPath.row)
        
        cell.didTapBidNumber = {
            guard let anchorView = cell.bidNumberContainer else { return }
            self.didTapBidNumber(anchorView)
        }
        
        cell.didTapBid = {
            let priceString = cell.bidPriceField.text
            self.confirmBid(indexPath.row, price: priceString)
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
extension PointAuctionViewController: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        guard textField != tagTextField else { return true }
        
        let currentText = textField.text ?? "0.00"
        textField.text = currentText.doubleValue.priceString
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField != tagTextField else { return true }
        
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

// MARK: - TagInputFieldDelegate
extension PointAuctionViewController: TagInputFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let _ = textField as? TagInputField else { return true }
        
//        guard let tag = textField.text,
//              tag.count > 1 else {
//            showInfoVC("ATB", msg: "Please type-in a tag word or phrase.")
//            return true
//        }
        
        textField.resignFirstResponder()
        getPinPointAuctions()
        
        return true
    }
}

// MARK: - SelectGroupDelegate
extension PointAuctionViewController: SelectGroupDelegate {
    
    func didSelectGroup(_ selected: String) {
        selectedGroup = selected
        
        lblGroup.text = selected
        
        getPinPointAuctions()
    }
}

class PointAuctionHeader: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "PointAuctionHeader"
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        let bgView = UIView()
        bgView.backgroundColor = .colorPrimary
        contentView.addSubview(bgView)
        addConstraintWithFormat("H:|[v0]|", views: bgView)
        addConstraintWithFormat("V:|[v0]|", views: bgView)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        contentView.addSubview(stackView)
        addConstraintWithFormat("H:|[v0]|", views: stackView)
        addConstraintWithFormat("V:|[v0]|", views: stackView)
        
        // Current Bid
        let currentContainer = UIView()
        
        let currentView = UIView()
        
        let currentImageView = UIImageView()
        currentImageView.image = UIImage(named: "confirm.bid")?.withRenderingMode(.alwaysTemplate)
        currentImageView.tintColor = .white
        
        let currentLabel = UILabel()
        currentLabel.text = "Current Bid"
        currentLabel.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        currentLabel.textColor = .white
        
        let currentInfoImageView = UIImageView()
        if #available(iOS 13.0, *) {
            currentInfoImageView.image = UIImage(systemName: "info.circle")
        } else {
            // Fallback on earlier versions
        }
        currentInfoImageView.tintColor = .white
        
        currentView.addSubview(currentImageView)
        currentView.addSubview(currentLabel)
        currentView.addSubview(currentInfoImageView)
        
        currentView.addConstraintWithFormat("H:|[v0(24)]-10-[v1]-10-[v2(20)]|", views: currentImageView, currentLabel, currentInfoImageView)
        currentView.addConstraintWithFormat("V:|[v0]|", views: currentLabel)
        
        currentContainer.addSubview(currentView)
        currentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentImageView.heightAnchor.constraint(equalToConstant: 24),
            currentImageView.centerYAnchor.constraint(equalTo: currentLabel.centerYAnchor),
            currentLabel.centerYAnchor.constraint(equalTo: currentInfoImageView.centerYAnchor),
            currentInfoImageView.heightAnchor.constraint(equalToConstant: 20),
            currentView.centerXAnchor.constraint(equalTo: currentContainer.centerXAnchor),
            currentView.centerYAnchor.constraint(equalTo: currentContainer.centerYAnchor),
        ])
        
        let currentButton = UIButton()
        currentButton.addTarget(self, action: #selector(didTapCurrentBid(_:)), for: .touchUpInside)
        currentContainer.addSubview(currentButton)
        currentButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentButton.leftAnchor.constraint(equalTo: currentView.leftAnchor),
            currentButton.rightAnchor.constraint(equalTo: currentView.rightAnchor),
            currentButton.topAnchor.constraint(equalTo: currentView.topAnchor),
            currentButton.bottomAnchor.constraint(equalTo: currentView.bottomAnchor)
        ])
        
        // Your Bid
        let yourContainer = UIView()
        
        let yourView = UIStackView()
        
        let yourImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        if #available(iOS 13.0, *) {
            yourImageView.image = UIImage(systemName: "person.crop.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        yourImageView.tintColor = .white
        
        let yourLabel = UILabel()
        yourLabel.text = "Your Bid"
        yourLabel.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        yourLabel.textColor = .white
        
        let yourInfoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        if #available(iOS 13.0, *) {
            yourInfoImageView.image = UIImage(systemName: "info.circle")
        } else {
            // Fallback on earlier versions
        }
        yourInfoImageView.tintColor = .white
        
        yourView.addSubview(yourImageView)
        yourView.addSubview(yourLabel)
        yourView.addSubview(yourInfoImageView)
        
        yourView.addConstraintWithFormat("H:|[v0(24)]-10-[v1]-10-[v2(20)]|", views: yourImageView, yourLabel, yourInfoImageView)
        yourView.addConstraintWithFormat("V:|[v0]|", views: yourLabel)
        
        yourContainer.addSubview(yourView)
        yourView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            yourImageView.heightAnchor.constraint(equalToConstant: 24),
            yourImageView.centerYAnchor.constraint(equalTo: yourLabel.centerYAnchor),
            yourLabel.centerYAnchor.constraint(equalTo: yourInfoImageView.centerYAnchor),
            yourInfoImageView.heightAnchor.constraint(equalToConstant: 20),
            yourView.centerXAnchor.constraint(equalTo: yourContainer.centerXAnchor),
            yourView.centerYAnchor.constraint(equalTo: yourContainer.centerYAnchor),
        ])
        
        let yourButton = UIButton()
        yourButton.addTarget(self, action: #selector(didTapYourBid(_:)), for: .touchUpInside)
        yourContainer.addSubview(yourButton)
        yourButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            yourButton.leftAnchor.constraint(equalTo: yourView.leftAnchor),
            yourButton.rightAnchor.constraint(equalTo: yourView.rightAnchor),
            yourButton.topAnchor.constraint(equalTo: yourView.topAnchor),
            yourButton.bottomAnchor.constraint(equalTo: yourView.bottomAnchor)
        ])
        
        stackView.addArrangedSubview(currentContainer)
        stackView.addArrangedSubview(yourContainer)
    }
    
    var didTapCurrentBidBlock: ((Any) -> Void)? = nil
    @objc private func didTapCurrentBid(_ sender: Any) {
        didTapCurrentBidBlock?(sender)
    }
    
    var didTapYourBidBlock: ((Any) -> Void)? = nil
    @objc private func didTapYourBid(_ sender: Any) {
        didTapYourBidBlock?(sender)
    }
}

// MARK: - PaymentAuthorizationDelegate
extension PointAuctionViewController: PaymentAuthorizationDelegate {
    
    func didAuthorizePayment() {
        getPinPointAuctions(showLoading: true, message: bidMessage)
    }
    
    func didCancelAuthorization() {
        showInfoVC("ATB", msg: "Payment authorization has been cancelled!")
    }
}
