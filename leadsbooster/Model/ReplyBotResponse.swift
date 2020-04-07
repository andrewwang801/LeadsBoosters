//
//  ReplyBotResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/5.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

class ReplyBotResponse: BaseResponse {
    
    var response: ReplyBotData
    
    override init() {
        response = ReplyBotData()
        super.init()
    }
    
    override init(json: JSON) {
        self.response = ReplyBotData(json: json["data"])
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        response = try map.value("response")
        super.init()
    }
}
