//
//  CommentViewController.swift
//  one
//
//  Created by Kai Chen on 1/9/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {

    @IBOutlet var commentTextField: UITextField!

    @IBOutlet var postButton: UIButton!

    @IBOutlet var commentsTableView: UITableView!

    @IBOutlet var commentsView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

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
        /*
        UIView.animate(withDuration: 0.4, animations: { [weak self]() -> Void in
            guard let strongSelf = self else {
                return
            }
            strongSelf.commentsTableView.frame =
            self.scrollView.frame.size.height = self.view.frame.height
        })
 */
    }
}
