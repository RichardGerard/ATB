//
//  InputBarCollectionViewController.swift
//  ATB
//
//  Created by YueXi on 4/19/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import InputBarAccessoryView

class InputBarViewController: UIViewController {

    /// The `MessagesCollectionView` managed by the messages view controller object.
    open var commentCollectionView = CommentCollectionView()

    /// The `InputBarAccessoryView` used as the `inputAccessoryView` in the view controller.
    open lazy var inputBar = InputBarAccessoryView()

    /// A Boolean value that determines whether the `MessagesCollectionView` scrolls to the
    /// last item whenever the `InputTextView` begins editing.
    ///
    /// The default value of this property is `false`.
    /// NOTE: This is related to `scrollToLastItem` whereas the below flag is related to `scrollToBottom` - check each function for differences
    open var scrollsToLastItemOnKeyboardBeginsEditing: Bool = false

    /// A Boolean value that determines whether the `MessagesCollectionView` scrolls to the
    /// bottom whenever the `InputTextView` begins editing.
    ///
    /// The default value of this property is `false`.
    /// NOTE: This is related to `scrollToBottom` whereas the above flag is related to `scrollToLastItem` - check each function for differences
    open var scrollsToBottomOnKeyboardBeginsEditing: Bool = false
    
    /// A Boolean value that determines whether the `MessagesCollectionView`
    /// maintains it's current position when the height of the `MessageInputBar` changes.
    ///
    /// The default value of this property is `false`.
    open var maintainPositionOnKeyboardFrameChanged: Bool = false

    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open override var inputAccessoryView: UIView? {
        return inputBar
    }

    open override var shouldAutorotate: Bool {
        return false
    }

    /// A CGFloat value that adds to (or, if negative, subtracts from) the automatically
    /// computed value of `messagesCollectionView.contentInset.bottom`. Meant to be used
    /// as a measure of last resort when the built-in algorithm does not produce the right
    /// value for your app. Please let us know when you end up having to use this property.
    open var additionalBottomInset: CGFloat = 0 {
        didSet {
            let delta = additionalBottomInset - oldValue
            commentCollectionViewBottomInset += delta
        }
    }

    public var selectedIndexPath: IndexPath?

    private var isFirstLayout: Bool = true
    
    internal var isCommentControllerBeingDismissed: Bool = false

    internal var commentCollectionViewBottomInset: CGFloat = 0 {
        didSet {
            commentCollectionView.contentInset.bottom = commentCollectionViewBottomInset
            commentCollectionView.scrollIndicatorInsets.bottom = commentCollectionViewBottomInset
        }
    }

    // MARK: - View Life Cycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        setupSubviews()
        setupConstraints()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isCommentControllerBeingDismissed = false
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isCommentControllerBeingDismissed = true
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isCommentControllerBeingDismissed = false
    }
    
    open override func viewDidLayoutSubviews() {
        // Hack to prevent animation of the contentInset after viewDidAppear
        if isFirstLayout {
            defer { isFirstLayout = false }
            addKeyboardObservers()
            commentCollectionViewBottomInset = requiredInitialScrollViewBottomInset()
        }
        adjustScrollViewTopInset()
    }

    open override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
        }
        commentCollectionViewBottomInset = requiredInitialScrollViewBottomInset()
    }

    // MARK: - Initializers

    deinit {
        removeKeyboardObservers()
    }

    // MARK: - Methods [Private]

    private func setupDefaults() {
        extendedLayoutIncludesOpaqueBars = true
        //view.backgroundColor = .backgroundColor
        view.backgroundColor = .white
        
        commentCollectionView.contentInsetAdjustmentBehavior = .never
        commentCollectionView.keyboardDismissMode = .interactive
        commentCollectionView.alwaysBounceVertical = true
        commentCollectionView.backgroundColor = .backgroundColor
    }

    private func setupSubviews() {
        view.addSubview(commentCollectionView)
    }

    private func setupConstraints() {
        commentCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let top = commentCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: topLayoutGuide.length)
        let bottom = commentCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        if #available(iOS 11.0, *) {
            let leading = commentCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
            let trailing = commentCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            NSLayoutConstraint.activate([top, bottom, trailing, leading])
        } else {
            let leading = commentCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            let trailing = commentCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            NSLayoutConstraint.activate([top, bottom, trailing, leading])
        }
    }
}

internal extension InputBarViewController {

    // MARK: - Register / Unregister Observers
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(InputBarViewController.handleKeyboardDidChangeState(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InputBarViewController.handleTextViewDidBeginEditing(_:)), name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InputBarViewController.adjustScrollViewTopInset), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    // MARK: - Notification Handlers

    @objc
    private func handleTextViewDidBeginEditing(_ notification: Notification) {
        if scrollsToLastItemOnKeyboardBeginsEditing || scrollsToBottomOnKeyboardBeginsEditing {
            guard let inputTextView = notification.object as? InputTextView,
                inputTextView === inputBar.inputTextView else { return }

            if scrollsToLastItemOnKeyboardBeginsEditing {
                commentCollectionView.scrollToLastItem()
                
            } else {
                commentCollectionView.scrollToBottom(animated: true)
            }
        }
    }

    @objc
    private func handleKeyboardDidChangeState(_ notification: Notification) {
        guard !isCommentControllerBeingDismissed else { return }

        guard let keyboardStartFrameInScreenCoords = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect else { return }
        guard !keyboardStartFrameInScreenCoords.isEmpty || UIDevice.current.userInterfaceIdiom != .pad else {
            // WORKAROUND for what seems to be a bug in iPad's keyboard handling in iOS 11: we receive an extra spurious frame change
            // notification when undocking the keyboard, with a zero starting frame and an incorrect end frame. The workaround is to
            // ignore this notification.
            return
        }

        guard self.presentedViewController == nil else {
            // This is important to skip notifications from child modal controllers in iOS >= 13.0
            return
        }

        // Note that the check above does not exclude all notifications from an undocked keyboard, only the weird ones.
        //
        // We've tried following Apple's recommended approach of tracking UIKeyboardWillShow / UIKeyboardDidHide and ignoring frame
        // change notifications while the keyboard is hidden or undocked (undocked keyboard is considered hidden by those events).
        // Unfortunately, we do care about the difference between hidden and undocked, because we have an input bar which is at the
        // bottom when the keyboard is hidden, and is tied to the keyboard when it's undocked.
        //
        // If we follow what Apple recommends and ignore notifications while the keyboard is hidden/undocked, we get an extra inset
        // at the bottom when the undocked keyboard is visible (the inset that tries to compensate for the missing input bar).
        // (Alternatives like setting newBottomInset to 0 or to the height of the input bar don't work either.)
        //
        // We could make it work by adding extra checks for the state of the keyboard and compensating accordingly, but it seems easier
        // to simply check whether the current keyboard frame, whatever it is (even when undocked), covers the bottom of the collection
        // view.

        guard let keyboardEndFrameInScreenCoords = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardEndFrame = view.convert(keyboardEndFrameInScreenCoords, from: view.window)

        let newBottomInset = requiredScrollViewBottomInset(forKeyboardFrame: keyboardEndFrame)
        let differenceOfBottomInset = newBottomInset - commentCollectionViewBottomInset

        if maintainPositionOnKeyboardFrameChanged && differenceOfBottomInset != 0 {
            let contentOffset = CGPoint(x: commentCollectionView.contentOffset.x, y: commentCollectionView.contentOffset.y + differenceOfBottomInset)
            commentCollectionView.setContentOffset(contentOffset, animated: false)
        }

        commentCollectionViewBottomInset = newBottomInset
    }

    // MARK: - Inset Computation

    @objc
    func adjustScrollViewTopInset() {
        if #available(iOS 11.0, *) {
            // No need to add to the top contentInset
        } else {
            let navigationBarInset = navigationController?.navigationBar.frame.height ?? 0
            let statusBarInset: CGFloat = UIApplication.shared.isStatusBarHidden ? 0 : 20
            let topInset = navigationBarInset + statusBarInset
            commentCollectionView.contentInset.top = topInset
            commentCollectionView.scrollIndicatorInsets.top = topInset
        }
    }

    private func requiredScrollViewBottomInset(forKeyboardFrame keyboardFrame: CGRect) -> CGFloat {
        // we only need to adjust for the part of the keyboard that covers (i.e. intersects) our collection view;
        // see https://developer.apple.com/videos/play/wwdc2017/242/ for more details
        let intersection = commentCollectionView.frame.intersection(keyboardFrame)

        if intersection.isNull || (commentCollectionView.frame.maxY - intersection.maxY) > 0.001 {
            // The keyboard is hidden, is a hardware one, or is undocked and does not cover the bottom of the collection view.
            // Note: intersection.maxY may be less than messagesCollectionView.frame.maxY when dealing with undocked keyboards.
            return max(0, additionalBottomInset - automaticallyAddedBottomInset)
        } else {
            return max(0, intersection.height + additionalBottomInset - automaticallyAddedBottomInset)
        }
    }

    func requiredInitialScrollViewBottomInset() -> CGFloat {
        let inputAccessoryViewHeight = inputAccessoryView?.frame.height ?? 0
        return max(0, inputAccessoryViewHeight + additionalBottomInset - automaticallyAddedBottomInset)
    }

    /// iOS 11's UIScrollView can automatically add safe area insets to its contentInset,
    /// which needs to be accounted for when setting the contentInset based on screen coordinates.
    ///
    /// - Returns: The distance automatically added to contentInset.bottom, if any.
    private var automaticallyAddedBottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            return commentCollectionView.adjustedContentInset.bottom - commentCollectionView.contentInset.bottom
        } else {
            return 0
        }
    }
}

class CommentCollectionView: UICollectionView {
    
    // MARK: - Initializers
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public convenience init() {
        self.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())        
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    // NOTE: It's possible for small content size this wouldn't work - https://github.com/MessageKit/MessageKit/issues/725
    public func scrollToLastItem(at pos: UICollectionView.ScrollPosition = .bottom, animated: Bool = true) {
        guard numberOfSections > 0 else { return }

        let lastSection = numberOfSections - 1
        let lastItemIndex = numberOfItems(inSection: lastSection) - 1

        guard lastItemIndex >= 0 else { return }

        let indexPath = IndexPath(row: lastItemIndex, section: lastSection)
        scrollToItem(at: indexPath, at: pos, animated: animated)
    }

    // NOTE: This method seems to cause crash in certain cases - https://github.com/MessageKit/MessageKit/issues/725
    // Could try using `scrollToLastItem` above
    public func scrollToBottom(animated: Bool = false) {
        performBatchUpdates(nil) { [weak self] _ in
            guard let self = self else { return }
            let collectionViewContentHeight = self.collectionViewLayout.collectionViewContentSize.height
            self.scrollRectToVisible(CGRect(x: 0.0, y: collectionViewContentHeight - 1.0, width: 1.0, height: 1.0), animated: animated)
        }
    }

    public func reloadDataAndKeepOffset() {
        // stop scrolling
        setContentOffset(contentOffset, animated: false)

        // calculate the offset and reloadData
        let beforeContentSize = contentSize
        reloadData()
        layoutIfNeeded()
        let afterContentSize = contentSize

        // reset the contentOffset after data is updated
        let newOffset = CGPoint(
            x: contentOffset.x + (afterContentSize.width - beforeContentSize.width),
            y: contentOffset.y + (afterContentSize.height - beforeContentSize.height))
        setContentOffset(newOffset, animated: false)
    }
}
