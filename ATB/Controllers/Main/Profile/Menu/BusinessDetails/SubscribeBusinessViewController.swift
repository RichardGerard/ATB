//
//  SubscribeBusinessViewController.swift
//  ATB
//
//  Created by mobdev on 2019/5/28.
//  Updated by YueXi on 1/12/21.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import CHIPageControl
import BraintreeDropIn
import Braintree

// MARK: - SubscriptionDelegate
protocol SubscriptionDelegate {
    
    func didCompleteSubscription()
    func didIncompleteSubscription()
}

class SubscribeBusinessViewController: BaseViewController {
    
    static let kStoryboardID = "SubscribeBusinessViewController"
    class func instance() -> SubscribeBusinessViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: SubscribeBusinessViewController.kStoryboardID) as? SubscribeBusinessViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var pageIndicator: CHIPageControlJalapeno!
    @IBOutlet weak var viewStepContent: UIView!
    
    var pageViewController: UIPageViewController!
    var stepIndex:Int = 0
    
    let pageImages = ["step1", "step2", "step3", "step4", "step5", "step7", "step8", "step9"]
    let pageTitles = [
        "Insurance & Qualification\nVerification.",
        "Deposit Scheme",
        "Featured Posts",
        "Unlimited Sales/Service Posts*",
        "Multi-Post Services and Items",
        "Preferential Delivery Rates",
        "Preferential Delivery\nSlots using ATB Direct",
        "Priority Admin Support"]
    let pageContents = [
        "(Gaining ATB approved business status)",
        "Covers your business against\ncancelled or no-show appointments",
        "All your posts will be highlighted and show the ATB approved logo",
        "Post your entire list of services or products and really promote your business",
        "Post all your services and items at the same time making it easier for users to shop",
        "Coming Soon",
        "Coming Soon",
        "Dedicated helpline and email support"]
    
    var delegate: SubscriptionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = viewBackground.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.viewBackground.addSubview(blurEffectView)
        
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        self.pageViewController.dataSource = self
        
        let startVC = viewControllerAtIndex(0) as StepContentViewController
        let viewControllers = NSArray(object: startVC)
        pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        pageViewController.view.frame = CGRect(x:0, y:0, width: viewStepContent.frame.width, height: viewStepContent.frame.height)
        
        self.addChild(self.pageViewController)
        self.viewStepContent.addSubview(pageViewController.view)
        self.pageViewController.didMove(toParent: self)
        self.pageViewController.delegate = self
    }
    
    private func viewControllerAtIndex(_ index: Int) -> StepContentViewController {
        let stepVC = StepContentViewController.instance()
        
        stepVC.pageIndex = index
        stepVC.backImg = pageImages[index]
        stepVC.strTitle = pageTitles[index]
        stepVC.strContent = pageContents[index]
        
        return stepVC
    }
    
    @IBAction func didTapSubscribe(_ sender: Any) {
        showIndicator()
        ATBBraintreeManager.shared.getBraintreeClientToken(g_myToken) { (result, message) in
            self.hideIndicator()

            guard result else {
                self.showErrorVC(msg: message)
                return }

            let clientToken = message
            self.showDropIn(clientTokenOrTokenizationKey: clientToken)
        }
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String) {
        let request =  BTDropInRequest()
        request.vaultManager = true

        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request) { (controller, result, error) in
            controller.dismiss(animated: true, completion: nil)
            
            guard error == nil,
                  let result = result else {
                // show error
                self.showErrorVC(msg: error?.localizedDescription ?? "Your subscription has been failed!")
                return
            }
            
            guard !result.isCancelled,
                  let paymentMethod = result.paymentMethod else {
                // Payment has been cancelled by the user
                return
            }
            
            let nonce = paymentMethod.nonce
            self.showAlert("Subscription Confirmation", message: "Would you like to subscribe for a business with this payment method?", positive: "Yes", positiveAction: { _ in
                switch result.paymentOptionType {
                case .payPal:
                    self.addSubscription(withPaymentMethod: "Paypal", nonce: nonce)
                    
                case .masterCard,
                     .AMEX,
                     .dinersClub,
                     .JCB,
                     .maestro,
                     .visa:
                    self.addSubscription(withPaymentMethod: "Card", nonce: nonce)
                    
                default: break
                }
                
            }, negative: "No", negativeAction: nil, preferredStyle: .actionSheet)
        }
        
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    func addSubscription(withPaymentMethod paymentMethod: String, nonce: String) {
        let params = [
            "token" : g_myToken,
            "customerId" : g_myInfo.bt_customer_id,
            "paymentMethodNonce" : nonce,
            "paymentMethod" : paymentMethod
        ]
        
        showIndicator()
        _ = ATB_Alamofire.POST(ADD_PP_SUB, parameters: params as [String : AnyObject]) { (result, response) in
            self.hideIndicator()
            
            guard result,
                  let subscriptionID = response.object(forKey: "msg") as? String,
                  !subscriptionID.isEmpty else {
                self.showErrorVC(msg: "Your subscription has been failed!")
                return }
            
            self.didCompleteSubscription()
        }
    }
    
    private func didCompleteSubscription() {
        g_myInfo.business_profile.paid = "1"
        
        self.dismiss(animated: true) {
            self.delegate?.didCompleteSubscription()
        }
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true) {
            self.delegate?.didIncompleteSubscription()
        }
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension SubscribeBusinessViewController : UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let stepVC = viewController as? StepContentViewController,
              let index = stepVC.pageIndex,
              index != NSNotFound,
              index != 0 else { return nil }
        
        return viewControllerAtIndex(index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let stepVC = viewController as? StepContentViewController,
              let index = stepVC.pageIndex,
              index != NSNotFound else { return nil }
        
        guard pageImages.count > index + 1 else { return nil }
        
        return viewControllerAtIndex(index + 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard finished,
              let viewControllers = pageViewController.viewControllers,
              let firstStepContentVC = viewControllers.first as? StepContentViewController,
              let pageIndex = firstStepContentVC.pageIndex else { return }
        
        setPageControllerProgress(index: pageIndex)
    }
    
    func setPageControllerProgress(index:Int) {
        stepIndex = index
        pageIndicator.set(progress: index, animated: true)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return pageImages.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

// MARK: - StepContentViewController
class StepContentViewController: BaseViewController {
    
    static let kStoryboardID = "StepContentViewController"
    class func instance() -> StepContentViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: StepContentViewController.kStoryboardID) as? StepContentViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    
    var pageIndex: Int! = 0
    var backImg: String! = ""
    var strTitle: String! = ""
    var strContent: String! = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        imgBackground.image = UIImage(named: backImg)
        lblTitle.text = strTitle
        lblContent.text = strContent
    }
}

