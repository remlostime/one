//
//  ProfileViewController.swift
//  one
//
//  Created by Kai Chen on 2/13/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse

private let numberOfPicsPerPage = 12

class ProfileViewController: UICollectionViewController {

    var uuids = [String]()
    var pictures = [PFFile]()

    var imageCache = NSCache<NSString, UIImage>()

    var numberOfPosts = numberOfPicsPerPage

    var ptr: UIRefreshControl!

    var userid = PFUser.current()?.username

    // MARK: Lifecyle

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if userid != PFUser.current()?.username {
            self.navigationItem.rightBarButtonItem = nil
        }

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .newPostIsSent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserInfo), name: .updateUserInfo, object: nil)

        self.navigationItem.title = userid

        ptr = UIRefreshControl()
        ptr.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        collectionView?.addSubview(ptr)

        loadPosts(false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)]
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            loadPosts(true)
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: Identifier.homeHeaderView.rawValue,
                                                                         for: indexPath) as? HomeHeaderCollectionView
        headerView?.username = userid!
        headerView?.delegate = self
        // UI setup
        headerView?.config()

        if userid == PFUser.current()?.username {

            headerView?.userNameLabel.text = (PFUser.current()?.object(forKey: User.fullname.rawValue)) as? String
            headerView?.bioLabel.text = (PFUser.current()?.object(forKey: User.bio.rawValue)) as? String

            let profileImageQuery = PFUser.current()?.object(forKey: User.profileImage.rawValue) as! PFFile
            profileImageQuery.getDataInBackground { (data: Data?, error: Error?) in
                let image = UIImage(data: data!)
                headerView?.profileImageView.image = image
            }
        } else {
            let query = PFUser.query()
            query?.whereKey(User.id.rawValue, equalTo: userid!)
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
        }

        // Posts, followers and followings calculate

        let postsQuery = PFQuery(className: Post.modelName.rawValue)
        postsQuery.whereKey(User.id.rawValue, equalTo: (userid)!)
        postsQuery.countObjectsInBackground { (count: Int32, error: Error?) in
            if error == nil {
                headerView?.postsNumLabel.text = "\(count)"
            }
        }

        let followersQuery = PFQuery(className: Follow.modelName.rawValue)
        followersQuery.whereKey(Follow.following.rawValue, equalTo: (userid)!)
        followersQuery.countObjectsInBackground { (count: Int32, error: Error?) in
            if error == nil {
                headerView?.followersNumLabel.text = "\(count)"
            }
        }

        let followingQuery = PFQuery(className: Follow.modelName.rawValue)
        followingQuery.whereKey(Follow.follower.rawValue, equalTo: (userid)!)
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

        cell.tag = indexPath.row

        let key = "\(indexPath.row)"
        if let image = imageCache.object(forKey: key as NSString) {
            cell.imageView.image = image
        } else {
            pictures[indexPath.row].getDataInBackground { [weak cell, weak self](data: Data?, error: Error?) in
                guard let strongCell = cell, let strongSelf = self else {
                    return
                }

                if error == nil {
                    DispatchQueue.main.async {
                        if strongCell.tag == indexPath.row {
                            let image = UIImage(data: data!)
                            strongSelf.imageCache.setObject(image!, forKey: key as NSString)
                            strongCell.imageView.image = image
                        }
                    }
                } else {
                    print("error:\(error?.localizedDescription)")
                }
            }
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let uuid = uuids[indexPath.row]
        let postViewController = self.storyboard?.instantiateViewController(withIdentifier: Identifier.postViewController.rawValue) as? PostViewController
        postViewController?.postUUID = uuid

        navigationController?.pushViewController(postViewController!, animated: true)
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
        let followingVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.followVC.rawValue) as! FollowViewController
        followingVC.status = .Following

        self.navigationController?.pushViewController(followingVC, animated: true)
    }

    func followerLabelTapped() {
        let followerVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.followVC.rawValue) as! FollowViewController
        followerVC.status = .Followers

        self.navigationController?.pushViewController(followerVC, animated: true)
    }

    // MARK: Helpers

    func loadPosts(_ loadingMore: Bool) {
        let query = PFQuery(className: Post.modelName.rawValue)
        query.whereKey(User.id.rawValue, equalTo: (userid)!)
        if (!loadingMore) {
            numberOfPosts = numberOfPicsPerPage
        }
        query.limit = numberOfPosts
        query.findObjectsInBackground { [weak self](objects: [PFObject]?, error: Error?) in
            guard let strongSelf = self else {
                return
            }

            if error == nil {
                strongSelf.uuids.removeAll()
                strongSelf.pictures.removeAll()

                for object in objects! {
                    strongSelf.uuids.append(object.value(forKey: Post.uuid.rawValue) as! String)
                    strongSelf.pictures.append(object.value(forKey: Post.picture.rawValue) as! PFFile)
                }

                strongSelf.collectionView?.reloadData()

                strongSelf.numberOfPosts += numberOfPicsPerPage
            } else {
                print(error!.localizedDescription)
            }
        }
    }

    func reloadData() {
        loadPosts(false)
    }

    func updateUserInfo() {
        reloadData()
    }

    func pullToRefresh() {
        ptr.endRefreshing()

        loadPosts(false)
    }
}

extension ProfileViewController: HomeHeaderCollectionViewDelegate {
    func navigateToEditPage() {
        let editVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.editUserInfoViewController.rawValue) as? EditUserInfoViewController
        let navigationVC = UINavigationController(rootViewController: editVC!)

        present(navigationVC, animated: true, completion: nil)
    }
}
