//
//  WordpressData.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/18.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class WordPressData: ImmutableMappable {
    
    var site_key = ""
    var contact_form: [ContactFormInfo] = []
    
    init() {
        site_key = ""
        contact_form = []
    }
    
    init(json: JSON) {
        site_key = json["site_key"].stringValue
        for item in json["contact_form"].arrayValue {
            let contact = ContactFormInfo(json: item)
            contact_form.append(contact)
        }
    }
    
    required init(map: Map) throws {
        site_key = try map.value("site_key")
        contact_form = try map.value("contact_form")
    }
}
