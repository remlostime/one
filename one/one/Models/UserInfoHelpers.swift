//
//  UserConstant.swift
//  one
//
//  Created by Kai Chen on 12/27/16.
//  Copyright © 2016 Kai Chen. All rights reserved.
//

import Foundation
import Parse

enum User: String {
    case modelName = "_User"
    case id = "username"
    case profileImage = "profile_image"
    case fullname = "fullname"
    case bio = "bio"
    case uuid = "uuid"
    case website = "webstie"
    case mobile = "mobile"
    case gender = "gender"
}

class UserInfo {
    var user: PFUser?
    
    init(_ withUsername: String?) {
        if let username = withUsername {
            let query = PFQuery(className: User.modelName.rawValue)
            query.whereKey(User.id.rawValue, equalTo: username)
            query.findObjectsInBackground(block: { [weak self](objects: [PFObject]?, error: Error?) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.user = objects?.first as! PFUser?
            })
        } else {
            user = PFUser.current()
        }
    }
    
    var username: String? {
        get {
            return user?.username
        }
    }
    
    var profileImageFile: PFFile? {
        get {
            return user?.object(forKey: User.profileImage.rawValue) as? PFFile
        }
    }
    
    var fullname: String? {
        get {
            return user?.object(forKey: User.fullname.rawValue) as? String
        }
    }
    
    var bio: String? {
        get {
            return user?.object(forKey: User.bio.rawValue) as? String
        }
    }
    
    var website: String? {
        get {
            return user?.object(forKey: User.website.rawValue) as? String
        }
    }
    
    var email: String? {
        get {
            return user?.email
        }
    }
    
    var mobile: String? {
        get {
            return user?.object(forKey: User.mobile.rawValue) as? String
        }
    }
    
    var gender: String? {
        get {
            return user?.object(forKey: User.gender.rawValue) as? String
        }
    }
}

