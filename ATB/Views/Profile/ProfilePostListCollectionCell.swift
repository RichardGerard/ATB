//
//  ProfilePostListCollectionCell.swift
//  ATB
//
//  Created by YueXi on 4/26/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import YLProgressBar

class ProfilePostListCollectionCell: UITableViewCell {
    
    static let reusableIdentifier = "ProfilePostListCollectionCell"
    
    @IBOutlet weak var clvPosts: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupCollectionView()
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupCollectionView() {
        clvPosts.showsHorizontalScrollIndicator = false
        clvPosts.contentInsetAdjustmentBehavior = .never
        clvPosts.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let width = SCREEN_WIDTH - 16 - 12 - 40 // - left padding - itemSpacing - right item content initial width
        let height = width * CGFloat(210/376.0) + 102 + 20 // + height for bottom content + sum of top & bottom content inset(it's set in storyboard in cell design)
        let itemSize = CGSize(width: width, height: height)
        
        // collectionView FlowLayout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.itemSize = itemSize
        clvPosts.collectionViewLayout = layout
        
        clvPosts.register(UINib(nibName: "ProfilePostListCollecionViewCell", bundle: nil), forCellWithReuseIdentifier: ProfilePostListCollecionViewCell.reusableIdentifier)
    }
    
    func setCollectionViewDataSourceDelegate(_ dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        clvPosts.dataSource = dataSourceDelegate
        clvPosts.delegate = dataSourceDelegate
        clvPosts.tag = 300 + row
        
        clvPosts.reloadData()
    }
}

class ProfilePostListCollecionViewCell: UICollectionViewCell {
    
    static let reusableIdentifier = "ProfilePostListCollecionViewCell"
    
    // post imageView
    @IBOutlet weak var imvPost: UIImageView!
    // tag views on the top right corner
    @IBOutlet var vPostTags: [UIView]!
    @IBOutlet var imvPostTags: [UIImageView]!
    // post details
    @IBOutlet weak var lblPostTitle: UILabel!
    @IBOutlet weak var lblPostContent: UILabel!
    @IBOutlet weak var lblPostPrice: UILabel!
    // likes
    @IBOutlet weak var imvPostLike: UIImageView!
    @IBOutlet weak var lblPostLikes: UILabel!
    // comments
    @IBOutlet weak var imvPostComment: UIImageView!
    @IBOutlet weak var lblPostComments: UILabel!
    // post category label
    @IBOutlet weak var imvPostCategory: UIImageView!
    @IBOutlet weak var lblPostCategory: UILabel!
    
    var postID = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupSubviews()
    }
    
    private func setupSubviews() {
        imvPost.contentMode = .scaleAspectFill
        imvPost.layer.masksToBounds = true
        
        lblPostTitle.font = UIFont(name: "SegoeUI-Bold", size: 15)
        lblPostTitle.textColor = .colorGray13
        lblPostPrice.font = UIFont(name: "SegoeUI-Light", size: 19)
        lblPostPrice.textColor = .colorPrimary
        lblPostContent.font = UIFont(name: "SegoeUI-Light", size: 15)
        lblPostContent.textColor = .colorGray13
        lblPostContent.numberOfLines = 1
        
        if #available(iOS 13.0, *) {
            imvPostLike.image = UIImage(systemName: "suit.heart.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvPostLike.tintColor = .colorGray2
        lblPostLikes.font = UIFont(name: "SegoeUI-Light", size: 16)
        lblPostLikes.textColor = .colorGray2
        
        if #available(iOS 13.0, *) {
            imvPostComment.image = UIImage(systemName: "bubble.left.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvPostComment.tintColor = .colorGray2
        lblPostComments.font = UIFont(name: "SegoeUI-Light", size: 16)
        lblPostComments.textColor = .colorGray2
        
        // image could be varied, but just put this in here for UI version
        if #available(iOS 13.0, *) {
            imvPostCategory.image = UIImage(systemName: "tag.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvPostCategory.tintColor = .colorGray2
        lblPostCategory.font = UIFont(name: "SegoeUI-Semibold", size: 14)
        lblPostCategory.textColor = .colorGray2
        
        // just put this in for UI version
        imvPostTags[0].contentMode = .center
        imvPostTags[1].contentMode = .center
        
        imvPostTags[0].image = UIImage(named: "tag.group")
        imvPostTags[1].image = UIImage(named: "tag.sale")
    }
}

class ProfilePostListCell: UITableViewCell {
    
    static let reusableIdentifier = "ProfilePostListCell"
    
    @IBOutlet weak var imvPost: UIImageView!
    
    @IBOutlet weak var vPostAdvice: UIView!
    @IBOutlet weak var lblPostAdvice: UILabel!
    
    @IBOutlet weak var vPostPoll: UIView!
    @IBOutlet weak var lblPostPoll: UILabel!
    
    @IBOutlet var vPollOptions: [UIView]!
    @IBOutlet var vProgressBars: [YLProgressBar]!
    @IBOutlet var lblPollOptions: [UILabel]!
    @IBOutlet var imvPollCheck: [UIImageView]!
    
    @IBOutlet weak var imvPostTag: UIImageView!
    
    @IBOutlet weak var lblPostContent: UILabel!
    
    // likes
    @IBOutlet weak var imvPostLike: UIImageView!
    @IBOutlet weak var lblPostLikes: UILabel!
    // comments
    @IBOutlet weak var imvPostComment: UIImageView!
    @IBOutlet weak var lblPostComments: UILabel!
    
    var postID = ""
    var user_vote_id = ""
    var totalvotes = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        
        setupSubviews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    let progressBarStartTag = 300
    
    private func setupSubviews() {
        // sale or service
        imvPost.contentMode = .scaleAspectFill
        imvPost.layer.masksToBounds = true
        
        // advice
        vPostAdvice.backgroundColor = .colorPrimary
        lblPostAdvice.font = UIFont(name: "SegoeUI-Semibold", size: 24)
        lblPostAdvice.textColor = .white
        lblPostAdvice.numberOfLines = 0
        
        // poll
        lblPostPoll.font = UIFont(name: "SegoeUI-Semibold", size: 19)
        lblPostPoll.textColor = .colorGray13
        for i in 0 ..< 5 {
            vProgressBars[i].trackTintColor = .colorGray14
            vProgressBars[i].progressTintColor = .colorGray4
            vProgressBars[i].uniformTintColor = true
            vProgressBars[i].progressStretch = false
            vProgressBars[i].hideStripes = true
            vProgressBars[i].hideGloss = true
            vProgressBars[i].progressBarInset = 0.0
            vProgressBars[i].indicatorTextDisplayMode = .fixedRight
//            vProgressBars[i].indicatorTextLabel
//            vProgressBars[i].indicatorTextLabel.font = UIFont(name: "SegoeUI-Light", size: 18)
//            vProgressBars[i].indicatorTextLabel.textColor = UIColor.colorGray2.withAlphaComponent(0.37)
            
            // add a tap gesture
            // set a tag first
            vProgressBars[i].tag = progressBarStartTag + i
            
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(pollOptionSelected(_:)))
            vProgressBars[i].addGestureRecognizer(recognizer)
            
            
            lblPollOptions[i].font = UIFont(name: "SegoeUI-Light", size: 18)
            lblPollOptions[i].textColor = .colorGray2
            
            if #available(iOS 13.0, *) {
                imvPollCheck[i].image = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate)
            } else {
                // Fallback on earlier versions
            }
            imvPollCheck[i].tintColor = .white
            imvPollCheck[i].contentMode = .center
        }
        
        lblPostContent.font = UIFont(name: "SegoeUI-Light", size: 15)
        lblPostContent.textColor = .colorGray13
        lblPostContent.numberOfLines = 0
        
        if #available(iOS 13.0, *) {
            imvPostLike.image = UIImage(systemName: "suit.heart.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvPostLike.tintColor = .colorGray2
        lblPostLikes.font = UIFont(name: "SegoeUI-Light", size: 16)
        lblPostLikes.textColor = .colorGray2
        
        if #available(iOS 13.0, *) {
            imvPostComment.image = UIImage(systemName: "bubble.left.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvPostComment.tintColor = .colorGray2
        lblPostComments.font = UIFont(name: "SegoeUI-Light", size: 16)
        lblPostComments.textColor = .colorGray2
        
        imvPostTag.contentMode = .center
    }
    
    @objc private func pollOptionSelected(_ recognizer: UITapGestureRecognizer) {
        guard let progressBar = recognizer.view as? YLProgressBar else { return }
        // get index
        let index = progressBar.tag - progressBarStartTag
        
        updatePollOptionSelection(index)
    }
    
    private func updatePollOptionSelection(_ selected: Int) {
        for i in 0 ..< 5 {
            optionSelected(vProgressBars[i], optionLabel: lblPollOptions[i], checkMark: imvPollCheck[i], selected: i == selected)
        }
    }
    
    private func optionSelected(_ progressBar: YLProgressBar, optionLabel: UILabel, checkMark: UIImageView, selected: Bool) {
        if (user_vote_id == "") {
            
            if selected {
                progressBar.progressTintColor = .colorPrimary
                progressBar.indicatorTextLabel.font = UIFont(name: "SegoeUI-Bold", size: 18)
                progressBar.indicatorTextLabel.textColor = .colorPrimary
                // this is just update UI, but you can get this progress from model
                
                var votes = progressBar.progress * CGFloat(totalvotes)
                votes = votes + CGFloat(1)
                let progress = CGFloat(votes/CGFloat(totalvotes))
                
                progressBar.setProgress(progress, animated: true)
                checkMark.isHidden = false
                optionLabel.textColor = .white
                
                let params = [
                    "token" : g_myToken,
                    "post_id":postID,
                    "poll_value": optionLabel.text!
                ]
                       
                _ = ATB_Alamofire.POST(ADD_VOTE, parameters: params as [String : AnyObject],showLoading: false,showSuccess: false,showError: false){
                    (result, responseObject) in
                    self.user_vote_id = "set"
                }
                
            } else {
                progressBar.progressTintColor = .colorGray14
                progressBar.indicatorTextLabel.font = UIFont(name: "SegoeUI-Light", size: 18)
                progressBar.indicatorTextLabel.textColor = UIColor.colorGray2.withAlphaComponent(0.37)
                // this is just update UI, but you can get this progress from model
                progressBar.setProgress(progressBar.progress, animated: true)
                checkMark.isHidden = true
                optionLabel.textColor = .colorGray2
            }
            
            
        }
        
    }
    
    func configureCell() {
        
    }
}


