//
//  FeedPollCell.swift
//  ATB
//
//  Created by YueXi on 5/3/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import YLProgressBar

// ------------------
// V: | - 10 - 54(v0) - 10 - h1(Label) - 10 - (42 * x + 10 * (x-1)) - 10 - 20(v4) - 15

class FeedPollCell: UITableViewCell {
    
    static let reuseIdentifier = "FeedPollCell"
    
    @IBOutlet weak var vContainer: ShadowView!
    
    @IBOutlet weak var imvPosterProfile: UIImageView!
    @IBOutlet weak var lblPostername: UILabel!
    @IBOutlet weak var lblPostedTime: UILabel!
    
    @IBOutlet weak var lblPollQuestion: UILabel!
    
    @IBOutlet var vPollOptions: [UIView]!
    @IBOutlet var vProgressBars: [YLProgressBar]!
    @IBOutlet var imvPollChecks: [UIImageView]!
    @IBOutlet var lblPolOptions: [UILabel]!
    @IBOutlet var lblProgressIndicators: [ProgressIndicator]!
    
    @IBOutlet weak var imvPollLikes: UIImageView!
    @IBOutlet weak var lblPollLikes: UILabel!
    @IBOutlet weak var imvPollComments: UIImageView!
    @IBOutlet weak var lblPollComments: UILabel!
    
    @IBOutlet weak var pollImage: UIImageView!
    @IBOutlet var pollimageheight: NSLayoutConstraint?
    @IBOutlet var pollimageratio: NSLayoutConstraint?
    
    let progressBarStartTag = 480
    
    var user_vote_id = ""
    var totalvotes = 0
    var postID = ""
    
    var showingViewController = UIViewController()

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

    private func setupSubviews() {
        
        imvPosterProfile.image = UIImage(named: "new_profile_user")
        
        lblPostername.font = UIFont(name: "SegoeUI-Semibold", size: 15)
        lblPostername.textColor = .colorGray2
        
        lblPostedTime.font = UIFont(name: "SegoeUI-Light", size: 15)
        lblPostedTime.textColor = .colorGray16
        lblPostedTime.textAlignment = .right
        
        lblPollQuestion.font = UIFont(name: "SegoeUI-Bold", size: 15)
        lblPollQuestion.textColor = .colorGray13
        
        if #available(iOS 13.0, *) {
            imvPollLikes.image = UIImage(systemName: "suit.heart.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvPollLikes.tintColor = .colorGray2
        lblPollLikes.font = UIFont(name: "SegoeUI-Light", size: 16)
        lblPollLikes.textColor = .colorGray2
        
        if #available(iOS 13.0, *) {
            imvPollComments.image = UIImage(systemName: "bubble.left.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvPollComments.tintColor = .colorGray2
        lblPollComments.font = UIFont(name: "SegoeUI-Light", size: 16)
        lblPollComments.textColor = .colorGray2
        
        for i in 0 ..< 5 {
            vProgressBars[i].trackTintColor = .colorGray14
            vProgressBars[i].progressTintColor = .colorGray4
            vProgressBars[i].uniformTintColor = true
            vProgressBars[i].progressStretch = false
            vProgressBars[i].hideStripes = true
            vProgressBars[i].hideGloss = true
            vProgressBars[i].progressBarInset = 0.0
            vProgressBars[i].indicatorTextDisplayMode = .fixedRight
            
            // add a tap gesture
            // set a tag first
            vProgressBars[i].tag = progressBarStartTag + i
            
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(pollOptionSelected(_:)))
            vProgressBars[i].addGestureRecognizer(recognizer)
            
            lblProgressIndicators[i].isSelected = false
            lblProgressIndicators[i].progress = 0.0
            
            lblPolOptions[i].font = UIFont(name: "SegoeUI-Light", size: 18)
            lblPolOptions[i].textColor = .colorGray2
            
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
        
        updatePollOptionSelection(index)
    }
    
    func updatePollOptionSelection(_ selected: Int) {
        for i in 0 ..< 5 {
            optionSelected(vProgressBars[i], optionLabel: lblPolOptions[i], indicatorLabel: lblProgressIndicators[i], checkMark: imvPollChecks[i], selected: i == selected)
        }
    }
    
    private func optionSelected(_ progressBar: YLProgressBar, optionLabel: UILabel, indicatorLabel: ProgressIndicator, checkMark: UIImageView, selected: Bool) {
        
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
            
            
       } else {
            showingViewController.showErrorVC(msg: "Already voted on this poll")
       }
    }
    
    // pass the model here
    func configureCell(_ options: [String]) {
        
        for i in 0 ..< 5 {
            if i < options.count {
                vPollOptions[i].isHidden = false
                
                if i == 1 {
                    lblPolOptions[i].textColor = .white
                    vProgressBars[i].progressTintColor = .colorPrimary
                    vProgressBars[i].progress = 0.4
                    
                    lblProgressIndicators[i].isSelected = true
                    lblProgressIndicators[i].progress = 0.4
                    
                    imvPollChecks[i].isHidden = false
                    
                } else {
                    lblPolOptions[i].textColor = .colorGray2
                    vProgressBars[i].progressTintColor = .colorGray4
                    vProgressBars[i].progress = i == 0 ? 0.3 : 0.5
                    
                    lblProgressIndicators[i].isSelected = false
                    lblProgressIndicators[i].progress = i == 0 ? 0.3 : 0.5
                    
                    imvPollChecks[i].isHidden = true
                }
                
                lblPolOptions[i].text = options[i]
                
            } else {
                vPollOptions[i].isHidden = true
            }
        }
    }
}
