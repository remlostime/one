//
//  EditUserInfoViewController.swift
//  one
//
//  Created by Kai Chen on 12/30/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class EditUserInfoViewController: UITableViewController {
    
    fileprivate var profileImageCell: ProfileUserImageViewCell?
    
    fileprivate var genderPickerView: UIPickerView!
    let genders = ["Male", "Female"]
    
    var genderCell: UserInfoViewCell?
    
    let userInfo = UserInfo.init(nil)
    
    fileprivate var profileImage: UIImage?
    fileprivate var username: String?
    fileprivate var fullname: String?
    fileprivate var bio: String?
    fileprivate var website: String?
    fileprivate var email: String?
    fileprivate var mobile: String?
    fileprivate var gender: String?
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        genderPickerView = UIPickerView()
        genderPickerView.dataSource = self
        genderPickerView.delegate = self
        genderPickerView.backgroundColor = UIColor.groupTableViewBackground
        genderPickerView.showsSelectionIndicator = true
    }
    
    // MARK: Action
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        // TODO: We should setup listener in email field to get email when user is done with it
        let emailIndexPath = IndexPath(row: 0, section: 1)
        let emailCell = tableView.cellForRow(at: emailIndexPath) as? UserInfoViewCell
        let email = emailCell?.contentTextField.text
        
        if let email = email {
            if !email.isValidEmail() {
                let alert = AlertHelper.init("Incorrect Email", message: "Please provoide correct email.", delegate: self)
                alert.show()
                
                return
            }
        }
        
        
        let websiteIndexPath = IndexPath(row: 3, section: 0)
        let websiteCell = tableView.cellForRow(at: websiteIndexPath) as? UserInfoViewCell
        let website = websiteCell?.contentTextField.text
        
        if let website = website {
            if !website.isValidWebsite() {
                let alert = AlertHelper.init("Incorrect Website", message: "Please provide correct website", delegate: self)
                alert.show()
                
                return
            }
        }
        
        let user = PFUser.current()
        
        let usernameIndexPath = IndexPath(row: 2, section: 0)
        let usernameCell = tableView.cellForRow(at: usernameIndexPath) as? UserInfoViewCell
        user?.username = usernameCell?.contentTextField.text
        
        user?.email = emailCell?.contentTextField.text
        user?[User.website.rawValue] = websiteCell?.contentTextField.text
        
        let fullnameIndexPath = IndexPath(row: 1, section: 0)
        let fullnameCell = tableView.cellForRow(at: fullnameIndexPath) as? UserInfoViewCell
        user?[User.fullname.rawValue] = fullnameCell?.contentTextField.text
        
        let bioIndexPath = IndexPath(row: 4, section: 0)
        let bioCell = tableView.cellForRow(at: bioIndexPath) as? UserInfoViewCell
        user?[User.bio.rawValue] = bioCell?.contentTextField.text
        
        let mobileIndexPath = IndexPath(row: 1, section: 1)
        let mobileCell = tableView.cellForRow(at: mobileIndexPath) as? UserInfoViewCell
        user?[User.mobile.rawValue] = mobileCell?.contentTextField.text
        
        
        let genderIndexPath = IndexPath(row: 2, section: 0)
        let genderCell = tableView.cellForRow(at: genderIndexPath) as? UserInfoViewCell
        user?[User.gender.rawValue] = genderCell?.contentTextField.text
        
        let profileImageData = UIImagePNGRepresentation((profileImageCell?.profileImageView.image)!)
        let profileImageFile = PFFile(name: "profile_image.png", data: profileImageData!)
        user?[User.profileImage.rawValue] = profileImageFile
        
        user?.saveInBackground(block: { [weak self](success: Bool, error: Error?) in
            guard let strongSelf = self else {
                return
            }
            
            guard !success else {
                let alert = AlertHelper.init("Save Error", message: "Can not save, please try again!", delegate: strongSelf)
                alert.show()
                return
            }
            
            // TODO: NSNotification to tell home profile vc to update user info
            
            strongSelf.dismiss(animated: true, completion: nil)
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        } else {
            return 3
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0 && indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.profileUserImageViewCell.rawValue, for: indexPath) as? ProfileUserImageViewCell
            // setup user image
            cell?.delegate = self
            
            let profileImageFile = userInfo.profileImageFile
            profileImageFile?.getDataInBackground(block: { [weak cell](data: Data?, error: Error?) in
                guard let strongCell = cell else {
                    return
                }
                
                strongCell.profileImageView?.image = UIImage(data: data!)
            })
            
            return cell!
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Identifier.userInfoViewCell.rawValue, for: indexPath) as? UserInfoViewCell
            cell?.config(indexPath, userInfo: userInfo)
            
            if (indexPath.section == 1 && indexPath.row == 2) {
                cell?.contentTextField.inputView = genderPickerView
                genderCell = cell
            }
        
            
            return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else {
            return "PRIVATE INFORMATION"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 150.0
        } else {
            return 46.0
        }
    }
    

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension EditUserInfoViewController: ProfileUserImageViewCellDelegate {
    func showImagePicker(_ profileImageCell: ProfileUserImageViewCell) {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.allowsEditing = true
        
        self.profileImageCell = profileImageCell
        
        present(imagePickerVC, animated: true, completion: nil)
    }
}

extension EditUserInfoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        profileImageCell?.profileImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }
}

extension EditUserInfoViewController: UINavigationControllerDelegate {
    
}

extension EditUserInfoViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let genderCell = genderCell {
            genderCell.contentTextField.text = genders[row]
            genderCell.endEditing(true)
        }
    }
}

extension EditUserInfoViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
}

extension EditUserInfoViewController: AlertHelperDelegate {
    func show(_ alertViewController: UIAlertController) {
        present(alertViewController, animated: true, completion: nil)
    }
}
