//
//  ThirdPartyResponseData.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/18.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class ThirdPartyResponseData: ImmutableMappable {
    
    var third_party_apply = false
    var agent_list:[AgentDetailInfo] = []
    
    init() {
        third_party_apply = false
        agent_list = []
    }
    
    init(json: JSON) {
        third_party_apply = json["third_party_apply"].boolValue
        for item in json["agent_list"].arrayValue {
            let agent = AgentDetailInfo(json: item)
            agent_list.append(agent)
        }
    }
    
    required init(map: Map) throws {
        third_party_apply = try map.value("third_party_apply")
        agent_list = try map.value("agent_list")
    }
}
