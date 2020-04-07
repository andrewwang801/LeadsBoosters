//
//  Ext.swift
//  Alaitisal
//
//  Created by Alex on 2019/7/21.
//  Copyright © 2019 JN. All rights reserved.
//

import Foundation
import UIKit

import protocol RxSwift.ObserverType

public struct Ext<Base> {
    public let base:Base
    public init(_ base:Base){
        self.base = base
    }
}

public protocol ExtCompatible{
    associatedtype ExtCompatibleType
    static var ext:Ext<ExtCompatibleType>.Type { get }
    var ext:Ext<ExtCompatibleType> { get }
}

public extension ExtCompatible {
    /**
     Ext extensions.
     */
    public static var ext: Ext<Self>.Type {
        return Ext<Self>.self
    }
    
    /**
     Ext extensions.
     */
    public var ext: Ext<Self> {
        return Ext(self)
    }
}

extension NSObject: ExtCompatible {}


extension ObserverType {
    /**
     Combination of onNext & onCompleted
     */
    func onNextAndCompleted(_ element:Self.E) {
        on(.next(element))
        on(.completed)
    }
}

public extension String {
    
    //right is the first encountered string after left
    func between(_ left: String, _ right: String) -> String? {
        guard
            let leftRange = range(of: left), let rightRange = range(of: right, options: .backwards)
            , leftRange.upperBound <= rightRange.lowerBound
            else { return nil }
        
        let sub = self[leftRange.upperBound...]
        let closestToLeftRange = sub.range(of: right)!
        return String(sub[..<closestToLeftRange.lowerBound])
    }
    
    var length: Int {
        get {
            return self.count
        }
    }
    
    func substring(to : Int) -> String {
        let toIndex = self.index(self.startIndex, offsetBy: to)
        return String(self[...toIndex])
    }
    
    func substring(from : Int) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: from)
        return String(self[fromIndex...])
    }
    
    func substring(_ r: Range<Int>) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let toIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        let indexRange = Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex))
        return String(self[indexRange])
    }
    
    func character(_ at: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: at)]
    }
    
    func lastIndexOfCharacter(_ c: Character) -> Int? {
        return range(of: String(c), options: .backwards)?.lowerBound.encodedOffset
    }
    
    func convertHtml() -> NSAttributedString{
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do{
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html,
                                                                .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        }catch{
            return NSAttributedString()
        }
    }
    
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    var validDateString:Bool {
        get {
            if self.isEmpty { return false }
            if self.contains(find: "0000") { return false }
            
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "YYYY-mm-dd HH:mm:ss"
            guard let _ = dateformatter.date(from: self) else { return false }
            
            return true
        }
    }
    
    func otherFormatTimeString(_ format:String, _ convFormat:String)->String {
        if !self.validDateString { return self }
        return TimeUtils.otherFormatTime(format, self, convFormat)
    }
}



extension Ext where Base: UIView {
    func setDefaultBorder() {
        base.layer.borderColor = UIColor(red:208/255, green:208/255, blue:208/255, alpha: 1).cgColor
        base.layer.borderWidth = 1
        base.layer.cornerRadius = 5
    }
}
