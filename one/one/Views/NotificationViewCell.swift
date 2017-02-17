//
//  NotificationViewCell.swift
//  one
//
//  Created by Kai Chen on 1/26/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit

protocol NotificationViewCellDelegate {
    func navigateToUserPage(_ userid: String?)

    func navigateToPostPage(_ postUUID: String?)
}

class NotificationViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!

    @IBOutlet var usernameLabel: UILabel!

    @IBOutlet var actionLabel: UILabel!

    @IBOutlet var postImageView: UIImageView!

    var delegate: NotificationViewCellDelegate?

    var userid: String?

    var postUUID: String?

    override func awakeFromNib() {
        super.awakeFromNib()

        let profileImageTapped = UITapGestureRecognizer(target: self, action: #selector(navigateToUserPage))
        profileImageView.addGestureRecognizer(profileImageTapped)

        let usernameTapped = UITapGestureRecognizer(target: self, action: #selector(navigateToUserPage))
        usernameLabel.addGestureRecognizer(usernameTapped)

        let postImageTapped = UITapGestureRecognizer(target: self, action: #selector(navigateToPostPage))
        postImageView.addGestureRecognizer(postImageTapped)
    }

    func navigateToUserPage() {
        delegate?.navigateToUserPage(userid)
    }

    func navigateToPostPage() {
        delegate?.navigateToPostPage(postUUID)
    }
}
