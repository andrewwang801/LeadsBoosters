//
//  CampaignListResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/15.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class CampaignListResponse: BaseResponse {
    
    var data: [CampaignInfo] = []
    
    required init(map: Map) throws {
        data = try map.value("data")
        super.init()
    }
    
    override init(json: JSON) {
        for item in json["data"].arrayValue {
            let campaignInfo = CampaignInfo(json: item)
            data.append(campaignInfo)
        }
        super.init(json: json)
    }
}
