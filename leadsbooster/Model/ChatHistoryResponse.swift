//
//  ChatHistoryResponse.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/19.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

class ChatHistoryResponse: BaseResponse {
    
    var messages: [ChatMessage] = []
    var chatInfo: ChatRoom? = nil
    
    override init(json: JSON) {
        for item in json["messages"].arrayValue {
            let message = ChatMessage(json: item)
            messages.append(message)
        }
        chatInfo = ChatRoom(json: json["chatInfo"])
        super.init(json: json)
    }
    
    required init(map: Map) throws {
        messages = try map.value("messages")
        chatInfo = try map.value("chatInfo")
        super.init()
    }
}
