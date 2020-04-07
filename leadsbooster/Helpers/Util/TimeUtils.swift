//
//  TimeUtils.swift
//  Alaitisal
//
//  Created by JinMing on 9/7/19.
//  Copyright © 2019 JN. All rights reserved.
//

import Foundation

class TimeUtils {
    public static func UTCToLocal(_ format:String, _ strTime:String, _ convFormat:String) -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let time = dateFormatter.date(from: strTime)
        
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = convFormat
        
        return dateFormatter.string(from: time!)
    }
    public static func localToUTC(_ format:String, _ strTime:String,  _ convFormat:String)->String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        let time = dateFormatter.date(from: strTime)
        
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = convFormat
        
        return dateFormatter.string(from: time!)
    }
    
    
    public static func otherFormatTime(_ format:String, _ strTime:String,  _ convFormat:String)->String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format
        let time = dateFormatter.date(from: strTime)
        
        dateFormatter.dateFormat = convFormat
        let result = dateFormatter.string(from: time!)
        return dateFormatter.string(from: time!)
    }
    
    
}
