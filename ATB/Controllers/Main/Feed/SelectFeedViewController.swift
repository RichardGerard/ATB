//
//  SelectFeedViewController.swift
//  ATB
//
//  Created by mobdev on 2019/5/20.
//  Updated by YueXi on 2021/4/19
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

// MARK: - @Protocol ATBChooseDelegate
protocol ATBChooseDelegate {
    func ATBSelected(feed:FeedModel)
    func ATBDialogClosed()
}

class SelectFeedViewController: BaseViewController {
    
    static let kStoryboardID = "SelectFeedViewController"
    class func instance() -> SelectFeedViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: SelectFeedViewController.kStoryboardID) as? SelectFeedViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }

    var selectedResult:FeedModel = FeedModel()
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var myATBButton: UIButton! { didSet {
        myATBButton.backgroundColor = .colorPrimary
        }}
    @IBOutlet weak var collectionView_Category: UICollectionView!
    
    var feedGroups = [FeedGroup]()
//    var screenWidth:CGFloat = 0.0
    var atbDelegate:ATBChooseDelegate!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblDescription.textColor = .colorGray5
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.numberOfLines = 0
        
        let selectTitle = "Selecting My ATB combines all your groups into one feed so you can view multiple groups simultaneously"
        let attributedSelectText = NSMutableAttributedString(string: selectTitle)
        attributedSelectText.addAttributes(
            [.font: UIFont(name: Font.SegoeUISemibold, size: 16)!],
            range: (selectTitle as NSString).range(of: "My ATB"))
        lblDescription.attributedText = attributedSelectText
        lblDescription.setLineSpacing(lineHeightMultiple: 0.75)
        lblDescription.textAlignment = .center
        
        myATBButton.layer.cornerRadius = 5.0
        
        collectionView_Category.showsVerticalScrollIndicator = false
        
        initGroups()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let cellHeight = (collectionView_Category.bounds.height - 40) / 5.0
        let cellWidth = (SCREEN_WIDTH - 50) / 2.0
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView_Category.collectionViewLayout = layout
    }
    
    @IBAction func myATBClicked(_ sender: Any) {
//"My ATB"
        let feedModel = FeedModel()
        feedModel.Title = "My ATB"
        
        self.atbDelegate.ATBSelected(feed: feedModel)
        self.dismiss(animated: true, completion: nil)
    }
    private func initGroups() {
        let groupIcons = ["group.beauty", "group.ladies.wear", "group.mens.wear", "group.hair", "group.kids", "group.garden", "group.home", "group.parties", "group.health", "group.seasonal"]
        
        let groupNames = g_StrFeeds.filter{ $0 != "My ATB" }
        
        for i in 0 ..< 10 {
            let feedGroup = FeedGroup(isSelected: false, icon: groupIcons[i], name: groupNames[i])
            
            feedGroups.append(feedGroup)
        }
    }
    
    @IBAction func OnBtnClose(_ sender: UIButton) {
        self.atbDelegate.ATBDialogClosed()
        self.dismiss(animated: true, completion: nil)
    }
}

extension SelectFeedViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SearchCategoryCellDelegate
{
    func OnClickSearchCategory(index: Int) {
        let selectedFeedData = self.feedGroups[index]
        let feedModel = FeedModel()
        feedModel.Title = selectedFeedData.name
        
        self.atbDelegate.ATBSelected(feed: feedModel)
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedGroups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let categoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCategoryCollectionViewCell",
                                                          for: indexPath) as! SearchCategoryCollectionViewCell
        categoryCell.cellDelegate = self
        let strCategory = feedGroups[indexPath.row]
        
        categoryCell.configureWithData(categoryData: strCategory, index: indexPath.row, search:false)

        return categoryCell
    }
}
