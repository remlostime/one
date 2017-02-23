//
//  FeedViewController.swift
//  one
//
//  Created by Kai Chen on 1/20/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class FeedViewController: UITableViewController {

    var postUUIDs: [String?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "One"

        loadPosts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.titleTextAttributes =
            [NSFontAttributeName: UIFont(name: "Vonique64-Bold", size: 26)!]
    }

    func loadPosts() {
        let userid = PFUser.current()?.username

        let query = PFQuery(className: Follow.modelName.rawValue)

        query.whereKey(Follow.follower.rawValue, equalTo: userid!)

        var following: [String?] = []
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            for object in objects! {
                following.append(object[Follow.following.rawValue] as! String?)
            }
            let postQuery = PFQuery(className: Post.modelName.rawValue)
            postQuery.whereKey(Post.username.rawValue, containedIn: following)
            postQuery.order(byDescending: "createdAt")

            postQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
                for object in objects! {
                    self.postUUIDs.append(object[Post.uuid.rawValue] as! String?)
                }

                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postUUIDs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.postHeaderViewCell.rawValue, for: indexPath) as? PostHeaderViewCell

        cell?.delegate = self

        let uuid = postUUIDs[indexPath.row]
        cell?.config(uuid!)

        return cell!
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
    }
}

extension FeedViewController: PostHeaderViewCellDelegate {
    func navigateToUserPage(_ username: String?) {
        guard let username = username else {
            return
        }

        let homeVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.profileViewController.rawValue) as? ProfileViewController
        homeVC?.userid = username
        self.navigationController?.pushViewController(homeVC!, animated: true)
    }

    func showActionSheet(_ alertController: UIAlertController?) {
        self.present(alertController!, animated: true, completion: nil)
    }

    func navigateToPostPage(_ uuid: String?) {
        guard let uuid = uuid else {
            return
        }

        let dstVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.commentViewController.rawValue) as? CommentViewController
        dstVC?.hidesBottomBarWhenPushed = true
        dstVC?.postUUID = uuid

        self.navigationController?.pushViewController(dstVC!, animated: true)
    }
}
