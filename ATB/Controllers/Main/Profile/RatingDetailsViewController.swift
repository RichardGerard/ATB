//
//  RatingDetailViewController.swift
//  ATB
//
//  Created by mobdev on 2019/5/27.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import ReadMoreTextView
import Cosmos
import LinearProgressBar

class RatingDetailsViewController: BaseViewController {
    
    static let kStoryboardID = "RatingDetailsViewController"
    class func instance() -> RatingDetailsViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: RatingDetailsViewController.kStoryboardID) as? RatingDetailsViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    // rating container graident view
    @IBOutlet weak var vRatingContainer: UIView!
    
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvBack.tintColor = .white
        imvBack.contentMode = .scaleAspectFit
        }}
    
    @IBOutlet weak var imvBusinessProfile: UIImageView!
    @IBOutlet weak var lblBusinessName: UILabel! { didSet {
        lblBusinessName.font = UIFont(name: Font.SegoeUISemibold, size: 36)
        lblBusinessName.textColor = .white
        }}
    @IBOutlet weak var lblBusinessUsername: UILabel! { didSet {
        lblBusinessUsername.font = UIFont(name: Font.SegoeUILight, size: 22)
        lblBusinessUsername.textColor = .white
        }}
    
    @IBOutlet weak var starAverageRating: CosmosView! { didSet {
        starAverageRating.settings.totalStars = 1
        starAverageRating.settings.updateOnTouch = false
        starAverageRating.settings.filledImage = UIImage(named: "star.average.fill")
        starAverageRating.settings.emptyImage = UIImage(named: "star.average.empty")
        }}
    @IBOutlet weak var lblAverageScore: UILabel! { didSet {
        lblAverageScore.font = UIFont(name: Font.SegoeUILight, size: 28)
        lblAverageScore.textColor = .white
        }}
    @IBOutlet weak var lblReviews: UILabel! { didSet {
        lblReviews.font = UIFont(name: Font.SegoeUILight, size: 12)
        lblReviews.textColor = .white
        }}
    
    @IBOutlet weak var vSeparatorLine: UIView! { didSet {
        vSeparatorLine.backgroundColor = UIColor.black.withAlphaComponent(0.09)
        }}
    
    @IBOutlet weak var fiveStarRatingView: CosmosView! { didSet {
        fiveStarRatingView.settings.totalStars = 5
        fiveStarRatingView.settings.updateOnTouch = false
        fiveStarRatingView.settings.filledImage = UIImage(named: "star.rating.view.fill")
        fiveStarRatingView.settings.emptyImage = UIImage(named: "star.rating.view.empty")
        fiveStarRatingView.rating = 5
        }}
    @IBOutlet weak var fiveStarRatingBar: LinearProgressBar! { didSet {
        fiveStarRatingBar.barColor = .white
        fiveStarRatingBar.trackColor = UIColor.black.withAlphaComponent(0.09)
        fiveStarRatingBar.capType = 1
        fiveStarRatingBar.barThickness = 6
        }}
    @IBOutlet weak var lblFiveStarCnt: UILabel! { didSet {
        lblFiveStarCnt.font = UIFont(name: Font.SegoeUILight, size: 12)
        lblFiveStarCnt.textColor = .white
        lblFiveStarCnt.textAlignment = .center
        }}
    
    @IBOutlet weak var fourStarRatingView: CosmosView! { didSet {
        fourStarRatingView.settings.totalStars = 4
        fourStarRatingView.settings.updateOnTouch = false
        fourStarRatingView.settings.filledImage = UIImage(named: "star.rating.view.fill")
        fourStarRatingView.settings.emptyImage = UIImage(named: "star.rating.view.empty")
        fourStarRatingView.rating = 4
        }}
    @IBOutlet weak var fourStarRatingBar: LinearProgressBar! { didSet {
        fourStarRatingBar.barColor = .white
        fourStarRatingBar.trackColor = UIColor.black.withAlphaComponent(0.09)
        fourStarRatingBar.capType = 1
        fourStarRatingBar.barThickness = 6
        }}
    @IBOutlet weak var lblFourStarCnt: UILabel! { didSet {
        lblFourStarCnt.font = UIFont(name: Font.SegoeUILight, size: 12)
        lblFourStarCnt.textColor = .white
        lblFourStarCnt.textAlignment = .center
        }}
    
    @IBOutlet weak var threeStarRatingView: CosmosView! { didSet {
        threeStarRatingView.settings.totalStars = 3
        threeStarRatingView.settings.updateOnTouch = false
        threeStarRatingView.settings.filledImage = UIImage(named: "star.rating.view.fill")
        threeStarRatingView.settings.emptyImage = UIImage(named: "star.rating.view.empty")
        threeStarRatingView.rating = 3
        }}
    @IBOutlet weak var threeStarRatingBar: LinearProgressBar! { didSet {
        threeStarRatingBar.barColor = .white
        threeStarRatingBar.trackColor = UIColor.black.withAlphaComponent(0.09)
        threeStarRatingBar.capType = 1
        threeStarRatingBar.barThickness = 6
        }}
    @IBOutlet weak var lblThreeStarCnt: UILabel! { didSet {
        lblThreeStarCnt.font = UIFont(name: Font.SegoeUILight, size: 12)
        lblThreeStarCnt.textColor = .white
        lblThreeStarCnt.textAlignment = .center
        }}
    
    @IBOutlet weak var twoStarRatingView: CosmosView! { didSet {
        twoStarRatingView.settings.totalStars = 2
        twoStarRatingView.settings.updateOnTouch = false
        twoStarRatingView.settings.filledImage = UIImage(named: "star.rating.view.fill")
        twoStarRatingView.settings.emptyImage = UIImage(named: "star.rating.view.empty")
        twoStarRatingView.rating = 2
        }}
    @IBOutlet weak var twoStarRatingBar: LinearProgressBar! { didSet {
        twoStarRatingBar.barColor = .white
        twoStarRatingBar.trackColor = UIColor.black.withAlphaComponent(0.09)
        twoStarRatingBar.capType = 1
        twoStarRatingBar.barThickness = 6
        }}
    @IBOutlet weak var lblTwoStarCnt: UILabel! { didSet {
        lblTwoStarCnt.font = UIFont(name: Font.SegoeUILight, size: 12)
        lblTwoStarCnt.textColor = .white
        lblTwoStarCnt.textAlignment = .center
        }}
    
    @IBOutlet weak var oneStarRatingView: CosmosView! { didSet {
        oneStarRatingView.settings.totalStars = 1
        oneStarRatingView.settings.updateOnTouch = false
        oneStarRatingView.settings.filledImage = UIImage(named: "star.rating.view.fill")
        oneStarRatingView.settings.emptyImage = UIImage(named: "star.rating.view.empty")
        oneStarRatingView.rating = 1
        }}
    @IBOutlet weak var oneStarRatingBar: LinearProgressBar! { didSet {
        oneStarRatingBar.barColor = .white
        oneStarRatingBar.trackColor = UIColor.black.withAlphaComponent(0.09)
        oneStarRatingBar.capType = 1
        oneStarRatingBar.barThickness = 6
        }}
    @IBOutlet weak var lblOneStarCnt: UILabel! { didSet {
        lblOneStarCnt.font = UIFont(name: Font.SegoeUILight, size: 12)
        lblOneStarCnt.textColor = .white
        lblOneStarCnt.textAlignment = .center
        }}
    
    @IBOutlet weak var lblDisplayRecent: UILabel! { didSet {
        lblDisplayRecent.text = "Display Most Recent Reviews"
        lblDisplayRecent.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        lblDisplayRecent.textColor = .colorGray15
        }}
    
    @IBOutlet weak var imvSort: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvSort.image = UIImage(systemName: "arrow.up.arrow.down")
        } else {
            // Fallback on earlier versions
        }
        imvSort.contentMode = .scaleAspectFit
        imvSort.tintColor = .colorPrimary
        }}
    
    @IBOutlet weak var tblRatings: UITableView!
    
    @IBOutlet weak var vRateBtnContainer: UIView! { didSet {
        vRateBtnContainer.layer.shadowOffset = CGSize(width: 0, height: -16)
        vRateBtnContainer.layer.shadowRadius = 16.0
        vRateBtnContainer.layer.shadowColor = UIColor.colorGray7.cgColor
        vRateBtnContainer.layer.shadowOpacity = 0.4
        }}
    @IBOutlet weak var btnRate: RoundedShadowButton! { didSet {
        btnRate.setTitle("Rate this Business", for: .normal)
        btnRate.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        btnRate.backgroundColor = .colorPrimary
        }}
    
    var selectedPost:RatingDetailModel = RatingDetailModel()
    var ratings: [RatingDetailModel] = []
    
    var viewingUser: UserModel? = nil
    var expandedCells = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        setupViews()
    }
    
    private func setupViews() {
        self.view.backgroundColor = .colorGray7
        
        vRatingContainer.addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 73, alphaValue: 1.0)
        vRatingContainer.layer.masksToBounds = true
        
        tblRatings.estimatedRowHeight = 120
        tblRatings.rowHeight = UITableView.automaticDimension
        
        var totalRating:Double = 0.0
        var fiveStars = 0
        var fourStars = 0
        var threeStars = 0
        var twoStars = 0
        var oneStars = 0

        let totalRatingCount = ratings.count
        
        for rating in ratings {
            let ratingValue = rating.Rating_Value.intValue
            totalRating += rating.Rating_Value.doubleValue

           switch ratingValue {
               case 1: oneStars += 1
               case 2: twoStars += 1
               case 3: threeStars += 1
               case 4: fourStars += 1
               default: fiveStars += 1
           }
        }
        
        fiveStarRatingBar.progressValue = totalRatingCount > 0 ? CGFloat(fiveStars)/CGFloat(totalRatingCount)*100: 0
        fourStarRatingBar.progressValue = totalRatingCount > 0 ? CGFloat(fourStars)/CGFloat(totalRatingCount)*100: 0
        threeStarRatingBar.progressValue = totalRatingCount > 0 ? CGFloat(threeStars)/CGFloat(totalRatingCount)*100: 0
        twoStarRatingBar.progressValue = totalRatingCount > 0 ? CGFloat(twoStars)/CGFloat(totalRatingCount)*100: 0
        oneStarRatingBar.progressValue = totalRatingCount > 0 ? CGFloat(oneStars)/CGFloat(totalRatingCount)*100: 0
        
        lblFiveStarCnt.text = "\(fiveStars)"
        lblFourStarCnt.text = "\(fourStars)"
        lblThreeStarCnt.text = "\(threeStars)"
        lblTwoStarCnt.text = "\(twoStars)"
        lblOneStarCnt.text = "\(oneStars)"
        
        let averageRating: Double = totalRatingCount > 0 ? totalRating/Double(totalRatingCount) : 0
        starAverageRating.rating = 1.0*(averageRating/5.0)
        lblAverageScore.text = String(format: "%.1f", averageRating)
        lblReviews.text = totalRatingCount > 1 ? "\(totalRatingCount) reviews" : "\(totalRatingCount) review"
        
        let isOwnRating: Bool = (viewingUser == nil)
        vRateBtnContainer.isHidden = true
        tblRatings.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        tblRatings.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isOwnRating ? 0 : 90, right: 0)
        
        let businessProfile: BusinessModel = isOwnRating ? g_myInfo.business_profile : viewingUser!.business_profile
        lblBusinessName.text = businessProfile.businessProfileName
        lblBusinessUsername.text = "@" + businessProfile.businessName
        
        imvBusinessProfile.loadImageFromUrl(businessProfile.businessPicUrl, placeholder: "profile.placeholder")
        
        if !isOwnRating {
            canRateBusiness()
        }
    }
    
    private func canRateBusiness() {
        guard let viewingUser = viewingUser else { return }
        APIManager.shared.canRateBusiness(g_myToken, toUserId: viewingUser.ID) { result in
            switch result {
            case .success(let canRate):
                guard canRate else { return }
                
                UIView.animate(withDuration: 0.22) {
                    self.tblRatings.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
                    self.vRateBtnContainer.isHidden = false
                }
                
            case .failure(_): break
            }
        }
    }
    
    @IBAction func didTapSort(_ sender: Any) {
        
    }
    
    @IBAction func didTapRate(_ sender: UIButton) {
//        btnRate.isHidden = true - original code; not sure why to hide this button
        
        let ratingVC = SendRatingViewController.instance()
        ratingVC.viewingUser = viewingUser
        self.navigationController?.pushViewController(ratingVC, animated: true)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension RatingDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ratings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tblCell = tableView.dequeueReusableCell(withIdentifier: "RatingTableViewCell", for: indexPath) as! RatingTableViewCell
        let ratingData = ratings[indexPath.row]
        
        let text = ratingData.Rating_Text
                
        let txtFontAttribute = [ NSAttributedString.Key.font: UIFont(name: "SegoeUI-Light", size: 13.0)! ]
        let RatingTextString = NSMutableAttributedString(string: text, attributes: txtFontAttribute)
        
        tblCell.txtRating.attributedText = RatingTextString
        
        if(ratingData.Rater_Info.profile_image != "")
        {
            let url = URL(string: ratingData.Rater_Info.profile_image)
            tblCell.profileImage.kf.setImage(with: url)
        }
        
        tblCell.lblRaterName.text = ratingData.Rater_Info.firstName + " " + ratingData.Rater_Info.lastName
        tblCell.lblRatingTime.text = ratingData.created
        
        tblCell.ratingStars.rating = Double(ratingData.Rating_Value)!
        
        let readMoreTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.viewMoreTextColor,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)
        ]
        let readLessTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.viewLessTextColor,
            NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 12)
        ]
        
        tblCell.txtRating.attributedReadMoreText = NSAttributedString(string: " ... Read more", attributes: readMoreTextAttributes)
        tblCell.txtRating.attributedReadLessText = NSAttributedString(string: " Read less", attributes: readLessTextAttributes)
        tblCell.txtRating.maximumNumberOfLines = 2
        
        tblCell.txtRating.shouldTrim = !expandedCells.contains(indexPath.row)
        tblCell.txtRating.setNeedsUpdateTrim()
        tblCell.contentView.layoutIfNeeded()
        
        return tblCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let readMoreTextView = cell.contentView.viewWithTag(1) as! ReadMoreTextView
        readMoreTextView.onSizeChange = { [unowned tableView, unowned self] r in
            let point = tableView.convert(r.bounds.origin, from: r)
            guard let indexPath = tableView.indexPathForRow(at: point) else { return }
            if r.shouldTrim {
                self.expandedCells.remove(indexPath.row)
            } else {
                self.expandedCells.insert(indexPath.row)
            }
            tableView.reloadData()
        }
        
//        tblConstHeight.constant = self.tbl_ratings.contentSize.height
        self.view.layoutIfNeeded()
    }
}
