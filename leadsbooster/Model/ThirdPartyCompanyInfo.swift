//
//  ThirdPartyCompanyInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/18.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class ThirdPartyCompanyInfo: ImmutableMappable {
    
    var id = ""
    var company_name = ""
    var company_token = ""
    var description = ""
    
    init() {
        id = ""
        company_name = ""
        company_token = ""
        description = ""
    }
    
    init(json: JSON) {
        
        id = json["id"].stringValue
        company_name = json["company_name"].stringValue
        company_token = json["company_token"].stringValue
        description = json["description"].stringValue
    }
    
    required init(map: Map) throws {
        id = try map.value("id")
        company_token = try map.value("company_token")
        company_name = try map.value("company_name")
        description = try map.value("description")
    }
}
