//
//  NewsInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/15.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class NewsInfo: ImmutableMappable {
    
    var id = 0
    var created_date = ""
    var news = ""
    
    required init(map: Map) throws {
        id = try map.value("id")
        created_date = try map.value("created_date")
        news = try map.value("news")
    }
    
    init(json: JSON) {
        id = json["id"].intValue
        created_date = json["created_date"].stringValue
        news = json["news"].stringValue
    }
}
