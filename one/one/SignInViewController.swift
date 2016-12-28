//
//  SignInViewController.swift
//  one
//
//  Created by Kai Chen on 12/20/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse

let kOneSignInVCIdentifier = "OneSignInVCIdentifier"

class SignInViewController: UIViewController {
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var forgotPasswordButton: UIButton!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var signUpButton: UIButton!

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        let username = userNameTextField.text
        let password = passwordTextField.text

        if let username = username, let password = password {
            PFUser.logInWithUsername(inBackground: username, password: password, block: { [weak self](user: PFUser?, error: Error?) in
                guard let strongSelf = self else {
                    return
                }

                guard let user = user else {
                    strongSelf.showLoginErrorAlert(error?.localizedDescription)
                    return
                }

                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                appDelegate?.login(withUserName: user.username)
            })
        }
    }

    func showLoginErrorAlert(_ message: String?) {
        let alertVC = UIAlertController(title: "Error",
                                        message: message,
                                        preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .cancel,
                                     handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC,
                     animated: true,
                     completion: nil)
    }
}
