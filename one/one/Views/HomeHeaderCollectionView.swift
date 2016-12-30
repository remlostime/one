//
//  HomeHeaderCollectionView.swift
//  one
//
//  Created by Kai Chen on 12/22/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class HomeHeaderCollectionView: UICollectionReusableView {
        
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var bioLabel: UILabel!
    @IBOutlet var postsNumLabel: UILabel!
    @IBOutlet var followersNumLabel: UILabel!
    @IBOutlet var followingNumLabel: UILabel!
    @IBOutlet var editButton: UIButton!

    var guestname: String = ""

    let currentUsername = PFUser.current()?.username

    func config() {
        if guestname.isEmpty {
            editButton.layer.borderWidth = 1
            editButton.layer.borderColor = UIColor.lightGray.cgColor
        } else {
            configButton(currentUsername, toUser: guestname)
        }
        editButton.layer.cornerRadius = 3
    }

    func configFollowButtonStyle() {
        editButton.backgroundColor = .followButtonLightBlue
        editButton.setTitle(FollowUI.followButtonText.rawValue, for: .normal)
        editButton.setTitleColor(.white, for: .normal)
        editButton.layer.borderWidth = 0
    }

    func configFollowingButtonStyle() {
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = UIColor.lightGray.cgColor
        editButton.backgroundColor = .white
        editButton.setTitle(FollowUI.followingButtonText.rawValue, for: .normal)
        editButton.setTitleColor(.black, for: .normal)
    }

    // Show current user follow the guest or not
    func configButton(_ fromUser: String?, toUser: String?) {
        if let fromUser = fromUser, let toUser = toUser {
            let followQuery = PFQuery(className: Follow.modelName.rawValue)
            followQuery.whereKey(Follow.follower.rawValue, equalTo: fromUser)
            followQuery.whereKey(Follow.following.rawValue, equalTo: toUser)
            followQuery.countObjectsInBackground { [weak self](count: Int32, error: Error?) in
                guard let strongSelf = self else {
                    return
                }

                let isFollowing = (error == nil && count > 0)

                if isFollowing {
                    strongSelf.configFollowingButtonStyle()
                } else {
                    strongSelf.configFollowButtonStyle()
                }
            }
        }
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        let title = editButton.title(for: .normal)
        
        if title == FollowUI.followButtonText.rawValue {
            let object = PFObject(className: Follow.modelName.rawValue)
            object[Follow.follower.rawValue] = (PFUser.current()?.username)!
            object[Follow.following.rawValue] = guestname
            object.saveInBackground(block: { [weak self](success: Bool, error: Error?) in
                guard let strongSelf = self else {
                    return
                }

                if success {
                    strongSelf.configFollowingButtonStyle()
                } else {
                    print("error:\(error?.localizedDescription)")
                }
            })
        } else if title == FollowUI.followingButtonText.rawValue {
            let query = PFQuery(className: Follow.modelName.rawValue)
            query.whereKey(Follow.follower.rawValue, equalTo: (PFUser.current()?.username)!)
            query.whereKey(Follow.following.rawValue, equalTo: guestname)
            query.findObjectsInBackground(block: { [weak self](objects: [PFObject]?, error: Error?) in
                guard let strongSelf = self else {
                    return
                }

                if error == nil {
                    for object in objects! {
                        object.deleteInBackground(block: { (success: Bool, error: Error?) in
                            if success {
                                strongSelf.configFollowButtonStyle()
                            } else {
                                print("error:\(error?.localizedDescription)")
                            }
                        })
                    }
                } else {
                    
                }
            })
        }
    }
}
