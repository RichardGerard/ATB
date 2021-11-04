//
//  BusinessStoreViewController.swift
//  ATB
//
//  Created by YueXi on 7/29/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Panels
import NBBottomSheet
import Braintree
import BraintreeDropIn
import PopupDialog

// MARK: - @Protocol: StoreLoadDelegate
protocol StoreLoadDelegate {
    
    func didLoadStoreProducts(_ hasProducts: Bool)
}

class BusinessStoreViewController: BaseViewController {
    
    static let kStoryboardID = "BusinessStoreViewController"
    class func instance() -> BusinessStoreViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: BusinessStoreViewController.kStoryboardID) as? BusinessStoreViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    // services & products
    var storeItems = [PostModel]()
    @IBOutlet weak var clvStore: UICollectionView!
    
    var isOwnProfile = true
    var viewingUser: UserModel? = nil
    
    var delegate: StoreLoadDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        loadStoreItems()
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(didUpdateItem(_:)), name: .DidUpdatePost, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didDeleteProduct(_:)), name: .DidDeleteProduct, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didDeleteService(_:)), name: .DidDeleteService, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didReceiveProductStockChanged(_:)), name: .ProductStockChanged, object: nil)
    }
    
    private func setupViews() {        
        clvStore.showsVerticalScrollIndicator = false
        clvStore.alwaysBounceVertical = true
        clvStore.contentInsetAdjustmentBehavior = .always
        clvStore.backgroundColor = .colorGray7
        clvStore.dataSource = self
        clvStore.delegate = self
        
//        let inset: CGFloat = isCartPanelShown ? 106 : 16
        clvStore.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 16, right: 8) // 16 - no cart panel
        
        let width = (SCREEN_WIDTH - 22) / 2.0
        let height = isOwnProfile ? width + 124.0 : width + 85
        let itemSize = CGSize(width: width, height: height)
        
        // customize collectionviewlayout
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 14
        layout.minimumInteritemSpacing = 6
        layout.itemSize = itemSize
        clvStore.collectionViewLayout = layout
    }
    
    // This will load products & services from server
    // So the 'id' value in return will be the product or service id
    func loadStoreItems() {
        let user_id = viewingUser != nil ? viewingUser!.ID : g_myInfo.ID
        
        let params = [
            "token" : g_myToken,
            "user_id": user_id
        ]
        
        showIndicator()
        _ = ATB_Alamofire.POST(GET_BUSINESS_ITEMS, parameters: params as [String : AnyObject], showLoading: false, showSuccess: false, showError: false) { (result, responseObject) in
            self.storeItems.removeAll()
            
            self.hideIndicator()
            
            guard result,
                  let extra = responseObject.object(forKey: "extra") as? NSDictionary,
                  let items = extra.object(forKey: "items") as? [NSDictionary] else { return }
            
            for item in items {
                let newPost = PostModel(info: item)
                
                if newPost.isActive {
                    self.storeItems.append(newPost)
                }
            }
            
            self.delegate?.didLoadStoreProducts(self.storeItems.count > 0)
            
            DispatchQueue.main.async {
                self.clvStore.reloadData()
            }
        }
    }
    
    private func isValidMakePost() -> Bool {
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
    
    private func makePost(with selected: PostModel) {
        guard isValidMakePost() else { return }
        
        // check post limitation
        // need to check if user is limited to post
        let url = selected.isSale ? COUNT_SALE_POST : COUNT_SERVICE_POST
        let params = [
            "token": g_myToken
        ]
        
        showIndicator()
        _ = ATB_Alamofire.POST(url, parameters: params as [String: AnyObject], showLoading: false, showSuccess: false, showError: false, completionHandler: { (result, responseObject) in
            if result,
               let ok = responseObject["result"] as? Bool,
               ok {
                self.createPost(withSelected: selected)
                
            } else {
                self.hideIndicator()
                
                if selected.isSale {
                    self.showErrorVC(msg: "You may only post 10 sale posts within 30 days.")
                    
                } else {
                    self.showErrorVC(msg: "You may only post 3 service posts a day.")
                }
            }
        })
    }
    
    // selected will be either a service or a product
    private func createPost(withSelected selected: PostModel) {
        let profileType = "1"
        let postType = selected.isSale ? "2" : "3"
        let mediaType = selected.isVideoPost ? "2" : "1"
        
        var params = [
            "token" : g_myToken,
            "type" : postType,
            "media_type" : mediaType,
            "profile_type" : profileType,
            "title" : selected.Post_Title,
            "description" : selected.Post_Text,
            "brand" : selected.Post_Brand,
            "price" : selected.Post_Price,
            "category_title" : selected.Post_Category,
            "post_condition": selected.Post_Condition,
            "post_tags": selected.Post_Tags,
            "item_title" : selected.Post_Item,
            "payment_options" : selected.Post_Payment_Option,
            "location_id" : selected.Post_Location,
            "delivery_option" : selected.Delivery_Option,
            "delivery_cost" : selected.deliveryCost,
            "deposit" : selected.Post_Deposit,
            "lat" : "\(selected.Post_Position.latitude)",
            "lng" : "\(selected.Post_Position.longitude)",
            
            "is_multi": "0"
        ]
        
        if selected.Post_Media_Urls.count > 0 {
            var post_img_uris = ""
            for url in selected.Post_Media_Urls {
                post_img_uris += (url + ",")
            }
            
            post_img_uris = String(post_img_uris.dropLast())
            
            params["post_img_uris"] = post_img_uris
        }
        
        if selected.isSale {
            params["product_id"] = selected.Post_ID
            params["stock_level"] = selected.stock_level
            
        } else {
            params["is_deposit_required"] = selected.Post_DepositRequired
            params["cancellations"] = selected.cancellations
            params["insurance_id"] = selected.insuranceID
            params["qualification_id"] = selected.qualificationID
            
            params["service_id"] = selected.Post_ID
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
    
    private func didCompletePost() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainNav = storyboard.instantiateViewController(withIdentifier: "MainNav") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = mainNav
    }
    
    private func createBooking(withService service: PostModel) {
        guard let viewingUser = viewingUser,
              viewingUser.isBusiness else { return }
        
        let appointmentVC = AppointmentViewController.instance()
        appointmentVC.selectedService = service
        appointmentVC.business = viewingUser.business_profile
        appointmentVC.hidesBottomBarWhenPushed = true
        appointmentVC.isFromBusinessStore = true
        
        navigationController?.pushViewController(appointmentVC, animated: true)
    }
    
    // false - when the post is deleted
    private func showDeleteNotification(isProductDeleted: Bool) {
        let toastMessage = "The \(isProductDeleted ? "product" : "service") has been deleted successfully."
        let toastFont = UIFont(name: Font.SegoeUILight, size: 16)
        let estimatedFrame = toastMessage.heightForString(SCREEN_WIDTH - 72, font: toastFont)
        
        let toastViewHeight: CGFloat = estimatedFrame.height + 36
        let toastView = TextToastView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 40, height: toastViewHeight))
        toastView.toastMessage = toastMessage
        
        // giving position with a point as we have input accessory view
        showToast(toastView)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Notificaiton Handler
extension BusinessStoreViewController {
    
    @objc private func didUpdateItem(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let updated = object["updated"] as? PostModel,
              updated.isSale || updated.isService else { return }
        
        // only product and service updated will get here
        // make sure both type is same
        // the type is manually added in the back
        guard let index = storeItems.firstIndex(where: { $0.Post_Type == updated.Post_Type && $0.Post_ID == updated.Post_ID }) else { return }
        
        // store item could be updated from post
        if updated.isSale {
            storeItems[index].update(withProduct: updated)
            
        } else {
            storeItems[index].update(withService: updated)
        }
        
        DispatchQueue.main.async {
            self.clvStore.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    @objc private func didReceiveProductStockChanged(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let updatedProductId = object["product_id"] as? String,
              let updated = object["updated"] as? PostModel else { return }
        
        // make sure the type is sale
        guard let index = storeItems.firstIndex(where: { $0.isSale && $0.Post_ID == updatedProductId }) else { return }
        
        storeItems[index].update(withProduct: updated)
        DispatchQueue.main.async {
            self.clvStore.reloadItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    @objc private func didDeleteProduct(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let deletedProductId = object["product_id"] as? String else { return }
        
        guard let index = storeItems.firstIndex(where: { $0.Post_ID == deletedProductId }) else { return }
        
        storeItems.remove(at: index)
        DispatchQueue.main.async {
            self.clvStore.reloadData()
            
            self.showDeleteNotification(isProductDeleted: true)
        }
    }
    
    @objc private func didDeleteService(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let deletedServiceId = object["service_id"] as? String else { return }
        
        guard let index = storeItems.firstIndex(where: { $0.Post_ID == deletedServiceId }) else { return }
        
        storeItems.remove(at: index)
        DispatchQueue.main.async {
            self.clvStore.reloadData()
            
            self.showDeleteNotification(isProductDeleted: false)
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension BusinessStoreViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storeItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let storeItem = storeItems[indexPath.row]
        
        if isOwnProfile {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BusinessStoreOwnItemViewCell.reusableIdentifier, for: indexPath) as! BusinessStoreOwnItemViewCell
            // configure the cell
            cell.configureCell(storeItem)
            
            cell.postBlock = {
                self.makePost(with: storeItem)
            }
            
            cell.editBlock = {
                if storeItem.isService {
                    let editService = EditServiceViewController.instance()
                    editService.editingService = storeItem
                    editService.hidesBottomBarWhenPushed = true
                    
                    self.navigationController?.pushViewController(editService, animated: true)
                    
                } else {
                    let editProduct = EditProductViewController.instance()
                    editProduct.editingProduct = storeItem
                    editProduct.hidesBottomBarWhenPushed = true
                    
                    self.navigationController?.pushViewController(editProduct, animated: true)
                }
            }
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BusinessStoreItemViewCell.reusableIdentifier, for: indexPath) as! BusinessStoreItemViewCell
            // configure the cell
            cell.configureCell(storeItem)
            
            cell.actionBlock = {
                guard self.isBusinessApproved() else { return }
                
                if storeItem.isSale {
                    // Buy
                    guard !storeItem.isSoldOut else {
                        self.showInfoVC("ATB", msg: "The product is out of stock")
                        return
                    }
                    // if the product has variants
                    if storeItem.productVariants.count > 0 {
                        self.selectVariation(forProduct: storeItem)
                        
                    } else {
                        // add the product to cart
                        // no variant
//                        self.addItemInCart(storeItem, vid: "")
                        self.selectDeliveryOption(forProduct: storeItem, vid: "", quantity: 1)
                    }
                    
                } else {
                    // book the service
                    self.createBooking(withService: storeItem)
                }
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = storeItems[indexPath.row]
        openStoreItem(selected)
    }
    
    private func openStoreItem(_ selected: PostModel) {
        let storeItemVC = BusinessStoreItemViewController()
        
        storeItemVC.selectedItem = selected
        storeItemVC.viewingUser = viewingUser
        storeItemVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(storeItemVC, animated: true)
    }
    
    private func isBusinessApproved() -> Bool {
        guard let viewingUser = viewingUser,
              viewingUser.isBusinessApproved else {
            showAlert("ATB", message: "Admin is currently reviewing the business!\nPlease wait until they get approved, we always value your experience on ATB.", positive: "Ok", positiveAction: nil, preferredStyle: .actionSheet)
            return false
        }
        
        return true
    }
    
    private func selectVariation(forProduct product: PostModel) {
        // get product variations - UI model
        var variations = [VariationModel]()
        guard product.productVariants.count > 0 else { return }
        
        let variantAttributes = product.productVariants[0].attributes
        for variantAttribute in variantAttributes {
            let variation = VariationModel()
            let name = variantAttribute.name
            variation.name = name
            
            var values = [String]()
            
            for productVariant in product.productVariants {
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
    
    private func addItemInCart(_ item: PostModel, vid: String) {
        // get product id
        // the item id will be the product id
        let pid = item.Post_ID
        
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
extension BusinessStoreViewController: InstantCartDelegate {
    
    func buyProduct(_ product: PostModel, vid: String, quantity: Int) {
        // select delivery option
        selectDeliveryOption(forProduct: product, vid: vid, quantity: quantity)
    }
    
    // select delivery option
    private func selectDeliveryOption(forProduct product: PostModel, vid: String, quantity: Int) {
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

// MARK: - SelectVariationDelegate
extension BusinessStoreViewController: SelectVariationDelegate {
    
    func didAddItemToCart(_ product: PostModel, vid: String, quantity: Int) {
        showInstantCart(withProduct: product, vid: vid, quantity: quantity)
    }
    
    func willBuyProduct(_ product: PostModel, vid: String, quantity: Int) {
        selectDeliveryOption(forProduct: product, vid: vid, quantity: quantity)
    }
}

// MARK: - SelectDeliveryDelegate
extension BusinessStoreViewController: SelectDeliveryDelegate {
    
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
extension BusinessStoreViewController: SelectPaymentDelegate {
    
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
                self.updateStock(forProduct: product, vid: vid, quantity: quantity, paymentMethod: 1, showMessage: message)
                
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
                    self.showErrorVC(msg: "You cannot use your card to pay for goods.")
//                    self.makePayment(withPaymentMethod: "Card", nonce: nonce, vid: vid, quantity: quantity, deliveryOption: deliveryOption)
                    
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
                self.updateStock(forProduct: product, vid: vid, quantity: quantity)
//                self.deletePurchasedItems(product, vid: vid)
                
            } else {
                let msg = response.object(forKey: "msg") as? String ?? "Failed to proceed your payment, please try again!"                
                self.showErrorVC(msg: msg)
            }
        })
    }
    
    // paymentMethod: 1 - pay with cash, 2 - pay by PayPal
    private func updateStock(forProduct product: PostModel, vid: String, quantity: Int, paymentMethod: Int = 2, showMessage: String = "") {
        guard let storeItemIndex = storeItems.firstIndex(where: { $0.isSale && $0.Post_ID == product.Post_ID }) else { return }
        
        let selectedItem = storeItems[storeItemIndex]
        
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
            self.clvStore.reloadData()
        }
        
        let objectToPost: [String: Any] = [
            "product_id": selectedItem.Post_ID,                // send product id seperately
            "updated": selectedItem                 // use only post details to update product or post
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
        completedVC.purchasedItem = product
        completedVC.delegate = self
        
        let popupDialog = PopupDialog(viewController: completedVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(popupDialog, animated: true, completion: nil)
    }
    
    private func chatWithSeller() {
        guard let viewingUser = viewingUser,
              viewingUser.isBusiness else { return }
        
        let conversationVC = ConversationViewController()
        conversationVC.userId = viewingUser.business_profile.ID + "_" + viewingUser.ID
        
        self.navigationController?.pushViewController(conversationVC, animated: true)
    }
}

// MARK: - PurchaseCompleteDelegate
extension BusinessStoreViewController: PurchaseCompleteDelegate {
    
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

// MARK: - SubscriptionDelegate
extension BusinessStoreViewController: SubscriptionDelegate {
    
    func didCompleteSubscription() {
        
    }
    
    func didIncompleteSubscription() {
        
    }
}
