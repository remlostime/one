//
//  SignInViewController.swift
//  one
//
//  Created by Kai Chen on 12/20/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var forgotPasswordButton: UIButton!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var signUpButton: UIButton!

    @IBAction func signInButtonTapped(_ sender: UIButton) {
        print("here we go")
    }
}
