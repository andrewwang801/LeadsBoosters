//
//  SavaAutoReplyBotResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/5.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

class SaveAutoReplyBotResponse: BaseResponse {
    var id = 0
    
    override init() {
        id = 0
        super.init()
    }
    
    override init(json: JSON) {
        id = json["id"].intValue
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        id = try map.value("id")
        super.init()
    }
}
