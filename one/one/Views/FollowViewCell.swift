//
//  FollowViewCell.swift
//  one
//
//  Created by Kai Chen on 12/24/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse
import QuartzCore

enum FollowState: Int {
    case following = 0
    case notFollowing
}

class FollowViewCell: UITableViewCell {

    @IBOutlet weak var profielImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followingButton: UIButton!

    let currentUsername = (PFUser.current()?.username)!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        followingButton.layer.cornerRadius = 3
        followingButton.clipsToBounds = true
        followingButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func followingButtonTapped(_ sender: UIButton) {
        let title = sender.title(for: .normal)
        
        if title == FollowUI.followButtonText.rawValue {
            configure(withState: .following)
            let object = PFObject(className: Follow.modelName.rawValue)
            object[Follow.follower.rawValue] = currentUsername
            object[Follow.following.rawValue] = usernameLabel.text!
            object.saveInBackground(block: { [weak self](success: Bool, error: Error?) in
                guard let strongSelf = self else {
                    return
                }
                if !success {
                    strongSelf.configure(withState: .notFollowing)
                    print("error:\(error?.localizedDescription)")
                }
            })


            let notificationObject = PFObject(className: Notifications.modelName.rawValue)
            notificationObject[Notifications.sender.rawValue] = currentUsername
            notificationObject[Notifications.receiver.rawValue] = usernameLabel.text!
            notificationObject[Notifications.action.rawValue] = NotificationsAction.follow.rawValue
            notificationObject.saveEventually()
        } else {
            configure(withState: .notFollowing)
            let query = PFQuery(className: Follow.modelName.rawValue)
            query.whereKey(Follow.follower.rawValue, equalTo: currentUsername)
            let followingUsername = usernameLabel.text!
            query.whereKey(Follow.following.rawValue, equalTo: followingUsername)
            query.findObjectsInBackground(block: { [weak self](objects: [PFObject]?, error: Error?) in
                guard let strongSelf = self else {
                    return
                }

                if error == nil {
                    for object in objects! {
                        object.deleteInBackground(block: { (success: Bool, error: Error?) in
                            if !success {
                                strongSelf.configure(withState: .following)
                                print("error:\(error?.localizedDescription)")
                            }
                        })
                    }
                } else {
                    strongSelf.followingButton.setTitle(FollowUI.followingButtonText.rawValue, for: .normal)
                    strongSelf.followingButton.backgroundColor = .white
                    print("error:\(error?.localizedDescription)")
                }
            })
            /*
            object.findObj(block: { (success: Bool, error: Error?) in
                if success {
                    self.followingButton.setTitle("following", for: .normal)
                    self.followingButton.backgroundColor = .blue
                } else {
                    print("error:\(error?.localizedDescription)")
                }
            })
 */

            let notificationQuery = PFQuery(className: Notifications.modelName.rawValue)
            notificationQuery.whereKey(Notifications.sender.rawValue, equalTo: currentUsername)
            notificationQuery.whereKey(Notifications.receiver.rawValue, equalTo: usernameLabel.text!)
            notificationQuery.whereKey(Notifications.action.rawValue, equalTo: NotificationsAction.follow.rawValue)
            notificationQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                for object in objects! {
                    object.deleteEventually()
                }
            })
        }
    }

    // MARK: Helpers
    func configure(withState state: FollowState) {
        switch state {
        case .following:
            followingButton.setTitle(FollowUI.followingButtonText.rawValue, for: .normal)
            followingButton.setTitleColor(.black, for: .normal)
            followingButton.layer.borderWidth = 1
            followingButton.layer.borderColor = UIColor.gray.cgColor
            followingButton.backgroundColor = .white
        case .notFollowing:
            followingButton.setTitle(FollowUI.followButtonText.rawValue, for: .normal)
            followingButton.setTitleColor(.white, for: .normal)
            followingButton.layer.borderWidth = 0
            followingButton.setTitleColor(.white, for: .normal)
            followingButton.backgroundColor = .followButtonLightBlue
        }
    }
}
