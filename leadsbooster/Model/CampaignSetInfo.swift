//
//  CampaignSetInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/16.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class CampaignSetInfo: ImmutableMappable {
    
    var campaign_welcome_bot = ""
    var agents: [CampaignAgentInfo] = []
    
    init() {
        campaign_welcome_bot = ""
        agents = []
    }

    init(json: JSON) {
        campaign_welcome_bot = json["campaign_welcome_bot"].stringValue
        
        for item in json["agents"].arrayValue {
            let agent = CampaignAgentInfo(json: item)
            agents.append(agent)
        }
    }
    
    required init(map: Map) throws {
        campaign_welcome_bot = try map.value("campaign_welcome_bot")
        agents = try map.value("agents")
    }
}
