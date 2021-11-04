//
//  PostGridMediaCell.swift
//  ATB
//
//  Created by YueXi on 4/24/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Kingfisher

class ProfilePostGridCell: UICollectionViewCell {
    
    static let reusableIdentifier = "ProfilePostGridCell"
    
    @IBOutlet weak var imvPost: UIImageView! { didSet {
        imvPost.contentMode = .scaleAspectFill
        }}
    
    @IBOutlet weak var vGroupTagContainer: UIView!
    @IBOutlet weak var imvGroupPostTag: UIImageView! { didSet {
        imvGroupPostTag.image = UIImage(named: "tag.group")
        imvGroupPostTag.contentMode = .center
        imvGroupPostTag.contentMode = .center
        }}
    
    @IBOutlet weak var imvPostTag: UIImageView! { didSet {
        imvPostTag.contentMode = .center
        }}
    @IBOutlet weak var lblContent: UILabel! { didSet {
        lblContent.font = UIFont(name: "SegoeUI-Semibold", size: 17)
        lblContent.numberOfLines = 0
        }}
    
    @IBOutlet weak var vPlay: UIView!
    
    @IBOutlet weak var scheduleContainer: UIView! { didSet {
        scheduleContainer.backgroundColor = UIColor.black.withAlphaComponent(0.45)
    }}
    
    @IBOutlet weak var imvTimer: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvTimer.image = UIImage(systemName: "timer")
        } else {
            // Fallback on earlier versions
        }
        imvTimer.tintColor = .white
    }}
    
    @IBOutlet weak var lblSchedule: UILabel! { didSet {
        lblSchedule.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblSchedule.numberOfLines = 0
        lblSchedule.textAlignment = .center
        lblSchedule.textColor = .white
    }}
    
    func configureCell(_ post: PostModel, isScheduled: Bool = false) {
        vPlay.isHidden = true
        
        vGroupTagContainer.isHidden = !post.is_multi
        
        scheduleContainer.isHidden = !isScheduled
        updateScheduleTitle(post.Post_Scheduled)
        
        if (post.Post_Media_Type == "Text") {
            imvPost.isHidden = true
            lblContent.isHidden = false
                     
            lblContent.text = post.Post_Title
            
            if post.Post_Type == "Poll" {
                lblContent.textColor = .white
                contentView.backgroundColor = .colorPrimary
                
            } else {
                lblContent.textColor = .colorGray2
                contentView.backgroundColor = .white
            }
            
        } else {
            imvPost.isHidden = false
            lblContent.isHidden = true
            
            let url = post.Post_Media_Urls.count > 0 ? post.Post_Media_Urls[0] : ""
            if post.Post_Media_Type == "Video" {
                vPlay.isHidden = false
                
                // set placeholder
                imvPost.image = UIImage(named: "post.placeholder")
                
                if ImageCache.default.imageCachedType(forKey: url).cached {
                    ImageCache.default.retrieveImage(forKey: url) { result in
                        switch result {
                        case .success(let cacheResult):
                            if let image = cacheResult.image {
                                let animation = CATransition()
                                animation.type = .fade
                                animation.duration = 0.25
                                self.imvPost.layer.add(animation, forKey: "transition")
                                self.imvPost.image = image
                            }
                            
                            break
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                            break
                        }
                    }
                    
                } else {
                    // thumbnail is not cached, get thumbnail from video url
                    Utils.shared.getThumbnailImageFromVideoUrl(url) { thumbnail in
                        if let thumbnail = thumbnail {
                            let animation = CATransition()
                            animation.type = .fade
                            animation.duration = 0.3
                            self.imvPost.layer.add(animation, forKey: "transition")
                            self.imvPost.image = thumbnail
                            
                            ImageCache.default.store(thumbnail, forKey: url)
                        }
                    }
                }
                
            } else {
                imvPost.loadImageFromUrl(url, placeholder: "post.placeholder")
            }
        }
        
        switch post.Post_Type {
        case "Advice": imvPostTag.image = UIImage(named: "tag.advice")
        case "Sales": imvPostTag.image = UIImage(named: "tag.sale")
        case "Service": imvPostTag.image = UIImage(named: "tag.service")
        case "Poll": imvPostTag.image = UIImage(named: "tag.poll")
        default: imvPostTag.image = nil
        }
    }
    
    private func updateScheduleTitle(_ scheduled: String) {
        guard !scheduled.isEmpty else {
            lblSchedule.isHidden = true
            return
        }
        
        let scheduledDate = Date(timeIntervalSince1970: scheduled.doubleValue)
        let formattedDate = scheduledDate.toString("E d'\(scheduledDate.daySuffix())' MMMM yyyy'\n'h:mm a", timeZone: .current)
        let scheduleTitle = "Scheduled post\n" + formattedDate
        let attributedScheduleTitle = NSMutableAttributedString(string: scheduleTitle)
        let scheduleRange = (scheduleTitle as NSString).range(of: "Scheduled post")
        attributedScheduleTitle.addAttributes([
            .font: UIFont(name: Font.SegoeUIBold, size: 15)!
        ], range: scheduleRange)
        
        lblSchedule.attributedText = attributedScheduleTitle
        lblSchedule.setLineSpacing(lineHeightMultiple: 0.75)
        lblSchedule.textAlignment = .center
    }
}
