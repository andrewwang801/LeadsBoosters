//
//  ChatMessage.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/19.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChatMessage {
    var id = ""
    var body = ""
    var fromMe = false
    var _self = 0
    var isForwarded = 0
    var author = ""
    var time = 0
    var chatId = ""
    var messageNumber = 0
    var type = ""
    var senderName = ""
    var chatName = ""
    
    init() {
        id = ""
        body = ""
        fromMe = false
        _self = 0
        isForwarded = 0
        author = ""
        time = 0
        chatId = ""
        messageNumber = 0
        type = ""
        senderName = ""
        chatName = ""
    }
    
    init(json: JSON) {
        id = json["id"].stringValue
        body = json["body"].stringValue
        fromMe = json["fromMe"].boolValue
        _self = json["_self"].intValue
        isForwarded = json["isForwarded"].intValue
        author = json["author"].stringValue
        time = json["time"].intValue
        chatId = json["chatId"].stringValue
        messageNumber = json["messageNumber"].intValue
        type = json["type"].stringValue
        senderName = json["senderName"].stringValue
        chatName = json["chatName"].stringValue
    }
    
    func getDateSent() -> String{
        let date = Date(timeIntervalSince1970: TimeInterval(time * 1000))
        return date.toDateString(format: "MMMM d") ?? ""
    }
    
    func getTimeSent() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time * 1000))
        return date.toDateString(format: "h:mm a") ?? ""
    }
    
    func getDateAsHeaderId() -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        return date.toDateString(format: "dd/MM/yyyy") ?? ""
    }
    
    func getURL() -> String {
        return body
    }
    
    func getBody() -> String {
        return body
    }
    
    func getSenderName(userInfo: UserInfo, chatRoom: ChatRoom) -> String {
        if !isIncoming(userInfo: userInfo) {
            return userInfo.username
        }
        else {
            return chatRoom.customer_name
        }
    }
    
    func isAttachment() -> Bool {
        if type == "chat" {
            return false
        }
        else {
            return true
        }
    }
    
    func isIncoming(userInfo: UserInfo) -> Bool {
        if !fromMe {
            if author.starts(with: userInfo.phone_number.substring(from: 1)) {
                return true
            }
            else {
                return false
            }
        }
        else {
            return false
        }
    }
}
