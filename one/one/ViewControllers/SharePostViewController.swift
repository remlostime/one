//
//  SharePostViewController.swift
//  one
//
//  Created by Kai Chen on 1/2/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class SharePostViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let imageViewTap = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.addGestureRecognizer(imageViewTap)
        
        let keyboardDismissTap = UITapGestureRecognizer(target: self, action: #selector(keyboardDismissTapped))
        self.view.addGestureRecognizer(keyboardDismissTap)
    }
    
    func keyboardDismissTapped() {
        self.contentTextField.endEditing(true)
    }
    
    func imageViewTapped() {
        let pickerVC = UIImagePickerController()
        pickerVC.delegate = self
        pickerVC.allowsEditing = true
        pickerVC.sourceType = .photoLibrary
        present(pickerVC, animated: true, completion: nil)
    }
    
    @IBAction func sharePostButtonTapped(_ sender: UIButton) {
        let object = PFObject(className: Post.modelName.rawValue)
        object[User.id.rawValue] = PFUser.current()?.username
        object[User.profileImage.rawValue] = PFUser.current()?.value(forKey: User.profileImage.rawValue) as? PFFile
        
        if (contentTextField.text?.isEmpty)! {
            object[Post.title.rawValue] = ""
        } else {
            object[Post.title.rawValue] = contentTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        }
        
        let imageData = UIImagePNGRepresentation(imageView.image!)
        let imageFile = PFFile(name: "post.png", data: imageData!)
        object[Post.picture.rawValue] = imageFile

        object[Post.uuid.rawValue] = UUID().uuidString
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        object.saveInBackground { [weak self](success: Bool, error: Error?) in
            guard let strongSelf = self else {
                return
            }
            
            if error == nil {
                MBProgressHUD.hide(for: strongSelf.view, animated: true)
                NotificationCenter.default.post(name: .newPostIsSent, object: nil)
                strongSelf.tabBarController?.selectedIndex = 0
            }
        }
    }
    
    @IBAction func removeButtonTapped(_ sender: UIButton) {
        imageView.image = nil
        shareButton.isEnabled = false
        shareButton.backgroundColor = .lightGray
    }
}

extension SharePostViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        dismiss(animated: true, completion: nil)
        
        shareButton.isEnabled = true
        shareButton.backgroundColor = .sharePostButtonColor
        
        
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension SharePostViewController: UINavigationControllerDelegate {
}
