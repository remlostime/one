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

            let createTime = object.createdAt
            strongSelf.postTimeLabel.text = strongSelf.timeDescription(createTime!)

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

    func timeDescription(_ postTime: Date) -> String {
        let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
        let diff = NSCalendar.current.dateComponents(components, from: postTime)

        if diff.second! <= 0 {
            return "now"
        }

        if diff.minute == 0 {
            return "\(diff.second)s"
        }

        if diff.hour == 0 {
            return "\(diff.minute)m"
        }

        if diff.day == 0 {
            return "\(diff.hour)h"
        }

        if diff.weekOfMonth == 0 {
            return "\(diff.day)d"
        }

        return "\(diff.weekOfMonth)w"
    }
}
