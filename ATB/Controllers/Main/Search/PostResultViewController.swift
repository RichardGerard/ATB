//
//  PostResultViewController.swift
//  ATB
//
//  Created by YueXi on 3/31/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit

class PostResultViewController: BaseViewController {
    
    @IBOutlet weak var tblResults: UITableView!

    private var searchResults = [PostModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .clear
        
        // setup feed table view
        tblResults.register(UINib(nibName: "TextPostCell", bundle: nil), forCellReuseIdentifier: TextPostCell.reuseIdentifier)
        tblResults.register(UINib(nibName: "MediaPostCell", bundle: nil), forCellReuseIdentifier: MediaPostCell.reuseIdentifier)
        tblResults.register(UINib(nibName: "TextPollPostCell", bundle: nil), forCellReuseIdentifier: TextPollPostCell.reuseIdentifier)
        tblResults.register(UINib(nibName: "MediaPollPostCell", bundle: nil), forCellReuseIdentifier: MediaPollPostCell.reuseIdentifier)
        tblResults.register(UINib(nibName: "MultiplePostCell", bundle: nil), forCellReuseIdentifier: MultiplePostCell.reuseIdentifier)
        
        tblResults.backgroundColor = .clear
        tblResults.showsVerticalScrollIndicator = false
        tblResults.separatorStyle = .none
        tblResults.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tblResults.tableFooterView = UIView()
        
        tblResults.dataSource = self
        tblResults.delegate = self
    }
    
    func reload(with results: [PostModel]) {
        // replace search results
        searchResults.removeAll()
        searchResults.append(contentsOf: results)
        
        // reload table view
        DispatchQueue.main.async {
            self.tblResults.reloadData()
            self.tblResults.scroll(to: .top, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource , UITableViewDelegate
extension PostResultViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = searchResults[indexPath.row]
        
        if post.isMultiplePost {
            let cell = tableView.dequeueReusableCell(withIdentifier: MultiplePostCell.reuseIdentifier, for: indexPath)
            
            return cell
            
        } else {
            if (post.Post_Type == "Poll") {
                if post.isTextPost {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TextPollPostCell.reuseIdentifier, for: indexPath) as! TextPollPostCell
                    // configure the cell
                    cell.configureCell(post, in: 2)
                    
                    cell.profileTapBlock = {
                        let ownUser = g_myInfo
                        
                        if post.Post_User_ID == ownUser.ID {
                            self.openMyProfile(forBusiness: post.isBusinessPost)
                            
                        } else {
                            self.openPosterProfile(forPost: post)
                        }
                    }
                    
                    cell.delegate = self

                    return cell
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: MediaPollPostCell.reuseIdentifier, for: indexPath) as! MediaPollPostCell
                    // configure the cell
                    cell.configureCell(post, in: 2)
                    
                    cell.profileTapBlock = {
                        let ownUser = g_myInfo
                        
                        if post.Post_User_ID == ownUser.ID {
                            self.openMyProfile(forBusiness: post.isBusinessPost)
                            
                        } else {
                            self.openPosterProfile(forPost: post)
                        }
                    }
                    
                    cell.delegate = self

                    return cell
                }
                
            } else {
                if(post.Post_Media_Type == "Text") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: TextPostCell.reuseIdentifier, for: indexPath) as! TextPostCell
                    // configure the cell
                    cell.configureCell(post, in: 2)
                    
                    cell.likeBlock = {
                        print("like tapped")
                    }
                    
                    cell.profileTapBlock = {
                        let ownUser = g_myInfo
                        
                        if post.Post_User_ID == ownUser.ID {
                            self.openMyProfile(forBusiness: post.isBusinessPost)
                            
                        } else {
                            self.openPosterProfile(forPost: post)
                        }
                    }
                    
                    return cell
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: MediaPostCell.reuseIdentifier, for: indexPath) as! MediaPostCell
                    // configure the cell
                    cell.configureCell(post, in: 2)
                    
                    cell.likeBlock = {
                        print("like tapped")
                    }
                    
                    cell.profileTapBlock = {
                        let ownUser = g_myInfo
                        
                        if post.Post_User_ID == ownUser.ID {
                            self.openMyProfile(forBusiness: post.isBusinessPost)
                            
                        } else {
                            self.openPosterProfile(forPost: post)
                        }
                    }
                    
                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let post = searchResults[indexPath.row]
        guard post.isMultiplePost,
              let multiplePostCell = cell as? MultiplePostCell else { return }
        multiplePostCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = searchResults[indexPath.row]
        
        if (post.isMultiplePost) {
            return MultiplePostCell.cellHeight(post)
            
        } else {
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
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPost = searchResults[indexPath.row]
        
        getPostDetail(selectedPost)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PostResultViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let post = searchResults[collectionView.tag - 300]
        return post.group_posts.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let multiplePostCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: MultiplePostCollectionCell.reuseIdentifier, for: indexPath) as! MultiplePostCollectionCell
        // configure the cell
        let post = searchResults[collectionView.tag - 300]
        let row = indexPath.row
        
        multiplePostCollectionCell.configureCell(row == 0 ? post : post.group_posts[row - 1])
        
        multiplePostCollectionCell.likeBlock = {
            print("like tapped")
        }
        
        multiplePostCollectionCell.profileTapBlock = {
            let ownUser = g_myInfo
            
            if post.Post_User_ID == ownUser.ID {
                self.openMyProfile(forBusiness: post.isBusinessPost)
                
            } else {
                self.openPosterProfile(forPost: post)
            }
        }
        
        return multiplePostCollectionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = searchResults[collectionView.tag - 300]
        let row = indexPath.row
        
        // only sales & service has multiple post
        // so no need to check the post type
        getPostDetail(row == 0 ? post : post.group_posts[row - 1])
    }
}

// MARK: - PollVoteDelegate
extension PostResultViewController: PollVoteDelegate {
    
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
        _ = ATB_Alamofire.POST(ADD_VOTE, parameters: params as [String : AnyObject], showLoading: false, showSuccess: false, showError: false) { (result, responseObject) in
            self.hideIndicator()

            if result {
                // add the new vote made
                // { $0.Post_ID == post.Post_ID }
                if let indexForPost = self.searchResults.firstIndex(where: { (item) -> Bool in item.Post_ID == post.Post_ID }) {
                    self.searchResults[indexForPost].Post_PollOptions[index].votes.append(ownID)
                    
                    completion(true, self.searchResults[indexForPost])
                }
            }
        }
    }
}
