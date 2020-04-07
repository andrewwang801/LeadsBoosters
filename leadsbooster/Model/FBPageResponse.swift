//
//  FBPageResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class FBPageResponse: BaseResponse {
    
    var data: FBPageInfo
    
    override init(json: JSON){
        data = FBPageInfo(json: json["data"])
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        data = try map.value("data")
        super.init()
    }
}
