//
//  BaseResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/1.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

class BaseResponse: ImmutableMappable {
    var message = ""
    var result = 0
    
    init(json: JSON) {
        message = json["message"].string ?? ""
        result = json["result"].int ?? 0
    }
    
    init() {
        message = ""
        result = 0
    }
    
    required init(map: Map) throws {
        message = try map.value("message")
        result = try map.value("result")
    }
}

