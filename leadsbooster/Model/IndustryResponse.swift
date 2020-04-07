//
//  IndustryResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/1.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import SwiftyJSON

class IndustryResponse {
    
    var result = 0
    var message = ""
    var items: [String] = []
    
    init(data: JSON) {
        result = data["result"].int ?? 0
        message = data["message"].string ?? ""
        items = data["data"].arrayValue.map{$0["industry"].string ?? ""}
    }
    
    init() {
        result = 0
        message = ""
        items = []
    }
}
