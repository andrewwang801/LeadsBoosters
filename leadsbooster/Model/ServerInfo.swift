//
//  ServerInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class ServerInfo: ImmutableMappable {
    
    var id = 0
    var name = ""
    var phone_number = ""
    var industry = ""
    var country_code = ""
    
    init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
        phone_number = json["phone_number"].stringValue
        industry = json["industry"].stringValue
        country_code = json["country_code"].stringValue
    }
    
    required init(map: Map) throws {
        id = try map.value("id")
        name = try map.value("name")
        phone_number = try map.value("industry")
        country_code = try map.value("country_code")
    }
}
