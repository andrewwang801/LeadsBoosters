//
//  ReplyBotData.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/5.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import SwiftyJSON

class ReplyBotData {
    
    var message = ""
    var title_emoji = 0
    var message_emoji = 0
    var is_reminder = 0
    var reminder = ""
    
    init() {
        message = ""
        title_emoji = 0
        message_emoji = 0
        is_reminder = 0
        reminder = ""
    }
    
    init(json: JSON) {
        message = json["message"].string ?? ""
        title_emoji = json["title_emoji"].int ?? 0
        message_emoji = json["message_emoji"].int ?? 0
        is_reminder = json["is_reminder"].int ?? 0
        reminder = json["reminder"].string ?? ""
    }
}
