//
//  SearchViewController.swift
//  ATB
//
//  Created by YueXi on 3/31/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import BetterSegmentedControl
import NBBottomSheet

class SearchViewController: BaseViewController {
    
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var imvSearch: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var searchFieldContainer: UIView!
    @IBOutlet weak var searchField: NoBorderTextField!
    
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var segmentControl: BetterSegmentedControl!
    
    @IBOutlet weak var lblWhere: UILabel!
    @IBOutlet weak var lblGroup: UILabel!
    @IBOutlet weak var imvGroupDownArrow: UIImageView!
    
    private let searchAccessoryView: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60)
        button.backgroundColor = .colorBlue7
        button.setTitle("Go!", for: .normal)
        button.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 21)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapGo(_:)), for: .touchUpInside)
        return button
    }()
    
    var selectedGroup = "Beauty"
    
    var selectedSearchType = 0 // 0 - ATB Business, 1 - ATB Post

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        hideKeyboardWhenTapped()
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
        if SCREEN_HEIGHT <= 667 {
            headerViewHeight.constant = 200
        }
        
        headerView.addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 43)
        
        if #available(iOS 13.0, *) {
            imvSearch.image = UIImage(systemName: "magnifyingglass")
        } else {
            // Fallback on earlier versions
        }
        imvSearch.tintColor = .white
        
        lblTitle.text = "Looking for something?"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 21)
        lblTitle.textColor = .white
        
        searchFieldContainer.layer.cornerRadius = 5
        searchFieldContainer.layer.shadowColor = UIColor.lightGray.cgColor
        searchFieldContainer.layer.shadowOpacity = 0.4
        searchFieldContainer.layer.shadowRadius = 4
        searchFieldContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        searchField.layer.cornerRadius = 5
        searchField.backgroundColor = .white
        searchField.placeholder = "Search for..."
        searchField.font = UIFont(name: Font.SegoeUILight, size: 18)
        searchField.textColor = .colorGray1
        searchField.tintColor = .colorGray1
        searchField.inputPadding = 16
        searchField.returnKeyType = .go
        searchField.inputAccessoryView = searchAccessoryView
        searchField.autocorrectionType = .no
        searchField.delegate = self
        
        setupSegmentControl()
        
        lblWhere.text = "Where would you like to search?"
        lblWhere.font = UIFont(name: Font.SegoeUILight, size: 17)
        lblWhere.textColor = .colorGray2
        
        lblGroup.text = selectedGroup
        lblGroup.font = UIFont(name: Font.SegoeUILight, size: 22)
        lblGroup.textColor = .colorPrimary
        
        if #available(iOS 13.0, *) {
            imvGroupDownArrow.image = UIImage(systemName: "chevron.down")
        } else {
            // Fallback on earlier versions
        }
        imvGroupDownArrow.tintColor = .colorPrimary
    }
    
    private func setupSegmentControl() {
        segmentContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        segmentContainer.layer.shadowRadius = 3
        segmentContainer.layer.shadowColor = UIColor.gray.cgColor
        segmentContainer.layer.shadowOpacity = 0.4
        
        segmentControl.segments = LabelSegment.segments(withTitles:
                                                            ["ATB Business", "ATB Post"],
                                                        normalBackgroundColor: .colorGray17,
                                                        normalFont: UIFont(name: Font.SegoeUILight, size: 16),
                                                        normalTextColor: .colorGray2,
                                                        selectedBackgroundColor: .white,
                                                        selectedFont: UIFont(name: Font.SegoeUIBold, size: 16),
                                                        selectedTextColor: .colorPrimary)
        segmentControl.backgroundColor = .colorGray17
        segmentControl.cornerRadius = 5
        segmentControl.indicatorViewInset = 0
        segmentControl.panningDisabled = true
        segmentControl.animationDuration = 0.35
        segmentControl.animationSpringDamping = 0.85
        
        segmentControl.addTarget(self, action: #selector(didSelectSearchType(_:)), for: .valueChanged)
        segmentControl.setIndex(selectedSearchType, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !searchField.isFirstResponder {
            searchField.becomeFirstResponder()
        }
    }
    
    @objc private func didSelectSearchType(_ sender: BetterSegmentedControl) {
        selectedSearchType = sender.index
    }
    
    @objc private func didTapGo(_ sender: Any) {
        gotoSearchResult()
    }
    
    @IBAction func didTapSelectGroup(_ sender: Any) {
        let configuration = NBBottomSheetConfiguration()
        configuration.animationDuration = 0.35
        configuration.sheetSize = .fixed(60+480+8+56+8)
        configuration.backgroundViewColor = UIColor.black.withAlphaComponent(0.45)
        
        let sheetController = NBBottomSheetController(configuration: configuration)
        
        let toVC = SelectGroupViewController.instance()
        toVC.selected = selectedGroup
        toVC.delegate = self
        
        sheetController.present(toVC, on: self)
    }
    
    private func gotoSearchResult() {
        let toVC = SearchResultViewController.instance()
        
        toVC.selectedGroup = selectedGroup
        toVC.selectedSearchType = selectedSearchType
        toVC.searchFor = searchField.text!
        
        navigationController?.pushViewController(toVC, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        gotoSearchResult()
        
        return true
    }
}

// MARK: - SelectCategoryDelegate
extension SearchViewController: SelectGroupDelegate {
    
    func didSelectGroup(_ selected: String) {
        selectedGroup = selected
        
        lblGroup.text = selected
    }
}
