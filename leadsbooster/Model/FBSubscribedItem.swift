//
//  FBSubscribedItem.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class FBSubscribedItem: ImmutableMappable {
    var page_id = ""
    var page_token = ""
    var name = ""
    
    init() {
        page_id = ""
        page_token = ""
        name = ""
    }
    
    init(json: JSON) {
        page_id = json["page_id"].stringValue
        page_token = json["page_token"].stringValue
        name = json["name"].stringValue
    }
    
    required init(map: Map) throws {
        page_id = try map.value("page_id")
        page_token = try map.value("page_token")
        name = try map.value("name")
    }
}
