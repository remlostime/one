//
//  FollowersViewController.swift
//  one
//
//  Created by Kai Chen on 12/23/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class FollowersViewController: UITableViewController {
    
    var followers = [String]()
    var followings = [String]()
    var profileImages = [PFFile]()
    var usernames = [String]()

    let followerTitle = "Followers"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = followerTitle

        loadFollowing()
        loadFollowers()
    }
    
    func loadFollowing() {
        let followingQuery = PFQuery(className: Follow.modelName.rawValue)
        let currentUsername = (PFUser.current()?.username)!
        followingQuery.whereKey(Follow.follower.rawValue, equalTo: currentUsername)
        followingQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                self.followings.removeAll()
                
                for object in objects! {
                    self.followings.append(object.value(forKey: Follow.following.rawValue) as! String)
                }
            }
        }
    }

    func loadFollowers() {
        let followQuery = PFQuery(className: Follow.modelName.rawValue)
        let currentUsername = (PFUser.current()?.username)!
        followQuery.whereKey(Follow.following.rawValue, equalTo: currentUsername)
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
        if username == (PFUser.current()?.username)! {
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.homeViewController.rawValue) as? HomeCollectionViewController
            self.navigationController?.pushViewController(homeVC!, animated: true)
        } else {
            let guestVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.guestViewController.rawValue) as? GuestCollectionViewController
            guestVC?.guestname = username!
            self.navigationController?.pushViewController(guestVC!, animated: true)
        }
    }
}
