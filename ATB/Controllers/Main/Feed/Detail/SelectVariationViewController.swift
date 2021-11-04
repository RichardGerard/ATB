//
//  SelectVariationViewController.swift
//  ATB
//
//  Created by YueXi on 11/13/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Kingfisher

protocol SelectVariationDelegate: class {
    
    func willBuyProduct(_ product: PostModel, vid: String, quantity: Int)
    func didAddItemToCart(_ product: PostModel, vid: String, quantity: Int)
}

class SelectVariationViewController: BaseViewController {
    
    static let kStoryboardID = "SelectVariationViewController"
    class func instance() -> SelectVariationViewController {
        let storyboard = UIStoryboard(name: "Sheet", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: SelectVariationViewController.kStoryboardID) as? SelectVariationViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var productContainer: UIView!
    @IBOutlet weak var imvProduct: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var lblBefore: UILabel!
    @IBOutlet weak var lblSelect: UILabel!
    
    @IBOutlet weak var tblVariations: UITableView!
    
    @IBOutlet weak var btnBuy: UIButton!
    @IBOutlet weak var btnAddCart: UIButton!
    
    var selectedProduct: PostModel!
    var variations = [VariationModel]()
    
    var delegate: SelectVariationDelegate?
    
    var isFromBusinessStore = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 24)
    }
    
    private func initView() {
        view.backgroundColor = .colorGray14
        
        productContainer.backgroundColor = .colorGray7
        productContainer.layer.cornerRadius = 5
        productContainer.layer.shadowColor = UIColor.black.cgColor
        productContainer.layer.shadowRadius = 4
        productContainer.layer.shadowOpacity = 0.22
        productContainer.layer.shadowOffset = CGSize(width: 1, height: 2)
        
        imvProduct.layer.cornerRadius = 5
        imvProduct.layer.masksToBounds = true
        imvProduct.contentMode = .scaleAspectFill
        
        let url = selectedProduct.Post_Media_Urls.count > 0 ? selectedProduct.Post_Media_Urls[0] : ""
        if selectedProduct.isVideoPost {
            // set placeholder
            imvProduct.image = UIImage(named: "post.placeholder")
            
            if ImageCache.default.imageCachedType(forKey: url).cached {
                ImageCache.default.retrieveImage(forKey: url) { result in
                    switch result {
                    case .success(let cacheResult):
                        if let image = cacheResult.image {
                            let animation = CATransition()
                            animation.type = .fade
                            animation.duration = 0.25
                            self.imvProduct.layer.add(animation, forKey: "transition")
                            self.imvProduct.image = image
                        }
                        
                        break
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                }
                
            } else {
                // thumbnail is not cached, get thumbnail from video url
                Utils.shared.getThumbnailImageFromVideoUrl(url) { thumbnail in
                    if let thumbnail = thumbnail {
                        let animation = CATransition()
                        animation.type = .fade
                        animation.duration = 0.3
                        self.imvProduct.layer.add(animation, forKey: "transition")
                        self.imvProduct.image = thumbnail
                        
                        ImageCache.default.store(thumbnail, forKey: url)
                    }
                }
            }
            
        } else {
            imvProduct.loadImageFromUrl(url, placeholder: "post.placeholder")
        }
        
        lblTitle.text = selectedProduct.Post_Title.capitalizingFirstLetter
        lblTitle.font = UIFont(name: Font.SegoeUIBold, size: 25)
        lblTitle.textColor = .colorGray5
        
        lblDescription.text = selectedProduct.Post_Text
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .colorGray5
        lblDescription.numberOfLines = 2        
                
        lblBefore.text = "Before you continue...."
        lblBefore.font = UIFont(name: Font.SegoeUISemibold, size: 22)
        lblBefore.textColor = .colorGray5
        
        lblSelect.text = "Please select the following variations to complete your order"
        lblSelect.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblSelect.textColor = .colorGray5
        lblSelect.numberOfLines = 2
        
        btnBuy.backgroundColor = .colorPrimary
        btnBuy.layer.cornerRadius = 5
        btnBuy.setTitle("Buy Now", for: .normal)
        btnBuy.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        btnBuy.setTitleColor(.white, for: .normal)
        
        btnAddCart.backgroundColor = .white
        btnAddCart.layer.cornerRadius = 5
        btnAddCart.layer.borderWidth = 1
        btnAddCart.layer.borderColor = UIColor.colorGray4.cgColor
        btnAddCart.setTitle(" Add to Cart", for: .normal)
        btnAddCart.setTitleColor(.colorGray5, for: .normal)
        btnAddCart.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        if #available(iOS 13.0, *) {
            btnAddCart.setImage(UIImage(systemName: "cart.fill.badge.plus"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnAddCart.tintColor = .colorGray5
        
        tblVariations.separatorStyle = .none
        tblVariations.backgroundColor = .clear
        tblVariations.showsVerticalScrollIndicator = false
//        tblVariations.bounces = false
        
        tblVariations.dataSource = self
        tblVariations.delegate = self
    }
    
    private func isValid() -> Bool {
        for variation in variations {
            if let _ = variation.selected {
                continue
                
            } else {
                self.showErrorVC(msg: "Please select \(variation.name.lowercased())")
                return false
            }
        }
        
        return true
    }
    
    private func isStockValid(forVariant vid: String) -> Bool {
        let productVariants = selectedProduct.productVariants        
        guard let selectedVariant = productVariants.first(where: { $0.id == vid }),
              selectedVariant.stock_level.intValue > 0 else {
            showAlert("ATB", message: "The product is out of stock!", positive: "Ok", positiveAction: nil, preferredStyle: .actionSheet)
            return false
        }
        
        return true
    }

    @IBAction func didTapBuy(_ sender: Any) {
        guard isValid() else { return }
        
        let vid = getSelectedVariant()
        guard !vid.isEmpty else {
            showErrorVC(msg: "The variant is invalid!")
            return
        }
        
        guard isStockValid(forVariant: vid) else { return }
        
        dismiss(animated: true) {
            self.delegate?.willBuyProduct(self.selectedProduct, vid: vid, quantity: 1)
        }
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
        
        for productVariant in selectedProduct.productVariants {
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
    
    @IBAction func didTapAddCart(_ sender: Any) {
        guard isValid() else { return }
        
        let vid = getSelectedVariant()
        guard !vid.isEmpty else {
            showErrorVC(msg: "The variant is invalid!")
            return
        }
        
        addItemToCart(withVariant: vid)
    }
    
    private func addItemToCart(withVariant vid: String) {
        let pid = isFromBusinessStore ? selectedProduct.Post_ID : selectedProduct.pid ?? ""
        guard !pid.isEmpty else { return }
        
        showIndicator()
        APIManager.shared.addItemInCart(g_myToken, pid: pid, vid: vid) { (result, message, cartInfo) in
            self.hideIndicator()

            guard result,
                  let cartInfo = cartInfo else {
                self.showErrorVC(msg: "It's been failed to add the product to your cart!")
                return
            }
            
            self.dismiss(animated: true) {
                self.delegate?.didAddItemToCart(self.selectedProduct, vid: vid, quantity: cartInfo.1)
            }
        }
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension SelectVariationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return variations.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VariationSelectCell.reuseIdentifier, for: indexPath) as! VariationSelectCell
        
        // configure the cell
        cell.configureCell(withVariation: variations[indexPath.section])
        cell.attributeOptionSelected = { selected in
            self.variations[indexPath.section].selected = selected
            
            NotificationCenter.default.post(name: .DidSelectVariant, object: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 91
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section >= variations.count-1 ? 0 : 10
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = .clear
    }
}
