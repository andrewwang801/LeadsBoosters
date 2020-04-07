//
//  InboxCampaignInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class InboxCampaignInfo: ImmutableMappable {
    
    var project_name = "-1"
    init() {
        project_name = "-1"
    }
    
    init(json: JSON) {
        project_name = json["project_name"].stringValue
    }
    
    required init(map: Map) throws {
        project_name = try map.value("project_name")
    }
}
