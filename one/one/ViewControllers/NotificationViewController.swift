//
//  NotificationViewController.swift
//  one
//
//  Created by Kai Chen on 1/26/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class NotificationViewController: UITableViewController {

    var notifications : [PFObject] = []

    var profileImageCache = NSCache<NSString, UIImage>()
    var postImageCache = NSCache<NSString, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "One"

        let username = PFUser.current()?.username
        let query = PFQuery(className: Notifications.modelName.rawValue)

        query.whereKey(Notifications.receiver.rawValue, equalTo: username!)
        query.findObjectsInBackground { [weak self](objects: [PFObject]?, error: Error?) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.notifications = objects!

            strongSelf.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.notificationViewCell.rawValue, for: indexPath) as? NotificationViewCell

        let notification = notifications[indexPath.row]

        guard let userid = notification[Notifications.sender.rawValue] as? String else {
            return cell!
        }

        cell?.usernameLabel.text = userid
        cell?.userid = userid
        cell?.delegate = self

        if let profileImage = profileImageCache.object(forKey: userid as NSString) {
            cell?.profileImageView.image = profileImage
        } else {
            let userQuery = PFUser.query()
            userQuery?.whereKey(User.id.rawValue, equalTo: userid)

            userQuery?.getFirstObjectInBackground(block: { (user: PFObject?, error: Error?) in
                let imageFile = user?[User.profileImage.rawValue] as? PFFile

                imageFile?.getDataInBackground(block: { [weak cell, weak self](data: Data?, error: Error?) in
                    guard let strongCell = cell, let strongSelf = self else {
                        return
                    }
                    let image = UIImage(data: data!)

                    strongSelf.profileImageCache.setObject(image!, forKey: userid as NSString)

                    DispatchQueue.main.async {
                        strongCell.profileImageView.image = image;
                    }
                })
            })
        }

        if let postUUID = notification[Notifications.postUUID.rawValue] as? String {
            cell?.postUUID = postUUID

            if let postImage = postImageCache.object(forKey: postUUID as NSString) {
                cell?.postImageView.image = postImage
            } else {
                let postQuery = PFQuery(className: Post.modelName.rawValue)
                postQuery.whereKey(Post.uuid.rawValue, equalTo: postUUID)

                postQuery.getFirstObjectInBackground(block: { (object: PFObject?, error: Error?) in
                    let imageFile = object?[Post.picture.rawValue] as? PFFile

                    imageFile?.getDataInBackground(block: { [weak cell, weak self](data: Data?, error: Error?) in
                        let image = UIImage(data: data!)

                        self?.postImageCache.setObject(image!, forKey: postUUID as NSString)

                        DispatchQueue.main.async {
                            cell?.postImageView.image = image;
                        }
                    })
                })
            }
        }

        let action = notification[Notifications.action.rawValue] as? String
        var actionStr: String?

        if action == NotificationsAction.like.rawValue {
            actionStr = "liked your post."
        } else if action == NotificationsAction.follow.rawValue {
            actionStr = "is following you."
        } else if action == NotificationsAction.mention.rawValue {
            actionStr = "mentioned you."
        } else {
            actionStr = "commented on your post."
        }

        cell?.actionLabel.text = actionStr

        return cell!
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension NotificationViewController: NotificationViewCellDelegate {
    func navigateToUserPage(_ userid: String?) {
        guard let userid = userid else {
            return
        }

        if userid == PFUser.current()?.username {
            let userVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.homeViewController.rawValue)
            self.navigationController?.pushViewController(userVC!, animated: true)
        } else {
            let userVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.guestViewController.rawValue) as? GuestCollectionViewController
            userVC?.guestname = userid

            self.navigationController?.pushViewController(userVC!, animated: true)
        }
    }

    func navigateToPostPage(_ postUUID: String?) {
        guard let postUUID = postUUID else {
            return
        }

        let postVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.postViewController.rawValue) as? PostViewController

        postVC?.postUUID = postUUID

        self.navigationController?.pushViewController(postVC!, animated: true)
    }
}
