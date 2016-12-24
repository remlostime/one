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
    @IBOutlet var websiteTextField: UITextField!
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

        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true

        let profileImageTapGesture = UITapGestureRecognizer(target: self,
                                                            action: #selector(profileImageTapped(recognizer:)))
        profileImageTapGesture.numberOfTapsRequired = 1
        profileImageView.isUserInteractionEnabled = true
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
//        let keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
//
//        UIView.animate(withDuration: 0.4, animations: { () -> Void in
//            self.scrollView.frame.size.height = self.scrollViewHeight - keyboard.height
//        })
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
        user["fullname"] = fullNameTextField.text?.lowercased()
        user["bio"] = bioTextField.text
        user["website"] = websiteTextField.text?.lowercased()
        user["tel"] = ""
        user["gender"] = ""

        let profileData = UIImagePNGRepresentation(profileImageView.image!)
        let profileFile = PFFile(name: "profile.png",
                                 data: profileData!)
        user["profile_image"] = profileFile

        user.signUpInBackground { (success: Bool, error: Error?) in
            if success {
                print("successfully signup")

                // Store logged user
                UserDefaults.standard.set(user.username, forKey: "username")
                UserDefaults.standard.synchronize()

                // Call login func from AppDelegate
                let appDelegate = UIApplication.shared.delegate as? AppDelegate

                appDelegate?.login()
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
            websiteTextField.text!.isEmpty ||
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
