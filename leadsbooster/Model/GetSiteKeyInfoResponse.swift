//
//  GetSiteKeyInfoResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/18.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class GetSiteKeyInfoResponse: BaseResponse {

    var data:[AgentDetailInfo] = []
    
    override init() {
        data = []
        super.init()
    }
    
    override init(json: JSON) {
        for item in json["data"].arrayValue {
            data.append(AgentDetailInfo(json: item))
        }
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        data = try map.value("data")
        super.init()
    }
}
