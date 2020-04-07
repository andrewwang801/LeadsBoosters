//
//  FBPageItem.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class FBpageItem: ImmutableMappable {
    var name = ""
    var id = ""
    var access_token = ""
    
    init() {
        name = ""
        id = ""
        access_token = ""
    }
    
    init(json: JSON) {
        name = json["name"].stringValue
        id = json["id"].stringValue
        access_token = json["access_token"].stringValue
    }
    
    required init(map: Map) throws {
        name = try map.value("name")
        id = try map.value("id")
        access_token = try map.value("access_token")
    }
}
