//
//  FollowingViewController.swift
//  one
//
//  Created by Kai Chen on 12/23/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class FollowingViewController: UITableViewController {
    
    var followings = [String]()
    var usernames = [String]()
    var profileImages = [PFFile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Following"
        
        loadFollowing()
    }
    
    func loadFollowing() {
        let followingQuery = PFQuery(className: "Follow")
        let currentUsername = (PFUser.current()?.username)!
        followingQuery.whereKey("follower", equalTo: currentUsername)
        followingQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if error == nil {
                self.followings.removeAll()
                
                for object in objects! {
                    self.followings.append(object.value(forKey: "following") as! String)
                }
                
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.followings)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                    if error == nil {
                        self.usernames.removeAll()
                        self.profileImages.removeAll()
                        
                        for object in objects! {
                            self.usernames.append(object.object(forKey: "username") as! String)
                            self.profileImages.append(object.object(forKey: "profile_image") as! PFFile)
                        }
                        
                        self.tableView.reloadData()
                    } else {
                        print("error:\(error!.localizedDescription)")
                    }
                })
            }
        }
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followViewCell", for: indexPath) as? FollowViewCell
        
        cell?.usernameLabel.text = usernames[indexPath.row]
        
        let pfFile = profileImages[indexPath.row]
        pfFile.getDataInBackground { (data: Data?, error: Error?) in
            let image = UIImage(data: data!)
            cell?.profielImageView.image = image
        }

        return cell!
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
