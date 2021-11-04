//
//  MediaPollInPostViewCell.swift
//  ATB
//
//  Created by YueXi on 11/12/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import YLProgressBar
import ImageSlideshow

class MediaPollInPostViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "MediaPollInPostViewCell"
    
    @IBOutlet weak var badgeContainer: UIView! { didSet {
        badgeContainer.backgroundColor = UIColor.black.withAlphaComponent(0.22)
        badgeContainer.layer.cornerRadius = 13
        badgeContainer.layer.masksToBounds = true
        }}
    @IBOutlet weak var imvTag: UIImageView! { didSet {
        imvTag.image = UIImage(named: "tag.poll")
        imvTag.contentMode = .center
        }}
    
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 22)
        lblTitle.textColor = .colorGray5
        lblTitle.numberOfLines = 0
        }}
    
    let progressBarStartTag = 480
    @IBOutlet var vPollOptions: [UIView]!
    @IBOutlet var vProgressBars: [YLProgressBar]!
    @IBOutlet var imvPollChecks: [UIImageView]!
    @IBOutlet var lblPollOptions: [UILabel]!
    @IBOutlet var lblProgressIndicators: [ProgressIndicator]!
    
    @IBOutlet weak var mediaContainer: UIView!
    private lazy var imageSlide: ImageSlideshow = {
        let imageSlide = ImageSlideshow(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH*3/4.0))
        imageSlide.slideshowInterval = 5
        imageSlide.contentScaleMode = .scaleAspectFill
        imageSlide.pageIndicatorPosition = .init(horizontal: .center, vertical: .bottom)
        imageSlide.contentScaleMode = .scaleAspectFill
        if #available(iOS 13.0, *) {
            imageSlide.activityIndicator = DefaultActivityIndicator(style: .medium, color: .white)
            
        } else {
            // Fallback on earlier versions
            imageSlide.activityIndicator = DefaultActivityIndicator(style: .white)
        }
        return imageSlide
    }()
    
    var tapOnImage: ((UITapGestureRecognizer) -> Void)? = nil
    
    var delegate: PollVoteDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // add image slide show
        mediaContainer.insertSubview(imageSlide, at: 0)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTapPostImage(_:)))
        imageSlide.addGestureRecognizer(recognizer)
        
        setupProgressBars()
    }
    
    private func setupProgressBars() {
        for i in 0 ..< 5 {
            vProgressBars[i].trackTintColor = .colorGray14
            vProgressBars[i].progressTintColor = .colorGray4
            vProgressBars[i].uniformTintColor = true
            vProgressBars[i].progressStretch = false
            vProgressBars[i].hideStripes = true
            vProgressBars[i].hideGloss = true
            vProgressBars[i].progressBarInset = 0.0
            vProgressBars[i].indicatorTextDisplayMode = .none
            
            // add a tap gesture
            // set a tag first
            vProgressBars[i].tag = progressBarStartTag + i
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(pollOptionSelected(_:)))
            vProgressBars[i].addGestureRecognizer(recognizer)
            
            lblProgressIndicators[i].progress = 0
            lblProgressIndicators[i].isSelected = false
            
            lblPollOptions[i].font = UIFont(name: Font.SegoeUILight, size: 18)
            lblPollOptions[i].textColor = .colorGray2 // white for selected
            
            if #available(iOS 13.0, *) {
                imvPollChecks[i].image = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate)
            } else {
                // Fallback on earlier versions
            }
            imvPollChecks[i].tintColor = .white
            imvPollChecks[i].contentMode = .center
        }
    }
    
    @objc private func pollOptionSelected(_ recognizer: UITapGestureRecognizer) {
        guard let progressBar = recognizer.view as? YLProgressBar else { return }
        
        // get index
        let index = progressBar.tag - progressBarStartTag
        delegate?.vote(forOption: index, completion: { (voted, post) in
            guard voted,
                  let updated = post else { return }
            
            self.updateOptions(ForVote: index, withPost: updated)
        })
    }
    
    private func updateOptions(ForVote voted: Int, withPost post: PostModel) {
        var totalVotes = 0
        for option in post.Post_PollOptions {
            totalVotes += option.votes.count
        }
        
        for (index, option) in post.Post_PollOptions.enumerated() {
            let progress = CGFloat(option.votes.count)/CGFloat(totalVotes)
            
            configurePollOption(index, value: option.value, progress: progress, animated: true, isVoted: index == voted)
        }
    }
    
    private func configurePollOption(_ index: Int, value: String, progress: CGFloat, animated: Bool, isVoted: Bool) {
        lblPollOptions[index].text = value
        lblPollOptions[index].textColor = isVoted ? .white : .colorGray2
        
        vProgressBars[index].progressTintColor = isVoted ? .colorPrimary : .colorGray4
        vProgressBars[index].setProgress(progress, animated: animated)
        
        lblProgressIndicators[index].progress = progress
        lblProgressIndicators[index].isSelected = isVoted
        
        imvPollChecks[index].isHidden = !isVoted
    }
    
    @objc fileprivate func didTapPostImage(_ sender: UITapGestureRecognizer) {
        tapOnImage?(sender)
    }
    
    func configureCell(_ post: PostModel) {
        badgeContainer.isHidden = !post.isBusinessPost
        
        var imageSources = [KingfisherSource]()
        for mediaUrl in post.Post_Media_Urls {
            if let imageSource = KingfisherSource(urlString: mediaUrl, placeholder: UIImage(named: "post.placeholder")) {
                imageSources.append(imageSource)
            }
        }
        
        imageSlide.setImageInputs(imageSources)
        
        lblTitle.text = post.Post_Title
        
        var totalVotes = 0
        for option in post.Post_PollOptions {
            totalVotes += option.votes.count
        }
        
        let ownID = g_myInfo.ID
        
        for i in 0 ..< 5 {
            if i < post.Post_PollOptions.count {
                vPollOptions[i].isHidden = false
                
                let option = post.Post_PollOptions[i].value
                let progress = (totalVotes > 0) ? CGFloat(post.Post_PollOptions[i].votes.count)/CGFloat(totalVotes) : 0
                let isVoted = (post.Post_PollOptions[i].votes.firstIndex(of: ownID) != nil)
                
                configurePollOption(i, value: option, progress: progress, animated: false, isVoted: isVoted)
                
            } else {
                vPollOptions[i].isHidden = true
            }
        }
    }
    
    private static let CONTENT_PREFERRED_WIDTH = SCREEN_WIDTH - 32
    class func sizeForItem(_ post: PostModel) -> CGSize {
        // height for media view
        var height = SCREEN_WIDTH * 3.0/4.0
        // top padding of poll question
        height += 12
        height += post.Post_Title.heightForString(CONTENT_PREFERRED_WIDTH, font: UIFont(name: Font.SegoeUISemibold, size: 22)).height
        
        // height for poll options
        // top padding of poll options
        height += 12
        let pollCount = post.Post_PollOptions.count
        let heightForOptions = 42*pollCount + 10*(pollCount - 1)
        height += CGFloat(heightForOptions)
        // bottom padding of poll options
        height += 16
        height += 4 // an experience value
        
        return CGSize(width: SCREEN_WIDTH, height: height)
    }
}
