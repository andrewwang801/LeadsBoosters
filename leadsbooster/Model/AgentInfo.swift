//
//  AgentInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class AgentInfo: ImmutableMappable {
    var phone_number = ""
    var email = ""
    var id = 0
    
    init() {
        phone_number = ""
        email = ""
        id = 0
    }
    
    init(json: JSON) {
        phone_number = json["phone_number"].stringValue
        email = json["email"].stringValue
        id = json["id"].intValue
    }
    
    required init(map: Map) throws {
        phone_number = try map.value("phone_number")
        email = try map.value("email")
        id = try map.value("id")
    }
    
}
