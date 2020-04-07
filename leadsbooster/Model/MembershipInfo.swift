//
//  MembershipInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/16.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class MembershipInfo: ImmutableMappable {
    
    var plans = "free"
    var expired = false
    var start_date = "Unknown"
    var end_date = "Unknown"
    var remain_budget = 0
    var corporate_balance = 0
    var _json: JSON?
    
    init() {
        plans = "free"
        expired = false
        start_date = "Unknown"
        end_date = "Unknown"
        remain_budget = 0
        corporate_balance = 0
    }
    
    init(json: JSON) {
        plans = json["plans"].stringValue
        expired = json["expired"].boolValue
        start_date = json["start_date"].stringValue
        end_date = json["end_date"].stringValue
        remain_budget = json["remain_budget"].intValue
        corporate_balance = json["corporate_balance"].intValue
        
        _json = json
    }
    
    required init(map: Map) throws {
        plans = try map.value("plans")
        expired = try map.value("expired")
        start_date = try map.value("start_date")
        end_date = try map.value("end_date")
        remain_budget = try map.value("remain_budget")
        corporate_balance = try map.value("corporate_balance")
    }
    
    func toString() -> String {
        if let _json = _json {
            return _json.rawString() ?? ""
        }
        return ""
    }
}
