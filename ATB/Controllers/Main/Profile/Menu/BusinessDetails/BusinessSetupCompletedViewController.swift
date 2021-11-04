//
//  BussinessSetupCompletedViewController.swift
//  ATB
//
//  Created by YueXi on 7/21/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import SemiModalViewController

// MARK: BusinessAddDelegate
protocol BusinessAddDelegate {
    // The parameters in delegate function will only be used
    // when they add products & services when they setting up business profile
    // the other case when they add products & services from their business store profile
    // the parameters will not have any meaning, so let's ignore and reload them from the server
    func didAddNewProducts(_ items: [PostToPublishModel])
    func didAddNewService(_ item: PostToPublishModel)
}

class BusinessSetupCompletedViewController: BaseViewController {
    
    static let kStoryboardID = "BusinessSetupCompletedViewController"
    class func instance() -> BusinessSetupCompletedViewController {
        let storyboard = UIStoryboard(name: "BusinessDetails", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: BusinessSetupCompletedViewController.kStoryboardID) as? BusinessSetupCompletedViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvCompletedLogo: UIImageView!
    @IBOutlet weak var lblBusinessReady: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    @IBOutlet weak var tblServices: IntrinsicTableView! { didSet {
        tblServices.showsVerticalScrollIndicator = false
        tblServices.separatorStyle = .none
        tblServices.tableFooterView = UIView()
        tblServices.backgroundColor = .clear
        tblServices.dataSource = self
        tblServices.delegate = self
        }}
    @IBOutlet weak var tblProducts: IntrinsicTableView! { didSet {
        tblProducts.showsVerticalScrollIndicator = false
        tblProducts.separatorStyle = .none
        tblProducts.tableFooterView = UIView()
        tblProducts.backgroundColor = .clear
        tblProducts.dataSource = self
        tblProducts.delegate = self
        }}
    
    @IBOutlet weak var btnAddService: UIButton!
    @IBOutlet weak var btnAddProduct: UIButton!
    
    @IBOutlet weak var btnGotoStore: UIButton!
    
    var products = [PostToPublishModel]()
    var services = [PostToPublishModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        /// add gradient layer
        self.view.addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 47, alphaValue: 1.0)
        
        if #available(iOS 13.0, *) {
            imvCompletedLogo.image = UIImage(systemName: "checkmark.seal.fill")
        } else {
            // Fallback on earlier versions
        }
        imvCompletedLogo.tintColor = .white
        
        let businessUser = g_myInfo.business_profile
        lblBusinessReady.text = "\(businessUser.businessName) is Ready!"
        lblBusinessReady.font = UIFont(name: Font.SegoeUISemibold, size: 26)
        lblBusinessReady.textColor = .white
        
        lblInfo.text = "Your Business has been set up successfully, now add some products and services"
        lblInfo.font = UIFont(name: Font.SegoeUILight, size: 14)
        lblInfo.textColor = .white
        lblInfo.numberOfLines = 0
        
        /// setup add buttons
        setupButton(btnAddService, title: "  Add a Service")
        setupButton(btnAddProduct, title: "  Add Products")
        
        btnGotoStore.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        btnGotoStore.layer.cornerRadius = 5.0
        
        updateNextButton(false)
    }
    
    private func setupButton(_ button: UIButton, title: String) {
        button.backgroundColor = UIColor.white.withAlphaComponent(0.24)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: Font.SegoeUILight, size: 20)
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
    
    /// isEnabled - will be true when a product or service is added
    private func updateNextButton(_ isEnabled: Bool) {
        if isEnabled {
            btnGotoStore.backgroundColor = .colorBlue5
            btnGotoStore.setTitleColor(.white, for: .normal)
            if #available(iOS 13.0, *) {
                btnGotoStore.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            btnGotoStore.setTitle("Go to my Store Page ", for: .normal)
            btnGotoStore.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            btnGotoStore.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            btnGotoStore.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            btnGotoStore.tintColor = .white
            
        } else {
            btnGotoStore.backgroundColor = UIColor.colorBlue5.withAlphaComponent(0.5)
            btnGotoStore.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .normal)
            btnGotoStore.setImage(nil, for: .normal)
            btnGotoStore.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            btnGotoStore.titleLabel?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            btnGotoStore.imageView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            btnGotoStore.setTitle("I'll Do it Later", for: .normal)
        }
    }
    
    @IBAction func didTapAddService(_ sender: Any) {
        let postServiceVC = PostServiceViewController.instance()
        postServiceVC.isPosting = false
        postServiceVC.view.frame.size.height = SCREEN_HEIGHT - 44
        postServiceVC.delegate = self
        
        let options: [SemiModalOption : Any] = [
            SemiModalOption.pushParentBack: false,
            SemiModalOption.parentScale: 1.0,
            SemiModalOption.animationDuration: 0.35]
        
        presentSemiViewController(postServiceVC, options: options)
    }
    
    @IBAction func didTapAddProduct(_ sender: Any) {
        let postProductVC = PostProductViewController.instance()
        postProductVC.isPosting = false
        postProductVC.view.frame.size.height = SCREEN_HEIGHT - 44
        postProductVC.delegate = self
        
        let options: [SemiModalOption : Any] = [
            SemiModalOption.pushParentBack: false,
            SemiModalOption.parentScale: 1.0,
            SemiModalOption.animationDuration: 0.35]
        
        presentSemiViewController(postProductVC, options: options)
    }
    
    @IBAction func didTapGotoStore(_ sender: Any) {
        guard let presentingViewController = self.presentingViewController,
              let parentPresentingViewController = presentingViewController.presentingViewController,
              let navigationController = parentPresentingViewController as? UINavigationController,
              let mainTabController = navigationController.viewControllers.first as? MainTabBarVC,
              let feedNavController = mainTabController.viewControllers?.first as? UINavigationController,
              let feedViewController = feedNavController.viewControllers.first else { return }
        
        var viewControllers = feedNavController.viewControllers
        viewControllers.removeAll()
        
        // keep the Feed page as is
        viewControllers.append(feedViewController)
        
        SlideMenuOptions.contentViewScale = 1.0
        SlideMenuOptions.leftViewWidth = SCREEN_WIDTH - 104
        // profile controller
        let profileVC = ProfileViewController.instance()
        profileVC.isBusiness = true
        profileVC.isBusinessUser = true
        
        // menu controller
        let menuVC = ProfileMenuViewController.instance()
        // uncomment this if the account is business user
        menuVC.isBusiness = true
        menuVC.isBusinessUser = true

        let slideController = ExSlideMenuController(mainViewController: profileVC, rightMenuViewController: menuVC)
        
        viewControllers.append(slideController)
        
        // Don't switch below two lines, it will look weird
        feedNavController.setViewControllers(viewControllers, animated: true)
        
        parentPresentingViewController.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension BusinessSetupCompletedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblProducts {
            return products.count
            
        } else {
            return services.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BusinessCompleteCell.reuseIdentifier, for: indexPath) as! BusinessCompleteCell
        
        // configure the cell
        if tableView == tblProducts {
            cell.configureCell(products[indexPath.row])
            
        } else {
            cell.configureCell(services[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BusinessCompleteCell.rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: - BusinessAddDelegate
extension BusinessSetupCompletedViewController: BusinessAddDelegate {
    
    func didAddNewProducts(_ items: [PostToPublishModel]) {
        if products.count == 0 && services.count == 0 {
            updateNextButton(true)
        }
        
        products.append(contentsOf: items)
        
        tblProducts.reloadData()
        
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
        }
    }
    
    func didAddNewService(_ item: PostToPublishModel) {
        if products.count == 0 && services.count == 0 {
            updateNextButton(true)
        }
        
        services.append(item)
        
        tblServices.reloadData()
        
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
        }
    }
}
