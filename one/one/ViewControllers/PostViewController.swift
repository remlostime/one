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

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else {
            return
        }
        if id == Identifier.commentViewController.rawValue {
            let dstVC = segue.destination as? CommentViewController
            dstVC?.hidesBottomBarWhenPushed = true
            dstVC?.commentUUID = postUUID
        }
    }

}

extension PostViewController: PostHeaderViewCellDelegate {
    func navigateToUserPage(_ username: String?) {
        guard let username = username else {
            self.navigationController?.popViewController(animated: true)
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

    func showActionSheet(_ alertController: UIAlertController?) {
        self.present(alertController!, animated: true, completion: nil)
    }
}
