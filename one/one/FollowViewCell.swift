//
//  FollowViewCell.swift
//  one
//
//  Created by Kai Chen on 12/24/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class FollowViewCell: UITableViewCell {

    @IBOutlet weak var profielImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followingButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func followingButtonTapped(_ sender: UIButton) {
        let title = sender.title(for: .normal)
        
        if title == "follow" {
            let object = PFObject(className: "Follow")
            object["follower"] = (PFUser.current()?.username)!
            object["following"] = usernameLabel.text!
            object.saveInBackground(block: { (success: Bool, error: Error?) in
                if success {
                    self.followingButton.setTitle("following", for: .normal)
                    self.followingButton.backgroundColor = .blue
                } else {
                    print("error:\(error?.localizedDescription)")
                }
            })
        } else {
            let query = PFQuery(className: "Follow")
            query.whereKey("follower", equalTo: (PFUser.current()?.username)!)
            query.whereKey("following", equalTo: usernameLabel.text!)
            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackground(block: { (success: Bool, error: Error?) in
                            if success {
                                self.followingButton.setTitle("follow", for: .normal)
                                self.followingButton.backgroundColor = .gray
                            } else {
                                print("error:\(error?.localizedDescription)")
                            }
                        })
                    }
                } else {
                    
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
        }
    }
}
