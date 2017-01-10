//
//  CommentViewCell.swift
//  one
//
//  Created by Kai Chen on 1/9/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit

class CommentViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!

    @IBOutlet var usernameButton: UIButton!

    @IBOutlet var commentLabel: UILabel!

    @IBOutlet var commentTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
