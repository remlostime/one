//
//  SearchTableViewController.swift
//  one
//
//  Created by Kai Chen on 1/25/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class SearchTableViewController: UITableViewController {

    var users: [String?] = []
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)

        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true

        // Use the current view controller to update the search results.
        searchController.searchResultsUpdater = self;

        // Install the search bar as the table header.
        tableView.tableHeaderView = searchController.searchBar;

        // It is usually good to set the presentation context.
        self.definesPresentationContext = true;
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.searchViewCell.rawValue, for: indexPath) as? SearchViewCell

        let user = users[indexPath.row]
        cell?.configure(user)

        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        var dstVC: UIViewController?

        if user == PFUser.current()?.username {
            dstVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.homeViewController.rawValue)
        } else {
            let guestVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.guestViewController.rawValue) as? GuestCollectionViewController
            guestVC?.guestname = user!
            dstVC = guestVC
        }
        self.navigationController?.pushViewController(dstVC!, animated: true)
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

    func updateKeyword(_ keyword: String) {
        users.removeAll()

        let query = PFQuery(className: User.modelName.rawValue)
        let regex = "[A-Za-z0-9_]*\(keyword.lowercased())[A-Za-z0-9_]*"
        query.whereKey(User.id.rawValue, matchesRegex: regex)

        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            for object in objects! {
                self.users.append(object[User.id.rawValue] as! String?)
            }

            self.tableView.reloadData()
        }
    }

}

extension SearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let keyword = searchController.searchBar.text
        self.updateKeyword(keyword!)
    }
}
