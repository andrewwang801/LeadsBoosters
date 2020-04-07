//
//  InstanceResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/15.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class InstanceResponse: BaseResponse {
    var data: InstanceData
    
    override init(json: JSON) {
        data = InstanceData(json: json["data"])
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        data = try map.value("data")
        super.init()
    }
}
