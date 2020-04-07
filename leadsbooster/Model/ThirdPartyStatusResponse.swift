//
//  ThirdPartyStatusResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/18.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class ThirdPartyStatusResponse: BaseResponse {
    
    var data: ThirdPartyResponseData = ThirdPartyResponseData()
    
    override init(json: JSON) {
        data = ThirdPartyResponseData(json: json["data"])
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        data = try map.value("data")
        super.init()
    }
}
