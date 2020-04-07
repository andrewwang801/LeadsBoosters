//
//  WordPressDataResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/18.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class WordPressDataResponse: BaseResponse {
    
    var data: WordPressData = WordPressData()
    
    override init(json: JSON) {
        data = WordPressData(json: json["data"])
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        data = try map.value("data")
        super.init()
    }
}
