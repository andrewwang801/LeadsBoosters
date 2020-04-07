//
//  AutoResponseReply.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/5.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

class AutoReplyBotResponse: BaseResponse {
    var data: [AutoReplyInfo] = []
    
    override init(json: JSON) {
        
        for item in json["data"].arrayValue {
            let autoReplyInfo = AutoReplyInfo(json: item)
            data.append(autoReplyInfo)
        }
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        data = try map.value("data")
        super.init()
    }
}
