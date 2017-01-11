//
//  CommentViewController.swift
//  one
//
//  Created by Kai Chen on 1/9/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class CommentViewController: UIViewController {

    @IBOutlet var commentTextField: UITextField!

    @IBOutlet var postButton: UIButton!

    @IBOutlet var commentsTableView: UITableView!

    @IBOutlet var commentsView: UIView!

    var commentUUID: String?

    let countOfCommentsPerPage: Int32 = 15

    var refreher: UIRefreshControl?

    override func viewDidLoad() {
        super.viewDidLoad()

        commentTextField.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        commentsTableView.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDismiss(notification:)), name: .UIKeyboardWillHide, object: nil)
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

            if strongSelf.countOfCommentsPerPage < count {
                strongSelf.refreher?.addTarget(self, action: #selector(loadMoreComments), for: .valueChanged)
                strongSelf.commentsTableView.addSubview(strongSelf.refreher!)
            }

            let query = PFQuery(className: Comments.modelName.rawValue)
            query.whereKey(Comments.uuid.rawValue, equalTo: strongSelf.commentUUID!)
            query.skip = count - strongSelf.countOfCommentsPerPage
            query.addAscendingOrder("createdAt")
            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                if error == nil {
                    // Add username, profile image
                }
            })
        }
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
}
