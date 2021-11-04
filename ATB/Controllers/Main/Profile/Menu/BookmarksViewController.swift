//
//  BookmarksViewController.swift
//  ATB
//
//  Created by mobdev on 2019/5/23.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class BookmarksViewController: BaseViewController {
    
    static let kStoryboardID = "BookmarksViewController"
    class func instance() -> BookmarksViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: BookmarksViewController.kStoryboardID) as? BookmarksViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvBack.tintColor = .white
    }}
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var tblBookmarks: UITableView!
    
    var bookmarks: [PostModel] = []
    
    var business = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(didSavePost(_:)), name: .DidSavePost, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didDeleteSavedPost(_:)), name: .DiDDeleteSavedPost, object: nil)
        
        loadList()
    }
    
    private func setupViews() {
        lblTitle.text = "Saved Posts"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size:27)
        lblTitle.textColor = .white
        
        
        tblBookmarks.register(UINib(nibName: "TextPostTableViewCell", bundle: nil), forCellReuseIdentifier: "TextPostTableViewCell")
        tblBookmarks.register(UINib(nibName: "MediaTableViewCell", bundle: nil), forCellReuseIdentifier: "MediaPostTableViewCell")
        
        tblBookmarks.register(UINib(nibName: "TextPostCell", bundle: nil), forCellReuseIdentifier: TextPostCell.reuseIdentifier)
        tblBookmarks.register(UINib(nibName: "MediaPostCell", bundle: nil), forCellReuseIdentifier: MediaPostCell.reuseIdentifier)
        tblBookmarks.register(UINib(nibName: "TextPollPostCell", bundle: nil), forCellReuseIdentifier: TextPollPostCell.reuseIdentifier)
        tblBookmarks.register(UINib(nibName: "MediaPollPostCell", bundle: nil), forCellReuseIdentifier: MediaPollPostCell.reuseIdentifier)
        
        tblBookmarks.showsVerticalScrollIndicator = false
        tblBookmarks.separatorStyle = .none
        tblBookmarks.contentInset = UIEdgeInsets(top: 8.0, left: 0.0, bottom: 8.0, right: 0.0)
        tblBookmarks.tableFooterView = UIView()
        
        tblBookmarks.dataSource = self
        tblBookmarks.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard needsToScrollTop else { return }
        needsToScrollTop = false
        
        tblBookmarks.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    private func loadList() {
        let params = [
            "token" : g_myToken,
            "user_id": g_myInfo.ID
        ]
        
        showIndicator()
        _ = ATB_Alamofire.POST(GET_USER_BOOKMARKS, parameters: params as [String : AnyObject]) { (result, response) in
            self.hideIndicator()
            guard result,
                  let postDicts = response.object(forKey: "msg") as? [NSDictionary] else {
                self.showErrorVC(msg: "It's been failed to load your bookmarked posts!")
                return
            }
            
            guard postDicts.count > 0 else {
                self.showInfoVC("ATB", msg: "No bookmarked posts!")
                return
            }
            
            for postDict in postDicts {
                let bookmarkedPost = PostModel(info: postDict)
                self.bookmarks.append(bookmarkedPost)
            }
            
            self.tblBookmarks.reloadData()
        }
    }
    
    @objc private func didDeleteSavedPost(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let post = object["post"] as? PostModel,
              let index = bookmarks.firstIndex(where: { $0.Post_ID == post.Post_ID }) else { return }
        
        bookmarks.remove(at: index)
        DispatchQueue.main.async {
            self.tblBookmarks.reloadData()
        }
    }
    
    private var needsToScrollTop: Bool = false
    @objc private func didSavePost(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let post = object["post"] as? PostModel else { return }
        
        bookmarks.insert(post, at: 0)
        DispatchQueue.main.async {
            self.tblBookmarks.reloadData()
            self.needsToScrollTop = true
        }
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension BookmarksViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = bookmarks[indexPath.row]
        
        if post.isPoll {
            if post.isTextPost {
                let cell = tableView.dequeueReusableCell(withIdentifier: TextPollPostCell.reuseIdentifier, for: indexPath) as! TextPollPostCell
                // configure the cell
                cell.configureCell(post, in: 2)
                
                cell.profileTapBlock = {
                    // no need to check if the post is own post item
                    // user can't/don't save their own post
                    self.openPosterProfile(forPost: post)
                }
                
                cell.delegate = self
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: MediaPollPostCell.reuseIdentifier, for: indexPath) as! MediaPollPostCell
                // configure the cell
                cell.configureCell(post, in: 2)
                
                cell.profileTapBlock = {
                    // no need to check if the post is own post item
                    // user can't/don't save their own post
                    self.openPosterProfile(forPost: post)
                }
                
                cell.delegate = self

                return cell
            }
            
        } else {
            if post.isTextPost {
                let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.reuseIdentifier, for: indexPath) as! TextPostCell
                // configure the cell
                cell.configureCell(post, in: 2)
                                
                cell.profileTapBlock = {
                    // no need to check if the post is own post item
                    // user can't/don't save their own post
                    self.openPosterProfile(forPost: post)
                }
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: MediaPostCell.reuseIdentifier, for: indexPath) as! MediaPostCell
                // configure the cell
                cell.configureCell(post, in: 2)
                
                cell.profileTapBlock = {
                    // no need to check if the post is own post item
                    // user can't/don't save their own post
                    self.openPosterProfile(forPost: post)
                }
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = bookmarks[indexPath.row]
        
        if post.isPoll {
            if post.isTextPost {
                return TextPollPostCell.cellHeight(post)
                
            } else {
                return MediaPollPostCell.cellHeight(post)
            }
            
        } else {
            if post.isTextPost {
                return TextPostCell.cellHeight(post)
                
            } else {
                return MediaPostCell.cellHeight(post)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = bookmarks[indexPath.row]
        getPostDetail(selected)
    }
}

// MARK: - PollVoteDelegate
extension BookmarksViewController: PollVoteDelegate {
    
    func vote(forOption index: Int, inPost post: PostModel, completion: @escaping (Bool, PostModel?) -> Void) {
        // check if user already voted
        let ownID = g_myInfo.ID

        var voted = false
        for option in post.Post_PollOptions {
            if let _ = option.votes.firstIndex(of: ownID) {
                voted = true
                break
            }
        }

        guard !voted else {
            showErrorVC(msg: "You've already voted on this poll!")
            return
        }

        let value = post.Post_PollOptions[index].value

        let params = [
            "token": g_myToken,
            "post_id": post.Post_ID,
            "poll_value": value
        ]

        showIndicator()
        _ = ATB_Alamofire.POST(ADD_VOTE, parameters: params as [String : AnyObject]) { (result, responseObject) in
            self.hideIndicator()

            if result {
                // add the new vote made
                if let index = self.bookmarks.firstIndex(where: { $0.Post_ID == post.Post_ID }) {
                    self.bookmarks[index].Post_PollOptions[index].votes.append(ownID)

                    completion(true, self.bookmarks[index])
                }
            }
        }
    }
}
