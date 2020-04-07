//
//  AgentDetailInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/18.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class AgentDetailInfo: ImmutableMappable {
    
    var id = 0
    var phone_number = ""
    var user_id = ""
    var username = ""
    var email = ""
    var status = 0
    var leads_count = 0
    var instance_count = 0
    
    init() {
        id = 0
        phone_number = ""
        user_id = ""
        username = ""
        email = ""
        status = 0
        leads_count = 0
        instance_count = 0
    }
    
    init(json: JSON) {
        id = json["id"].intValue
        phone_number = json["phone_number"].stringValue
        user_id = json["user_id"].stringValue
        username = json["username"].stringValue
        email = json["email"].stringValue
        status = json["status"].intValue
        leads_count = json["leads_count"].intValue
        instance_count = json["instance_count"].intValue
    }
    
    required init(map: Map) throws {
        id = try map.value("id")
        phone_number = try map.value("phone_number")
        user_id = try map.value("user_id")
        username = try map.value("username")
        email = try map.value("email")
        status = try map.value("status")
        leads_count = try map.value("leads_count")
        instance_count = try map.value("instance_count")
    }
}
