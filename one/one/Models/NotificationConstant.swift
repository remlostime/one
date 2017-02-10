//
//  NotificationConstant.swift
//  one
//
//  Created by Kai Chen on 1/26/17.
//  Copyright © 2017 Kai Chen. All rights reserved.
//

import Foundation

enum Notifications: String {
    case modelName = "Notification"
    case sender = "sender"
    case receiver = "receiver"
    case action = "action"
    case postUUID = "post_uuid"
}

enum NotificationsAction: String {
    case like = "like"
    case comment = "comment"
    case follow = "follow"
    case mention = "mention"
}
