//
//  NotificationViewCell.swift
//  one
//
//  Created by Kai Chen on 1/26/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit

class NotificationViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!

    @IBOutlet var usernameLabel: UILabel!

    @IBOutlet var actionLabel: UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
