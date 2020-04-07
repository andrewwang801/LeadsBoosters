//
//  GenerateSiteKeyResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/18.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class GenerateSiteKeyResponse: BaseResponse {
    
    var site_key = ""
    
    override init() {
        site_key = ""
        super.init()
    }
    
    override init(json: JSON) {
        site_key = json["cf7_id"].stringValue
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        site_key = try map.value("site_key")
        super.init()
    }
}
