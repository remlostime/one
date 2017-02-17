//
//  UserInfoViewCell.swift
//  one
//
//  Created by Kai Chen on 12/30/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import UIKit
import Parse

class UserInfoViewCell: UITableViewCell {

    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var iconImageView: UIImageView!
    
    let imageName = "imageName"
    let placeholder = "placeholder"
    let content = "content"
    
    var userInfo: UserInfo?
    
    // MARK: Helpers

    func config(_ indexPath: IndexPath, userInfo: UserInfo) {
        self.userInfo = userInfo

        if let info = cellInfo(indexPath) {
            if let imageName = info[imageName] {
                iconImageView.image = UIImage(named: imageName!)
            }
            if let content = info[content] {
                contentTextField.text = content
            }
            if let placeholder = info[placeholder] {
                contentTextField.placeholder = placeholder
            }
        }
    }

    private func cellInfo(_ forIndexPath: IndexPath) -> [String: String?]? {
        if forIndexPath.section == 0 {
            switch forIndexPath.row {
            case 1:
                return
                    [
                        imageName: "user_fullname_icon",
                        placeholder: "Full Name",
                        content: userInfo?.fullname
                    ]
            case 2:
                return
                    [
                        imageName: "user_id_icon",
                        placeholder: "User ID",
                        content: userInfo?.username
                    ]
            case 3:
                return
                    [
                        imageName: "user_website_icon",
                        placeholder: "Website",
                        content: userInfo?.website
                    ]
            case 4:
                return
                    [
                        imageName: "user_bio_icon",
                        placeholder: "Bio",
                        content: userInfo?.bio
                    ]
            default:
                return nil
            }
        } else {
            switch forIndexPath.row {
            case 0:
                return
                    [
                        imageName: "user_email_icon",
                        placeholder: "Email",
                        content: userInfo?.email
                    ]
            case 1:
                return
                    [
                        imageName: "user_phone_icon",
                        placeholder: "Mobile",
                        content: userInfo?.mobile
                    ]
            case 2:
                return
                    [
                        imageName: "user_gender_icon",
                        placeholder: "Gender",
                        content: userInfo?.gender
                    ]
            default:
                return nil
            }
        }
    }
}
