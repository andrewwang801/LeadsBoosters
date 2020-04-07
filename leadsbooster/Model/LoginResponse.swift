//
//  LoginResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/1.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

class LoginResponse: BaseResponse {
    var data: UserInfo
    
    override init() {
        data = UserInfo()
        super.init()
    }
    
    override init(json: JSON) {
        data = UserInfo(json: json["data"])
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        data = try map.value("data")
        super.init()
    }
    
    
}
