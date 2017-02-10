//
//  CommentViewController.swift
//  one
//
//  Created by Kai Chen on 1/9/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse
import MJRefresh
import KILabel

class CommentViewController: UIViewController {

    @IBOutlet var commentTextField: UITextField!

    @IBOutlet var postButton: UIButton!

    @IBOutlet var commentsTableView: UITableView!

    @IBOutlet var commentsView: UIView!

    var postUsername: String?

    var commentUUID: String?

    let countOfCommentsPerPage: Int32 = 15

    var refreher: UIRefreshControl?

    var commentModels: [CommentViewCellModel] = [CommentViewCellModel]()


    @IBAction func usernameButtonTapped(_ sender: UIButton) {
        let username = sender.title(for: .normal)
        if username == PFUser.current()?.username {
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.homeViewController.rawValue)
            self.navigationController?.pushViewController(homeVC!, animated: true)
        } else {
            let guestVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.guestViewController.rawValue) as? GuestCollectionViewController
            guestVC?.guestname = username!
            self.navigationController?.pushViewController(guestVC!, animated: true)

        }
    }

    @IBAction func postButtonTapped(_ sender: UIButton) {
        sendComment()
    }

    func sendComment() {
        let comment = PFObject(className: Comments.modelName.rawValue)
        let commentModel = CommentViewCellModel()

        commentModel.comments = commentTextField.text
        commentModel.username = PFUser.current()?.username
        commentModel.createdTime = Date()
        commentModel.uuid = UUID().uuidString

        self.commentModels.append(commentModel)

        commentsTableView.reloadData()

        comment[Comments.comment.rawValue] = commentTextField.text
        comment[Comments.username.rawValue] = PFUser.current()?.username
        comment[Comments.uuid.rawValue] = commentUUID
        comment[Comments.comment_uuid.rawValue] = commentModel.uuid
        comment.saveEventually()

        let notification = PFObject(className: Notifications.modelName.rawValue)
        notification[Notifications.sender.rawValue] = PFUser.current()?.username!
        notification[Notifications.receiver.rawValue] = postUsername!
        notification[Notifications.action.rawValue] = NotificationsAction.comment.rawValue
        notification.saveEventually()

        let text: [String] = (commentTextField.text?.components(separatedBy: CharacterSet.whitespacesAndNewlines))!
        for word in text {
            if word.hasPrefix("#") {
                let object = PFObject(className: Hashtag.modelName.rawValue)
                object[Hashtag.hashtag.rawValue] = word
                object[Hashtag.username.rawValue] = PFUser.current()?.username!
                object[Hashtag.postid.rawValue] = commentUUID!
                object[Hashtag.commentid.rawValue] = commentModel.uuid

                object.saveEventually()
            }

            if word.hasPrefix("@") {
                let notification = PFObject(className: Notifications.modelName.rawValue)
                notification[Notifications.sender.rawValue] = PFUser.current()?.username!
                let index = word.index(word.startIndex, offsetBy: 1)
                notification[Notifications.receiver.rawValue] = word.substring(from: index)
                notification[Notifications.action.rawValue] = NotificationsAction.mention.rawValue
                notification.saveEventually()
            }
        }
        
        commentTextField.text = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commentTextField.delegate = self
        commentsTableView.delegate = self
        commentsTableView.dataSource = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        commentsTableView.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDismiss(notification:)), name: .UIKeyboardWillHide, object: nil)

        loadComments()
    }

    func endEditing() {
        commentTextField.endEditing(true)
    }

    func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.4, animations: { [weak self]() -> Void in
                guard let strongSelf = self else {
                    return
                }

                var frame = strongSelf.commentsTableView.frame
                frame.size.height = frame.size.height - keyboardSize.height
                strongSelf.commentsTableView.frame = frame

                var commentViewFrame = strongSelf.commentsView.frame
                commentViewFrame.origin.y = frame.height
                strongSelf.commentsView.frame = commentViewFrame
            })
        }
    }

    func keyboardWillDismiss(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.4, animations: { [weak self]() -> Void in
                guard let strongSelf = self else {
                    return
                }

                var frame = strongSelf.commentsTableView.frame
                frame.size.height = frame.size.height + keyboardSize.height
                strongSelf.commentsTableView.frame = frame
            })
        }
    }

    func loadComments() {
        let countQuery = PFQuery(className: Comments.modelName.rawValue)
        countQuery.whereKey(Comments.uuid.rawValue, equalTo: commentUUID!)
        countQuery.countObjectsInBackground { [weak self](count: Int32, error: Error?) in
            guard let strongSelf = self else {
                return
            }

//            if strongSelf.countOfCommentsPerPage < count {
//                strongSelf.refreher?.addTarget(self, action: #selector(loadMoreComments), for: .valueChanged)
//                strongSelf.commentsTableView.addSubview(strongSelf.refreher!)
//            }

            let query = PFQuery(className: Comments.modelName.rawValue)
            query.whereKey(Comments.uuid.rawValue, equalTo: strongSelf.commentUUID!)
//            query.skip = count - strongSelf.countOfCommentsPerPage
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground(block: { [weak self](objects: [PFObject]?, error: Error?) in
                guard let strongSelf = self else {
                    return
                }
                if error == nil {
                    for object in objects! {
                        let model = CommentViewCellModel()
                        model.username = object.object(forKey: Comments.username.rawValue) as! String?
                        model.comments = object.object(forKey: Comments.comment.rawValue) as! String?
                        model.createdTime = object.createdAt

                        strongSelf.commentModels.append(model)
                    }

                    strongSelf.commentsTableView.reloadData()
                }
            })
        }
    }
}

extension CommentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()

        let username = commentModels[indexPath.row].username

        // TODO: Add If the the post belong to current user, user can delete comment
        if username == PFUser.current()?.username {
            actions.append(delete())
        }

        if username != PFUser.current()?.username {
            actions.append(reply())
            actions.append(complain())
        }

        return actions
    }

    func complain() -> UITableViewRowAction {
        let complainAction = UITableViewRowAction(style: .normal, title: "Complain", handler: {(action: UITableViewRowAction, indexPath: IndexPath) in })
        // TODO: Add complain logic

        return complainAction
    }

    func reply() -> UITableViewRowAction {
        let replyAction = UITableViewRowAction(style: .normal, title: "Reply", handler: { [weak self](action: UITableViewRowAction, indexPath: IndexPath) in
            guard let strongSelf = self else {
                return
            }

            let model = strongSelf.commentModels[indexPath.row]

            strongSelf.commentTextField.text = strongSelf.commentTextField.text! + "@" + model.username!
        })

        return replyAction
    }

    func delete() -> UITableViewRowAction {
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete", handler: { [weak self](action: UITableViewRowAction, indexPath: IndexPath) in
            guard let strongSelf = self else {
                return
            }

            let model = strongSelf.commentModels[indexPath.row]

            let query = PFQuery(className: Comments.modelName.rawValue)
            query.whereKey(Comments.uuid.rawValue, equalTo: strongSelf.commentUUID!)
            query.whereKey(Comments.username.rawValue, equalTo: model.username!)
            query.whereKey(Comments.comment.rawValue, equalTo: model.comments!)
            query.whereKey(Comments.comment_uuid.rawValue, equalTo: model.uuid!)

            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                guard let object = objects?.first else {
                    return
                }

                object.deleteEventually()
            })

            strongSelf.commentModels.remove(at: indexPath.row)

            strongSelf.commentsTableView.deleteRows(at: [indexPath], with: .automatic)

            let hashtagQuery = PFQuery(className: Hashtag.modelName.rawValue)
            hashtagQuery.whereKey(Hashtag.commentid.rawValue, equalTo: model.uuid!)
            hashtagQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                for object in objects! {
                    object.deleteEventually()
                }
            })
        })

        deleteAction.backgroundColor = .red

        return deleteAction
    }
}

extension CommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.commentViewCell.rawValue, for: indexPath) as? CommentViewCell

        let model = commentModels[indexPath.row]

        cell?.usernameButton.setTitle(model.username, for: .normal)
//        cell?.commentTimeLabel.text = model.createdTime?.description
        cell?.delegate = self
        cell?.commentLabel.text = model.comments

        cell?.commentLabel.userHandleLinkTapHandler = { label, handle, range in
            let index = handle.index(handle.startIndex, offsetBy: 1)
            let username = handle.substring(from: index)

            self.navigateToUser(username)
        }

        cell?.commentLabel.hashtagLinkTapHandler = { label, hashtag, range in
            let hashtagVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.hashtagViewController.rawValue) as? HashtagCollectionViewController

            hashtagVC?.hashtag = hashtag

            self.navigationController?.pushViewController(hashtagVC!, animated: true)
        }

        let user = PFUser.query()
        user?.whereKey(User.id.rawValue, equalTo: model.username!)
        user?.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
            guard let objects = objects else {
                return
            }

            let object = objects.first as? PFUser

            let imageFile = object?.object(forKey: User.profileImage.rawValue) as? PFFile

            imageFile?.getDataInBackground(block: { [weak cell](data: Data?, error: Error?) in
                guard let strongCell = cell, let data = data else {
                    return
                }

                DispatchQueue.main.async {
                    strongCell.profileImageView.image = UIImage.init(data: data)
                }
            })
        })

        return cell!
    }
}

extension CommentViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let spacing = NSCharacterSet.whitespacesAndNewlines
        if (textField.text?.trimmingCharacters(in: spacing).isEmpty)! {
            postButton.isEnabled = false
        } else {
            postButton.isEnabled = true
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        sendComment()

        return true
    }
}

extension CommentViewController: CommentViewCellDelegate {
    func navigateToUser(_ username: String?) {
        let guestVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.guestViewController.rawValue) as? GuestCollectionViewController
        guestVC?.guestname = username!

        self.navigationController?.pushViewController(guestVC!, animated: true)
    }
}
