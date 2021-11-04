//
//  FeedSelectViewController.swift
//  ATB
//
//  Created by YueXi on 5/30/20.
//  Updated by YueXi on 4/18/21.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class CreateFeedViewController: BaseViewController {
    
    static let kStoryboardID = "CreateFeedViewController"
    class func instance() -> CreateFeedViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: CreateFeedViewController.kStoryboardID) as? CreateFeedViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var lblSelectGroups: UILabel!
    
    @IBOutlet weak var lblSelectAll: UILabel!
    @IBOutlet weak var vCheckSelectAll: CheckBox!
    
    var feedGroups = [FeedGroup]()
    @IBOutlet weak var clvGroups: UICollectionView!
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var imvAlert: UIImageView!
    @IBOutlet weak var lblAlert: UILabel!
    
    @IBOutlet weak var btnCreateFeed: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initGroups()
        
        setupViews()
    }
    
    private func initGroups() {
        let groupIcons = ["group.beauty", "group.ladies.wear", "group.mens.wear", "group.hair", "group.kids", "group.garden", "group.home", "group.parties", "group.health", "group.seasonal"]
        
        let groupNames = g_StrFeeds.filter{ $0 != "My ATB" }
        
        for i in 0 ..< 10 {
            let feedGroup = FeedGroup(isSelected: false, icon: groupIcons[i], name: groupNames[i])
            
            feedGroups.append(feedGroup)
        }
    }
    
    private func setupViews() {
        self.view.backgroundColor = .colorGray14
        
        let select = "Please select groups that interest you so that we can personalise your "
        let ATBFeed = "ATB Feed"
        let attributedSelectString = NSMutableAttributedString(string: select + ATBFeed)
        
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUILight, size: 19)!,
            .foregroundColor: UIColor.colorGray5
        ]
        
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Font.SegoeUIBold, size: 19)!,
            .foregroundColor: UIColor.colorGray5
        ]
        
        attributedSelectString.addAttributes(normalAttrs, range: NSRange(location: 0, length: select.count))
        attributedSelectString.addAttributes(boldAttrs, range: NSRange(location: select.count, length: ATBFeed.count))
        
        lblSelectGroups.attributedText = attributedSelectString        
        lblSelectGroups.textAlignment = .center
        lblSelectGroups.numberOfLines = 0
        
        let selectAll = "Select All"
        let underlineAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Semibold", size: 15)!,
            .foregroundColor: UIColor.colorPrimary,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.colorPrimary
        ]
        
        let selectAllAttrString = NSMutableAttributedString(string: selectAll)
        selectAllAttrString.addAttributes(underlineAttrs, range: NSRange(location: 0, length: selectAll.count))
        lblSelectAll.attributedText = selectAllAttrString
        lblSelectAll.isUserInteractionEnabled = true
        
        let selectAllGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSelectAll(_:)))
        lblSelectAll.addGestureRecognizer(selectAllGesture)
        
        // style checkbox
        vCheckSelectAll.checkboxBackgroundColor = .colorGray14
        vCheckSelectAll.borderStyle = .roundedSquare(radius: 4)
        vCheckSelectAll.style = .tick
        vCheckSelectAll.borderWidth = 2
        vCheckSelectAll.tintColor = .colorPrimary
        vCheckSelectAll.uncheckedBorderColor = .colorPrimary
        vCheckSelectAll.checkedBorderColor = .colorPrimary
        vCheckSelectAll.checkmarkSize = 0.8
        vCheckSelectAll.checkmarkColor = .colorPrimary
        vCheckSelectAll.addTarget(self, action: #selector(selectAllChecked(_:)), for: .valueChanged)
        
        // setup collection view
        setupCollectionView()
        
        // alert view
        alertView.backgroundColor = .colorGray14
        if #available(iOS 13.0, *) {
            imvAlert.image = UIImage(systemName: "arrow.up.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvAlert.tintColor = .colorRed1
        lblAlert.text = "Please select one of the above groups, this will create a custom feed where you can explore things of you interest"
        lblAlert.textColor = .colorRed1
        lblAlert.font = UIFont(name: "SegoeUI-Light", size: 15)
        lblAlert.numberOfLines = 0
        
        alertView.alpha = 0
        alertView.isHidden = true
        
        btnCreateFeed.layer.cornerRadius = 5.0
        btnCreateFeed.setTitle("Create your Feed", for: .normal)
        btnCreateFeed.titleLabel?.font = UIFont(name: "SegoeUI-Bold", size: 18)
        btnCreateFeed.backgroundColor = .colorPrimary
        
        updateCreateFeedButton()
    }
    
    private func setupCollectionView() {
        clvGroups.showsVerticalScrollIndicator = false
        clvGroups.dataSource = self
        clvGroups.delegate = self
        clvGroups.contentInset = UIEdgeInsets(top: 4, left: 10, bottom: 0, right: 10)
        
        // initialize collectionview
        let width = (SCREEN_WIDTH - 20) / 2.0
        let height: CGFloat = 102
        
        let itemSize = CGSize(width: width, height: height)
        
        // customize collectionviewlayout
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = itemSize
        
        clvGroups.collectionViewLayout = layout
    }
    
    @objc func didTapSelectAll(_ sender: Any) {
        vCheckSelectAll.isChecked = !vCheckSelectAll.isChecked
        
        selectAll(vCheckSelectAll.isChecked)
    }
    
    @objc func selectAllChecked(_ sender: CheckBox) {
        selectAll(sender.isChecked)
    }
    
    private func selectAll(_ isSelecting: Bool) {
        for i in 0 ..< 10 {
            feedGroups[i].isSelected = isSelecting
        }
        
        updateCreateFeedButton()
        
        clvGroups.reloadData()
    }
    
    private func showAlertView() {
        alertView.isHidden = false
        
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.alertView.alpha = 1.0
        })
    }
    
    private func hideAlertView() {
        UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.alertView.alpha = 0.0
            
        }, completion: { _ in
            self.alertView.isHidden = true
        })
    }
    
    private func isValid() -> Bool {
        for feedGroup in feedGroups {
            if feedGroup.isSelected {
                return true
            }
        }
        
        return false
    }
    
    private func updateCreateFeedButton() {
        if !alertView.isHidden {
            hideAlertView()
        }
        
        if isValid() {
            btnCreateFeed.setTitleColor(.white, for: .normal)
            return
        }
        
        btnCreateFeed.setTitleColor(UIColor.white.withAlphaComponent(0.22), for: .normal)
    }
    
    @IBAction func didTapCreateFeed(_ sender: Any) {
        guard isValid() else {
            showAlertView()
            return
        }
        
        var feedString = ""
        
        for feedGroup in feedGroups{
            if feedGroup.isSelected {
                if(feedString == "")
                {
                    feedString = feedGroup.name
                }
                else
                {
                    feedString = feedString + "," + feedGroup.name
                }
            }
        }
        
        let params = [
            "token" : g_myToken,
            "feeds" : feedString
            ] as [String : Any]
        
        _ = ATB_Alamofire.POST(UPDATE_FEED_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            self.view.isUserInteractionEnabled = true
            
            if(result) {
                let mainNav = self.storyboard?.instantiateViewController(withIdentifier: "MainNav") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = mainNav
                
            } else {
                let msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if(msg == "")
                {
                    self.showErrorVC(msg: "Update feed error!")
                }
                else
                {
                    self.showErrorVC(msg: "Server returned the error message: " + msg)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionVieweDelegate
extension CreateFeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedGroups.count
    }
     
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedGroupCell.reuseIdentifier, for: indexPath) as! FeedGroupCell
        // configure the cell
        cell.configureCell(feedGroups[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        feedGroups[indexPath.row].isSelected = !feedGroups[indexPath.row].isSelected
        
        updateCreateFeedButton()
        
        clvGroups.reloadItems(at: [indexPath])
    }
}

struct FeedGroup {
    
    var isSelected: Bool = false
    var icon: String = ""
    var name: String = ""
}
