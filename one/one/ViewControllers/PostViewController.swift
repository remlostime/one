//
//  PostViewController.swift
//  one
//
//  Created by Kai Chen on 1/3/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UITableViewController {

    var postUUID: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Add back swipe action
        // TODO: Add post navigation
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 600
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.postHeaderViewCell.rawValue, for: indexPath) as? PostHeaderViewCell

        cell?.delegate = self

        cell?.config(postUUID!)


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

extension PostViewController: PostHeaderViewCellDelegate {
    func navigateToUserPage(_ username: String?) {
        guard let username = username else {
            return
        }

        if username == PFUser.current()?.username! {
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.homeViewController.rawValue) as? HomeCollectionViewController
            self.navigationController?.pushViewController(homeVC!, animated: true)
        } else {
            let guestVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.guestViewController.rawValue)
            self.navigationController?.pushViewController(guestVC!, animated: true)
        }
    }
}
