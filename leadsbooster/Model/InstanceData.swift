//
//  InstanceData.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/15.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class InstanceData: BaseResponse {
    var instances: [InstanceInfo] = []
    var news: [NewsInfo] = []
    var fb_account_list: [AccountInfo] = []
    
    required init(map: Map) {
        super.init()
    }
    
    override init(json: JSON) {
        
        for item in json["instances"].arrayValue {
            let instance = InstanceInfo(json: item)
            instances.append(instance)
        }
        
        for item in json["news"].arrayValue {
            let new = NewsInfo(json: item)
            news.append(new)
        }
        
        for item in json["fb_account_list"].arrayValue {
            let account = AccountInfo(json: item)
            fb_account_list.append(account)
        }
        
        super.init()
    }
}
