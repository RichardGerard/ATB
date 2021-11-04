//
//  TextPollPostCell.swift
//  ATB
//
//  Created by YueXi on 11/12/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import YLProgressBar

// MARK: PollVoteDelegate
// the delegate will be dispatched when an option is voted/selected
protocol PollVoteDelegate: class {
    // used in feed list
    func vote(forOption index: Int, inPost post: PostModel, completion: @escaping (Bool, PostModel?) -> Void)
    // used in post detail page
    func vote(forOption index: Int, completion: @escaping(Bool, PostModel?) -> Void)
}

// to make protocol as optional
extension PollVoteDelegate {
     
    func vote(forOption index: Int, inPost post: PostModel, completion: @escaping (Bool, PostModel?) -> Void) { }
    func vote(forOption index: Int, completion: @escaping(Bool, PostModel?) -> Void) { }
}

class TextPollPostCell: UITableViewCell {
    
    static let reuseIdentifier = "TextPollPostCell"
    
    // shadow effect will be applied to this container view
    @IBOutlet weak var shadowEffectView: UIView! { didSet {
        shadowEffectView.layer.cornerRadius = 5
        shadowEffectView.layer.shadowOffset = CGSize.zero
        shadowEffectView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowEffectView.layer.shadowRadius = 2
        shadowEffectView.layer.shadowOpacity = 0.4
        }}
    
    @IBOutlet weak var vContainer: UIView! { didSet {
        vContainer.layer.cornerRadius = 5
        vContainer.layer.masksToBounds = true
        }}
    
    @IBOutlet weak var profileContainer: UIView!
    @IBOutlet weak var imvProfile: ProfileView! { didSet {
        imvProfile.borderWidth = 2
        imvProfile.borderColor = .colorPrimary
        }}
    @IBOutlet weak var lblName: UILabel! { didSet {
        lblName.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblName.textColor = .colorGray2
        }}
    @IBOutlet weak var lblDate: UILabel! { didSet {
        lblDate.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDate.textColor = .colorGray6
        }}
    
    @IBOutlet weak var postContainer: UIView!
    @IBOutlet weak var imvPostTag: UIImageView! { didSet {
        imvPostTag.image = UIImage(named: "tag.poll.medium")?.withRenderingMode(.alwaysTemplate)
        imvPostTag.contentMode = .scaleAspectFit
        }}
    
    @IBOutlet weak var lblTitle: UILabel! { didSet {
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblTitle.textColor = .colorGray13
        lblTitle.numberOfLines = 0
        }}
    
    let progressBarStartTag = 480
    @IBOutlet var vPollOptions: [UIView]!
    @IBOutlet var vProgressBars: [YLProgressBar]!
    @IBOutlet var imvPollChecks: [UIImageView]!
    @IBOutlet var lblPollOptions: [UILabel]!
    @IBOutlet var lblProgressIndicators: [ProgressIndicator]!
    
    @IBOutlet weak var imvLikes: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvLikes.image = UIImage(systemName: "suit.heart.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvLikes.tintColor = .colorGray2
        imvLikes.contentMode = .scaleAspectFit
        }}
    @IBOutlet weak var lblLikes: UILabel! { didSet {
        lblLikes.font = UIFont(name: Font.SegoeUISemibold, size: 16)
        lblLikes.textColor = .colorGray2
        }}
    
    @IBOutlet weak var imvComments: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvComments.image = UIImage(systemName: "bubble.left.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvComments.tintColor = .colorGray2
        imvComments.contentMode = .scaleAspectFit
        }}
    @IBOutlet weak var lblComments: UILabel! { didSet {
        lblComments.font = UIFont(name: Font.SegoeUISemibold, size: 16)
        lblComments.textColor = .colorGray2
        }}
    
    var profileTapBlock: (() -> Void)?
    
    var delegate: PollVoteDelegate?
    
    var selectedPost: PostModel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
        selectionStyle = .none
        
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
            lblProgressIndicators[i].font = UIFont(name: Font.SegoeUILight, size: 18)
            lblProgressIndicators[i].textColor = UIColor.colorGray2.withAlphaComponent(0.37)
            
            lblPollOptions[i].font = UIFont(name: Font.SegoeUILight, size: 18)
            lblPollOptions[i].textColor = .colorGray2
            
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
        delegate?.vote(forOption: index, inPost: selectedPost, completion: { (voted, post) in
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
            
            configurePollOption(index, value: option.value, progress: progress, animated: true, isVoted: index == voted, isBusiness: post.isBusinessPost)
        }
    }
    
    private func configurePollOption(_ index: Int, value: String, progress: CGFloat, animated: Bool, isVoted: Bool, isBusiness: Bool) {
        lblPollOptions[index].text = value
        
        lblProgressIndicators[index].progress = progress
        
        if isVoted {
            imvPollChecks[index].isHidden = false
            imvPollChecks[index].tintColor = isBusiness ? .colorPrimary : .white
            
            lblPollOptions[index].font = UIFont(name: Font.SegoeUISemibold, size: 18)
            lblPollOptions[index].textColor = isBusiness ? .colorPrimary : .white
            
            vProgressBars[index].progressTintColor = isBusiness ? .white : .colorPrimary
            
            lblProgressIndicators[index].font = UIFont(name: Font.SegoeUISemibold, size: 18)
            lblProgressIndicators[index].textColor = isBusiness ? .colorPrimary : .white
            
        } else {
            imvPollChecks[index].isHidden = true
            
            lblPollOptions[index].font = UIFont(name: Font.SegoeUILight, size: 18)
            lblPollOptions[index].textColor = .colorGray2
            
            vProgressBars[index].progressTintColor = .colorGray4
            
            lblProgressIndicators[index].font = UIFont(name: Font.SegoeUILight, size: 18)
            lblProgressIndicators[index].textColor = UIColor.colorGray2.withAlphaComponent(0.37)
        }
        
        vProgressBars[index].setProgress(progress, animated: animated)
    }
    
    // page
    // 0: in feed, hide the play sign
    // 1: in profile
    // 2: others
    func configureCell(_ post: PostModel, in page: Int = 0) {
        // no need to show poster's profile on the profile page
        profileContainer.isHidden = page == 1
        
        selectedPost = post
          
        lblTitle.text = post.Post_Title
        lblLikes.text = post.Post_Likes
        lblComments.text = post.Post_Comments
        
        let isBusinessPost = post.isBusinessPost
        if isBusinessPost {
            postContainer.backgroundColor = .colorPrimary
            
            imvPostTag.tintColor = .white
            lblTitle.textColor = .white
            
            imvLikes.tintColor = .white
            lblLikes.textColor = .white
            imvComments.tintColor = .white
            lblComments.textColor = .white
            
        } else {
            postContainer.backgroundColor = .white
            
            imvPostTag.tintColor = .colorPrimary
            lblTitle.textColor = .colorGray13
            
            imvLikes.tintColor = .colorGray2
            lblLikes.textColor = .colorGray2
            imvComments.tintColor = .colorGray2
            lblComments.textColor = .colorGray2
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
                
                configurePollOption(i, value: option, progress: progress, animated: false, isVoted: isVoted, isBusiness: isBusinessPost)
                
            } else {
                vPollOptions[i].isHidden = true
            }
        }
        
        guard page != 1 else { return }
        
        imvProfile.loadImageFromUrl(post.Poster_Profile_Img, placeholder: "profile.placeholder")
        lblName.text = post.Poster_Name
        lblDate.text = post.Post_Human_Date
        
        if isBusinessPost {
            profileContainer.backgroundColor = .colorPrimary
            imvProfile.borderColor = .white
            lblName.textColor = .white
            lblDate.textColor = .white
            
        } else {
            profileContainer.backgroundColor = .white
            imvProfile.borderColor = .colorPrimary
            lblName.textColor = .colorGray2
            lblDate.textColor = .colorGray6
        }
    }
    
    @IBAction func didTapProfile(_ sender: Any) {
        profileTapBlock?()
    }
    
    // content preferred width for title
    // 32 - container left & right padding (16*2)
    // 10 - tag image view left margin
    // 34 - tag image view width
    // 20 - left and right padding of title & description
    private static let CONTENT_PREFERRED_WIDTH = SCREEN_WIDTH - 32 - 10 - 34 - 20
    class func cellHeight(_ post: PostModel, isProfile: Bool = false) -> CGFloat {
        // shadow container default top & bottom padding - (8 + 8)
        // like & comments - 36
        // container stack view bottom padding - 4
        var height: CGFloat = 16 + 36 + 4
        
        // top profile container - 42
        if !isProfile {
            height += 42
        }
        
        // add post container height
        height += post.Post_Title.heightForString(CONTENT_PREFERRED_WIDTH, font: UIFont(name: Font.SegoeUISemibold, size: 15)).height
        height += 10 // post cotainer stack view bottom padding
        
        // poll options
        // top margin
        height += 10
        // poll options - 42 * x + 10(spacing) * (x-1)
        let pollCount = post.Post_PollOptions.count
        let heightForOptions = 42*pollCount + 10*(pollCount - 1)
        height += CGFloat(heightForOptions)
        // bottom margin
        height += 2
        
        return height
    }
    
}
