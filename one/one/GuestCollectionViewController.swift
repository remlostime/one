//
//  GuestCollectionViewController.swift
//  one
//
//  Created by Kai Chen on 12/26/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class GuestCollectionViewController: UICollectionViewController {
    
    let numberOfPostsPerPage = 10
    
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
    
    // MARK: Action
    
    func pullToRefresh() {
        collectionView?.reloadData()
        ptr.endRefreshing()
    }
    
    // MARK: Helpers
    
    func loadPosts() {
        let query = PFQuery(className: "Post")
        query.whereKey("username", equalTo: guestname)
        query.limit = numberOfPostsPerPage
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                for object in objects! {
                    self.uuids.append(object.value(forKey: "uuid") as! String)
                    self.posts.append(object.value(forKey: "picture") as! PFFile)
                }
                
                self.collectionView?.reloadData()
            } else {
                print("error:\(error?.localizedDescription)")
            }
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pictureCell", for: indexPath) as? PictureCollectionViewCell
    
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
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "homeHeaderView", for: indexPath) as? HomeHeaderCollectionView
        
        let query = PFUser.query()
        query?.whereKey("username", equalTo: guestname)
        query?.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                let object = objects?.first
                headerView?.userNameLabel.text = object?.object(forKey: "fullname") as? String
                headerView?.bioLabel.text = object?.object(forKey: "bio") as? String
                let profileImageFile = object?.object(forKey: "profile_image") as? PFFile
                profileImageFile?.getDataInBackground(block: { (data: Data?, error: Error?) in
                    headerView?.profileImageView.image = UIImage(data: data!)
                })
            } else {
                print("error:\(error?.localizedDescription)")
            }
        })
        
        // Show current user follow the guest or not
        let followQuery = PFQuery(className: "Follow")
        followQuery.whereKey("follower", equalTo: (PFUser.current()?.username)!)
        followQuery.whereKey("following", equalTo: guestname)
        followQuery.countObjectsInBackground { (count: Int32, error: Error?) in
            if error == nil {
                if count == 0 {
                    headerView?.editButton.setTitle("Follow", for: .normal)
                    headerView?.editButton.backgroundColor = .blue
                } else {
                    headerView?.editButton.setTitle("Following", for: .normal)
                    headerView?.editButton.backgroundColor = .gray
                }
            } else {
                print("error:\(error?.localizedDescription)")
            }
        }
        
        // Post count
        let postQuery = PFQuery(className: "Post")
        postQuery.whereKey("username", equalTo: guestname)
        postQuery.countObjectsInBackground { (count: Int32, error: Error?) in
            if error == nil {
                headerView?.postsNumLabel.text = "\(count)"
            } else {
                print("error:\(error?.localizedDescription)")
            }
        }
        
        // Followers count
        let followerQuery = PFQuery(className: "Follow")
        followerQuery.whereKey("following", equalTo: guestname)
        followerQuery.countObjectsInBackground { (count: Int32, error: Error?) in
            if error == nil {
                headerView?.followersNumLabel.text = "\(count)"
            } else {
                print("error:\(error?.localizedDescription)")
            }
        }
        
        // Following count
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("follower", equalTo: guestname)
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
        let followerVC = self.storyboard?.instantiateViewController(withIdentifier: "followerVC") as? FollowersViewController
        
        self.navigationController?.pushViewController(followerVC!, animated: true)
    }
    
    func followingTapped() {
        let followingVC = self.storyboard?.instantiateViewController(withIdentifier: "followingVC") as? FollowingViewController
        self.navigationController?.pushViewController(followingVC!, animated: true)
    }
    
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
