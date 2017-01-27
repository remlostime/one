//
//  NotificationViewController.swift
//  one
//
//  Created by Kai Chen on 1/26/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class NotificationViewController: UITableViewController {

    var notifications : [PFObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let username = PFUser.current()?.username
        let query = PFQuery(className: Notifications.modelName.rawValue)

        query.whereKey(Notifications.receiver.rawValue, equalTo: username!)
        query.findObjectsInBackground { [weak self](objects: [PFObject]?, error: Error?) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.notifications = objects!

            strongSelf.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.notificationViewCell.rawValue, for: indexPath) as? NotificationViewCell

        let notification = notifications[indexPath.row]
        cell?.usernameLabel.text = notification[Notifications.sender.rawValue] as? String
        let action = notification[Notifications.action.rawValue]!
        var actionStr: String

//        if action == NotificationsAction.like {
//            actionStr = "liked your post."
//        } else if action == NotificationsAction.follow {
//            actionStr = "is following you."
//        } else if action == NotificationsAction.mention {
//            actionStr = "mentioned you."
//        } else {
//            actionStr = "commented on your post."
//        }

//        cell?.actionLabel.text = actionStr

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
