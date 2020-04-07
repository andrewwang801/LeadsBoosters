//
//  InboxCampaignInfoResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class InboxCampaignInfoResponse: BaseResponse {
    
    var campaigns: [InboxCampaignInfo] = []
    
    override init(json: JSON) {
        for item in json["campaigns"].arrayValue {
            let campaign = InboxCampaignInfo(json: item)
            campaigns.append(campaign)
        }
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        campaigns = try map.value("campaigns")
        super.init()
    }
}
