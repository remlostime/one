//
//  ResetPasswordViewController.swift
//  one
//
//  Created by Kai Chen on 12/20/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class ResetPasswordViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true,
                     completion: nil)
    }

    @IBAction func resetButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)

        if emailTextField.text!.isEmpty {
            let alertVC = UIAlertController(title: "Email is empty",
                                            message: "Please fill the email",
                                            preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .cancel,
                                         handler: nil)
            alertVC.addAction(okAction)
            self.present(alertVC,
                         animated: true,
                         completion: nil)

            return
        }

        // Request server to reset password
        PFUser.requestPasswordResetForEmail(inBackground: emailTextField.text!) { (success: Bool, error: Error?) in
            if (success) {
                let alertVC = UIAlertController(title: "Email for reseting password",
                                                message: "Sent to server",
                                                preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: { (UIAlertAction) in
                                                self.dismiss(animated: true,
                                                             completion: nil)
                })
                alertVC.addAction(okAction)
                self.present(alertVC,
                             animated: true,
                             completion: nil)
            } else {
                print("here is error: \(error!.localizedDescription)")
            }
        }
        
    }
}
