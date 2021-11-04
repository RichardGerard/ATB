//
//  PostListViewController.swift
//  ATB
//
//  Created by YueXi on 4/24/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class PostGridViewController: BaseViewController {
    
    static let kStoryboardID = "PostGridViewController"
    class func instance() -> PostGridViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: PostGridViewController.kStoryboardID) as? PostGridViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    var postList = [PostModel]()
    @IBOutlet weak var clvPost: UICollectionView!
    
    var isBusiness = false
    var viewingUser: UserModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupCollectionView()
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(didUpdatePost(_:)), name: .DidUpdatePost, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didDeletePost(_:)), name: .DidDeletePost, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didDeleteProduct(_:)), name: .DidDeleteProduct, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didDeleteService(_:)), name: .DidDeleteService, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didReceiveProductStockChanged(_:)), name: .ProductStockChanged, object: nil)
        
        loadList()
    }
    
    private func setupCollectionView() {
        clvPost.showsVerticalScrollIndicator = false
        clvPost.alwaysBounceVertical = true
        clvPost.contentInsetAdjustmentBehavior = .always
        clvPost.backgroundColor = .colorGray7
        clvPost.dataSource = self
        clvPost.delegate = self
        clvPost.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        let width = (SCREEN_WIDTH - 2) / 2.0
        let itemSize = CGSize(width: width, height: width * 0.9)
        
        // customize collectionviewlayout
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.itemSize = itemSize
        clvPost.collectionViewLayout = layout
    }
    
    func loadList() {
        // if business added service or products before we get this page
        // no run reload
        guard clvPost != nil else { return }
        
        postList.removeAll()
        
        let isOwnProfile = (viewingUser == nil)
        let user_id = isOwnProfile ? g_myInfo.ID : viewingUser!.ID
        
        let params = [
            "token" : g_myToken,
            "user_id": user_id,
            "business": isBusiness ? "1" : "0"
        ]

        _ = ATB_Alamofire.POST(GET_USERS_POSTS, parameters: params as [String : AnyObject],showLoading: false, showSuccess: false, showError: false){
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
            
            // make sure to reload run in the main thread
            DispatchQueue.main.async {
                self.clvPost.reloadData()
            }
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

// MARK: - Notificaiton Handler
extension PostGridViewController {
    
    @objc private func didDeletePost(_ notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
              let postId = userInfo["post_id"] as? String,
              let index = postList.firstIndex(where: { $0.Post_ID == postId }) else { return }
        
        postList.remove(at: index)
        
        DispatchQueue.main.async {
            self.clvPost.reloadData()
            
            self.showDeleteNotification()
        }
    }
    
    @objc private func didUpdatePost(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let updated = object["updated"] as? PostModel else { return }
        
        if updated.isAdvice {
            // the updated will be a post model
            // advice does not have multiple posts
            guard let index = postList.firstIndex(where: { $0.Post_ID == updated.Post_ID }) else { return}
            
            // advice can get user type changed
            if updated.isBusinessPost == isBusiness {
                // the poster account type has not been changed
                // no need for business - it will get updated automatically
                // for user profile - we have two tabs(grid & list), items could not get updated
                postList[index].update(withPost: updated)
                DispatchQueue.main.async {
                    self.clvPost.reloadItems(at: [IndexPath(row: index, section: 0)])
                }
                
            } else {
                // the poster account type has been changed
                postList.remove(at: index)
                DispatchQueue.main.async {
                    self.clvPost.reloadData()
                }
            }
            
        } else {
            // the updated will be whether a product or a service
            // get all posts for the updated product or service
            let filtered = postList.filter({
                // grid view does not show group posts
                // so no need to check
                if updated.isSale {
                    guard let pid = $0.pid,
                          pid == updated.Post_ID else { return false }
                    
                    return true
                    
                } else {
                    guard let sid = $0.sid,
                          sid == updated.Post_ID else { return false }
                    
                    return true
                }
            })
            
            var reloadIndexes = [IndexPath]()
            for filteredPost in filtered {
                if updated.isSale {
                    filteredPost.update(withProduct: updated)
                    
                } else {
                    filteredPost.update(withService: updated)
                }
                
                if let index = postList.firstIndex(where: { $0.Post_ID == filteredPost.Post_ID }) {
                    reloadIndexes.append(IndexPath(row: index, section: 0))
                }
            }
            
            guard reloadIndexes.count > 0 else { return }
            
            DispatchQueue.main.async {
                self.clvPost.reloadItems(at: reloadIndexes)
            }
        }
    }
    
    @objc private func didDeleteProduct(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let deletedProductId = object["product_id"] as? String else { return }
        
        // get only none-deleted posts
        var updatedPosts = [PostModel]()
        for post in postList {
            guard post.isSale else {
                updatedPosts.append(post)
                continue
            }
            
            if post.isMultiplePost {
                if let productId = post.pid,
                   productId != deletedProductId {
                    updatedPosts.append(post)
                    
                    if let updatedPost = updatedPosts.last {
                        guard let index = updatedPost.group_posts.firstIndex(where: {
                            guard let productIdInGroup = $0.pid,
                                  productIdInGroup == deletedProductId else { return false }
                            
                            return true
                            
                        }) else {
                            continue
                        }
                        
                        updatedPost.group_posts.remove(at: index)
                    }
                }
                
            } else {
                if let productId = post.pid,
                   productId != deletedProductId {
                    updatedPosts.append(post)
                }
            }
        }
        
        postList.removeAll()
        postList.append(contentsOf: updatedPosts)

        DispatchQueue.main.async {
            self.clvPost.reloadData()
        }
    }
    
    @objc private func didDeleteService(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let deletedServiceId = object["service_id"] as? String else { return }
        
        // get only none-deleted posts
        var updatedPosts = [PostModel]()
        for post in postList {
            guard post.isService else {
                updatedPosts.append(post)
                continue
            }
            
            if post.isMultiplePost {
                if let serviceId = post.sid,
                   serviceId != deletedServiceId {
                    updatedPosts.append(post)
                    
                    if let updatedPost = updatedPosts.last {
                        guard let index = updatedPost.group_posts.firstIndex(where: {
                            guard let serviceIdInGroup = $0.sid,
                                  serviceIdInGroup == deletedServiceId else { return false }
                            
                            return true
                            
                        }) else {
                            continue
                        }
                        
                        updatedPost.group_posts.remove(at: index)
                    }
                }
                
            } else {
                if let serviceId = post.sid,
                   serviceId != deletedServiceId {
                    updatedPosts.append(post)
                }
            }
        }
        
        postList.removeAll()
        postList.append(contentsOf: updatedPosts)

        DispatchQueue.main.async {
            self.clvPost.reloadData()
        }
    }
    
    @objc private func didReceiveProductStockChanged(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let updatedProductId = object["product_id"] as? String,
              let updated = object["updated"] as? PostModel else { return }
        
        // get all posts for the updated product
        let filtered = postList.filter({
            // grid view does not show group posts
            guard $0.isSale,
                let pid = $0.pid,
                  pid == updatedProductId else { return false }
            
            return true
        })
        
        var reloadIndexes = [IndexPath]()
        for filteredPost in filtered {
            filteredPost.update(withProduct: updated)
            
            if let index = postList.firstIndex(where: { $0.Post_ID == filteredPost.Post_ID }) {
                reloadIndexes.append(IndexPath(row: index, section: 0))
            }
        }
        
        guard reloadIndexes.count > 0 else { return }
        
        DispatchQueue.main.async {
            self.clvPost.reloadItems(at: reloadIndexes)
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PostGridViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfilePostGridCell.reusableIdentifier, for: indexPath) as! ProfilePostGridCell
        // configure the cell
        let post = postList[indexPath.row]
        cell.configureCell(post, isScheduled: post.isScheduled)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPost = postList[indexPath.row]        
        // Here will be limitation with multiple post
        // no way to select 2nd or 3rd post, no way to display multiple posts in grid view
        getPostDetail(selectedPost)
    }
}
