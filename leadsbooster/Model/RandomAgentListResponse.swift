//
//  RandomAgentListResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/16.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class RandomAgentListResponse: BaseResponse {
    var agents: [CampaignAgentInfo] = []
    
    override init() {
        agents = []
        super.init()
    }
    
    override init(json: JSON) {
        for item in json["agents"].arrayValue {
            let agent = CampaignAgentInfo(json: item)
            agents.append(agent)
        }
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        agents = try map.value("agents")
        super.init()
    }
}
