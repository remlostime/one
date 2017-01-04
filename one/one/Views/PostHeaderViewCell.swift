//
//  PostHeaderViewCell.swift
//  one
//
//  Created by Kai Chen on 1/3/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class PostHeaderViewCell: UITableViewCell {

    @IBOutlet var profileImageView: UIImageView!

    @IBOutlet var profileUsernameButton: UIButton!

    @IBOutlet var postTimeLabel: UILabel!

    @IBOutlet var postImageView: UIImageView!

    @IBOutlet var likeButton: UIButton!

    @IBOutlet var commentButton: UIButton!

    @IBOutlet var moreButton: UIButton!

    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func config(_ uuid: String) {
        let postQuery = PFQuery(className: Post.modelName.rawValue)
        postQuery.whereKey(Post.uuid.rawValue, equalTo: uuid)
        postQuery.findObjectsInBackground { [weak self](objects: [PFObject]?, error: Error?) in
            guard error == nil else {
                print("error:\(error?.localizedDescription)")
                return
            }

            guard let object = objects?.first, let strongSelf = self else {
                return
            }

            let profileImageFile = object[Post.profileImage.rawValue] as? PFFile
            profileImageFile?.getDataInBackground(block: { (data: Data?, error: Error?) in
                guard error == nil else {
                    return
                }

                if let data = data {
                    strongSelf.profileImageView.image = UIImage(data: data)
                }
            })

            let username = object[Post.username.rawValue] as? String
            strongSelf.profileUsernameButton.setTitle(username, for: .normal)

            let createTime = object[Info.createTime.rawValue] as? Date
            strongSelf.postTimeLabel.text = createTime?.description

            let postImageFile = object[Post.picture.rawValue] as? PFFile
            postImageFile?.getDataInBackground(block: { (data: Data?, error: Error?) in
                guard error == nil else {
                    return
                }

                if let data = data {
                    strongSelf.postImageView.image = UIImage(data: data)
                }
            })

            let title = object[Post.title.rawValue] as? String
            strongSelf.titleLabel.text = title
        }
    }
}
