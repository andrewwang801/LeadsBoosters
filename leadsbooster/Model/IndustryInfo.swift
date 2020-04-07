//
//  IndustryInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class IndustryInfo: ImmutableMappable {
    var industry = ""
    
    init(json: JSON) {
        industry = json["industry"].stringValue
    }
    
    required init(map: Map) throws {
        industry = try map.value("industry")
    }
}
