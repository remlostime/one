//
//  PostHeaderViewCell.swift
//  one
//
//  Created by Kai Chen on 1/3/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse

protocol PostHeaderViewCellDelegate {
    func navigateToUserPage(_ username: String?)
    func showActionSheet(_ alertController: UIAlertController?)
    func navigateToPostPage(_ uuid: String?)
}

class PostHeaderViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!

    @IBOutlet var profileUsernameButton: UIButton!

    @IBOutlet var postTimeLabel: UILabel!

    @IBOutlet var postImageView: UIImageView!

    @IBOutlet var likeButton: UIButton!

    @IBOutlet var commentButton: UIButton!

    @IBOutlet var moreButton: UIButton!

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var heartImageView: UIImageView!

    @IBOutlet var likeLabel: UILabel!
    
    var delegate: PostHeaderViewCellDelegate?

    var isLiked: Bool?
    var uuid: String?

    override func awakeFromNib() {
        super.awakeFromNib()

        let doubleTapLikeGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapLike))
        doubleTapLikeGesture.numberOfTapsRequired = 2
        postImageView.addGestureRecognizer(doubleTapLikeGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configLike() {
        isLiked = false

        likeButton.setImage(UIImage(imageLiteralResourceName: "unlike"), for: .normal)

        let query = PFQuery(className: Like.modelName.rawValue)
        query.whereKey(Like.postID.rawValue, equalTo: uuid)
        let username = PFUser.current()?.username!
        query.whereKey(Like.username.rawValue, equalTo: username)
        query.findObjectsInBackground(block: { [weak self](objects: [PFObject]?, error: Error?) in
            guard error == nil else {
                return
            }

            guard let strongSelf = self else {
                return
            }

            guard let _ = objects?.first else {
                return
            }

            strongSelf.isLiked = true
            strongSelf.likeButton.setImage(UIImage(imageLiteralResourceName: "like"), for: .normal)
        })
    }

    func config(_ uuid: String) {
        self.uuid = uuid

        configLike()

        let likesQuery = PFQuery(className: Like.modelName.rawValue)
        likesQuery.whereKey(Like.postID.rawValue, equalTo: uuid)
        likesQuery.countObjectsInBackground { [weak self](count: Int32, error: Error?) in
//            self?.likeLabel.text = "\(count) likes"
        }

        let postQuery = PFQuery(className: Post.modelName.rawValue)
        postQuery.whereKey(Post.uuid.rawValue, equalTo: uuid)
        postQuery.findObjectsInBackground { [weak self](objects: [PFObject]?, error: Error?) in
            guard error == nil else {
                print("error:\(error?.localizedDescription)")
                return
            }

            guard let object = objects?.first, let strongSelf = self else {
                return
            }

            let profileImageFile = object[Post.profileImage.rawValue] as? PFFile
            profileImageFile?.getDataInBackground(block: { (data: Data?, error: Error?) in
                guard error == nil else {
                    return
                }

                if let data = data {
                    strongSelf.profileImageView.image = UIImage(data: data)
                }
            })

            let username = object[Post.username.rawValue] as? String
            strongSelf.profileUsernameButton.setTitle(username, for: .normal)

            let createTime = object.createdAt
            strongSelf.postTimeLabel.text = strongSelf.timeDescription(createTime!)

            let postImageFile = object[Post.picture.rawValue] as? PFFile
            postImageFile?.getDataInBackground(block: { (data: Data?, error: Error?) in
                guard error == nil else {
                    return
                }

                if let data = data {
                    strongSelf.postImageView.image = UIImage(data: data)
                }
            })

            let title = object[Post.title.rawValue] as? String
            strongSelf.titleLabel.text = title
        }
    }

    func timeDescription(_ postTime: Date) -> String {
        let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
        let diff = NSCalendar.current.dateComponents(components, from: postTime)

        if diff.second! <= 0 {
            return "now"
        }

        if diff.minute == 0 {
            return "\(diff.second)s"
        }

        if diff.hour == 0 {
            return "\(diff.minute)m"
        }

        if diff.day == 0 {
            return "\(diff.hour)h"
        }

        if diff.weekOfMonth == 0 {
            return "\(diff.day)d"
        }

        return "\(diff.weekOfMonth)w"
    }

    // MARK: Actions

    func handleLikeAction() {
        guard let isLiked = isLiked, let uuid = uuid else {
            return
        }

        if isLiked {
            self.isLiked = false
            likeButton.setImage(UIImage(imageLiteralResourceName: "unlike"), for: .normal)

            // Unlike this post
            let query = PFQuery(className: Like.modelName.rawValue)
            query.whereKey(Like.postID.rawValue, equalTo: uuid)
            let username = PFUser.current()?.username!
            query.whereKey(Like.username.rawValue, equalTo: username)

            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                guard error == nil else {
                    return
                }

                guard let object = objects?.first else {
                    return
                }

                object.deleteInBackground(block: { (success: Bool, error: Error?) in
                    if (error != nil) {
                        print("error:\(error?.localizedDescription)")
                    }
                })
            })

            let notificationQuery = PFQuery(className: Notifications.modelName.rawValue)
            notificationQuery.whereKey(Notifications.sender.rawValue, equalTo: (PFUser.current()?.username)!)
            notificationQuery.whereKey(Notifications.receiver.rawValue, equalTo: profileUsernameButton.title(for: .normal)!)
            notificationQuery.whereKey(Notifications.action.rawValue, equalTo: NotificationsAction.like.rawValue)
            notificationQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                for object in objects! {
                    object.deleteEventually()
                }
            })
        } else {
            // Like this post
            let object = PFObject(className: Like.modelName.rawValue)

            object[Like.postID.rawValue] = uuid
            object[Like.username.rawValue] = PFUser.current()?.username!

            self.isLiked = true
            likeButton.setImage(UIImage(imageLiteralResourceName: "like"), for: .normal)

            object.saveInBackground(block: { (success: Bool, error: Error?) in
                if (!success) {
                    print("error:\(error?.localizedDescription)")
                }
            })

            let notificationObject = PFObject(className: Notifications.modelName.rawValue)
            notificationObject[Notifications.sender.rawValue] = (PFUser.current()?.username)!
            notificationObject[Notifications.receiver.rawValue] = profileUsernameButton.title(for: .normal)
            notificationObject[Notifications.action.rawValue] = NotificationsAction.like.rawValue
            notificationObject.saveEventually()
        }

    }

    func doubleTapLike() {
        UIView.animate(withDuration: 0.3
            , animations: { [weak self] () in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.heartImageView.isHidden = false
                strongSelf.heartImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }, completion: { [weak self](success: Bool) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.heartImageView.isHidden = true
            strongSelf.heartImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })

        handleLikeAction()
    }

    @IBAction func likeButtonTapped(_ sender: UIButton) {
        handleLikeAction()
    }

    @IBAction func usernameButtonTapped(_ sender: UIButton) {
        let username = sender.title(for: .normal)
        delegate?.navigateToUserPage(username)
    }

    @IBAction func moreButtonTapped(_ sender: UIButton) {
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { [weak self](UIAlertAction) -> Void in
            guard let strongSelf = self else {
                return
            }

            strongSelf.removePost()

            strongSelf.delegate?.navigateToUserPage(nil)
        })

        let alertController = UIAlertController(title: "Action", message: nil, preferredStyle: .actionSheet)

        alertController.addAction(deleteAction)

        self.delegate?.showActionSheet(alertController)
    }

    func removePost() {
        let query = PFQuery(className: Post.modelName.rawValue)
        query.whereKey(Post.uuid.rawValue, equalTo: uuid!)

        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            for object in objects! {
                object.deleteEventually()
            }
        }

        let commentQuery = PFQuery(className: Comments.modelName.rawValue)
        commentQuery.whereKey(Comments.uuid.rawValue, equalTo: uuid!)

        commentQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            for object in objects! {
                object.deleteEventually()
            }
        }

        let hashtagQuery = PFQuery(className: Hashtag.modelName.rawValue)
        hashtagQuery.whereKey(Hashtag.postid.rawValue, equalTo: uuid!)

        hashtagQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            for object in objects! {
                object.deleteEventually()
            }
        }

        let likeQuery = PFQuery(className: Like.modelName.rawValue)
        likeQuery.whereKey(Like.postID.rawValue, equalTo: uuid!)

        likeQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            for object in objects! {
                object.deleteEventually()
            }
        }
    }

    @IBAction func commentButtonTapped(_ sender: UIButton) {
        self.delegate?.navigateToPostPage(uuid)
    }
}
