//
//  FBPageInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class FBPageInfo: ImmutableMappable {
    
    var fb_pages:[FBpageItem] = []
    var fb_subscribed:[FBSubscribedItem] = []
    
    init(json: JSON) {
        for item in json["fb_pages"].arrayValue {
            let fb_page = FBpageItem(json: item)
            fb_pages.append(fb_page)
        }
        
        for item in json["fb_subscribed"].arrayValue {
            let fb_sub = FBSubscribedItem(json: item)
            fb_subscribed.append(fb_sub)
        }
    }
    
    required init(map: Map) throws {
        fb_pages = try map.value("fb_pages")
        fb_subscribed = try map.value("fb_subscribed")
    }
}
