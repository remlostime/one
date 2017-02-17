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
        let username = users[indexPath.row]

        let dstVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.profileViewController.rawValue) as? ProfileViewController
        dstVC?.userid = username
        self.navigationController?.pushViewController(dstVC!, animated: true)
    }

    // MARK: Helpers
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
