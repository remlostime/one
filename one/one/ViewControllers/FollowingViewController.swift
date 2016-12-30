//
//  FollowingViewController.swift
//  one
//
//  Created by Kai Chen on 12/23/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class FollowingViewController: UITableViewController {
    
    var followings = [String]()
    var usernames = [String]()
    var profileImages = [PFFile]()

    let currentUsername = (PFUser.current()?.username)!

    var followerName = (PFUser.current()?.username)!

    let followingTitle = FollowUI.followingButtonText.rawValue

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = followingTitle
        
        loadFollowing()
    }
    
    func loadFollowing() {
        let followingQuery = PFQuery(className: Follow.modelName.rawValue)
        followingQuery.whereKey(Follow.follower.rawValue, equalTo: followerName)
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
