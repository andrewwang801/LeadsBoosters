//
//  InboxInfoResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class InboxInfoResponse: BaseResponse {
    var chatrooms: [ChatRoom] = []
    
    override init(json: JSON) {
        for item in json["chatrooms"].arrayValue {
            let chatroom = ChatRoom(json: item)
            chatrooms.append(chatroom)
        }
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        chatrooms = try map.value("chatrooms")
        super.init()
    }
}
