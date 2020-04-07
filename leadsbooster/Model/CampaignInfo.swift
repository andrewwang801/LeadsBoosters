//
//  CampaignInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/15.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

class CampaignInfo: BaseResponse {
    
    var id = ""
    var spend = ""
    var clicks = ""
    var leads_count = ""
    var ad_account = ""
    var campaign_name = ""
    var per_leads = ""
    
    override init() {
        id = ""
        spend = ""
        clicks = ""
        leads_count = ""
        ad_account = ""
        campaign_name = ""
        per_leads = ""
        super.init()
    }
    
    override init(json: JSON) {
        id = json["id"].stringValue
        spend = json["spend"].stringValue
        clicks = json["clicks"].stringValue
        leads_count = json["leads_count"].stringValue
        ad_account = json["ad_account"].stringValue
        campaign_name = json["campaign_name"].stringValue
        per_leads = json["per_leads"].stringValue
        super.init()
    }
    
    required init(map: Map) throws {
        super.init()
    }
    
}
