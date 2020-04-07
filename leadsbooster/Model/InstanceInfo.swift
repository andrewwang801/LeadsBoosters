//
//  InstanceInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/15.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class InstanceInfo: ImmutableMappable {
    
    var id = 0
    var type = 0
    var instance_id = 0
    var name = ""
    var status = 0
    var user_id = 0
    
    required init(map: Map) throws {
        id = try map.value("id")
        type = try map.value("type")
        instance_id = try map.value("instance_id")
        name = try map.value("name")
        status = try map.value("status")
        id = try map.value("user_id")
    }
    
    init(json: JSON) {
        id = json["id"].intValue
        type = json["type"].intValue
        instance_id = json["instance_id"].intValue
        name = json["name"].stringValue
        status = json["status"].intValue
        user_id = json["user_id"].intValue
    }
}
