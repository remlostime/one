//
//  SettingsViewController.swift
//  one
//
//  Created by Kai Chen on 2/21/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UITableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        logout()
    }

    func logout() {
        PFUser.logOutInBackground { (error: Error?) in
            if error == nil {
                UserDefaults.standard.removeObject(forKey: User.id.rawValue)
                UserDefaults.standard.synchronize()

                let signInVC = self.storyboard?.instantiateViewController(withIdentifier: Identifier.signInViewController.rawValue) as? SignInViewController
                let appDelegate: AppDelegate = (UIApplication.shared.delegate as? AppDelegate)!
                appDelegate.window?.rootViewController = signInVC
            }
        }
    }
}
