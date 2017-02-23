//
//  NotificationViewController.swift
//  one
//
//  Created by Kai Chen on 1/26/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse
import RandomColorSwift

class NotificationViewController: UITableViewController {

    var notifications : [PFObject] = []

    var profileImageCache = NSCache<NSString, UIImage>()
    var postImageCache = NSCache<NSString, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "One"

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

    override func viewDidAppear(_ animated: Bool) {
        let username = PFUser.current()?.username
        let query = PFQuery(className: Notifications.modelName.rawValue)

        query.whereKey(Notifications.receiver.rawValue, equalTo: username!)
        query.whereKey(Notifications.seen.rawValue, notEqualTo: true)

        query.findObjectsInBackground { [weak self](objects: [PFObject]?, error: Error?) in
            var likeCount = 0
            var commentCount = 0
            var mentionCount = 0

            for object in objects! {
                let action = object[Notifications.action.rawValue] as! String
                switch action {
                case "comment":
                    commentCount += 1
                case "like":
                    likeCount += 1
                case "mention":
                    mentionCount += 1
                default:
                    break
                }

                object[Notifications.action.rawValue] = true
                object.saveEventually()
            }

            self?.promptNotificationBar(likeCount, commentCount: commentCount, mentionCount: mentionCount)
        }
    }

    func promptNotificationBar(_ likeCount: Int, commentCount: Int, mentionCount: Int) {
        let oneSectionWidth = 40
        let halfSectionWidth = 20

        var width = 0
        let likeView = UIView(frame: CGRect(x: 0, y: 0, width: oneSectionWidth, height: 20))
        if likeCount > 0 {
            let likeImage = UIImage(named: "like-notification")
            let likeImageView = UIImageView(image: likeImage)
            let likeLabel = UILabel(frame: CGRect(x: halfSectionWidth, y: 0, width: halfSectionWidth, height: 20))
            likeLabel.text = "\(likeCount)"
            likeLabel.textColor = .white
            width += oneSectionWidth

            likeView.addSubview(likeImageView)
            likeView.addSubview(likeLabel)
        }

        let commentView = UIView(frame: CGRect(x: width, y: 0, width: oneSectionWidth, height: 20))
        if commentCount > 0 {
            let commentImage = UIImage(named: "comment-notification")
            let commentImageView = UIImageView(image: commentImage)
            let commentLabel = UILabel(frame: CGRect(x: halfSectionWidth, y: 0, width: halfSectionWidth, height: 20))
            commentLabel.text = "\(commentCount)"
            commentLabel.textColor = .white
            width += oneSectionWidth

            commentView.addSubview(commentImageView)
            commentView.addSubview(commentLabel)
        }

        let mentionView = UIView(frame: CGRect(x: width, y: 0, width: oneSectionWidth, height: 20))
        if mentionCount > 0 {
            let mentionImage = UIImage(named: "comment-notification")
            let mentionImageView = UIImageView(image: mentionImage)
            let mentionLabel = UILabel(frame: CGRect(x: halfSectionWidth, y: 0, width: halfSectionWidth, height: 20))
            mentionLabel.text = "\(mentionCount)"
            mentionLabel.textColor = .white
            width += oneSectionWidth

            mentionView.addSubview(mentionImageView)
            mentionView.addSubview(mentionLabel)
        }

        let notificationView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 20))
        if likeCount > 0 {
            notificationView.addSubview(likeView)
        }
        if commentCount > 0 {
            notificationView.addSubview(commentView)
        }
        if mentionCount > 0 {
            notificationView.addSubview(mentionView)
        }

        notificationView.backgroundColor = .red
        notificationView.layer.cornerRadius = 5

        let height = self.tabBarController?.tabBar.frame.height
        let itemWidth = (self.tabBarController?.tabBar.frame.width)! / ((CGFloat)((self.tabBarController?.tabBar.items?.count)!))

        let center = CGPoint(x: itemWidth * 3 + itemWidth / 2, y: self.view.frame.height - (self.navigationController?.navigationBar.frame.height)! - height! - 40)

        notificationView.center = center

        UIView.animate(withDuration: 1.0, delay: 1.0, options: .curveEaseIn, animations: {
            self.view.addSubview(notificationView)
        }, completion: { _ in
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { _ in
                notificationView.removeFromSuperview()
            })
        })
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

        let userVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.profileViewController.rawValue) as? ProfileViewController
        userVC?.userid = userid
        self.navigationController?.pushViewController(userVC!, animated: true)
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
