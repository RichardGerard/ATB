//
//  CartPanel.swift
//  ATB
//
//  Created by YueXi on 7/30/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Panels
import Kingfisher

// MARK: - CartItemModel
class CartItemModel: NSObject {
    
    var id: String = ""             // cart id
    var pid: String = ""            // product id
    var vid: String = ""            // variant id
    var uid: String = ""            // seller user id
    var unitPrice: Float = 0.0
    var quantity: Int = 0
    
    var product: PostModel = PostModel()
}

protocol CartPanelDelegate {
    
    func increase(_ item: CartItemModel)
    func decrease(_ item: CartItemModel)
    func reachedToMinimum(_ item: CartItemModel)
    func reachedToMaximum(_ item: CartItemModel)
}

// MARK: CartPanel
class CartPanel: UIViewController, Panelable {
    
    // Pannelable Protocol variables
    @IBOutlet var headerHeight: NSLayoutConstraint!
    @IBOutlet var headerPanel: UIView!
    
    @IBOutlet weak var arrow: ArrowView! { didSet {
        arrow.arrowColor = UIColor.black.withAlphaComponent(0.17)
        }}
    
    @IBOutlet weak var imvCart: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvCart.image = UIImage(systemName: "cart.fill")
        } else {
            // Fallback on earlier versions
        }
        imvCart.contentMode = .scaleAspectFit
        imvCart.tintColor = .white
        }}
    
    private let boldAttrs: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: Font.SegoeUISemibold, size: 16)!
    ]
    @IBOutlet weak var lblDescription: UILabel! { didSet {
        lblDescription.text = ""
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 16)
        lblDescription.textColor = .white
        lblDescription.numberOfLines = 2
        }}
    
    @IBOutlet weak var lblPrice: UILabel! { didSet {
        lblPrice.text = ""
        lblPrice.font = UIFont(name: Font.SegoeUIBold, size: 24)
        lblPrice.textColor = .white
        }}
    
    @IBOutlet weak var tblProducts: UITableView!
    @IBOutlet weak var btnCheckOut: UIButton!
    
    var cartList = [CartItemModel]()
    
    var delegate: CartPanelDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        headerPanel.backgroundColor = .clear
        self.view.backgroundColor = .colorPrimary
        
        tblProducts.tableFooterView = UIView()
        tblProducts.showsVerticalScrollIndicator = false
        tblProducts.backgroundColor = .clear
        tblProducts.separatorStyle = .none
        
        tblProducts.dataSource = self
        tblProducts.delegate = self
        
        btnCheckOut.setTitle("Checkout £0.0", for: .normal)
        btnCheckOut.setTitleColor(.white, for: .normal)
        btnCheckOut.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 20)
        btnCheckOut.layer.cornerRadius = 5
        btnCheckOut.layer.masksToBounds = true
        btnCheckOut.backgroundColor = .colorBlue5
    }
    
    func updateCart(_ cartList: [CartItemModel]) {
        // updat cart list in the cart panel
        self.cartList.removeAll()
        self.cartList.append(contentsOf: cartList)
        
        var totalItems = 0
        var totalPrice: Float = 0
        for cart in cartList {
            totalItems += cart.quantity
            
            totalPrice += cart.unitPrice * Float(cart.quantity)
        }
        
        let itemDescription = totalItems > 1 ? "\(totalItems) items in the cart." : "\(totalItems) item in the cart."
        let cartDescription = "You currently have \n" + itemDescription
        
        
        let attributedText = NSMutableAttributedString(string: cartDescription)
        let productRange = (cartDescription as NSString).range(of: itemDescription)
        attributedText.addAttributes(boldAttrs, range: productRange)
        lblDescription.attributedText = attributedText
        
        lblPrice.text = "£\(totalPrice.priceString)"
        
        UIView.setAnimationsEnabled(false)
        btnCheckOut.setTitle("Checkout £\(totalPrice.priceString)", for: .normal)
        btnCheckOut.layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
        
        tblProducts.reloadData()
    }
    
    func reloadCart() {
        tblProducts.reloadData()
    }
    
    @IBAction func didTapCheckOut(_ sender: Any) {
        
    }
}

// MARK: - PanelNotifications
extension CartPanel: PanelNotifications {
    
    func panelDidPresented() {
        arrow.update(to: .up, animated: true)
    }
    
    func panelDidCollapse() {
        arrow.update(to: .up, animated: true)
    }
    
    func panelDidOpen() {
        arrow.update(to: .middle, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension CartPanel: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductCellInCart.reuseIdentifier, for: indexPath) as! ProductCellInCart
        // configure the cell
        let item = cartList[indexPath.row]
        cell.configureCell(item)
        
        cell.increased = { _ in
            self.delegate?.increase(item)
        }
        
        cell.decreased = { _ in
            self.delegate?.decrease(item)
        }
        
        cell.valueLimited = { isBottom in
            if isBottom {
                self.delegate?.reachedToMinimum(item)

            } else {
                self.delegate?.reachedToMaximum(item)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: ProductCellInCart
class ProductCellInCart: UITableViewCell {
    
    static let reuseIdentifier = "ProductCellInCart"
    
    @IBOutlet weak var vContainer: UIView! { didSet {
        vContainer.layer.cornerRadius = 5
        vContainer.layer.masksToBounds = true
        }}
    
    @IBOutlet weak var imvProduct: UIImageView! { didSet {
        imvProduct.contentMode = .scaleAspectFill
        }}
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.text = ""
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 19)
        lblTitle.textColor = .colorGray1
        }}
    @IBOutlet weak var lblPrice: UILabel! { didSet {
        lblPrice.text = ""
        lblPrice.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        lblPrice.textColor = .colorPrimary
        }}
    @IBOutlet weak var stepper: GMStepper! { didSet {
        stepper.minimumValue = 1
        stepper.maximumValue = 100
        stepper.stepValue = 1
        stepper.autorepeat = false
        stepper.buttonsTextColor = .colorPrimary
        stepper.buttonsFont = UIFont(name: Font.SegoeUIBold, size: 16)!
        stepper.buttonsBackgroundColor = .colorGray14
        stepper.labelTextColor = .colorGray2
        stepper.labelFont = UIFont(name: Font.SegoeUILight, size: 21)!
        stepper.labelBackgroundColor = .colorGray14
        stepper.cornerRadius = 5
        stepper.borderWidth = 1
        stepper.borderColor = .colorGray14
        stepper.labelCornerRadius = 5
        stepper.limitHitAnimationColor = .colorGray14
        stepper.delegate = self
        }}
    
    var increased: ((Int) -> Void)? = nil
    var decreased: ((Int) -> Void)? = nil
    var valueLimited: ((Bool) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        stepper.value = 1
    }
    
    func configureCell(_ cart: CartItemModel) {
        let url = cart.product.Post_Media_Urls.count > 0 ? DOMAIN_URL + cart.product.Post_Media_Urls[0] : ""
        if cart.product.isVideoPost {
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
        
        lblTitle.text = cart.product.Post_Title
        lblPrice.text = "£\(cart.product.Post_Price)"
        
        stepper.value = Double(cart.quantity)
    }
}

// MARK: - StepperDelegate
extension ProductCellInCart: StepperDelegate {
    
    func reachedToLimit(_ value: Double) {
        if value == stepper.minimumValue {
            // reached to minimum
            valueLimited?(true)
            
        } else {
            // reached to maximum
            valueLimited?(false)
        }
    }
    
    func leftButtonPressed(_ value: Double) {
        decreased?(Int(value))
    }
    
    func rightButtonPressed(_ value: Double) {
        increased?(Int(value))
    }
}

// MARK: - UIStoryboard Extension
public extension UIStoryboard {

    /// Helper method to initialize a panel using Storyboards
    ///
    /// - Parameter identifier: Name of the storyboard
    /// - Returns: The intial VC from the Storyboard that conforms Panelable
    class func instantiatePanel(identifier: String) -> Panelable & UIViewController {
        guard let panel = UIStoryboard(name: identifier, bundle: nil).instantiateInitialViewController() as? Panelable & UIViewController else {
            fatalError("Try to instanciate something that does not conform Panelable :(")
        }
        
        return panel
    }
}
