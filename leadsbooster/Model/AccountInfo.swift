//
//  AccountInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/15.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

class AccountInfo: BaseResponse {
    
    var id = ""
    var name = ""
    
    override init() {
        id = ""
        name = ""
        super.init()
    }
    
    override init(json: JSON) {
        id = json["id"].stringValue
        name = json["name"].stringValue
        super.init()
    }
    
    required init(map: Map) throws {
        id = try map.value("id")
        name = try map.value("name")
        super.init()
    }
}
