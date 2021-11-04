//
//  PostMultipleProductsViewController.swift
//  ATB
//
//  Created by YueXi on 4/27/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import PopupDialog
import NBBottomSheet

class PostMultipleProductsViewController: BaseViewController {
    
    let kSkeletonViewCount = 5
    
    var postingUser: UserModel!
    
    var postsToPublish = [PostToPublishModel]()
    
    var isPosting: Bool = false
    var rootViewController: PostProductViewController? = nil
    
    // temp variable for UI version
    var isProductAdded: Bool = false
    
    @IBOutlet weak var tblSaleProducts: UITableView! { didSet {
        tblSaleProducts.showsVerticalScrollIndicator = false
        tblSaleProducts.dataSource = self
        tblSaleProducts.delegate = self
        tblSaleProducts.separatorStyle = .none
        tblSaleProducts.tableFooterView = UIView()
        tblSaleProducts.backgroundColor = .colorGray14
        tblSaleProducts.isEditing = true
        }}
    
    @IBOutlet weak var vBottom: UIView!
    @IBOutlet weak var lblAddDescription: UILabel! {
        didSet {
            lblAddDescription.textAlignment = .center
            
            let attachment = NSTextAttachment()
            if #available(iOS 13.0, *) {
                attachment.image = UIImage(systemName: "plus.circle.fill")?.withTintColor(.colorGray2)
                //                attachment.setImageHeight(height: 24, verticalOffset: -4.0)
            } else {
                // Fallback on earlier versions
            }
            
            let normalAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "SegoeUI-Light", size: 15)!,
                .foregroundColor: UIColor.colorGray15
            ]
            
            let attrYourProducts = NSMutableAttributedString(string: "Your products will display here, add a new one\nby clicking  ")
            attrYourProducts.addAttributes(normalAttrs, range: NSRange(location: 0, length: attrYourProducts.length))
            
            let boldAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "SegoeUI-Semibold", size: 15)!,
                .foregroundColor: UIColor.colorGray15
            ]
            
            let attrAddProduct = NSMutableAttributedString(attachment: attachment)
            attrAddProduct.append(NSAttributedString(string: "  Add a Product"))
            attrAddProduct.addAttributes(boldAttrs, range: NSRange(location: 0, length: attrAddProduct.length))
            
            attrYourProducts.append(attrAddProduct)
            
            lblAddDescription.attributedText = attrYourProducts
        }
    }
    
    @IBOutlet weak var vAddButton: DashlineView!
    @IBOutlet weak var btnAdd: UIButton! { didSet {
        btnAdd.setTitle(" Add a Product", for: .normal)
        btnAdd.titleLabel?.font = UIFont(name: "SegoeUI-Semibold", size: 20)
        btnAdd.setTitleColor(.colorGray2, for: .normal)
        if #available(iOS 13.0, *) {
            btnAdd.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnAdd.tintColor = .colorGray2
        }}
    @IBOutlet weak var btnPublish: RoundedShadowButton! { didSet {
        if #available(iOS 13.0, *) {
            btnPublish.setImage(UIImage(systemName: "square.and.arrow.up.on.square"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnPublish.tintColor = .white
        btnPublish.setTitle(" Publish all items", for: .normal)
        btnPublish.setTitleColor(.white, for: .normal)
        btnPublish.titleLabel?.font = UIFont(name: "SegoeUI-Semibold", size: 20)
        }}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .colorGray14
        vBottom.backgroundColor = .colorGray14
        
        vBottom.layer.masksToBounds = false
        vBottom.layer.shadowOffset = CGSize(width: 0, height: -8)
        vBottom.layer.shadowRadius = 8.0
        vBottom.layer.shadowColor = UIColor.gray.cgColor
        vBottom.layer.shadowOpacity = 0.17
        
        if !isProductAdded {
            btnPublish.isHidden = true
            lblAddDescription.isHidden = false
            
        } else {
            btnPublish.isHidden = false
            lblAddDescription.isHidden = true
        }
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
        let addProductVC = PostSingleProductViewController.instance()
        addProductVC.isAddingMultipleProducts = true
        addProductVC.delegate = self
        addProductVC.postingUser = postingUser
        addProductVC.rootViewController = rootViewController
        
        let nav = UINavigationController(rootViewController: addProductVC)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true, completion: nil)
    }
    
    @IBAction func didTapPublish(_ sender: Any) {
        guard postsToPublish.count > 0 else { return }
        
        if isPosting {
            // posting products
            let params = [
                "token" : g_myToken
            ]
            
            showIndicator()
            _ = ATB_Alamofire.POST(COUNT_SALE_POST, parameters: params as [String : AnyObject], showLoading: false, showSuccess: false, showError: false){
                (result, responseObject) in
                if result,
                    let ok = responseObject["result"] as? Bool,
                    ok {
                    self.createSalesPost()
                    
                } else {
                    self.hideIndicator()
                    self.showErrorVC(msg: "You may only post 10 sales posts within 30 days.")
                }
            }
            
        } else {
            // adding products
            createSalesPost()
        }
    }
    
    private func createSalesPost() {
        if postsToPublish.count < 2 {
            createSingleSalesPost()
            
        } else {
            createMultipleSalesPost()
        }
    }
}

// MARK: AddProductDelegate
extension PostMultipleProductsViewController: AddProductDelegate {
    
    func didAddProduct(_ post: PostToPublishModel) {
        postsToPublish.append(post)
        
        tblSaleProducts.reloadData()
        
        if postsToPublish.count == 1 {
            UIView.animate(withDuration: 0.35, animations: {
                self.btnPublish.isHidden = false
                self.lblAddDescription.isHidden = true
                self.tblSaleProducts.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 216, right: 0)
                
                self.view.layoutIfNeeded()
                
            })
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension PostMultipleProductsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  postsToPublish.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SaleProductCell.reuseIdentifier, for: indexPath) as! SaleProductCell
        
        // configure the cell
        cell.configureCell(postsToPublish[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 104
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.postsToPublish[sourceIndexPath.row]
        postsToPublish.remove(at: sourceIndexPath.row)
        postsToPublish.insert(movedObject, at: destinationIndexPath.row)
    }
}

// MARK: -  Post Handlers
extension PostMultipleProductsViewController {
    
    // create a sale post
    private func createSingleSalesPost() {
        let post = postsToPublish[0]
        
        let posterProfileType = postingUser == nil ? "1" : (postingUser!.isBusiness ? "1": "0")
        
        var params = [
            "token" : g_myToken,
            "poster_profile_type" : posterProfileType,
            "media_type" : post.media_type,
            "title" : post.title,
            "brand" : post.brand,
            "price" : post.price,
            "description" : post.description,
            "category_title" : post.category_title,
            "post_tags" : post.post_tags,
            "lat" : post.lat,
            "lng" : post.lng,
            "item_title" : post.item_title,
            "payment_options" : post.payment_options,
            "location_id" : post.location_id,
            "delivery_option" : post.delivery_option,
            "delivery_cost": post.deliveryCost,
            "post_condition": post.post_condition,
            "stock_level" : post.stock_level,
            
            "make_post": isPosting ? "1" : "0",
                        
            "is_multi" : "0",
            
            // unused in sale
            "is_deposit_required": "0",
            "deposit": "0",
        ]
        
        if (post.variants.count > 0) {
            let encodedVariants = Utils.shared.json(from: post.variants)
            params["attributes"] = encodedVariants
        }
        
        let upload = ATB_Alamofire.shareInstance.upload(
            multipartFormData: { (multipartFormData) in
                if post.media_type == "1" {
                    // attach images
                    for (mediaFileIndex, photoData) in post.photoDatas.enumerated() {
                        multipartFormData.append(photoData, withName: "post_imgs[\(mediaFileIndex)]", fileName: "img\(mediaFileIndex).jpg", mimeType: "image/jpeg")
                    }
                    
                } else {
                    // attach the selected video
                    if let videoData = post.videoData {
                        multipartFormData.append(videoData, withName: "post_imgs[0]", fileName: "vid0.mp4", mimeType: "video/mp4")
                    }
                }
                
                for (key, value) in params {
                    multipartFormData.append((value.data(using: .utf8)!), withName: key)
                }
            },
            to: ADD_PRODUCT,
            usingThreshold: multipartFormDataEncodingMemoryThreshold,
            method: .post,
            headers: nil,
            interceptor: nil,
            fileManager: FileManager.default)
        
        upload.responseJSON { (response) in
            switch response.result {
            case .success(let JSON):
                let res = JSON as! NSDictionary
                
                if let ok = res["result"] as? Bool,
                    ok {
                    let product = res["extra"] as! NSDictionary
                    let variants = product["variations"] as! [NSDictionary]
                   
                    if (variants.count > 0) {
                        self.updateProductVariants(variants, at: 0)
                        
                        self.uploadProductVariants()
                        
                    } else {
                        self.hideIndicator()
                            
                        self.didCompletePost()
                    }
                    
                } else {
                    self.hideIndicator()
                    
                    let msg = res["msg"] as? String ?? ""
                                               
                    if(msg == "") {
                       self.showErrorVC(msg: "Failed to create post, please try again")
                        
                    } else {
                       self.showErrorVC(msg: "Server returned the error message: " + msg)
                    }
                }
                
            case .failure(_):
                self.hideIndicator()
                self.showErrorVC(msg: "Failed to create post, please try again")
            }
        }
    }
    
    // create multiple sales post
    private func createMultipleSalesPost() {
        // This will count total posted count
        let totalCountToPost = postsToPublish.count
        var postedCount = 0
        
        var hasVariants = false
        
        let posterProfileType = postingUser == nil ? "1" : (postingUser!.isBusiness ? "1": "0")
        
        let groupParams = [
            "token" : g_myToken
        ]
        
        _ = ATB_Alamofire.POST(GET_PRODUCT_MULTI_GROUP_ID, parameters: groupParams as [String : AnyObject], showLoading: false, showSuccess: false, showError: false) { (result, responseObject) in
            guard let groupId = responseObject.object(forKey: "msg") as? Int else {
                self.showErrorVC(msg: "Failed to create post, please try again")
                return
            }
            let groupString = String(groupId)
            
            for (positionInGroup, post) in self.postsToPublish.enumerated() {
                var params = [
                    "token" : g_myToken,
                    "poster_profile_type" : posterProfileType,
                    "media_type" : post.media_type,
                    "title" : post.title,
                    "brand" : post.brand,
                    "price" : post.price,
                    "description" : post.description,
                    "category_title" : post.category_title,
                    "post_tags" : post.post_tags,
                    "lat" : post.lat,
                    "lng" : post.lng,
                    "item_title" : post.item_title,
                    "payment_options" : post.payment_options,
                    "location_id" : post.location_id,
                    "delivery_option" : post.delivery_option,
                    "delivery_cost": post.deliveryCost,
                    "post_condition": post.post_condition,
                    "stock_level" : post.stock_level,
                    
                    "make_post": self.isPosting ? "1" : "0",
                    
                    "is_multi" : "1",
                    "multi_pos" : "\(positionInGroup)",
                    "multi_group" : groupString,
                    
                    // unused in sale
                    "is_deposit_required": "0",
                    "deposit": "0"
                ]
                
                if (post.variants.count > 0) {
                    let encodedVariants = Utils.shared.json(from: post.variants)
                    params["attributes"] = encodedVariants
                }
                
                let upload = ATB_Alamofire.shareInstance.upload(
                    multipartFormData: { (multipartFormData) in
                        if(post.media_type == "1") {
                            for (mediaFileIndex, photoData) in post.photoDatas.enumerated() {
                                multipartFormData.append(photoData, withName: "post_imgs[\(mediaFileIndex)]", fileName: "img\(mediaFileIndex).jpg", mimeType: "image/jpeg")
                            }
                            
                        } else {
                            if let videoData = post.videoData {
                                multipartFormData.append(videoData, withName: "post_imgs[0]", fileName: "vid0.mp4", mimeType: "video/mp4")
                            }
                        }
                        
                        for (key, value) in params
                        {
                            multipartFormData.append((value.data(using: .utf8)!), withName: key)
                        }
                },
                    to: ADD_PRODUCT,
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
                            let product = res["extra"] as! NSDictionary
                            
                            if let variants = product["variations"] as? [NSDictionary],
                               variants.count > 0 {
                                hasVariants = true
                                self.updateProductVariants(variants, at: positionInGroup)
                            }
                            
                        } else {
                            let msg = res["msg"] as? String ?? ""
                            self.hideIndicator()
                            
                            if msg == "" {
                                self.showErrorVC(msg: "Failed to create post, please try again")
                                return
                                
                            } else {
                                
                                self.showErrorVC(msg: "Server returned the error message: " + msg)
                                return
                            }
                        }
                        
                    case .failure(_):
                        self.hideIndicator()
                        
                        self.showErrorVC(msg: "Failed to create post, please try again")
                        return
                    }
                    
                    if postedCount >= totalCountToPost {
                        if hasVariants {
                            self.uploadProductVariants()
                            
                        } else {
                            self.hideIndicator()
                            
                            self.didCompletePost()
                        }
                    }
                }
            }
        }
    }
    
    // assign variant id to local product variants
    private func updateProductVariants(_ variants: [NSDictionary], at: Int) {
        // parse variants and set the ID
        for variant in variants {
            let id = variant.object(forKey: "id") as? String ?? ""
            
            var attributes = [VariantAttribute]()
            if let attributeDicts = variant.object(forKey: "attributes") as? [NSDictionary] {
                for attributeDict in attributeDicts {
                    let attribute = VariantAttribute(info: attributeDict)
                                    
                    attributes.append(attribute)
                }
            }
            
            if attributes.count > 0 {
                for (index, productVariant) in postsToPublish[at].productVariants.enumerated() {
                    guard productVariant.id.isEmpty else {
                        continue
                    }
                    
                    let sortedProductAttributes = productVariant.attributes.sorted {
                        $0.value.localizedCaseInsensitiveCompare($1.value) == .orderedAscending
                    }
                    
                    var allProductAttributes = ""
                    for productAttribute in sortedProductAttributes {
                        allProductAttributes += productAttribute.value
                    }
                    
                    let sortedAttributes = attributes.sorted { $0.value.localizedCaseInsensitiveCompare($1.value) == .orderedAscending }
                    
                    var allAttributes = ""
                    for attribute in sortedAttributes {
                        allAttributes += attribute.value
                    }
                    
                    if allProductAttributes == allAttributes {
                        postsToPublish[at].productVariants[index].id = id
                        break
                    }
                }
            }
        }
    }
    
    // upload prices & stockes for variants
    private func uploadProductVariants() {
        var totalCount = 0
        for post in postsToPublish {
            totalCount += post.productVariants.count
        }
        
        var updateCount = 0
        for post in postsToPublish {
            for productVariant in post.productVariants {
                guard !productVariant.id.isEmpty,
                      productVariant.isSelected else {
                    updateCount += 1
                    continue
                }
                
                let params = [
                    "token" : g_myToken,
                    "id" : productVariant.id,
                    "stock_level" : productVariant.stock_level,
                    "price" : productVariant.price
                ]
                
                _ = ATB_Alamofire.POST(UPDATE_PRODUCT_VARIANT, parameters: params as [String : AnyObject], showLoading: false, showSuccess: false, showError: false) { (result, responseObject) in
                    updateCount += 1
                    
                    if updateCount >= totalCount {
                        self.hideIndicator()
                        
                        self.didCompletePost()
                    }
                }
            }
        }
    }
    
    func didCompletePost() {
        if isPosting {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainNav = storyboard.instantiateViewController(withIdentifier: "MainNav") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = mainNav
            
        } else {
            guard let rootViewController = self.rootViewController else { return }
            
            rootViewController.didAddNewProducts(postsToPublish)
        }
    }
}
