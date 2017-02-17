//
//  CommentViewCell.swift
//  one
//
//  Created by Kai Chen on 1/9/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import ActiveLabel

protocol CommentViewCellDelegate {
    func navigateToUser(_ username: String?)
}

class CommentViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!

    @IBOutlet var usernameButton: UIButton!

    @IBOutlet var commentLabel: ActiveLabel!

    @IBOutlet var commentTimeLabel: UILabel!

    var delegate: CommentViewCellDelegate?
}
