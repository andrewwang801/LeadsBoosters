//
//  UIView+Corner.swift
//  Alaitisal
//
//  Created by Alex on 2019/7/21.
//  Copyright © 2019 JN. All rights reserved.
//

import UIKit

extension UIView {
    /**
     Make Oval Border
     - Parameter color : Border Color
     - Parameter borderWidth : Border Width
     */
    func makeOvalBorder(color:UIColor, borderWidth bw:CGFloat){
        // try get reasonable width
        setupBorder(color: color, borderWidth: bw, cornerRadius: min(bounds.width, bounds.height) / 2.0)
    }
    
    /**
     Set Corner Radius
     - Parameter color : Color of border, can be clear color
     - Parameter borderWidth : Width of border
     - Parameter cornerRadius : Corner radius of border
     */
    func setupBorder(color:UIColor, borderWidth bw:CGFloat, cornerRadius r:CGFloat){
        layer.masksToBounds = true
        layer.borderColor = color.cgColor
        layer.borderWidth = bw
        layer.cornerRadius = r
    }
}


extension Ext where Base: UIView {
    /**
     Make Oval Border
     - Parameter color : Border Color
     - Parameter borderWidth : Border Width
     */
    func makeOval(color:UIColor, borderWidth bw:CGFloat){
        // try get reasonable width
        var width:CGFloat?, height:CGFloat?
        for constraint in base.constraints{
            if constraint.firstAttribute == .width && constraint.relation == .equal && constraint.secondItem == nil && constraint.isActive{
                width = constraint.constant
            }
            if constraint.secondAttribute == .height && constraint.relation == .equal && constraint.secondItem == nil && constraint.isActive {
                height = constraint.constant
            }
        }
        
        if let width = width, let height = height {
            setupBorder(color: color, width: bw, cornerRadius: min(width, height) / 2.0)
        } else if let width = width {
            setupBorder(color: color, width: bw, cornerRadius: width / 2.0)
        } else if let height = height {
            setupBorder(color: color, width: bw, cornerRadius: height / 2.0)
        }
    }
    
    /**
     Set Corner Radius
     - Parameter color : Color of border, can be clear color
     - Parameter borderWidth : Width of border
     - Parameter cornerRadius : Corner radius of border
     */
    func setupBorder(color:UIColor, width bw:CGFloat, cornerRadius r:CGFloat){
        base.layer.masksToBounds = true
        base.layer.borderColor = color.cgColor
        base.layer.borderWidth = bw
        base.layer.cornerRadius = r
    }
    
    @available(iOS 11, *)
    func setTrailingTopBottomCorners(){
        //FIXME: According to language, change this behaviour
        setupBorder(color: UIColor(named: "grey")!, width: 1, cornerRadius: 5)
        base.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
    }
}
