//
//  Transforms.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/22.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import Foundation
import ObjectMapper

class AnyTransform: TransformType {
    func transformToJSON(_ value: Int?) -> Any? {
        return nil
    }
    
    typealias Object = Int
    typealias JSON = Any
    
    func transformFromJSON(_ value: Any?) -> Int? {
        guard let value = value as? Int else { return nil }
        
        return value
    }
}
