//
//  RegisterPhoneNumberResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class RegisterPhoneNumberResponse: BaseResponse {
    var id = 0
    
    override init(json: JSON) {
        id = json["id"].intValue
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        id = try map.value("id")
        super.init()
    }
}
