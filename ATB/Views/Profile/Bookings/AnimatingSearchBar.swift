//
//  AnimatingSearchBar.swift
//  ATB
//
//  Created by YueXi on 11/5/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

/**
 *  The different states for an AnimatingSearchBarState.
 */

public enum AnimatingSearchBarState: Int {
    /**
     *  The default or normal state. The search field is hidden.
     */
    
    case normal
    
    /**
     *  The state where the search field is visible.
     */
    
    case searchBarVisible
    
    /**
     *  The state where the search field is visible and there is text entered.
     */
    
    case searchBarHasContent
    
    /**
     *  The search bar is transitioning between states.
     */
    
    case transitioning
}

protocol AnimatingSearchBarDelegate {
    /**
     *  The delegate is asked to provide the destination frame for the search bar when the search bar is transitioning to the visible state.
     *
     *  @param searchBar The search bar that will begin transitioning.
     *
     *  @return The frame in the coordinate system of the search bar's superview.
     */
    
    func destinationFrameForSearchBar(_ searchBar: AnimatingSearchBar) -> CGRect
    
    /**
     *  The delegate is informed about the imminent state transitioning of the status bar.
     *
     *  @param searchBar        The search bar that will begin transitioning.
     *  @param destinationState The state that the bar will be in once transitioning completes. The current state of the search bar can be queried and will return the state before transitioning.
     */
    
    func searchBar(_ searchBar: AnimatingSearchBar, willStartTransitioningToState destinationState: AnimatingSearchBarState)
    
    /**
     *  The delegate is informed about the state transitioning of the status bar that has just occured.
     *
     *  @param searchBar        The search bar that went through state transitioning.
     *  @param destinationState The state that the bar was in before transitioning started. The current state of the search bar can be queried and will return the state after transitioning.
     */
    
    func searchBar(_ searchBar: AnimatingSearchBar, didEndTransitioningFromState previousState: AnimatingSearchBarState)
    
    /**
     *  The delegate is informed that the search bar's return key was pressed. This should be used to start querries.
     *
     *  @param searchBar        The search bar whose return key was pressed.
     */
    
    func searchBarDidTapReturn(_ searchBar: AnimatingSearchBar)
    
    /**
     *  The delegate is informed that the search bar's text has changed.
     *
     *  Important: If the searchField property is explicitly supplied with a delegate property this method will not be called.
     *
     *  @param searchBar        The search bar whose text did change.
     */
    
    func searchBarTextDidChange(_ searchBar: AnimatingSearchBar)
}


struct AnimatingSearchBarConfiguration {
    
    static let inset: CGFloat = 14.0
    static let iconSize: CGFloat = 22.0
    static let animationStepDuration: TimeInterval = 0.25
}

// MARK: SearchTextField
class SearchTextField: UITextField {
    
    var leftPadding: CGFloat = 0.0
    var rightPadding: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        
        return textRect
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.rightViewRect(forBounds: bounds)
        textRect.origin.x -= rightPadding
        
        return textRect
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size.width = 3
        
        return rect
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let padding = bounds.inset(by: UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding))
        return padding
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let padding = bounds.inset(by: UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding))
        return padding
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let padding = bounds.inset(by: UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding))
        return padding
    }
}

/**
 *  An animating search bar.
 */
class AnimatingSearchBar: UIView {

    /**
     *  The current state of the search bar.
     */
    
    private var state: AnimatingSearchBarState = .normal
    
    /**
     *  The (optional) delegate is responsible for providing values necessary for state change animations of the search bar. @see DAOSearchBarDelegate.
     */
    
    public var delegate: AnimatingSearchBarDelegate?

    /**
     *  The frame view of the search bar. Visible only when search mode is active.
     */
    
    private let searchFrame: UIView = UIView(frame: .zero)
    
    /**
     *  The text field used for entering search queries. Visible only when search is active.
     */
    
    public let searchField: SearchTextField = SearchTextField(frame: .zero)
    
    /**
     *  The image view containing the search magnifying glass icon  in white. Visible when search is not active.
     */
    private let iconImageViewOff: UIImageView = UIImageView(frame: .zero)
    
    /**
     *  The image view containing the search magnifying glass icon icon in black. Visible when search is active.
     */
    private let iconImageViewOn: UIImageView = UIImageView(frame: .zero)
    
    /**
     *  A gesture recognizer responsible for closing the keyboard once tapped on.
     *
     *    Added to the window's root view controller view and set to allow touches to propagate to that view.
     */
    
    let keyboardDismissGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    /**
    *  The frame of the search bar before a transition started. Only set if delegate is not nil.
    */
    private var originalFrame: CGRect = .zero
    
    /// The color of the icon image when search bar is not show
    var searchOffColor = UIColor.white {
        didSet {
            iconImageViewOff.tintColor = searchOffColor
        }
    }
    
    /// the color of the icon images and the text field text when search bar is show
    var searchOnColor = UIColor.black {
        didSet {
            iconImageViewOn.tintColor = searchOnColor
            
            searchField.textColor = searchOnColor
            searchField.tintColor = searchOnColor
        }
    }
    
    /// The color of the search bar background when search bar is show
    var searchBarOnColor = UIColor.white
    
    /// The color of the search bar background when search bar is not show
    var searchBarOffColor = UIColor.clear {
        didSet {
            if state == .normal {
                searchFrame.layer.backgroundColor = searchBarOffColor.cgColor
            }
        }
    }
    
    /// The color of the search bar border when search bar is not show
    var searchBarOnBorderColor = UIColor.white
    
    /// The color of the search bar border when search bar is show
    var searchBarOffBorderColor = UIColor.clear {
        didSet {
            if state == .normal {
                searchFrame.layer.borderColor = searchBarOffColor.cgColor
            }
        }
    }
    
    var searchBarFont: UIFont? = UIFont.systemFont(ofSize: 16) {
        didSet {
            searchField.font = searchBarFont
        }
    }
    
    var searchBarPlaceholder: String = "" {
        didSet {
            searchField.placeholder = searchBarPlaceholder
        }
    }
    
    // MARKK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isOpaque = false
        self.backgroundColor = .clear
        
        searchFrame.frame = self.bounds
        searchFrame.isOpaque = false
        searchFrame.backgroundColor = UIColor.clear
        searchFrame.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        searchFrame.layer.masksToBounds = true
        searchFrame.layer.cornerRadius = self.bounds.height / 2
        searchFrame.layer.borderWidth = 1.0
        searchFrame.layer.borderColor = searchBarOffBorderColor.cgColor
        searchFrame.contentMode = .redraw
        
        addSubview(searchFrame)
        
        searchField.frame = CGRect(x: AnimatingSearchBarConfiguration.inset, y: 6.0, width: self.bounds.width - (2 * AnimatingSearchBarConfiguration.inset) - AnimatingSearchBarConfiguration.iconSize, height: self.bounds.height - 12.0)
        searchField.leftPadding = AnimatingSearchBarConfiguration.inset * 0.5
        searchField.borderStyle = .none
        searchField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        searchField.font = searchBarFont
        searchField.textColor = searchOnColor
        searchField.tintColor = searchOnColor
        searchField.alpha = 0.0
        searchField.delegate = self
        
        searchFrame.addSubview(searchField)
        
        let iconContainerView: UIView = UIView(frame: CGRect(x: self.bounds.width - AnimatingSearchBarConfiguration.inset - AnimatingSearchBarConfiguration.iconSize, y: (self.bounds.height - AnimatingSearchBarConfiguration.iconSize)/2, width: AnimatingSearchBarConfiguration.iconSize, height: AnimatingSearchBarConfiguration.iconSize))
        iconContainerView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
        searchFrame.addSubview(iconContainerView)
        
        iconImageViewOn.frame = iconContainerView.bounds
        iconImageViewOn.alpha = 0.0
        if #available(iOS 13.0, *) {
            iconImageViewOn.image = UIImage(systemName: "magnifyingglass")
        } else {
            // Fallback on earlier versions
        }
        iconImageViewOn.tintColor = searchOnColor
        
        iconContainerView.addSubview(iconImageViewOn)
        
        iconImageViewOff.frame = CGRect(x: self.bounds.width - AnimatingSearchBarConfiguration.inset - AnimatingSearchBarConfiguration.iconSize, y: (self.bounds.height - AnimatingSearchBarConfiguration.iconSize)/2, width: AnimatingSearchBarConfiguration.iconSize, height: AnimatingSearchBarConfiguration.iconSize)
        iconImageViewOff.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
        iconImageViewOff.alpha = 1.0
        if #available(iOS 13.0, *) {
            iconImageViewOff.image = UIImage(systemName: "magnifyingglass")
        } else {
            // Fallback on earlier versions
        }
        iconImageViewOff.tintColor = searchOffColor
        
        searchFrame.addSubview(iconImageViewOff)
        
        let tapableView: UIView = UIView(frame: CGRect(x: self.bounds.width - (2 * AnimatingSearchBarConfiguration.inset) - AnimatingSearchBarConfiguration.iconSize, y: 0.0, width: (2 * AnimatingSearchBarConfiguration.inset) + AnimatingSearchBarConfiguration.iconSize, height: self.bounds.height))
        tapableView.autoresizingMask = [.flexibleLeftMargin, .flexibleHeight]
        tapableView.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(changeStateIfPossible(_:))))
        
        keyboardDismissGestureRecognizer.addTarget(self, action: #selector(dismissKeyboard(_:)))
        keyboardDismissGestureRecognizer.cancelsTouchesInView = false
        keyboardDismissGestureRecognizer.delegate = self
        
        searchFrame.addSubview(tapableView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange(_:)), name: UITextField.textDidChangeNotification, object: self.searchField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextField.textDidChangeNotification, object: self.searchField)
    }
    
    func showSearchBar(_ sender: Any?) {
        if state == .normal {
            delegate?.searchBar(self, willStartTransitioningToState: .searchBarVisible)
            
            state = .transitioning
            
            searchField.text = nil
            
            UIView.animate(withDuration: 0.25, animations: {
                self.searchFrame.layer.borderColor = self.searchBarOnBorderColor.cgColor
                
                if let delegate = self.delegate {
                    self.originalFrame = self.frame
                    
                    self.frame = delegate.destinationFrameForSearchBar(self)
                }
                
            }, completion: { (finished: Bool) in
                self.searchField.becomeFirstResponder()
                
                UIView.animate(withDuration: AnimatingSearchBarConfiguration.animationStepDuration * 2, animations: {
                    self.searchFrame.layer.backgroundColor  = self.searchBarOnColor.cgColor
                    
                    self.iconImageViewOff.alpha = 0.0
                    self.iconImageViewOn.alpha = 1.0
                    
                    self.searchField.alpha = 1.0
                    
                }, completion: { (finished: Bool) in
                    self.state = .searchBarVisible
                    
                    if let delegate = self.delegate {
                        delegate.searchBar(self, didEndTransitioningFromState: .normal)
                    }
                })
            })
        }
    }
    
    func hideSearchBar(_ sender: AnyObject?) {
        if state == .searchBarVisible || state == .searchBarHasContent {
            self.window?.endEditing(true)
            
            if let delegate = self.delegate {
                delegate.searchBar(self, willStartTransitioningToState: .normal)
            }
            
            searchField.text = nil
            
            state = .transitioning
            
            UIView.animate(withDuration: AnimatingSearchBarConfiguration.animationStepDuration, animations: {
                
                if self.delegate != nil {
                    self.frame = self.originalFrame
                }
                
                self.searchFrame.layer.backgroundColor = self.searchBarOffColor.cgColor
                self.iconImageViewOff.alpha = 1.0
                self.iconImageViewOff.alpha = 0.0
                self.searchField.alpha = 0.0
                
            }, completion: { (finished: Bool) in
                
                UIView.animate(withDuration: AnimatingSearchBarConfiguration.animationStepDuration * 2, animations: {
                    self.searchFrame.layer.borderColor = self.searchBarOffBorderColor.cgColor
                    
                }, completion: { (finished: Bool) in
                    
//                    self.searchImageCircle.frame = CGRect(x: 0.0, y: 0.0, width: 18.0, height: 18.0)
//                    self.searchImageCrossLeft.frame = CGRect(x: 14.0, y: 14.0, width: 8.0, height: 8.0)
//                    self.searchImageCircle.alpha = 0.0
//                    self.searchImageCrossLeft.alpha = 0.0
//                    self.searchImageCrossRight.alpha = 0.0
                    
                    self.state = .normal;
                    
                    if let delegate = self.delegate {
                        delegate.searchBar(self, didEndTransitioningFromState: .searchBarVisible)
                    }
                })
            })
        }
    }
}

// MARK: Animation
extension AnimatingSearchBar {
    
    @objc func changeStateIfPossible(_ gestureRecognizer: UITapGestureRecognizer) {
        switch state {
        case .normal:
            showSearchBar(gestureRecognizer)
            
        case .searchBarVisible:
            hideSearchBar(gestureRecognizer)
            
        case .searchBarHasContent:
            searchField.text = nil
            textDidChange(nil)
            
        default:
            break
        }
    }
}

// MARK: Keyboard Handlers
extension AnimatingSearchBar {
    
    @objc func keyboardWillShow(_ notification: Notification?) {
        if searchField.isFirstResponder {
            self.window?.rootViewController?.view.addGestureRecognizer(self.keyboardDismissGestureRecognizer)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification?) {
        if searchField.isFirstResponder {
            self.window?.rootViewController?.view.addGestureRecognizer(self.keyboardDismissGestureRecognizer)
        }
    }
    
    @objc func dismissKeyboard(_ gestureRecognizer: UITapGestureRecognizer) {
        if searchField.isFirstResponder {
            self.window?.endEditing(true)
            
            if state == .searchBarVisible && searchField.text!.count == 0 {
                hideSearchBar(nil)
            }
        }
    }
}

// MARK: UITextFieldDelegate
extension AnimatingSearchBar: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.searchBarDidTapReturn(self)
        
        return true
    }
    
    @objc func textDidChange(_ notification: Notification?) {
        let hasText: Bool = self.searchField.text!.count != 0
        
        if hasText {
            if state == .searchBarVisible {
                
                state = .transitioning
                
//                self.searchImageViewOn.alpha = 0.0
//                self.searchImageCircle.alpha = 1.0
//                self.searchImageCrossLeft.alpha = 1.0
                
                UIView.animate(withDuration: AnimatingSearchBarConfiguration.animationStepDuration, animations: {
                    
//                    self.searchImageCircle.frame = CGRect(x: 2.0, y: 2.0, width: 18.0, height: 18.0)
//                    self.searchImageCrossLeft.frame = CGRect(x: 7.0, y: 7.0, width: 8.0, height: 8.0)
                    
                }, completion: { (finished: Bool) in
                    
                    UIView.animate(withDuration: AnimatingSearchBarConfiguration.animationStepDuration, animations: {
                        
//                        self.searchImageCrossRight.alpha = 1.0
                        
                    }, completion: { (finished: Bool) in
                        
                        self.state = .searchBarHasContent
                    })
                })
            }
            
        } else {
            if state == .searchBarHasContent {
                
                state = .transitioning;
                
                UIView.animate(withDuration: AnimatingSearchBarConfiguration.animationStepDuration, animations: {
                    
//                    self.searchImageCrossRight.alpha = 0.0
                    
                }, completion: { (finished: Bool) in
                    
                    UIView.animate(withDuration: AnimatingSearchBarConfiguration.animationStepDuration, animations: {
                        
//                        self.searchImageCircle.frame = CGRect(x: 0.0, y: 0.0, width: 18.0, height: 18.0)
//                        self.searchImageCrossLeft.frame = CGRect(x: 14.0, y: 14.0, width: 8.0, height: 8.0)
                        
                    }, completion: { (finished: Bool) in
                        
//                        self.searchImageViewOn.alpha = 1.0
//                        self.searchImageCircle.alpha = 0.0
//                        self.searchImageCrossLeft.alpha = 0.0
                        
                        self.state = .searchBarVisible
                    })
                })
            }
        }
        
        if let delegate = self.delegate {
            delegate.searchBarTextDidChange(self)
        }
    }
}

// MARK: UIGestureRecognizerDelegate
extension AnimatingSearchBar: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var retVal: Bool = true
        
        if self.bounds.contains(touch.location(in: self)) {
            retVal = false
        }
        
        return retVal
    }
}
