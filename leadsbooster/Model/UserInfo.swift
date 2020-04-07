//
//  UserInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/1.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

class UserInfo: ImmutableMappable {
    var id = 0
    var username = ""
    var password = ""
    var email = ""
    var login_time = 0
    var phone_number = ""
    var secondary_phone_number = ""
    var created_time = ""
    var industry = ""
    var send_type = 0
    var token = ""
    
    var _json: JSON?

    required init(map: Map) throws {
        id = try map.value("id")
        username = try map.value("username")
        password = try map.value("password")
        email = try map.value("email")
        login_time = try map.value("login_time")
        phone_number = try map.value("phone_number")
        secondary_phone_number = try map.value("secondary_phone_number")
        created_time = try map.value("created_time")
        send_type = try map.value("send_type")
        token = try map.value("token")
    }
    init() {
        id =  0
        username =  ""
        password =  ""
        email =  ""
        login_time =  0
        phone_number =  ""
        secondary_phone_number =  ""
        created_time =  ""
        token =  ""
        industry = ""
        send_type = 0
    }
    
    init(json: JSON) {
        id =  json["id"].intValue
        username =  json["username"].stringValue
        password =  json["password"].stringValue
        email =  json["email"].stringValue
        login_time =  json["login_time"].intValue
        phone_number =  json["phone_number"].stringValue
        secondary_phone_number =  json["secondary_phone_number"].stringValue
        created_time =  json["created_time"].stringValue
        token =  json["token"].stringValue
        send_type = json["send_type"].intValue
        industry = json["industry"].stringValue
        
        _json = json
    }
    
    func toString() -> String {
        if let _json = _json {
            return _json.rawString() ?? ""
        }
        return ""
    }
}
