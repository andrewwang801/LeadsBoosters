//
//  CampaignInfoResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/16.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class CampaignInfoResponse: BaseResponse {
    
    var data: CampaignSetInfo = CampaignSetInfo()
    
    override init() {
        data = CampaignSetInfo()
        super.init()
    }
    
    override init(json: JSON) {
        data = CampaignSetInfo(json: json["data"])
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        data = try map.value("data")
        super.init()
    }
}
