//
//  UploadImageResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/19.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class UploadImageResponse: BaseResponse {
    
    var image_path = ""
    
    override init(json: JSON) {
        image_path = json["image_path"].stringValue
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        image_path = try map.value("image_path")
        super.init()
    }
}
