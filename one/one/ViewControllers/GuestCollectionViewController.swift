//
//  GuestCollectionViewController.swift
//  one
//
//  Created by Kai Chen on 12/26/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse

private let numberOfPicsPerPage = 12

class GuestCollectionViewController: UICollectionViewController {
    
    var numberOfPosts = numberOfPicsPerPage
    
    var ptr: UIRefreshControl!
    
    var guestname: String = ""
    
    var uuids = [String]()
    var posts = [PFFile]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = guestname
        
        ptr = UIRefreshControl()
        ptr.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        collectionView?.addSubview(ptr)
        
        loadPosts()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            loadPosts()
        }
    }
    
    // MARK: Action
    
    func pullToRefresh() {
        collectionView?.reloadData()
        ptr.endRefreshing()
    }
    
    // MARK: Helpers
    
    func loadPosts() {
        let query = PFQuery(className: Post.modelName.rawValue)
        query.whereKey(User.id.rawValue, equalTo: guestname)
        query.limit = numberOfPosts
        query.findObjectsInBackground { [weak self](objects: [PFObject]?, error: Error?) in
            guard let strongSelf = self else {
                return
            }
            if error == nil {
                for object in objects! {
//                    strongSelf.uuids.append(object.value(forKey: User.uuid.rawValue) as! String)
                    strongSelf.posts.append(object.value(forKey: "picture") as! PFFile)
                }
                
                strongSelf.collectionView?.reloadData()
                strongSelf.numberOfPosts += numberOfPicsPerPage
            } else {
                print("error:\(error?.localizedDescription)")
            }
        }
        
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.pictureCell.rawValue, for: indexPath) as? PictureCollectionViewCell
    
        let post = posts[indexPath.row]
        
        post.getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell?.imageView.image = UIImage(data: data!)
            } else {
                print("error:\(error?.localizedDescription)")
            }
        }
    
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Identifier.homeHeaderView.rawValue, for: indexPath) as? HomeHeaderCollectionView

        headerView?.guestname = guestname
        headerView?.config()
        
        let query = PFUser.query()
        query?.whereKey(User.id.rawValue, equalTo: guestname)
        query?.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                let object = objects?.first
                headerView?.userNameLabel.text = object?.object(forKey: User.fullname.rawValue) as? String
                headerView?.bioLabel.text = object?.object(forKey: User.bio.rawValue) as? String
                let profileImageFile = object?.object(forKey: User.profileImage.rawValue) as? PFFile
                profileImageFile?.getDataInBackground(block: { (data: Data?, error: Error?) in
                    headerView?.profileImageView.image = UIImage(data: data!)
                })
            } else {
                print("error:\(error?.localizedDescription)")
            }
        })
        
        // Post count
        let postQuery = PFQuery(className: Post.modelName.rawValue)
        postQuery.whereKey(User.id.rawValue, equalTo: guestname)
        postQuery.countObjectsInBackground { (count: Int32, error: Error?) in
            if error == nil {
                headerView?.postsNumLabel.text = "\(count)"
            } else {
                print("error:\(error?.localizedDescription)")
            }
        }
        
        // Followers count
        let followerQuery = PFQuery(className: Follow.modelName.rawValue)
        followerQuery.whereKey(Follow.following.rawValue, equalTo: guestname)
        followerQuery.countObjectsInBackground { (count: Int32, error: Error?) in
            if error == nil {
                headerView?.followersNumLabel.text = "\(count)"
            } else {
                print("error:\(error?.localizedDescription)")
            }
        }
        
        // Following count
        let followingQuery = PFQuery(className: Follow.modelName.rawValue)
        followingQuery.whereKey(Follow.follower.rawValue, equalTo: guestname)
        followingQuery.countObjectsInBackground { (count: Int32, error: Error?) in
            if error == nil {
                headerView?.followingNumLabel.text = "\(count)"
            } else {
                print("error:\(error?.localizedDescription)")
            }
        }
        
        let postTap = UITapGestureRecognizer(target: self, action: #selector(postTapped))
        headerView?.postsNumLabel.addGestureRecognizer(postTap)
        
        let followerTap = UITapGestureRecognizer(target: self, action: #selector(followerTapped))
        headerView?.followersNumLabel.addGestureRecognizer(followerTap)
        
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(followingTapped))
        headerView?.followingNumLabel.addGestureRecognizer(followingTap)
        
        return headerView!
    }
    
    // MARK: Action
    
    func postTapped() {
        if !posts.isEmpty {
            let indexPath = IndexPath(row: 0, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    func followerTapped() {
        let followerVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.followerVC.rawValue) as? FollowersViewController
        
        self.navigationController?.pushViewController(followerVC!, animated: true)
    }
    
    func followingTapped() {
        let followingVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.followingVC.rawValue) as? FollowingViewController
        self.navigationController?.pushViewController(followingVC!, animated: true)
    }
}
