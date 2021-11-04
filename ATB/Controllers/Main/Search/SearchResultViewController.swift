//
//  SearchResultViewController.swift
//  ATB
//
//  Created by YueXi on 3/31/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class SearchResultViewController: BaseViewController {
    
    static let kStoryboardID = "SearchResultViewController"
    class func instance() -> SearchResultViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: SearchResultViewController.kStoryboardID) as? SearchResultViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var segmentControl: BetterSegmentedControl!
    
    @IBOutlet weak var resultsContainer: UIView!
    @IBOutlet weak var lblResultsFor: UILabel!
    @IBOutlet weak var lblResultsNumber: UILabel!
    
    @IBOutlet weak var imvClose: UIImageView!
    
    @IBOutlet weak var businessResultsContainer: UIView!
    @IBOutlet weak var postResultsContainer: UIView!
    
    var selectedSearchType = 0
    
    var selectedGroup = "Beauty"
    var searchFor = ""

    private var postResults = [PostModel]()
    
    private var businessPins = [UserModel]()
    private var businessResults = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        selectedSearchType == 0 ? searchBusiness() : searchPosts()
    }
    
    private func setupViews() {
        backgroundView.addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 43)
                
        setupSegmentControl()
        
        resultsContainer.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        resultsContainer.layer.cornerRadius = 16
//        resultsContainer.layer.masksToBounds = true
        
        resultsContainer.backgroundColor = .colorGray14
        
        lblResultsFor.font = UIFont(name: Font.SegoeUISemibold, size: 16)
        lblResultsFor.textColor = .colorGray1
        
        let resultsText = "Results for #" + searchFor
        let attributedText = NSMutableAttributedString(string: resultsText)
        attributedText.addAttributes(
            [.foregroundColor: UIColor.colorPrimary,
             .font: UIFont(name: Font.SegoeUILight, size: 16)!],
            range: (resultsText as NSString).range(of: "#" + searchFor))
        lblResultsFor.attributedText = attributedText
        
        lblResultsNumber.text = ""
        lblResultsNumber.font = UIFont(name: Font.SegoeUILight, size: 14)
        lblResultsNumber.textColor = .colorGray2
        
        if #available(iOS 13.0, *) {
            imvClose.image = UIImage(systemName: "xmark.circle")
        } else {
            // Fallback on earlier versions
        }
        imvClose.tintColor = .colorGray3
    }
    
    private func setupSegmentControl() {
        segmentContainer.layer.shadowOffset = CGSize(width: 0, height: 1)
        segmentContainer.layer.shadowRadius = 2
        segmentContainer.layer.shadowColor = UIColor.gray.cgColor
        segmentContainer.layer.shadowOpacity = 0.4
        
        segmentControl.segments = LabelSegment.segments(withTitles:
                                                            ["ATB Business", "ATB Post"],
                                                        normalBackgroundColor: .colorBlue17,
                                                        normalFont: UIFont(name: Font.SegoeUILight, size: 16),
                                                        normalTextColor: .white,
                                                        selectedBackgroundColor: .white,
                                                        selectedFont: UIFont(name: Font.SegoeUIBold, size: 16),
                                                        selectedTextColor: .colorPrimary)
        segmentControl.backgroundColor = .colorBlue17
        segmentControl.cornerRadius = 5
        segmentControl.indicatorViewInset = 0
        segmentControl.panningDisabled = true
        segmentControl.animationDuration = 0.35
        segmentControl.animationSpringDamping = 0.85
        
        segmentControl.addTarget(self, action: #selector(didSelectSearchType(_:)), for: .valueChanged)
        segmentControl.setIndex(selectedSearchType, animated: false)
        
        selectResultsView(selectedSearchType, animated: false)
    }
    
    @objc private func didSelectSearchType(_ sender: BetterSegmentedControl) {
        selectedSearchType = sender.index
        selectResultsView(sender.index, animated: true)
        
        let resultsCount = selectedSearchType == 0 ? businessPins.count + businessResults.count : postResults.count
        
        if resultsCount <= 0 {
            lblResultsNumber.text = ""
            selectedSearchType == 0 ? searchBusiness() : searchPosts()
            
        } else {
            lblResultsNumber.text = "\(resultsCount) " + (resultsCount > 1 ? "results" : "result")
        }
    }
    
    private func selectResultsView(_ selected: Int, animated: Bool) {
        if animated {
            if selected == 0 {
                UIView.animate(withDuration: 0.35) {
                    self.businessResultsContainer.alpha = 1
                    self.postResultsContainer.alpha = 0
                }
                
            } else {
                UIView.animate(withDuration: 0.35) {
                    self.businessResultsContainer.alpha = 0
                    self.postResultsContainer.alpha = 1
                }
            }
            
        } else {
            if selected == 0 {
                businessResultsContainer.alpha = 1
                postResultsContainer.alpha = 0
                
            } else {
                businessResultsContainer.alpha = 0
                postResultsContainer.alpha = 1
            }
        }
    }
    
    private func searchBusiness() {
        showIndicator()
        APIManager.shared.searchBusiness(g_myToken, category: selectedGroup, tag: searchFor) { (result, message, pins, results) in
            self.hideIndicator()
            
            self.businessPins.removeAll()
            self.businessResults.removeAll()
            
            if result,
               let pins = pins,
               let results = results {
                self.businessPins.append(contentsOf: pins)
                self.businessResults.append(contentsOf: results)
            }
            
            self.reload()
        }
    }
    
    private func searchPosts() {
        let url = GET_SELECTED_FEED_API
        
        let params = [
            "token": g_myToken,
            "category_title": selectedGroup,
            "search_key": searchFor
        ]
        
        showIndicator()
        _ = ATB_Alamofire.POST(url, parameters: params as [String: AnyObject], completionHandler: { (result, response) in
            self.hideIndicator()
            
            self.postResults.removeAll()
            if result,
               let postDicts = response.object(forKey: "extra") as? [NSDictionary] {
                for postDict in postDicts {
                    let post = PostModel(info: postDict)
                    self.postResults.append(post)
                }
            }
            
            self.reload()
        })
    }
    
    private func reload() {
        var resultsCount = 0
        if selectedSearchType == 0 {
            businessResultVC?.reload(with: businessPins, results: businessResults)
            
            resultsCount = businessPins.count + businessResults.count
            
        } else {
            postResultVC?.reload(with: postResults)
            
            resultsCount = postResults.count
        }
        
        if resultsCount == 0 {
            lblResultsNumber.text = "No Results"
            
        } else {
            lblResultsNumber.text = "\(resultsCount) " + (resultsCount > 1 ? "results" : "result")
        }
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    private var postResultVC: PostResultViewController?
    private var businessResultVC: BusinessResultViewController?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Search2BusinessResult" {
            guard let resultVC = segue.destination as? BusinessResultViewController else { return }
            businessResultVC = resultVC
            
        } else if segue.identifier == "Search2PostResult" {
            guard let resultVC = segue.destination as? PostResultViewController else { return }
            postResultVC = resultVC
        }
    }
}
