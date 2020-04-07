//
//  UIColor+Ext.swift
//  Alaitisal
//
//  Created by Alex on 2019/7/22.
//  Copyright © 2019 JN. All rights reserved.
//
import UIKit

extension Ext where Base: UIColor {
    // return 1-px image
    var image:UIImage{
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(base.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    // Oval Image
    func ovalImage(_ radius:CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: radius.width * 2, height: radius.height * 2)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.allCorners], cornerRadii: radius)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        path.lineWidth = 0.0
        context?.addPath(path.cgPath)
        context?.setFillColor(base.cgColor)
        context?.fillPath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
