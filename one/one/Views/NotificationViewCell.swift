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
}

class NotificationViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!

    @IBOutlet var usernameLabel: UILabel!

    @IBOutlet var actionLabel: UILabel!

    var delegate: NotificationViewCellDelegate?

    var userid: String?

    override func awakeFromNib() {
        super.awakeFromNib()

        let profileImageTapped = UITapGestureRecognizer(target: self, action: #selector(navigateToUserPage))
        profileImageView.addGestureRecognizer(profileImageTapped)

        let usernameTapped = UITapGestureRecognizer(target: self, action: #selector(navigateToUserPage))
        usernameLabel.addGestureRecognizer(usernameTapped)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func navigateToUserPage() {
        delegate?.navigateToUserPage(userid)
    }
}
