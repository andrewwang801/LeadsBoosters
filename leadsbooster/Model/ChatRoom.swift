//
//  ChatRoom.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class ChatRoom: ImmutableMappable {
    
    var id = 0
    var project_name = ""
    var chatId = ""
    var customer = ""
    var customer_name = ""
    var label = 0
    
    init() {
        id = 0
        project_name = ""
        chatId = ""
        customer = ""
        customer_name = ""
        label = 0
    }
    
    init(json: JSON) {
        id = json["id"].intValue
        project_name = json["project_name"].stringValue
        chatId = json["chatId"].stringValue
        customer = json["customer"].stringValue
        label = json["label"].intValue
    }
    
    required init(map: Map) throws {
        id = try map.value("id")
        project_name = try map.value("project_name")
        chatId = try map.value("chatId")
        customer = try map.value("customer")
        customer_name = try map.value("customer_name")
        label = try map.value("label")
    }
}
