//
//  BusinessResultViewController.swift
//  ATB
//
//  Created by YueXi on 3/31/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import Cosmos

class BusinessResultViewController: BaseViewController {
    
    // pinned profile UI variables
    @IBOutlet var pinContainers: [UIView]!
    @IBOutlet var pinContentViews: [UIView]!           // shadow container
    @IBOutlet var pinnedViews: [UIView]!                // background view
    @IBOutlet var imvPinnedProfiles: [ProfileView]!
    @IBOutlet var lblPinnedNames: [UILabel]!
    @IBOutlet var lblPinnedBio: [UILabel]!
    @IBOutlet var pinnedRatingViews: [CosmosView]!
    @IBOutlet var lblPinnedRatings: [UILabel]!
    @IBOutlet var imvPinnedBadges: [UIImageView]!
    @IBOutlet var lblPinnedDistances: [UILabel]!
    
    @IBOutlet weak var tblResults: UITableView!
    
    private var pinResults = [UserModel]()
    private var searchResults = [UserModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        setupPinnedProfileViews()
        
        updatePinnedProfiles()
    }
    
    private func setupViews() {
        view.backgroundColor = .clear
        
        tblResults.backgroundColor = .clear
        tblResults.showsVerticalScrollIndicator = false
        tblResults.separatorStyle = .none
        tblResults.rowHeight = 88
        tblResults.tableFooterView = UIView()
        
        tblResults.dataSource = self
        tblResults.delegate = self
    }
    
    private func setupPinnedProfileViews() {
        for i in 0 ..< 3 {
            pinContentViews[i].layer.shadowOffset = CGSize(width: 0, height: 1)
            pinContentViews[i].layer.shadowRadius = 2
            pinContentViews[i].layer.shadowColor = UIColor.gray.cgColor
            pinContentViews[i].layer.shadowOpacity = 0.25
            
            pinnedViews[i].backgroundColor = .colorPrimary
            pinnedViews[i].layer.cornerRadius = 4
            pinnedViews[i].layer.masksToBounds = true
            
            imvPinnedProfiles[i].borderColor = .white
            imvPinnedProfiles[i].borderWidth = 1.5
            
            lblPinnedNames[i].font = UIFont(name: Font.SegoeUILight, size: 18)
            lblPinnedNames[i].textColor = .white
            
            lblPinnedBio[i].font = UIFont(name: Font.SegoeUILight, size: 13)
            lblPinnedBio[i].textColor = .white
            lblPinnedBio[i].numberOfLines = 2
            lblPinnedBio[i].setLineSpacing(lineHeightMultiple: 0.7)
            
            pinnedRatingViews[i].settings.emptyBorderColor = .white
            pinnedRatingViews[i].settings.emptyColor = .clear
            pinnedRatingViews[i].settings.emptyBorderWidth = 1
            pinnedRatingViews[i].settings.filledColor = .white
            pinnedRatingViews[i].settings.filledBorderColor = .white
            pinnedRatingViews[i].settings.filledBorderWidth = 1
            pinnedRatingViews[i].settings.fillMode = .precise
            pinnedRatingViews[i].settings.totalStars = 1
            pinnedRatingViews[i].settings.updateOnTouch = false
            pinnedRatingViews[i].settings.filledImage = UIImage(named: "star.rating.view.fill")
            pinnedRatingViews[i].settings.emptyImage = UIImage(named: "star.rating.view.empty")
            
            lblPinnedRatings[i].font = UIFont(name: Font.SegoeUIBold, size: 15)
            lblPinnedRatings[i].textColor = .white
            
            lblPinnedDistances[i].font = UIFont(name: Font.SegoeUILight, size: 15)
            lblPinnedDistances[i].textColor = .colorBlue16
            
            imvPinnedBadges[i].image = UIImage(named: "badge.approved")?.withRenderingMode(.alwaysTemplate)
            imvPinnedBadges[i].tintColor = .colorBlue16
        }
    }
    
    private func updatePinnedProfiles() {
        for i in 0 ..< 3 {
            if i < pinResults.count {
                pinContainers[i].isHidden = false
                
                let pinUser = pinResults[i]
                let businessProfile = pinUser.business_profile
                imvPinnedProfiles[i].loadImageFromUrl(businessProfile.businessPicUrl, placeholder: "profile.placeholder")
                
                lblPinnedNames[i].text = businessProfile.businessName
                lblPinnedBio[i].text = businessProfile.businessBio
                
                let locationAttachment = NSTextAttachment()
                if #available(iOS 13.0, *) {
                    locationAttachment.image = UIImage(systemName: "location.fill")?.withTintColor(.colorBlue16)
                } else {
                    // Fallback on earlier versions
                }
                locationAttachment.setImageHeight(height: 12)
                
                let distance = pinUser.distance / 1000.0
                let distanceFormattedString = String(format: " %.1f", distance) + "KM"
                let attributedDistance = NSMutableAttributedString(string: distanceFormattedString)
                attributedDistance.insert(NSAttributedString(attachment: locationAttachment), at: 0)
                lblPinnedDistances[i].attributedText = attributedDistance
                
                pinnedRatingViews[i].rating = Double(businessProfile.rating)
                
                let reviewCount = businessProfile.reviews
                let reviewText = reviewCount > 0 ? String(format: "%.1f", businessProfile.rating) + "/5.0" + " (\(reviewCount))" : String(format: "%.1f", businessProfile.rating) + "/5.0"
                let attributedReviewText = NSMutableAttributedString(string: reviewText)
                attributedReviewText.addAttributes(
                    [.font: UIFont(name: Font.SegoeUILight, size: 14)!]
                    , range: (reviewText as NSString).range(of: "(\(reviewCount))"))
                lblPinnedRatings[i].attributedText = attributedReviewText
                
            } else {
                pinContainers[i].isHidden = true
            }
        }
    }
    
    func reload(with pins: [UserModel], results: [UserModel]) {
        // replace search results
        pinResults.removeAll()
        pinResults.append(contentsOf: pins)
        
        searchResults.removeAll()
        searchResults.append(contentsOf: results)
        
        // reload table view
        DispatchQueue.main.async {
            self.updatePinnedProfiles()
            
            self.tblResults.reloadData()
            self.tblResults.scroll(to: .top, animated: true)
        }
    }
    
    @IBAction func didTapPinProfile(_ sender: UIButton) {
        let index = sender.tag - 500
        guard index < pinResults.count else { return }
        
        let ownUser = g_myInfo
        let pinUser = pinResults[index]
        if pinUser.ID == ownUser.ID {
            openMyProfile(forBusiness: ownUser.isBusiness)
            
        } else {
            openProfile(forUser: pinUser, forBusiness: pinUser.isBusiness)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension BusinessResultViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BusinessResultCell.reuseIdentifier, for: indexPath) as! BusinessResultCell
        // configure the cell
        cell.configureCell(searchResults[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ownUser = g_myInfo
        
        let searchUser = searchResults[indexPath.row]
        if searchUser.ID == ownUser.ID {
            openMyProfile(forBusiness: ownUser.isBusiness)
            
        } else {
            openProfile(forUser: searchUser, forBusiness: searchUser.isBusiness)
        }
    }
}
