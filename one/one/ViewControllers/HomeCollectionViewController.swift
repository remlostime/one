//
//  HomeCollectionViewController.swift
//  one
//
//  Created by Kai Chen on 12/22/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse

private let numberOfPicsPerPage = 10

class HomeCollectionViewController: UICollectionViewController {
    
//    var uuids = [String]()
    var pictures = [PFFile]()
    
    var ptr: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = PFUser.current()?.username
        
        let ptr = UIRefreshControl()
        ptr.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        collectionView?.addSubview(ptr)
        
        loadPosts()
    }
    
    func pullToRefresh() {
        collectionView?.reloadData()
        
        ptr.endRefreshing()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: Identifier.homeHeaderView.rawValue,
                                                                         for: indexPath) as? HomeHeaderCollectionView
        // UI setup
        headerView?.config()

        headerView?.userNameLabel.text = (PFUser.current()?.object(forKey: User.fullname.rawValue)) as? String
        headerView?.bioLabel.text = (PFUser.current()?.object(forKey: User.bio.rawValue)) as? String

        let profileImageQuery = PFUser.current()?.object(forKey: User.profileImage.rawValue) as! PFFile
        profileImageQuery.getDataInBackground { (data: Data?, error: Error?) in
            let image = UIImage(data: data!)
            headerView?.profileImageView.image = image
        }
        
        // Posts, followers and followings calculate
        
        let postsQuery = PFQuery(className: Post.modelName.rawValue)
        postsQuery.whereKey(User.id.rawValue, equalTo: (PFUser.current()?.username)!)
        postsQuery.countObjectsInBackground { (count: Int32, error: Error?) in
            if error == nil {
                headerView?.postsNumLabel.text = "\(count)"
            }
        }
        
        let followersQuery = PFQuery(className: Follow.modelName.rawValue)
        followersQuery.whereKey(Follow.following.rawValue, equalTo: (PFUser.current()?.username)!)
        followersQuery.countObjectsInBackground { (count: Int32, error: Error?) in
            if error == nil {
                headerView?.followersNumLabel.text = "\(count)"
            }
        }
        
        let followingQuery = PFQuery(className: Follow.modelName.rawValue)
        followingQuery.whereKey(Follow.follower.rawValue, equalTo: (PFUser.current()?.username)!)
        followingQuery.countObjectsInBackground { (count: Int32, error: Error?) in
            if error == nil {
                headerView?.followingNumLabel.text = "\(count)"
            }
        }
        
        let postGesture = UITapGestureRecognizer(target: self, action: #selector(postLabelTapped))
        headerView?.postsNumLabel.addGestureRecognizer(postGesture)
        
        let followingGesture = UITapGestureRecognizer(target: self, action: #selector(followingLabelTapped))
        headerView?.followingNumLabel.addGestureRecognizer(followingGesture)
        
        let followerGesture = UITapGestureRecognizer(target: self, action: #selector(followerLabelTapped))
        headerView?.followersNumLabel.addGestureRecognizer(followerGesture)

        return headerView!
    }
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.pictureCell.rawValue, for: indexPath) as! PictureCollectionViewCell
        
        pictures[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.imageView.image = UIImage(data: data!)
            } else {
                print("error:\(error?.localizedDescription)")
            }
        }
    
        return cell
    }
    
    // MARK: Actions
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        PFUser.logOutInBackground { (error: Error?) in
            if error == nil {
                UserDefaults.standard.removeObject(forKey: User.id.rawValue)
                UserDefaults.standard.synchronize()
                
                let signInVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.signInViewController.rawValue) as? SignInViewController
                let appDelegate: AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
                appDelegate.window?.rootViewController = signInVC
            }
        }
    }
    
    func postLabelTapped() {
        if !pictures.isEmpty {
            let indexPath = NSIndexPath(row: 0, section: 0)
            collectionView?.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
        }
    }
    
    func followingLabelTapped() {
        let followingVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.followingVC.rawValue) as! FollowingViewController
        
        self.navigationController?.pushViewController(followingVC, animated: true)
    }
    
    func followerLabelTapped() {
        let followerVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.followerVC.rawValue) as! FollowersViewController
        
        self.navigationController?.pushViewController(followerVC, animated: true)
    }
    
    // MARK: Helpers
    
    func loadPosts() {
        let query = PFQuery(className: Post.modelName.rawValue)
        query.whereKey(User.id.rawValue, equalTo: (PFUser.current()?.username)!)
        query.limit = numberOfPicsPerPage
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
//                self.uuids.removeAll()
                self.pictures.removeAll()
                
                for object in objects! {
//                    self.uuids.append(object.value(forKey: User.uuid.rawValue) as! String)
                    self.pictures.append(object.value(forKey: Post.picture.rawValue) as! PFFile)
                }
                
                self.collectionView?.reloadData()
            } else {
                print(error!.localizedDescription)
            }
        }
    }
}
