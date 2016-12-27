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

    @IBAction func buttonTapped(_ sender: UIButton) {
        let title = editButton.title(for: .normal)
        
        if title == "Follow" {
            let object = PFObject(className: "Follow")
            object["follower"] = (PFUser.current()?.username)!
            object["following"] = guestname
            object.saveInBackground(block: { (success: Bool, error: Error?) in
                if success {
                    self.editButton.setTitle("Following", for: .normal)
                    self.editButton.backgroundColor = .blue
                } else {
                    print("error:\(error?.localizedDescription)")
                }
            })
        } else if title == "Following" {
            let query = PFQuery(className: "Follow")
            query.whereKey("follower", equalTo: (PFUser.current()?.username)!)
            query.whereKey("following", equalTo: guestname)
            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackground(block: { (success: Bool, error: Error?) in
                            if success {
                                self.editButton.setTitle("Follow", for: .normal)
                                self.editButton.backgroundColor = .gray
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
