//
//  SearchViewCell.swift
//  one
//
//  Created by Kai Chen on 1/25/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class SearchViewCell: UITableViewCell {

    @IBOutlet weak var profielImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(_ withUsername: String?) {
        guard let username = withUsername else {
            return
        }

        usernameLabel.text = username

        let query = PFQuery(className: User.modelName.rawValue)

        query.whereKey(User.id.rawValue, equalTo: username)
        query.findObjectsInBackground { [weak self](objects: [PFObject]?, error: Error?) in
            guard let strongSelf = self else {
                return
            }

            if let object = objects?.first {
                let profileFile = object[User.profileImage.rawValue] as? PFFile

                profileFile?.getDataInBackground(block: { (data: Data?, error: Error?) in
                    DispatchQueue.main.async {
                        let image = UIImage(data: data!)

                        strongSelf.profielImageView.image = image
                    }
                })
            }
        }
    }

}
