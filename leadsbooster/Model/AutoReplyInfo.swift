//
//  AutoReplyInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/5.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import SwiftyJSON

class AutoReplyInfo {
    
    var keywork = ""
    var reply = ""
    var user_id = 0
    var id = 0
    
    init() {
        keywork = ""
        reply = ""
        user_id = 0
        id = 0
    }
    
    init(json: JSON) {
        keywork = json["keyword"].stringValue
        reply = json["reply"].stringValue
        id = json["id"].intValue
        user_id = json["user_id"].intValue
    }
}
