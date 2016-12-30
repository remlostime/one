//
//  SignUpViewController.swift
//  one
//
//  Created by Kai Chen on 12/20/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {

    @IBOutlet var profileImageView: UIImageView!

    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordAgainTextField: UITextField!
    @IBOutlet var fullNameTextField: UITextField!
    @IBOutlet var bioTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!

    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var cancelButton: UIButton!

    var scrollViewHeight : CGFloat = 0.0

    @IBOutlet var scrollView: UIScrollView!

    // MARK: Lifecyle

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: self.view.frame.width,
                                  height: self.view.frame.height)
        scrollView.contentSize.height = self.view.frame.height
        scrollViewHeight = scrollView.frame.size.height

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showKeyboard(notification:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideKeyboard(notification:)),
                                               name: .UIKeyboardWillHide,
                                               object: nil)

        let hideTapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(hideKeyboardTapped(recognizer:)))
        hideTapGesture.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTapGesture)

        let profileImageTapGesture = UITapGestureRecognizer(target: self,
                                                            action: #selector(profileImageTapped(recognizer:)))
        profileImageTapGesture.numberOfTapsRequired = 1
        profileImageView.addGestureRecognizer(profileImageTapGesture)
    }

    // MARK: Actions

    func profileImageTapped(recognizer: UITapGestureRecognizer) {
        let pickerVC = UIImagePickerController()
        pickerVC.delegate = self
        pickerVC.sourceType = .photoLibrary
        pickerVC.allowsEditing = true
        present(pickerVC,
                animated: true,
                completion: nil)
    }

    func showKeyboard(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.scrollView.frame.size.height = self.scrollViewHeight - keyboardSize.height
            })
        }
    }

    func hideKeyboard(notification: NSNotification) {
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.scrollView.frame.size.height = self.view.frame.height
        })
    }

    func hideKeyboardTapped(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true,
                     completion: nil)
    }

    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        
        // Check any empty field
        if isTextFieldEmpty() {
            showAlert(title: "Empty Field",
                      message: "Please fill all fields")
            return
        }

        // Check passwords are same
        if passwordTextField.text != passwordAgainTextField.text {
            showAlert(title: "Passwords are not same",
                      message: "Please type the same password")
            return
        }

        // Store data to server
        let user = PFUser()
        user.username = userNameTextField.text?.lowercased()
        user.email = emailTextField.text?.lowercased()
        user.password = passwordTextField.text
        user[User.fullname.rawValue] = fullNameTextField.text?.lowercased()
        user[User.bio.rawValue] = bioTextField.text

        let profileData = UIImagePNGRepresentation(profileImageView.image!)
        let profileFile = PFFile(name: "profile.png",
                                 data: profileData!)
        user[User.profileImage.rawValue] = profileFile

        user.signUpInBackground { (success: Bool, error: Error?) in
            if success {
                print("successfully signup")
                // Call login func from AppDelegate
                let appDelegate = UIApplication.shared.delegate as? AppDelegate

                appDelegate?.login(withUserName: user.username)
            } else {
                print("error:\(error)")
            }
        }
    }

    // MARK: Helpers

    func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title,
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

    func isTextFieldEmpty() -> Bool {
        return
            (userNameTextField.text!.isEmpty ||
            passwordTextField.text!.isEmpty ||
            passwordAgainTextField.text!.isEmpty ||
            fullNameTextField.text!.isEmpty ||
            bioTextField.text!.isEmpty ||
            emailTextField.text!.isEmpty)
    }
}

extension SignUpViewController: UINavigationControllerDelegate {
}

extension SignUpViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profileImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true,
                     completion: nil)
    }
}
