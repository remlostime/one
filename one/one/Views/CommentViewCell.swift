//
//  CommentViewCell.swift
//  one
//
//  Created by Kai Chen on 1/9/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import KILabel

protocol CommentViewCellDelegate {
    func navigateToUser(_ username: String?)
}

class CommentViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!

    @IBOutlet var usernameButton: UIButton!

    @IBOutlet var commentLabel: KILabel!

    @IBOutlet var commentTimeLabel: UILabel!

    var delegate: CommentViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()


    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
