//
//  ContactFormInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/18.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class ContactFormInfo: ImmutableMappable {
    
    var name = ""
    var leads_count = ""
    var site_key = ""
    var cf7_id = ""
    
    init() {
        name = ""
        leads_count = ""
        site_key = ""
        cf7_id = ""
    }
    
    init(json: JSON) {
        name = json["name"].stringValue
        leads_count = json["leads_count"].stringValue
        site_key = json["site_key"].stringValue
        cf7_id = json["cf7_id"].stringValue
    }
    
    required init(map: Map) throws {
        name = try map.value("name")
        leads_count = try map.value("leads_count")
        site_key = try map.value("site_key")
        cf7_id = try map.value("cf7_id")
    }
}
