//
//  BusinessStoreItemViewController.swift
//  ATB
//
//  Created by YueXi on 1/9/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import ImageSlideshow
import AVKit
import CoreLocation
import NBBottomSheet
import PopupDialog
import TTGTagCollectionView
import Branch
import Braintree
import BraintreeDropIn

class BusinessStoreItemViewController: InputBarViewController {
    
    private var isOwnItem = false
    var selectedItem: PostModel!
    
    var viewingUser: UserModel?
    
    // This represents whether the user is currently following this post or not
    var isFollowing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .colorGray7
        
        isOwnItem = (viewingUser == nil)
        
        setupNavigation()
        
        getVariations()
        
        setupCollectionView()
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(didSelectVariant(_:)), name: .DidSelectVariant, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didUpdatePost(_:)), name: .DidUpdatePost, object: nil)
    }
    
    override var canBecomeFirstResponder: Bool { return false }
    
    override var inputAccessoryView: UIView? { return nil }
    
    private var variations = [VariationModel]()
    private func getVariations() {
        guard selectedItem.isSale,
              selectedItem.productVariants.count > 0 else { return }
        
        let variantAttributes = selectedItem.productVariants[0].attributes
        for variantAttribute in variantAttributes {
            let variation = VariationModel()
            let name = variantAttribute.name
            variation.name = name
            
            var values = [String]()
            
            for productVariant in selectedItem.productVariants {
                for attribute in productVariant.attributes {
                    if attribute.name == name,
                       values.firstIndex(of: attribute.value) == nil {
                        values.append(attribute.value)
                    }
                }
            }
            
            variation.values = values
            
            variations.append(variation)
        }
    }
    
    private func setupNavigation() {
        let navigationView = NavigationView.instantiate()
        view.addSubview(navigationView)
        navigationView.delegate = self
        navigationView.backgroundColor = .white
        
        let navigationHeight = 82 + UIApplication.safeAreaTop()
        // constraint
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraintWithFormat("H:|[v0]|", views: navigationView)
        view.addConstraintWithFormat("V:|[v0(\(navigationHeight))]", views: navigationView)
        
        // only buisness
        let business = viewingUser != nil ? viewingUser!.business_profile : g_myInfo.business_profile
        navigationView.imvPoster.loadImageFromUrl(business.businessPicUrl, placeholder: "profile.placeholder")
        navigationView.lblName.text = business.businessProfileName
        navigationView.lblUsername.text = "@" + business.businessName

        navigationView.layer.shadowOffset = CGSize(width: 0, height: -2)
        navigationView.layer.shadowRadius = 4.0
        navigationView.layer.shadowColor = UIColor.gray.cgColor
        navigationView.layer.shadowOpacity = 0.4
    }
    
    private func setupCollectionView() {
        commentCollectionView.backgroundColor = .clear
        commentCollectionView.showsVerticalScrollIndicator = false
        
        maintainPositionOnKeyboardFrameChanged = true   // default false
        
        commentCollectionView.dataSource = self
        commentCollectionView.delegate = self
        
        // register collectionview cells
        commentCollectionView.register(UINib(nibName: "MediaInPostViewCell", bundle: nil), forCellWithReuseIdentifier: MediaInPostViewCell.reuseIdentifier)
        commentCollectionView.register(UINib(nibName: "LikesInfoViewCell", bundle: nil), forCellWithReuseIdentifier: LikesInfoViewCell.reuseIdentifier)
        commentCollectionView.register(UINib(nibName: "SaleInfoViewCell", bundle: nil), forCellWithReuseIdentifier: SaleInfoViewCell.reuseIdentifier)
        commentCollectionView.register(UINib(nibName: "ServiceInfoViewCell", bundle: nil), forCellWithReuseIdentifier: ServiceInfoViewCell.reuseIdentifier)
        commentCollectionView.register(UINib(nibName: "VariationTagsCell", bundle: nil), forCellWithReuseIdentifier: VariationTagsCell.reuseIdentifier)
        commentCollectionView.register(UINib(nibName: "PostActionCell", bundle: nil), forCellWithReuseIdentifier: PostActionCell.reuseIdentifier)
    }
    
    @objc private func didUpdatePost(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let _ = object["updated"] as? PostModel else { return }
                
        DispatchQueue.main.async {
            self.commentCollectionView.reloadSections([0, 1])
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension BusinessStoreItemViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // section - 0: media info
    // the 1st section will be varied
    // section - 1: service & sale info (only vailable for service & sale post)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) ->  Int {
        if section == 0 {
            return 1
            
        } else {
            if selectedItem.isSale {
                // sales info
                // variations
                // buy (if the selected post is own post, get rid of the 'Buy' button)
                return isOwnItem ? variations.count+1 : variations.count+2
                
            } else {
                // service
                return isOwnItem ? 1 : 2
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            // advice with media, sale, and service
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaInPostViewCell.reuseIdentifier, for: indexPath) as! MediaInPostViewCell
            // configure the cell
            let business = viewingUser == nil ? g_myInfo.business_profile : viewingUser!.business_profile
            cell.configureCell(selectedItem, isApproved: business.isApproved)
            
            // tap on video
            cell.tapOnVideo = {
                guard self.selectedItem.Post_Media_Urls.count > 0,
                      let videoURL = URL(string: self.selectedItem.Post_Media_Urls[0]) else {
                        self.showErrorVC(msg: "The video URL is invalid.")
                        return
                }

                let avPlayer = AVPlayer(url: videoURL)

                let playerViewController = AVPlayerViewController()
                playerViewController.player = avPlayer

                self.present(playerViewController, animated: true) {
                    playerViewController.player?.play()
                }
            }
            
            // tap on image
            cell.tapOnImage = { gesture in
                guard let imageSlide = gesture.view as? ImageSlideshow else { return }

                let fullScreenController = imageSlide.presentFullScreenController(from: self)
                // set the activity indicator for full screen controller (skipping the line will show no activity indicator)
                if #available(iOS 13.0, *) {
                    fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .medium, color: .white)
                } else {
                    // Fallback on earlier versions
                    fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
                }
            }
            
            return cell
            
        } else {
            // poll will not get here
            // service, sales, and advice with media
            if selectedItem.isSale {
                // sale
                if indexPath.row == 0 {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SaleInfoViewCell.reuseIdentifier, for: indexPath) as! SaleInfoViewCell
                    // configure the cell
                    cell.configureCell(selectedItem)
                    cell.delegate = self

                    return cell
                    
                } else if indexPath.row <= variations.count {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VariationTagsCell.reuseIdentifier, for: indexPath) as! VariationTagsCell
                    // configure the cell
                    cell.configureCell(withVariation: variations[indexPath.row - 1])
                    cell.setDelegate(self, forRow: indexPath.row-1)
                    
                    return cell
                    
                } else {
                    // action (buy & add)
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostActionCell.reuseIdentifier, for: indexPath) as! PostActionCell
                    // configure the cell
                    cell.configureCell(selectedItem)
                    cell.delegate = self
                    
                    return cell
                }
                
            } else {
                if indexPath.row == 0 {
                    // service info
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ServiceInfoViewCell.reuseIdentifier, for: indexPath) as! ServiceInfoViewCell
                    // configure the cell
                    cell.configureCell(selectedItem)
                    cell.delegate = self

                    return cell
                    
                } else {
                    // post action (book service & chat with provider)
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostActionCell.reuseIdentifier, for: indexPath) as! PostActionCell
                    // configure the cell
                    cell.configureCell(selectedItem)
                    cell.delegate = self
                    
                    return cell
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return MediaInPostViewCell.sizeForItem()
            
        } else {
            if selectedItem.isSale {
                // sale
                if indexPath.row == 0 {
                    return SaleInfoViewCell.sizeForItem(selectedItem)
                    
                } else if indexPath.row < 3 {
                    return VariationTagsCell.sizeForItem()
                    
                } else {
                    // buy & add
                    return CGSize(width: SCREEN_WIDTH, height: 88)
                }
                
            } else {
                // service
                if indexPath.row == 0 {
                    return ServiceInfoViewCell.sizeForItem(selectedItem)
                    
                } else {
                    // book & chat
                    return CGSize(width: SCREEN_WIDTH, height: 88)
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            // safeArea - 20 - Navigation(52) - 10
            return UIEdgeInsets(top: 82 + UIApplication.safeAreaTop(), left: 0, bottom: 0, right: 0)
            
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }
    }
}

// MARK: - TTGTextTagCollectionViewDelegate
extension BusinessStoreItemViewController: TTGTextTagCollectionViewDelegate {
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, didTapTag tagText: String!, at index: UInt, selected: Bool, tagConfig config: TTGTextTagConfig!) {
        let indexForTagsView = textTagCollectionView.tag
        guard indexForTagsView >= 0,
              variations.count > indexForTagsView else { return }
        
        if let lastSelected = variations[indexForTagsView].selected,
           lastSelected != index {
            textTagCollectionView.setTagAt(UInt(lastSelected), selected: false)
        }
        
        variations[indexForTagsView].selected = selected ? Int(index) : nil
    }
    
    func textTagCollectionView(_ textTagCollectionView: TTGTextTagCollectionView!, canTapTag tagText: String!, at index: UInt, currentSelected: Bool) -> Bool {
        return !isOwnItem
    }
}

// MARK: - NavigationViewDelegate
extension BusinessStoreItemViewController: NavigationViewDelegate {
    
    func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func didTapProfile() {
        navigationController?.popViewController(animated: true)
    }
    
    func didTapInfo() {
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35
        
        var heightForOptionSheet: CGFloat = 0
        if isOwnItem {
            if selectedItem.isSale {
                heightForOptionSheet = 60*5 + 32
                
            } else {
                // sold-out or re-list disabled for others
                heightForOptionSheet = 60*4 + 32
            }
            
        } else {
            heightForOptionSheet = 60*5 + 32
        }
        
        configuruation.sheetSize = .fixed(heightForOptionSheet)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        let bottomSheetController = NBBottomSheetController(configuration: configuruation)
        
        /// show action sheet with options (Edit or Delete)
        let optionSheet = OptionSheetViewController.instance()
        optionSheet.isOwnPost = isOwnItem
        
        optionSheet.isSale = selectedItem.isSale
        optionSheet.isSoldOut = selectedItem.isSoldOut

        optionSheet.isFollowing = isFollowing
        
        optionSheet.delegate = self
        
        bottomSheetController.present(optionSheet, on: self)
    }
}

// MARK: - ServiceInfoViewDelegate
extension BusinessStoreItemViewController: ServiceInfoViewDelegate {
    
    func didTapDeposit() {
        let dialogVC = ServiceInfoPopupViewController(nibName: "ServiceInfoPopupViewController", bundle: nil)
        dialogVC.isDeposit = true
        dialogVC.depositAmount = selectedItem.Post_Deposit.floatValue
        
        let popupDialog = PopupDialog(viewController: dialogVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: true, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(popupDialog, animated: true, completion: nil)
    }
    
    func didTapCancellations() {
        let dialogVC = ServiceInfoPopupViewController(nibName: "ServiceInfoPopupViewController", bundle: nil)
        dialogVC.isDeposit = false
        
        let popupDialog = PopupDialog(viewController: dialogVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: true, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(popupDialog, animated: true, completion: nil)
    }
    
    func didTapArea() {
        showLocationInMap()
    }
    
    func didTapInsurance() {
        guard !selectedItem.insuranceID.isEmpty,
              let insurance = selectedItem.insurance else { return }
        
        let dialogVC = InsurancePopupViewController(nibName: "InsurancePopupViewController", bundle: nil)
        dialogVC.isInsurance = true
        dialogVC.urlString = insurance.file
        
        let popupDialog = PopupDialog(viewController: dialogVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: true, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(popupDialog, animated: true, completion: nil)
    }
    
    func didTapQualification() {
        guard !selectedItem.qualificationID.isEmpty,
              let qualification = selectedItem.qualification else { return }
        
        let dialogVC = InsurancePopupViewController(nibName: "InsurancePopupViewController", bundle: nil)
        dialogVC.isInsurance = false
        dialogVC.urlString = qualification.file
        
        let popupDialog = PopupDialog(viewController: dialogVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: true, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(popupDialog, animated: true, completion: nil)
    }
}

// MARK: - SaleInfoViewDelegate
extension BusinessStoreItemViewController: SaleInfoViewDelegate {
    
    func didTapLocation() {
        showLocationInMap()
    }
    
    private func showLocationInMap() {
        guard let locationVC = PostLocationViewController.instance() else { return }
                
        locationVC.postLocation = CLLocation(latitude: selectedItem.Post_Position.latitude, longitude: selectedItem.Post_Position.longitude)
        locationVC.postAddress = selectedItem.Post_Location
        
        if selectedItem.Post_Type == "Service" {
            locationVC.strTitle = "Area Covered"
            
        } else {
            locationVC.strTitle = "Location"
        }
        
        self.navigationController?.pushViewController(locationVC, animated: true)
    }
}

// MARK: - ActionInPostDelegate
extension BusinessStoreItemViewController: ActionInPostDelegate {
    
    // buy a product or book a service
    func didTapLeft() {
        guard isBusinessApproved() else { return }
        
        if selectedItem.isSale {
            guard !selectedItem.isSoldOut else {
                showInfoVC("ATB", msg: "The product is out of stock")
                return
            }
            
            if variations.count > 0 {
                // check only when a variant is selected
                if isVariantSelected() {
                    let vid = getSelectedVariant()
                    guard !vid.isEmpty else {
                        showErrorVC(msg: "The variant is invalid!")
                        return
                    }
                    
                    guard isStockValid(forVariant: vid) else { return }
                    
                    selectDeliveryOption(forProduct: selectedItem, vid: vid, quantity: 1)
                    return
                }
                
                // select variation
                selectVariation(forProduct: selectedItem)
                
            } else {
                // select delivery option
                // with no variant, quantity 1
                selectDeliveryOption(forProduct: selectedItem, vid: "", quantity: 1)
            }
            
        } else {
            // just to make sure that
            // The service is not posted by the user own
            // They have business profile
            guard let viewingUser = viewingUser,
                  viewingUser.isBusiness else { return }

            let appointmentVC = AppointmentViewController.instance()
            appointmentVC.selectedService = selectedItem
            appointmentVC.business = viewingUser.business_profile
            appointmentVC.isFromBusinessStore = true

            navigationController?.pushViewController(appointmentVC, animated: true)
        }
    }
    
    // add product to cart or chat with provider
    func didTapRight() {
        if selectedItem.isSale {
            guard isBusinessApproved() else { return }
            
            guard !selectedItem.isSoldOut else {
                showInfoVC("ATB", msg: "The product is out of stock")
                return
            }
            
            if variations.count > 0 {
                // check only when a variant is selected
                if isVariantSelected() {
                    let vid = getSelectedVariant()
                    guard !vid.isEmpty else {
                        showErrorVC(msg: "The variant is invalid!")
                        return
                    }
                    
                    guard isStockValid(forVariant: vid) else { return }
                    
                    addItemToCart(selectedItem, vid: vid)
                    return
                }
                
                selectVariation(forProduct: selectedItem)
                
            } else {
                // add the product to cart
                // no variant
                addItemToCart(selectedItem, vid: "")
            }
            
        } else {
            chatWithSeller()
        }
    }
    
    private func chatWithSeller() {
        guard let viewingUser = viewingUser,
              viewingUser.isBusiness else { return }
        
        let conversationVC = ConversationViewController()
        conversationVC.userId = viewingUser.business_profile.ID + "_" + viewingUser.ID
        
        self.navigationController?.pushViewController(conversationVC, animated: true)
    }
    
    private func isBusinessApproved() -> Bool {
        guard let viewingUser = viewingUser,
              viewingUser.isBusinessApproved else {
            showAlert("ATB", message: "Admin is currently reviewing the business!\nPlease wait until they get approved, we always value your experience on ATB.", positive: "Ok", positiveAction: nil, preferredStyle: .actionSheet)
            return false
        }
        
        return true
    }
    
    // when all variations is selected, returns true
    // otherwise, returns false
    private func isVariantSelected() -> Bool {
        for variation in variations {
            if let _ = variation.selected {
                continue
                
            } else {
                return false
            }
        }
        return true
    }
    
    // get the selected variant and return it's id
    private func getSelectedVariant() -> String {
        // get selected variation
        var attributes = [VariantAttribute]()
        for variation in variations {
            if let selected = variation.selected,
               variation.values.count > selected {
                let attribute = VariantAttribute()
                attribute.name = variation.name
                attribute.value = variation.values[selected]
                
                attributes.append(attribute)
            }
        }
        
        let sortedAttributes = attributes.sorted { $0.value.localizedCaseInsensitiveCompare($1.value) == .orderedAscending }
        
        var selectedAttributes = ""
        for attribute in sortedAttributes {
            selectedAttributes += attribute.value
        }
        
        for productVariant in selectedItem.productVariants {
            guard !productVariant.id.isEmpty else { continue }
            
            let sortedProductAttributes = productVariant.attributes.sorted {
                $0.value.localizedCaseInsensitiveCompare($1.value) == .orderedAscending
            }
            
            var allProductAttributes = ""
            for productAttribute in sortedProductAttributes {
                allProductAttributes += productAttribute.value
            }
            
            if allProductAttributes == selectedAttributes {
                return productVariant.id
            }
        }
        
        return ""
    }
    
    private func isStockValid(forVariant vid: String) -> Bool {
        let productVariants = selectedItem.productVariants
        guard let selectedVariant = productVariants.first(where: { $0.id == vid }),
              selectedVariant.stock_level.intValue > 0 else {
            showAlert("ATB", message: "The product is out of stock!", positive: "Ok", positiveAction: nil, preferredStyle: .actionSheet)
            return false
        }
        
        return true
    }
    
    private func selectVariation(forProduct product: PostModel) {
        // get product id - the item id will be the product id
        let pid = product.Post_ID
        
        // check product id is valid
        guard !pid.isEmpty else {
            showErrorVC(msg: "The product is invalid!")
            return
        }
        
        // calculate the height
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35
        
        // 24 + 100 + 20 + 1 + 20 + 16*2 + 60 + 34
        var height: CGFloat = 291
        height += "Before you continue....".heightForString(SCREEN_WIDTH-40, font: UIFont(name: Font.SegoeUISemibold, size: 22)).height
        height += "Please select the following variations to complete your order".heightForString(SCREEN_WIDTH-40, font: UIFont(name: Font.SegoeUILight, size: 15)).height
        height += 4 // add an experienced value
        height -= UIApplication.safeAreaBottom()
        
        height += 91*CGFloat(variations.count)
        height += 10*CGFloat(variations.count-1)
        
        if height > (SCREEN_HEIGHT - 44) {
            height = SCREEN_HEIGHT - 44
        }
        
        configuruation.sheetSize = .fixed(height)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        let sheetController = NBBottomSheetController(configuration: configuruation)
        
        let variationVC = SelectVariationViewController.instance()
        
        variationVC.isFromBusinessStore = true
        
        variationVC.selectedProduct = product
        variationVC.variations = variations
        variationVC.delegate = self
        
        sheetController.present(variationVC, on: self)
    }
    
    // add item to cart
    private func addItemToCart(_ item: PostModel, vid: String) {
        // get product id - the item id will be the product id
        let pid = item.Post_ID
        
        // check product id is valid
        guard !pid.isEmpty else {
            showErrorVC(msg: "The product is invalid!")
            return
        }
        
        showIndicator()
        APIManager.shared.addItemInCart(g_myToken, pid: pid, vid: vid.isEmpty ? "0" : vid) { (result, message, cartInfo) in
            self.hideIndicator()

            guard result,
                  let cartInfo = cartInfo else {
                self.showErrorVC(msg: "It's been failed to add the product to your cart!")
                return
            }
            
            let quantity = cartInfo.1
            self.showInstantCart(withProduct: item, vid: vid, quantity: quantity)
        }
    }
    
    // shows instant cart
    private func showInstantCart(withProduct product: PostModel, vid: String, quantity: Int) {
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35
        
        configuruation.sheetSize = .fixed(200)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        let sheetController = NBBottomSheetController(configuration: configuruation)
        
        let instantCart = InstantCartViewController.instance()
        
        instantCart.isFromBusinessStore = true
        
        instantCart.cartItem = product
        instantCart.vid = vid
        instantCart.quantity = quantity
        instantCart.delegate = self
        
        sheetController.present(instantCart, on: self)
    }
}

// MARK: - InstantCartDelegate
extension BusinessStoreItemViewController: InstantCartDelegate {
    
    func buyProduct(_ product: PostModel, vid: String, quantity: Int) {
        // select delivery option
        selectDeliveryOption(forProduct: product, vid: vid, quantity: quantity)
    }
    
    // select delivery option
    private func selectDeliveryOption(forProduct product: PostModel, vid: String, quantity: Int) {
        // get product id - the item id will be the product id
        let pid = product.Post_ID
        
        // check product id is valid
        guard !pid.isEmpty else {
            showErrorVC(msg: "The product is invalid!")
            return
        }
        
        // calculate the height
        let configuruation = NBBottomSheetConfiguration()
        configuruation.animationDuration = 0.35
       
        let height: CGFloat = 380 - UIApplication.safeAreaBottom()
        
        configuruation.sheetSize = .fixed(height)
        configuruation.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        let sheetController = NBBottomSheetController(configuration: configuruation)
        
        let deliveryVC = SelectDeliveryViewController.instance()
        // sheet configuration for UI
        deliveryVC.configuration = configuruation
        
        deliveryVC.selectedProduct = product
        deliveryVC.vid = vid
        deliveryVC.quantity = quantity
        
        // set the delegate
        deliveryVC.delegate = self
        
        sheetController.present(deliveryVC, on: self)
    }
}

// MARK: SelectVariationDelegate
extension BusinessStoreItemViewController: SelectVariationDelegate {
    
    func didAddItemToCart(_ product: PostModel, vid: String, quantity: Int) {
        showInstantCart(withProduct: product, vid: vid, quantity: quantity)
    }
    
    func willBuyProduct(_ product: PostModel, vid: String, quantity: Int) {
        selectDeliveryOption(forProduct: product, vid: vid, quantity: quantity)
    }
    
    @objc private func didSelectVariant(_ notification: Notification) {
        DispatchQueue.main.async {
            // reload variation with new selected
            self.commentCollectionView.reloadSections([1])
        }
    }
}

// MARK: - SelectDeliveryDelegate
extension BusinessStoreItemViewController: SelectDeliveryDelegate {
    
    func purchaseProduct(_ product: PostModel, vid: String, quantity: Int, deliveryOption: Int) {
        let paymentVC = SelectPaymentViewController(nibName: "SelectPaymentViewController", bundle: nil)
        // send over payment parameters
        paymentVC.selectedProduct = product
        paymentVC.vid = vid
        paymentVC.quantity = quantity
        paymentVC.deliveryOption = deliveryOption
        
        paymentVC.delegate = self
        
        let popupDialog = PopupDialog(viewController: paymentVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(popupDialog, animated: true, completion: nil)
    }
}

// MARK: - SelectPaymentDelegate
extension BusinessStoreItemViewController: SelectPaymentDelegate {
    
    // paymentOption: 1 - PayPal, 2 - Cash
    func proceedPayment(forProduct product: PostModel, paymentOption: Int, vid: String, quantity: Int, deliveryOption: Int) {
        if paymentOption == 1 {
            payByPayPal(forProduct: product, vid: vid, quantity: quantity, deliveryOption: deliveryOption)
            
        } else {
            payWithCash(forProduct: product, vid: vid, quantity: quantity, deliveryOption: deliveryOption)
        }
    }
    
    private func payByPayPal(forProduct product: PostModel, vid: String, quantity: Int, deliveryOption: Int) {
        showIndicator()
        ATBBraintreeManager.shared.getBraintreeClientToken(g_myToken) { (result, message) in
            self.hideIndicator()
            
            guard result else {
                self.showErrorVC(msg: "Server returned the error message: " + message)
                return
            }
            
            let clientToken = message
            self.showDropIn(clientTokenOrTokenizationKey: clientToken, product: product, vid: vid, quantity: quantity, deliveryOption: deliveryOption)
        }
    }
    
    private func payWithCash(forProduct product: PostModel, vid: String, quantity: Int, deliveryOption: Int) {
        guard let viewingUser = viewingUser,
              viewingUser.isBusiness else { return }
        
        let productId = product.Post_ID
        let toUserId = viewingUser.ID       // seller's user id
        
        showIndicator()
        APIManager.shared.makeCashPayment(g_myToken, productId: productId, variantId: vid, deliveryOption: deliveryOption, quantity: quantity, toUserId: toUserId, isBusiness: "1") { result in
            self.hideIndicator()
            
            switch result {
            case .success(let message):
                self.updateStock(vid: vid, quantity: quantity, paymentMethod: 1, showMessage: message)
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    func contactSeller() {
        chatWithSeller()
    }
    
    private func showDropIn(clientTokenOrTokenizationKey: String, product: PostModel, vid: String, quantity: Int, deliveryOption: Int) {
        let request = BTDropInRequest()
        request.vaultManager = true
        request.cardDisabled = true
        
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request) { (controller, result, error) in
            controller.dismiss(animated: true, completion: nil)
            guard error == nil,
                  let result = result else {
                // show error
                self.showErrorVC(msg: "Failed to proceed your payment.\nPlease try again later!")
                
                return
            }
            
            guard !result.isCancelled,
                  let paymentMethod = result.paymentMethod else {
                // Payment has been cancelled by the user
                return
            }
            
            let nonce = paymentMethod.nonce
            self.showAlert("Payment Confirmation", message: "Would you like to proceed the payment?", positive: "Yes", positiveAction: { _ in
                switch result.paymentOptionType {
                case .payPal:
                    self.makePayment(forProduct: product, vid: vid, quantity: quantity, deliveryOption: deliveryOption, method: "Paypal", nonce: nonce)
                    
                case .masterCard,
                     .AMEX,
                     .dinersClub,
                     .JCB,
                     .maestro,
                     .visa:
//                    self.showErrorVC(msg: "You cannot use your card to pay for goods.")
                    self.makePayment(forProduct: product, vid: vid
                                     , quantity: quantity, deliveryOption: deliveryOption, method: "Card", nonce: nonce)
                    
                default: break
                }
                
            }, negative: "No", negativeAction: nil, preferredStyle: .actionSheet)
        }
        
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    private func makePayment(forProduct product: PostModel, vid: String, quantity: Int, deliveryOption: Int, method: String, nonce: String) {
        guard let viewingUser = viewingUser,
              viewingUser.isBusiness else { return }
        
        let pid = product.Post_ID
        let seller = viewingUser.ID // seller's user id
        
        var params = [
            "token" : g_myToken,
            "customerId" : g_myInfo.bt_customer_id,
            "paymentMethod" : method,
            "paymentNonce" : nonce,
            "toUserId" : seller,
            "amount" : product.Post_Price,
            "quantity": "\(quantity)",
            "is_business": "1",
            "delivery_option": "\(deliveryOption)"
        ]
        
        if !vid.isEmpty {
            params["variation_id"] = vid
            
        } else {
            params["product_id"] = pid
        }
        
        showIndicator()
        _ = ATB_Alamofire.POST(MAKE_PP_PAYMENT, parameters: params as [String: AnyObject], completionHandler: { (result, response) in
            self.hideIndicator()
            
            if result {
//                self.deletePurchasedItems(product, vid: vid)
                self.updateStock(vid: vid, quantity: quantity)
                
            } else {
                let msg = response.object(forKey: "msg") as? String ?? "Failed to proceed your payment, please try again!"
                self.showErrorVC(msg: msg)
            }
        })
    }
    
    // paymentMethod: 1 - pay with cash, 2 - pay by PayPal
    private func updateStock(vid: String, quantity: Int, paymentMethod: Int = 2, showMessage: String = "") {
        if vid.isEmpty {
            var stockLevel = selectedItem.stock_level.intValue
            stockLevel = stockLevel - quantity >= 0 ? stockLevel - quantity : 0
            
            selectedItem.stock_level = "\(stockLevel)"
            
            if stockLevel <= 0 {
                selectedItem.Post_Is_Sold = "1"
            }
            
        } else {
            guard let index = selectedItem.productVariants.firstIndex(where: { $0.id == vid }) else {
                return
            }
            
            var stockLevel = selectedItem.productVariants[index].stock_level.intValue
            stockLevel = stockLevel - quantity >= 0 ? stockLevel - quantity : 0
            
            selectedItem.productVariants[index].stock_level = "\(stockLevel)"
            
            var totalStocks = 0
            for variant in selectedItem.productVariants {
                totalStocks += variant.stock_level.intValue
            }
            
            if totalStocks <= 0 {
                selectedItem.Post_Is_Sold = "1"
            }
        }
        
        DispatchQueue.main.async {
            self.commentCollectionView.reloadSections([1])
        }
                
        let objectToPost: [String: Any] = [
            "product_id": selectedItem.Post_ID,                // send product id seperately
            "updated": selectedItem!  // use only post details to update product or post
        ]
        
        NotificationCenter.default.post(name: .ProductStockChanged, object: objectToPost)
        
        if paymentMethod == 2 {
            self.didCompletePurchase(forProduct: selectedItem)
            
        } else {
            // Pay with 'Cash'
            self.showAlert("ATB", message: showMessage, positive: "Contact Now", positiveAction: { _ in
                self.chatWithSeller()
                
            }, negative: "No, later", negativeAction: nil, preferredStyle: .actionSheet)
        }
    }
    
    private func deletePurchasedItems(_ item: PostModel, vid: String) {
        let pid = item.Post_ID
        
        APIManager.shared.deleteItemInCart(g_myToken, pid: pid, vid: vid.isEmpty ? "0" : vid, isAll: true) { (result, message) in
            self.hideIndicator()
            
            self.didCompletePurchase(forProduct: item)
        }
    }
    
    private func didCompletePurchase(forProduct product: PostModel) {
        let completedVC = PurchaseCompletedViewController(nibName: "PurchaseCompletedViewController", bundle: nil)
        completedVC.purchasedItem = selectedItem
        completedVC.delegate = self
        
        let popupDialog = PopupDialog(viewController: completedVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(popupDialog, animated: true, completion: nil)
    }
}

// MARK: - PurchaseCompleteDelegate
extension BusinessStoreItemViewController: PurchaseCompleteDelegate {
    
    func viewPurchases() {
        // redirect to PurchasesViewController
        let purchasesVC = PurchasesViewController.instance()
        purchasesVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(purchasesVC, animated: true)
    }
    
    func keepBuying() {
        // Do any additional things if redirection is required
    }
}

// MARK: - OptionSheetDelegate
extension BusinessStoreItemViewController: OptionSheetDelegate {
    
    func didTapReport() {
        let reportVC = ReportViewController.instance()
        reportVC.reportType = selectedItem.isService ? .SERVICE : .PRODUCT
        reportVC.reportId = selectedItem.Post_ID

        self.present(reportVC, animated: true, completion: nil)
    }
    
    func didTapBlock() {
        
    }
    
    func didTapFollow() {
        guard let viewingUser = viewingUser else { return }
        
        let url = isFollowing ? DELETE_FOLLOWER : ADD_FOLLOW
        
        // follow - always me, follower - always others
        let followUserID = g_myInfo.ID
//        let followBusinessID = g_myInfo.isBusiness ? g_myInfo.business_profile.ID : "0"
        // follow others with only my user account - this will always be '0'
        // no mean, no effect to filter
//        let followBusinessID = "0"
        
        let followerUserID = viewingUser.ID
        let isBusiness = viewingUser.isBusiness
//        let followerBusinessID = isBusiness ? selectedPost.Poster_Info.business_profile.ID : "0"
        
        var params = [
            "token": g_myToken,
            "follow_user_id": followUserID,
            "follower_user_id": followerUserID
        ]
        
        if !isFollowing {
//            params["follow_business_id"] = followBusinessID
            params["follow_business_id"] = "0"
//            params["follower_business_id"] = followerBusinessID
            params["follower_business_id"] = "0"
        }
        
        showIndicator()
        _ = ATB_Alamofire.POST(url, parameters: params as [String: AnyObject], showLoading: false, showSuccess: false, showError: false, completionHandler: { (result, responseObject) in
            self.hideIndicator()
            
            if self.isFollowing {
                if result {
                    self.showSuccessVC(msg: "You removed this follow!")
                    self.isFollowing = false
                    g_myInfo.followCount = ((g_myInfo.followCount - 1) > 0 ? (g_myInfo.followCount - 1) : 0)
                    
                } else {
                    self.showErrorVC(msg: "Failed to remove follow, please try again later.")
                }
                
            } else {
                if result {
                    self.showSuccessVC(msg: "You are following this user!")
                    self.isFollowing = true
                    
                    g_myInfo.followCount += 1
                    
                } else {
                    self.showErrorVC(msg: "Failed to add follow, please try again later.")
                }
            }
        })
    }
    
    func didTapSold() {
        let params = [
            "token" : g_myToken,
            "product_id" : selectedItem.Post_ID
        ]

        let isSoldOut = selectedItem.isSoldOut
        let url = isSoldOut ? RELIST : SET_SOLD

        _ = ATB_Alamofire.POST(url, parameters: params as [String : AnyObject],showLoading: true, showSuccess: false, showError: false) { (result, response) in
            if result {
                self.showSuccessVC(msg: isSoldOut ? "Item re-listed." : "Item sold.")
                self.didSetItemSold(!isSoldOut)

            } else {
                let message = response.object(forKey: "msg") as? String ?? (isSoldOut ? "It's been failed to re-list the item.": "It's been failed to set item as sold, please try again.")
                self.showErrorVC(msg: message)
            }
        }
    }
    
    private func didSetItemSold(_ isSoldOut: Bool) {
        selectedItem.Post_Is_Sold = isSoldOut ? "1" : "0"
        if isSoldOut {
            if selectedItem.productVariants.count > 0 {
                for i in 0 ..< selectedItem.productVariants.count {
                    selectedItem.productVariants[i].stock_level = "0"
                }
                
            } else {
                selectedItem.stock_level = "0"
            }
            
        } else {
            if selectedItem.productVariants.count > 0 {
                for i in 0 ..< selectedItem.productVariants.count {
                    selectedItem.productVariants[i].stock_level = "1"
                }
                
            } else {
                selectedItem.stock_level = "1"
            }
        }

        DispatchQueue.main.async {
            self.commentCollectionView.reloadItems(at: [IndexPath(row: 0, section: 2)])
        }

        let objectToPost: [String: Any] = [
            "product_id": selectedItem.Post_ID,
            "product": selectedItem!
        ]

        NotificationCenter.default.post(name: .ProductStockChanged, object: objectToPost)
    }
    
    func didTapDelete() {
        let alertController = UIAlertController(title: "Delete \(selectedItem.isService ? "Service" : "Product")", message: "Would you like to remove this \(selectedItem.isService ? "service" : "product")?", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .default, handler: { _ in
            self.deleteStoreItem()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alertController, animated: true, completion: nil)
    }
    
    func didTapEdit() {
        if selectedItem.isService {
            let editService = EditServiceViewController.instance()
            editService.editingService = selectedItem
            
            self.navigationController?.pushViewController(editService, animated: true)
            
        } else {
            let editProduct = EditProductViewController.instance()
            editProduct.editingProduct = selectedItem
            
            self.navigationController?.pushViewController(editProduct, animated: true)
        }
    }
    
    func didTapCopyLink() {
        
    }
    
    func didTapShare() {
        let lp = BranchLinkProperties()
        lp.addControlParam("$ios_url", withValue: "https://itunes.apple.com/app/id1501095031")
        lp.addControlParam("nav_here", withValue: selectedItem.Post_ID)
        lp.addControlParam("nav_type", withValue: selectedItem.isSale ? "1" : "2")

        let identifier = selectedItem.Post_ID
        let buo = BranchUniversalObject(canonicalIdentifier: "content/\(identifier))")
        buo.title = selectedItem.Post_Title.capitalizingFirstLetter
        buo.contentDescription = selectedItem.Post_Text
        if selectedItem.Post_Media_Urls.count > 0 {
            buo.imageUrl = selectedItem.Post_Media_Urls[0]
        }
        buo.publiclyIndex = true
        buo.locallyIndex = true

        buo.getShortUrl(with: lp) { (url, error) in
            guard let url = url,
                  let deepLink = URL(string: url) else { return }

            print(url)
            let items: [Any] = [deepLink]

            let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self.present(avc, animated: true)
        }
    }
    
    private func deleteStoreItem() {
        let isSale = selectedItem.isSale
        
        showIndicator()
        APIManager.shared.deleteStoreItem(g_myToken, isSale: isSale, id: selectedItem.Post_ID) { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                if isSale {
                    NotificationCenter.default.post(name: .DidDeleteProduct, object: ["product_id": self.selectedItem.Post_ID])
                    
                } else {
                    NotificationCenter.default.post(name: .DidDeleteService, object: ["service_id": self.selectedItem.Post_ID])
                }
                
                self.navigationController?.popViewController(animated: true)
            
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
}

