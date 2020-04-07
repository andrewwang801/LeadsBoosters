//
//  MembershipReponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/20.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class MembershipResponse: BaseResponse {
    
    var data: MembershipInfo
    
    override init () {
        data = MembershipInfo()
        super.init()
    }
    
    override init(json: JSON) {
        data = MembershipInfo(json: json["data"])
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        data = try map.value("data")
        super.init()
    }
}
