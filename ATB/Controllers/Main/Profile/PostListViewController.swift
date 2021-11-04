//
//  SavedPostListViewController.swift
//  ATB
//
//  Created by YueXi on 4/24/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class PostListViewController: BaseViewController {
    
    var viewingUser: UserModel? = nil
    var postList:[PostModel] = []
    
    static let kStoryboardID = "PostListViewController"
    class func instance() -> PostListViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: PostListViewController.kStoryboardID) as? PostListViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var tblPosts: UITableView!

    private let CONTENT_PREFERRED_WIDTH = SCREEN_WIDTH - 36 - 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupTableView()
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(didUpdatePost(_:)), name: .DidUpdatePost, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didDeletePost(_:)), name: .DidDeletePost, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didReceiveProductStockChanged(_:)), name: .ProductStockChanged, object: nil)
        
        loadList()
    }
    
    private func setupTableView() {
        tblPosts.backgroundColor = .colorGray7
        tblPosts.showsVerticalScrollIndicator = false
        tblPosts.separatorStyle = .none
        tblPosts.tableFooterView = UIView()
        tblPosts.contentInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        
        tblPosts.register(UINib(nibName: "TextPostCell", bundle: nil), forCellReuseIdentifier: TextPostCell.reuseIdentifier)
        tblPosts.register(UINib(nibName: "MediaPostCell", bundle: nil), forCellReuseIdentifier: MediaPostCell.reuseIdentifier)
        tblPosts.register(UINib(nibName: "TextPollPostCell", bundle: nil), forCellReuseIdentifier: TextPollPostCell.reuseIdentifier)
        tblPosts.register(UINib(nibName: "MediaPollPostCell", bundle: nil), forCellReuseIdentifier: MediaPollPostCell.reuseIdentifier)
        tblPosts.register(UINib(nibName: "MultiplePostCell", bundle: nil), forCellReuseIdentifier: MultiplePostCell.reuseIdentifier)
        
        tblPosts.dataSource = self
        tblPosts.delegate = self
    }
    
    func loadList() {
        postList.removeAll()
        
        let isOwnProfile = (viewingUser == nil)
        let user_id = isOwnProfile ? g_myInfo.ID : viewingUser!.ID

        // This list viewcontroller will be attached to only normal user profile
        let params = [
            "token" : g_myToken,
            "user_id": user_id,
            "business": "0"
        ]

        _ = ATB_Alamofire.POST(GET_USERS_POSTS, parameters: params as [String : AnyObject], showLoading: false, showSuccess: false, showError: false){
            (result, responseObject) in

            let postDicts = responseObject.object(forKey: "msg")  as? [NSDictionary] ?? []
            for postDict in postDicts {
                let newPost = PostModel(info: postDict)
                if isOwnProfile {
                    // show all posts
                    self.postList.append(newPost)
                    
                } else {
                    if newPost.isActive {
                        // show only active post
                        self.postList.append(newPost)
                    }
                }
                
            }

            self.tblPosts.reloadData()
        }
    }
    
    // false - when the post is deleted
    private func showDeleteNotification() {
        let toastMessage = "The post has been deleted successfully."
        let toastFont = UIFont(name: Font.SegoeUILight, size: 16)
        let estimatedFrame = toastMessage.heightForString(SCREEN_WIDTH - 72, font: toastFont)
        
        let toastViewHeight: CGFloat = estimatedFrame.height + 20
        let toastView = TextToastView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 40, height: toastViewHeight))
        toastView.toastMessage = toastMessage
        
        // giving position with a point as we have input accessory view
        showToast(toastView)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Notification Handler
extension PostListViewController {
    
    @objc private func didUpdatePost(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let updated = object["updated"] as? PostModel else { return }
        
        if updated.isAdvice {
            // advice
            // the updated will be a post model
            // advice does not have multiple posts
            guard let index = postList.firstIndex(where: { $0.Post_ID == updated.Post_ID }) else { return }
            
            // advice can get user type changed
            if updated.isBusinessPost {
                // ListView is only for user's only
                // poster account type has been changed
                postList.remove(at: index)
                DispatchQueue.main.async {
                    self.tblPosts.reloadData()
                }
                
            } else {
                // the poster account type has not been changed
                // for user - we have two tabs(grid & list), items could not get updated
                postList[index].update(withPost: updated)
                DispatchQueue.main.async {
                    self.tblPosts.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                }
            }
            
        } else {
            // only product
            guard updated.isSale else { return }
            
            let filtered = postList.filter({
                if $0.isMultiplePost {
                    if let _ = $0.group_posts.firstIndex(where: {
                        guard $0.isSale,
                              let pid = $0.pid,
                              pid == updated.Post_ID else { return false }
                        
                        return true
                        
                    }) {
                        return true
                        
                    } else {
                        guard $0.isSale,
                              let pid = $0.pid,
                              pid == updated.Post_ID else { return false }
                        
                        return true
                    }
                    
                } else {
                    guard $0.isSale,
                          let pid = $0.pid,
                          pid == updated.Post_ID else { return false }
                    
                    return true
                }
            })
            
            var reloadIndexes = [IndexPath]()
            for filteredPost in filtered {
                if filteredPost.isMultiplePost {
                    if let indexInGroup = filteredPost.group_posts.firstIndex(where: {
                        guard let pid = $0.pid,
                              pid == updated.Post_ID else { return false }
                        
                        return true
                    }) {
                        filteredPost.group_posts[indexInGroup].update(withProduct: updated)
                        
                    } else {
                        // the 1st in the group post
                        filteredPost.update(withProduct: updated)
                    }
                    
                } else {
                    filteredPost.update(withProduct: updated)
                }
                
                if let index = postList.firstIndex(where: { $0.Post_ID == filteredPost.Post_ID }) {
                    reloadIndexes.append(IndexPath(row: index, section: 0))
                }
            }
            
            guard reloadIndexes.count > 0 else { return }
            
            DispatchQueue.main.async {
                self.tblPosts.reloadRows(at: reloadIndexes, with: .fade)
            }
        }
    }
    
    @objc private func didReceiveProductStockChanged(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let updatedProductId = object["product_id"] as? String,
              let updated = object["updated"] as? PostModel else { return }
        
        let filtered = postList.filter({
            if $0.isMultiplePost {
                if let _ = $0.group_posts.firstIndex(where: {
                    guard $0.isSale,
                          let pid = $0.pid,
                          pid == updatedProductId else { return false }
                    
                    return true
                    
                }) {
                    return true
                    
                } else {
                    guard $0.isSale,
                          let pid = $0.pid,
                          pid == updatedProductId else { return false }
                    
                    return true
                }
                
            } else {
                guard $0.isSale,
                      let pid = $0.pid,
                      pid == updatedProductId else { return false }
                
                return true
            }
        })
        
        var reloadIndexes = [IndexPath]()
        for filteredPost in filtered {
            if filteredPost.isMultiplePost {
                if let indexInGroup = filteredPost.group_posts.firstIndex(where: {
                    guard let pid = $0.pid,
                          pid == updatedProductId else { return false }
                    
                    return true
                }) {
                    filteredPost.group_posts[indexInGroup].update(withProduct: updated)
                    
                } else {
                    // the 1st in the group post
                    filteredPost.update(withProduct: updated)
                }
                
            } else {
                filteredPost.update(withProduct: updated)
            }
            
            if let index = postList.firstIndex(where: { $0.Post_ID == filteredPost.Post_ID }) {
                reloadIndexes.append(IndexPath(row: index, section: 0))
            }
        }
        
        guard reloadIndexes.count > 0 else { return }
        
        DispatchQueue.main.async {
            self.tblPosts.reloadRows(at: reloadIndexes, with: .fade)
        }
    }
    
    @objc private func didDeletePost(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
              let postId = userInfo["post_id"] as? String,
              let index = postList.firstIndex(where: {
                if $0.isMultiplePost {
                    if let _ = $0.group_posts.firstIndex(where: { $0.Post_ID == postId }) {
                        return true
                    } else {
                        return $0.Post_ID == postId
                    }

                } else {
                    return $0.Post_ID == postId
                }
              }) else { return }

        let deleted = postList[index]
        if deleted.Post_ID == postId {
            postList.remove(at: index)

        } else {
            guard let indexInGroup = deleted.group_posts.firstIndex(where: {  $0.Post_ID == postId  }) else { return }
            postList[index].group_posts.remove(at: indexInGroup)
        }
        
        DispatchQueue.main.async {
            self.tblPosts.reloadData()
            
            self.showDeleteNotification()
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension PostListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = postList[indexPath.row]
        
        if (post.is_multi) {
            let cell = tableView.dequeueReusableCell(withIdentifier: MultiplePostCell.reuseIdentifier, for: indexPath)
            
            return cell
            
        } else {
            if (post.Post_Type == "Poll") {
                if post.isTextPost {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TextPollPostCell.reuseIdentifier, for: indexPath) as! TextPollPostCell
                    // configure the cell
                    cell.configureCell(post, in: 1)

                    return cell
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: MediaPollPostCell.reuseIdentifier, for: indexPath) as! MediaPollPostCell
                    // configure the cell
                    cell.configureCell(post, in: 1)

                    return cell
                }

            } else {
                if(post.Post_Media_Type == "Text") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.reuseIdentifier, for: indexPath) as! TextPostCell
                    // configure the cell
                    cell.configureCell(post, in: 1)
                                        
                    return cell
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: MediaPostCell.reuseIdentifier, for: indexPath) as! MediaPostCell
                    // configure the cell
                    cell.configureCell(post, in: 1)
                                        
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let post = postList[indexPath.row]
        guard post.is_multi,
            let multiplePostCell = cell as? MultiplePostCell else {
                return
        }
        
        multiplePostCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = postList[indexPath.row]
        
        if (post.is_multi) {
            return MultiplePostCell.cellHeight(post, isProfile: true)
            
        } else {
            if (post.Post_Type == "Poll") {
                if post.isTextPost {
                    return TextPollPostCell.cellHeight(post, isProfile: true)
                    
                } else {
                    return MediaPollPostCell.cellHeight(post, isProfile: true)
                }
                
            } else {
                if post.Post_Media_Type == "Text" {
                    return TextPostCell.cellHeight(post, isProfile: true)
                    
                } else {
                    return MediaPostCell.cellHeight(post, isProfile: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let selectedPost = postList[indexPath.row]
        getPostDetail(selectedPost)
    }
}

extension PostListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let post = postList[collectionView.tag - 300]
        return post.group_posts.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let multiplePostCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: MultiplePostCollectionCell.reuseIdentifier, for: indexPath) as! MultiplePostCollectionCell
        // configure the cell
        let post = postList[collectionView.tag - 300]
        let row = indexPath.row
        
        multiplePostCollectionCell.configureCell(row == 0 ? post : post.group_posts[row - 1 ], in: 1)
        
        return multiplePostCollectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = postList[collectionView.tag - 300]
        let row = indexPath.row
        getPostDetail(row == 0 ? post : post.group_posts[row - 1])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth: CGFloat = SCREEN_WIDTH - 10 - 31 // left padding, right item content initial width
        // top & bottom default padding, profile container, media container,
        // title, price, desctiption, like & comments
        var itemHeight: CGFloat = 16 + (itemWidth - 12) * 358/340.0
        // height for title, price, description
        itemHeight += UIFont(name: Font.SegoeUISemibold, size: 15)!.lineHeight*2.0
        itemHeight += 4 // top padding of post title
        itemHeight += UIFont(name: Font.SegoeUILight, size: 15)!.lineHeight
        itemHeight += 2
        itemHeight += 36
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
