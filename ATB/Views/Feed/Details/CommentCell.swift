//
//  CommentCollectionViewCell.swift
//  ATB
//
//  Created by YueXi on 4/19/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

// MARK: - CustomTapGestureRecognizer with index
class IndexTapGestureRecognizer: UITapGestureRecognizer {
    var index: Int = 0
}

// MARK: - BaseCollectionViewCell
class BaseCollectionViewCell: UICollectionViewCell {
    // MARK: - Initializers
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - BaseCommentCell
class BaseCommentCell: BaseCollectionViewCell {
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont(name: "SegoeUI-Light", size: 17)
        textView.textColor = .colorGray5
        textView.isEditable = false
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .colorGray4
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    let roundView: RoundShadowView = {
        let view = RoundShadowView()
        view.backgroundColor = .white
        return view
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    let mediaStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    let mediaViews: [UIImageView] = {
        var imageViews = [UIImageView]()
        for i in 0 ... 2 {
            let imageView = UIImageView()
            
            imageView.layer.cornerRadius = 14
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.activityIndicator = .activity
            imageView.activityIndicatorColor = .white
            imageView.isUserInteractionEnabled = true
            
            imageViews.append(imageView)
        }
        
        return imageViews
    }()
    
    let actionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .colorGray6
        label.font = UIFont(name: "SegoeUI-Light", size: 14)
        label.text = "A minute ago"
        return label
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .colorPrimary
        button.setTitleColor(UIColor.colorPrimary, for: .normal)
        button.titleLabel?.font = UIFont(name: "SegoeUI-Semibold", size: 15)
        button.setTitle("Like", for: .normal)
        return button
    }()
    
    let replyButton: UIButton = {
        let button = UIButton()
        button.tintColor = .colorPrimary
        button.setTitleColor(UIColor.colorPrimary, for: .normal)
        button.titleLabel?.font = UIFont(name: "SegoeUI-Semibold", size: 15)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "arrowshape.turn.up.left")?.withConfiguration(UIImage.SymbolConfiguration(weight: .semibold)), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.setTitle(" Reply", for: .normal)
        return button
    }()
    
    var likeBlock: (() -> Void)? = nil
    var replyBlock: (() -> Void)? = nil
    var imageTapBlock: ((Int) -> Void)? = nil
    var longPressBlock: (() -> Void)? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }
    
    func setupSubviews() {
        addSubview(bubbleView)
        addSubview(messageTextView)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        bubbleView.addGestureRecognizer(longPressRecognizer)
        
        // profile image shadow view
        addSubview(roundView)
        
        roundView.addSubview(profileImageView)
        
        // media UIStackView
        addSubview(mediaStackView)
        for i in 0 ... 2 {
            mediaStackView.addArrangedSubview(mediaViews[i])
        }
        
        // action stackview
        addSubview(actionStackView)
        actionStackView.addArrangedSubview(timeLabel)
        actionStackView.addArrangedSubview(likeButton)
        actionStackView.addArrangedSubview(replyButton)
        
        likeButton.addTarget(self, action: #selector(didTapLike(_:)), for: .touchUpInside)
        replyButton.addTarget(self, action: #selector(didTapReply(_:)), for: .touchUpInside)
    }
    
    fileprivate func setupMediaViews(_ urls: [String]) {
        for i in 0 ... 2 {
            if i < urls.count {
                mediaViews[i].isHidden = false
                mediaViews[i].loadImageFromUrl(urls[i], placeholder: "no_image")
                // add tap gesture
                let recognizer = IndexTapGestureRecognizer(target: self, action: #selector(tapOnImage(_:)))
                recognizer.index = i
                mediaViews[i].addGestureRecognizer(recognizer)
                
            } else {
                mediaViews[i].isHidden = true
            }
        }
    }
    
    fileprivate func setupLikeActionButton(_ liked: Bool) {
        if liked {
            if #available(iOS 13.0, *) {
                let boldConfig = UIImage.SymbolConfiguration(weight: .semibold)
                likeButton.setImage(UIImage(systemName: "suit.heart.fill", withConfiguration: boldConfig), for: .normal)
                likeButton.setTitle(" Liked", for: .normal)
                
            } else {
                // Fallback on earlier versions
            }
            
        } else {
            if #available(iOS 13.0, *) {
                let boldConfig = UIImage.SymbolConfiguration(weight: .semibold)
                likeButton.setImage(UIImage(systemName: "suit.heart", withConfiguration: boldConfig), for: .normal)
                likeButton.setTitle(" Like", for: .normal)
                
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageTextView.text = nil
        
        profileImageView.image = nil
        
        for i in 0 ... 2 {
            mediaViews[i].image = nil
        }
    }
    
    @objc private func didTapLike(_ sender: Any) {
        likeBlock?()
    }
    
    @objc private func didTapReply(_ sender: Any) {
        replyBlock?()
    }
    
    @objc private func tapOnImage(_ sender: IndexTapGestureRecognizer) {
        imageTapBlock?(sender.index)
    }
    
    @objc private func longPressed(_ sender: UILongPressGestureRecognizer) {
        longPressBlock?()
    }
}

class CommentCell: BaseCommentCell {
    static let reusableIdentifier = "CommentCell"
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addConstraintWithFormat("H:|-16-[v0(36)]", views: roundView)
        addConstraintWithFormat("V:|-6-[v0(36)]", views: roundView)
        
        profileImageView.layer.cornerRadius = 16
        
        // this enables autolayout for the profile imageView
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 32),
            profileImageView.centerXAnchor.constraint(equalTo: roundView.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: roundView.centerYAnchor),
        ])
        
        actionStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            actionStackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 58),
        ])
    }
    
    func configureCell(_ comment: CommentViewModel) {
        if comment.comment == "" {
            messageTextView.attributedText = NSAttributedString(string: "")
            
        } else {
            let boldAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "SegoeUI-Semibold", size: 17)!,
                .foregroundColor: UIColor.colorGray5
            ]
            
            let normalAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "SegoeUI-Light", size: 17)!,
                .foregroundColor: UIColor.colorGray5
            ]
            
            let prefix = comment.userNameDisplay
            let comment = comment.commentDisplay
            let commentWithUsername = prefix  + " " + comment
            let attribtedStr = NSMutableAttributedString(string: commentWithUsername)
            let nameRange = (commentWithUsername as NSString).range(of: prefix)
            attribtedStr.addAttributes(boldAttrs, range: nameRange)
            let commentRange = (commentWithUsername as NSString).range(of: comment)
            attribtedStr.addAttributes(normalAttrs, range: commentRange)
            
            messageTextView.attributedText = attribtedStr
        }
        
        profileImageView.loadImageFromUrl(comment.imageUrl, placeholder: "profile.placeholder")
        
        setupMediaViews(comment.mediaUrls)
        
        // time
        if let timeInterval = Double(comment.createdTimeMilliSeconds) {
            let date = Date(timeIntervalSince1970: timeInterval)
            timeLabel.text = date.timeAgoSinceDate()
        }
        
        if let liked = comment.liked, liked {
            setupLikeActionButton(true)
            
        } else {
            setupLikeActionButton(false)
        }
    }
}

class ReplyCell: BaseCommentCell {
    static let reusableIdentifier = "ReplyCell"
    
    override func setupSubviews() {
        super.setupSubviews()
        
        addConstraintWithFormat("H:|-62-[v0(25)]", views: roundView)
        addConstraintWithFormat("V:|-6-[v0(25)]", views: roundView)
        
        profileImageView.layer.cornerRadius = 11.5
        
        // this enables autolayout for the profile imageView
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 23),
            profileImageView.heightAnchor.constraint(equalToConstant: 23),
            profileImageView.centerXAnchor.constraint(equalTo: roundView.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: roundView.centerYAnchor),
        ])
        
        actionStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            actionStackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 95),
        ])
    }
    
    func configureCell(_ reply: ReplyModel) {
        if reply.reply == "" {
            messageTextView.attributedText = NSAttributedString(string: "")
            
        } else {
            let boldAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "SegoeUI-Semibold", size: 17)!,
                .foregroundColor: UIColor.colorGray5
            ]
            
            let normalAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "SegoeUI-Light", size: 17)!,
                .foregroundColor: UIColor.colorGray5
            ]
            
            let prefix = reply.userNameDisplay
            let reply = reply.commentDisplay
            let replyWithUsername = prefix  + " " + reply
            let attribtedStr = NSMutableAttributedString(string: replyWithUsername)
            let nameRange = (replyWithUsername as NSString).range(of: prefix)
            attribtedStr.addAttributes(boldAttrs, range: nameRange)
            let replyRange = (replyWithUsername as NSString).range(of: reply)
            attribtedStr.addAttributes(normalAttrs, range: replyRange)
            
            messageTextView.attributedText = attribtedStr
        }
        
        profileImageView.loadImageFromUrl(reply.imageUrl, placeholder: "profile.placeholder")
        
        setupMediaViews(reply.mediaUrls)
        
        // time
        if let timeInterval = Double(reply.createdTimeMilliSeconds) {
            let date = Date(timeIntervalSince1970: timeInterval)
            timeLabel.text = date.timeAgoSinceDate()
        }
        
        if let liked = reply.liked, liked {
            setupLikeActionButton(true)
            
        } else {
            setupLikeActionButton(false)
        }
    }
}

extension String {
    func heightForString(_ width: CGFloat, font: UIFont? = nil) -> CGSize {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        let defaultFont = font ?? UIFont(name: "SegoeUI-Semibold", size: 17)!
        
        let estimatedFrame = NSString(string: self).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: defaultFont], context: nil)
        
        return CGSize(width: estimatedFrame.width, height: estimatedFrame.height)
    }
}
