//
//  TextPollInPostViewCell.swift
//  ATB
//
//  Created by YueXi on 11/12/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import YLProgressBar

class TextPollInPostViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TextPollInPostViewCell"
    
    @IBOutlet weak var postContainer: UIView!
    @IBOutlet weak var imvTag: UIImageView! { didSet {
        imvTag.image = UIImage(named: "tag.poll.medium")?.withRenderingMode(.alwaysTemplate)
        imvTag.contentMode = .scaleAspectFit
        }}
    
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 22)
        lblTitle.textColor = .colorGray5
        lblTitle.numberOfLines = 0
        }}
    
    @IBOutlet weak var pollOptionsTopConstraint: NSLayoutConstraint!
    
    let progressBarStartTag = 480
    @IBOutlet var vPollOptions: [UIView]!
    @IBOutlet var vProgressBars: [YLProgressBar]!
    @IBOutlet var imvPollChecks: [UIImageView]!
    @IBOutlet var lblPollOptions: [UILabel]!
    @IBOutlet var lblProgressIndicators: [ProgressIndicator]!
    
    var delegate: PollVoteDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
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
    
    func configureCell(_ post: PostModel) {
        lblTitle.text = post.Post_Title
        
        if post.isBusinessPost {
            postContainer.backgroundColor = .colorPrimary
            imvTag.tintColor = .white
            lblTitle.textColor = .white
            
            pollOptionsTopConstraint.constant = 16
            
        } else {
            postContainer.backgroundColor = .white
            imvTag.tintColor = .colorPrimary
            lblTitle.textColor = .colorGray5
            
            pollOptionsTopConstraint.constant = 0
        }
        
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
    
    private static let CONTENT_PREFERRED_WIDTH = SCREEN_WIDTH - 32 - 10
    class func sizeForItem(_ post: PostModel) -> CGSize {
        // padding of poll question (sum of top & bottom)
        var height: CGFloat = 32
        
        // add post container height
        height += post.Post_Title.heightForString(CONTENT_PREFERRED_WIDTH, font: UIFont(name: Font.SegoeUISemibold, size: 22)).height
        
        // poll options - 42 * x + 10(spacing) * (x-1)
        // to remove white space in text poll by a normal user
        if post.isBusinessPost {
            height += 16 // top padding
        }
        let pollCount = post.Post_PollOptions.count
        let heightForOptions = 42*pollCount + 10*(pollCount - 1)
        height += CGFloat(heightForOptions)
        height += 16 // bottom padding
        
        return CGSize(width: SCREEN_WIDTH, height: height)
    }
}
