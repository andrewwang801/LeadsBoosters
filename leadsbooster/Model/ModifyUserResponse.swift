//
//  ModifyUserResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/23.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

class ModifyUserResponse: BaseResponse {
    var token = ""
    
    override init() {
        token = ""
        super.init()
    }
    
    override init(json: JSON) {
        token = json["token"].stringValue
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        super.init()
    }
}
