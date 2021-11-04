//
//  FeedMultipleSaleCell.swift
//  ATB
//
//  Created by YueXi on 4/29/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class FeedMultipleSaleCell: UITableViewCell {
    
    static let reuseIdentifier = "FeedMultipleSaleCell"
    
    @IBOutlet weak var clvMultipleSales: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        backgroundColor = .clear
        
        setupCollectionView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupCollectionView() {
        clvMultipleSales.showsHorizontalScrollIndicator = false
        clvMultipleSales.contentInsetAdjustmentBehavior = .never
        clvMultipleSales.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        clvMultipleSales.backgroundColor = .clear
        
        let width = SCREEN_WIDTH - 15 - 15 // - left padding - itemSpacing - right item content initial width
        //let height = (width - 25) * CGFloat(197/322.0) + 112 + 40 + 10 // + height for bottom content + sum of top & bottom content inset(it's set in storyboard in cell design)
        let height = CGFloat(600)
        let itemSize = CGSize(width: width, height: height)
        
        // collectionView FlowLayout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 5
        layout.itemSize = itemSize
        clvMultipleSales.collectionViewLayout = layout
        
        clvMultipleSales.register(UINib(nibName: "FeedMultipleSaleCollectionCell", bundle: nil), forCellWithReuseIdentifier: "FeedMultipleSaleCollectionCell")
        
    }

    func setCollectionViewDataSourceDelegate(_ dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow row: Int) {
        clvMultipleSales.dataSource = dataSourceDelegate
        clvMultipleSales.delegate = dataSourceDelegate
        clvMultipleSales.tag = 300 + row
        
        clvMultipleSales.reloadData()
    }
}

class FeedMultipleSaleCollectionCell: UICollectionViewCell {
    
    static let reuseIdentifier = "FeedMultipleSaleCollectionCell"
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var imvPosterProfile: UIImageView!
    @IBOutlet weak var lblPosterName: UILabel!
    @IBOutlet weak var lblPostedTime: UILabel!
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        setupSubviews()
    }
    
    private func setupSubviews() {
        mainView.backgroundColor = UIColor.white
        imvPosterProfile.image = UIImage(named: "new_profile_user")
        
        lblPosterName.font = UIFont(name: "SegoeUI-Semibold", size: 15)
        lblPosterName.textColor = .colorGray2
        
        lblPostedTime.font = UIFont(name: "SegoeUI-Light", size: 15)
        lblPostedTime.textColor = .colorGray16
        lblPostedTime.textAlignment = .right
        
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
