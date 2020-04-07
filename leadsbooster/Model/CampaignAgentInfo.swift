//
//  CampaignAgentInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/16.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class CampaignAgentInfo: ImmutableMappable {
    
    var id = 0
    var phone_number = ""
    var user_id = 0
    var email = ""
    var username = ""
    var status = 0
    var gravity = 0
    
    init(json: JSON) {
        id = json["id"].intValue
        phone_number = json["phone_number"].stringValue
        user_id = json["user_id"].intValue
        email = json["email"].stringValue
        username = json["username"].stringValue
        status = json["status"].intValue
        gravity = json["gravity"].intValue
    }
    
    required init(map: Map) throws {
        id = try map.value("id")
        phone_number = try map.value("phone_number")
        user_id = try map.value("user_id")
        email = try map.value("email")
        username = try map.value("username")
        status = try map.value("status")
        gravity = try map.value("gravity")
    }
}
