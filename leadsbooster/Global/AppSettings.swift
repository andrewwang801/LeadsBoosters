//
//  AppSettings.swift
//  Alaitisal
//
//  Created by Alex on 2019/7/22.
//  Copyright © 2019 JN. All rights reserved.
//

import Foundation
import SwiftyJSON

class AppSettings {
    
    static var shared: AppSettings {
        if gbInstance == nil {
            gbInstance = AppSettings()
            return gbInstance!
        }
        else {
            return gbInstance!
        }
    }
    
    var leagueId = 0
    var regionId = 0
    
    public static func string(_ forKey: String, default:String = "") -> String {
        return UserDefaults.standard.string(forKey: forKey) ?? `default`
    }
    
    public static func set(_ value:String, forKey:String){
        UserDefaults.standard.set(value, forKey: forKey)
    }
    
    public static func setJson(_ value: JSON, forKey: String) {
        UserDefaults.standard.set(value, forKey: forKey)
    }
    
    public static func bool(_ forKey: String) -> Bool {
        return UserDefaults.standard.bool(forKey: forKey)
    }
    
    public static func setAsBool(_ value:Bool, forKey:String){
        UserDefaults.standard.set(value, forKey: forKey)
    }

    ///User Info
    var membershipInfo: MembershipInfo?
}

var gbInstance: AppSettings?
