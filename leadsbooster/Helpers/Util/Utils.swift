//
//  Utils.swift
//  project
//
//  Created by Apple Developer on 2020/2/6.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import Reachability
import SwiftyJSON
import PhoneNumberKit

func hasConnectivity() -> Bool {
    let reachability = Reachability()
    if reachability?.connection == Optional.none {
        return false
    }
    return true
}

func isValidPhoneNumber(phoneNumber: String) -> Bool {
    let phoneNumberKit = PhoneNumberKit()
    do {
        _ = try phoneNumberKit.parse(phoneNumber)
        return true
    }
    catch {
        print("Generic parser error")
        return false
    }
}

func parsePhoneNumber(phoneNumberString: String) -> PhoneNumber? {
    let phoneNumberKit = PhoneNumberKit()
    var phoneNumber: PhoneNumber?
    do {
        phoneNumber = try phoneNumberKit.parse(phoneNumberString)
        return phoneNumber
    } catch {
        return nil
    }
}

func parse(string:String) -> JSON {
    let result = string.data(using: .utf8)
        .map({ (item) -> JSON in
            do {
                let json = try JSON(data: item)
                return json
            } catch {
                return JSON(NSNull())
            }
        })
    return result ?? JSON(NSNull())
}
