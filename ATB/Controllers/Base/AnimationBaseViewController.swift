//
//  AnimationBaseViewController.swift
//  ATB
//
//  Created by YueXi on 11/6/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import ARNTransitionAnimator

protocol ImageTransitionZoomable: class {
    
    func createTransitionImageView() -> UIImageView
    
    // Present, Push
    func presentationBeforeAction()

    func presentationAnimationAction(percentComplete: CGFloat)

    func presentationCancelAnimationAction()

    func presentationCompletionAction(didComplete: Bool)

    // Dismiss, Pop
    func dismissalBeforeAction()

    func dismissalAnimationAction(percentComplete: CGFloat)

    func dismissalCancelAnimationAction()

    func dismissalCompletionAction(didComplete: Bool)
}

class AnimationBaseViewController: UIViewController, ImageTransitionZoomable {
    
    func createTransitionImageView() -> UIImageView { return UIImageView() }
    
    func hideKeyboardWhenTapped() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
}

// MARK: ImageTransitionZoomable
extension AnimationBaseViewController {
    
    @objc func presentationBeforeAction() {}
    
    @objc func presentationAnimationAction(percentComplete: CGFloat) {}
    
    @objc func presentationCancelAnimationAction() {}
    
    @objc func presentationCompletionAction(didComplete: Bool) {}
    
    @objc func dismissalBeforeAction() {}
    
    @objc func dismissalAnimationAction(percentComplete: CGFloat) {}
    
    @objc func dismissalCancelAnimationAction() {}
    
    @objc func dismissalCompletionAction(didComplete: Bool) {}
}

// MARK: ImageZoomAnimation
final class ImageZoomAnimation<T: UIViewController> : TransitionAnimatable where T : ImageTransitionZoomable {
    
    fileprivate weak var rootVC: T!
    fileprivate weak var modalVC: T!
    fileprivate weak var rootNavigation: UINavigationController?
    
    var completion: ((Bool) -> Void)?
    
    fileprivate var sourceImageView: UIImageView?
    fileprivate var destinationImageView: UIImageView?
    
    fileprivate var sourceFrame: CGRect = CGRect.zero
    fileprivate var destFrame: CGRect = CGRect.zero
    
    deinit {
        print("deinit ImageZoomAnimation")
    }
    
    init(rootVC: T, modalVC: T, rootNavigation: UINavigationController? = nil) {
        self.rootVC = rootVC
        self.modalVC = modalVC
        self.rootNavigation = rootNavigation
    }
    
    func prepareContainer(_ transitionType: TransitionType, containerView: UIView, from fromVC: UIViewController, to toVC: UIViewController) {
        if transitionType.isPresenting {
            containerView.addSubview(toVC.view)
        } else {
            if let v = self.rootNavigation?.view {
                containerView.addSubview(v)
            } else {
                containerView.addSubview(toVC.view)
            }
            containerView.addSubview(fromVC.view)
        }
        fromVC.view.setNeedsLayout()
        fromVC.view.layoutIfNeeded()
        toVC.view.setNeedsLayout()
        toVC.view.layoutIfNeeded()
    }
    
    func willAnimation(_ transitionType: TransitionType, containerView: UIView) {
        if transitionType.isPresenting {
            self.sourceImageView = rootVC.createTransitionImageView()
            self.destinationImageView = modalVC.createTransitionImageView()
            
            containerView.addSubview(sourceImageView!)
            
            rootVC.presentationBeforeAction()
            modalVC.presentationBeforeAction()
            
            modalVC.view.alpha = 0.0
        } else {
            self.sourceImageView = modalVC.createTransitionImageView()
            self.destinationImageView = rootVC.createTransitionImageView()
            
            self.sourceFrame = self.sourceImageView!.frame
            self.destFrame = self.destinationImageView!.frame
            
            containerView.addSubview(sourceImageView!)
            
            rootVC.dismissalBeforeAction()
            modalVC.dismissalBeforeAction()
        }
    }
    
    func updateAnimation(_ transitionType: TransitionType, percentComplete: CGFloat) {
        print(percentComplete)
        if transitionType.isPresenting {
            self.sourceImageView?.frame = self.destinationImageView!.frame
            
            self.modalVC.view.alpha = 1.0 * percentComplete
            
            self.rootVC.presentationAnimationAction(percentComplete: percentComplete)
            self.modalVC.presentationAnimationAction(percentComplete: percentComplete)
        } else {
            let p = 1.0 - (1.0 * percentComplete)
            
            let frame = CGRect(
                x: destFrame.origin.x - (destFrame.origin.x - sourceFrame.origin.x) * p,
                y: destFrame.origin.y - (destFrame.origin.y - sourceFrame.origin.y) * p,
                width: destFrame.size.width + (sourceFrame.size.width - destFrame.size.width) * p,
                height: destFrame.size.height + (sourceFrame.size.height - destFrame.size.height) * p
            )
            self.sourceImageView!.frame = frame
            self.modalVC.view.alpha = p
            
            self.rootVC.dismissalAnimationAction(percentComplete: percentComplete)
            self.modalVC.dismissalAnimationAction(percentComplete: percentComplete)
        }
    }
    
    func finishAnimation(_ transitionType: TransitionType, didComplete: Bool) {
        self.sourceImageView?.removeFromSuperview()
        self.destinationImageView?.removeFromSuperview()
        
        if transitionType.isPresenting {
            self.rootVC.presentationCompletionAction(didComplete: didComplete)
            self.modalVC.presentationCompletionAction(didComplete: didComplete)
        } else {
            self.rootVC.dismissalCompletionAction(didComplete: didComplete)
            self.modalVC.dismissalCompletionAction(didComplete: didComplete)
        }
        self.completion?(didComplete)
    }
}

// MARK: ImageZoomAnimation
extension ImageZoomAnimation {
    
    func sourceVC() -> UIViewController { return self.rootVC }
    
    func destVC() -> UIViewController { return self.modalVC }
}
