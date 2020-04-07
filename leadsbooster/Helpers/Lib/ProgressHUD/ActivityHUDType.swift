//
//  HUDInfo.swift
//  AutoCorner
//
//  Created by Alex on 30/1/2016.
//  Copyright © 2016 stockNumSystems. All rights reserved.
//

import Foundation
import UIKit

protocol ActivityHUDType{
    // View that will be set center.
    var contentView:UIView? { get set }
    var message:String? { get set }
    var detailMessage:String? { get set }
    
    // Show/Hide
    func show(_ animated:Bool)
    
    // Hide
    func hide(_ animated:Bool)
    func hide(_ animated:Bool, delay : TimeInterval)
    
    // Fail / Success
    func setFail()
    func setFail(_ hideAfter:TimeInterval)
    
    func setSuccess()
    func setSuccess(_ hideAfter:TimeInterval)
}

// MARK: - Extension for ActivityHUDType
extension ActivityHUDType{
    /// Sets HUD Messages, only set when parameters are not nil
    mutating func setMessages(_ message:String? = nil, detailMessage:String? = nil){
        if let message = message{
            self.message = message
        }
        if let detailMessage = detailMessage{
            self.detailMessage = detailMessage
        }
    }
    
    /// Set Failed with message.
    mutating func setFailWithMessages(_ message:String? = nil, detailMessage:String? = nil){
        if let message = message {
            self.message = message
        } else {
            self.message = ""
        }
        if let detailMessage = detailMessage{
            self.detailMessage = detailMessage
        } else {
            self.message = ""
        }
        setFail()
    }
    
    /// Set Failed with message.
    mutating func setFailWithMessages(_ hideAfter:TimeInterval, message:String? = nil, detailMessage:String? = nil){
        if let message = message {
            self.message = message
        } else {
            self.message = ""
        }
        if let detailMessage = detailMessage{
            self.detailMessage = detailMessage
        } else {
            self.detailMessage = ""
        }
        setFail(hideAfter)
    }
    
    /// Set Success with message.
    mutating func setSuccessWithMessages(_ message:String? = nil, detailMessage:String? = nil){
        if let message = message {
            self.message = message
        } else {
            self.message = ""
        }
        if let detailMessage = detailMessage{
            self.detailMessage = detailMessage
        } else {
            self.detailMessage = detailMessage
            
        }
        setSuccess()
    }
    
    /// Set SuccessSuccess with message.
    mutating func setSuccessWithMessages(_ hideAfter:TimeInterval, message:String? = nil, detailMessage:String? = nil){
        if let message = message {
            self.message = message
        }
        if let detailMessage = detailMessage{
            self.detailMessage = detailMessage
        }
        setSuccess(hideAfter)
    }
}
