//
//  BusinessSignViewController.swift
//  ATB
//
//  Created by YueXi on 3/15/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import CHIPageControl

class BusinessSignViewController: UIViewController {
    
    static let kStoryboardID = "BusinessSignViewController"
    class func instance() -> BusinessSignViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: BusinessSignViewController.kStoryboardID) as? BusinessSignViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var pageIndicator: CHIPageControlJalapeno!
    @IBOutlet weak var stepContentView: UIView!
    
    var pageViewController: UIPageViewController!
    var stepIndex = 0
    
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
    
    // represents that the user gets to this page from profile
    var isFromProfile: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.addSubview(blurEffectView)
        
        pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        pageViewController.dataSource = self
        
        let startVC = viewControllerAtIndex(0) as StepContentViewController
        let viewControllers = NSArray(object: startVC)
        pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        pageViewController.view.frame = CGRect(x:0, y:0, width: stepContentView.frame.width, height: stepContentView.frame.height)
        
        self.addChild(pageViewController)
        stepContentView.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.delegate = self
    }
    
    private func viewControllerAtIndex(_ index: Int) -> StepContentViewController {
        let stepVC = StepContentViewController.instance()
        
        stepVC.pageIndex = index
        stepVC.backImg = pageImages[index]
        stepVC.strTitle = pageTitles[index]
        stepVC.strContent = pageContents[index]
        
        return stepVC
    }
    
    @IBAction func didTapSign(_ sender: Any) {
        let businessDetailsVC = BusinessDetailsViewController.instance()
        businessDetailsVC.isFromProfile = isFromProfile
        
        let nvc = UINavigationController(rootViewController: businessDetailsVC)
        nvc.isNavigationBarHidden =  true
        nvc.modalTransitionStyle = .crossDissolve
        nvc.modalPresentationStyle = .overFullScreen
        
        present(nvc, animated: true, completion: nil)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension BusinessSignViewController : UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
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
    
    func setPageControllerProgress(index: Int) {
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
