//
//  GetProfileResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class GetProfileResponse: BaseResponse {
    
    var membership: MembershipInfo? = nil
    var agent_phone_numbers: [AgentInfo] = []
    var industries: [IndustryInfo] = []
    var servers: [ServerInfo] = []
    
    required init(map: Map) throws {
        membership = try map.value("membership")
        agent_phone_numbers = try map.value("agent_phone_numbers")
        industries = try map.value("industries")
        servers = try map.value("servers")
        super.init()
    }
    
    override init(json: JSON) {
        membership = MembershipInfo(json: json["membership"])
        
        for item in json["agent_phone_numbers"].arrayValue {
            let agent = AgentInfo(json: item)
            agent_phone_numbers.append(agent)
        }
        
        for item in json["industries"].arrayValue {
            let industry = IndustryInfo(json: item)
            industries.append(industry)
        }
        
        for item in json["servers"].arrayValue {
            let serverInfo = ServerInfo(json: item)
            servers.append(serverInfo)
        }
        
        super.init(json: json)
    }
}
