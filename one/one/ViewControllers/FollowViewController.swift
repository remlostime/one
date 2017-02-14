//
//  FollowViewController.swift
//  one
//
//  Created by Kai Chen on 2/13/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse

enum FollowViewStatus: String {
    case Followers
    case Following
}

class FollowViewController: UITableViewController {
    var followers = [String]()
    var followings = [String]()
    var profileImages = [PFFile]()
    var usernames = [String]()

    var status: FollowViewStatus = .Followers

    let currentUserID = PFUser.current()?.username

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = status.rawValue

        switch status {
        case .Followers:
            loadFollowers()
        case .Following:
            loadFollowing()
        }
    }

    func loadFollowing() {
        guard let currentUserID = currentUserID else {
            return
        }

        let followingQuery = PFQuery(className: Follow.modelName.rawValue)
        followingQuery.whereKey(Follow.follower.rawValue, equalTo: currentUserID)
        followingQuery.findObjectsInBackground { [weak self](objects: [PFObject]?, error: Error?) in
            if error == nil {
                guard let strongSelf = self else {
                    return
                }

                strongSelf.followings.removeAll()

                for object in objects! {
                    strongSelf.followings.append(object.value(forKey: Follow.following.rawValue) as! String)
                }

                let query = PFUser.query()
                query?.whereKey(User.id.rawValue, containedIn: strongSelf.followings)
                query?.addDescendingOrder(Info.createTime.rawValue)
                query?.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                    if error == nil {
                        strongSelf.usernames.removeAll()
                        strongSelf.profileImages.removeAll()

                        for object in objects! {
                            strongSelf.usernames.append(object.object(forKey: User.id.rawValue) as! String)
                            strongSelf.profileImages.append(object.object(forKey: User.profileImage.rawValue) as! PFFile)
                        }

                        strongSelf.tableView.reloadData()
                    } else {
                        print("error:\(error!.localizedDescription)")
                    }
                })
            }
        }
    }

    func loadFollowers() {
        guard let currentUserID = currentUserID else {
            return
        }

        let followingQuery = PFQuery(className: Follow.modelName.rawValue)
        followingQuery.whereKey(Follow.follower.rawValue, equalTo: currentUserID)
        followingQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                self.followings.removeAll()

                for object in objects! {
                    self.followings.append(object.value(forKey: Follow.following.rawValue) as! String)
                }
            }
        }

        let followQuery = PFQuery(className: Follow.modelName.rawValue)
        followQuery.whereKey(Follow.following.rawValue, equalTo: currentUserID)
        followQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                self.followers.removeAll()

                for object in objects! {
                    self.followers.append(object.value(forKey: Follow.follower.rawValue) as! String)
                }

                let query = PFUser.query()
                query?.whereKey(User.id.rawValue, containedIn: self.followers)
                query?.addDescendingOrder(Info.createTime.rawValue)
                query?.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                    if error == nil {
                        self.usernames.removeAll()
                        self.profileImages.removeAll()

                        for object in objects! {
                            self.usernames.append(object.object(forKey: User.id.rawValue) as! String)
                            self.profileImages.append(object.object(forKey: User.profileImage.rawValue) as! PFFile)
                        }

                        self.tableView.reloadData()
                    } else {
                        print("error:\(error!.localizedDescription)")
                    }
                })
            } else {
                print("error:\(error!.localizedDescription)")
            }
        }

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.followViewCell.rawValue, for: indexPath) as? FollowViewCell

        cell?.tag = indexPath.row
        let username = usernames[indexPath.row]
        cell?.usernameLabel?.text = username

        if followings.contains(username) {
            cell?.configure(withState: .following)
        } else {
            cell?.configure(withState: .notFollowing)
        }

        let pfFile = profileImages[indexPath.row]
        pfFile.getDataInBackground { (data: Data?, error: Error?) in
            let image = UIImage(data: data!)
            cell?.profielImageView?.image = image
        }

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? FollowViewCell

        let username = cell?.usernameLabel.text
        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.profileViewController.rawValue) as? ProfileViewController
        homeVC?.userid = username
        self.navigationController?.pushViewController(homeVC!, animated: true)
    }
}
