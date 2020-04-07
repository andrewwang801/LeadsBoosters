//
//  UIButton+Style.swift
//  Alaitisal
//
//  Created by Alex on 2019/7/22.
//  Copyright © 2019 JN. All rights reserved.
//

import Foundation
import UIKit

enum ButtonStyle {
    case red
    case facebookbutton
}

extension ButtonStyle {
    var colors: (text:UIColor, normal:UIColor) { // Text Color, Normal Color, Clicked Color
        switch(self) {
        case .red:
            return (.white, UIColor(named:"barTint")!)
        case .facebookbutton:
            return (.white, UIColor(red: 57, green: 91, blue: 154, alpha: 1))
        }
    }
}

extension Ext where Base: UIButton {
    func setStyle(_ style:ButtonStyle) {
        switch style {
        case .red:
            base.setupBorder(color: .white, borderWidth: 0, cornerRadius: 8)
            base.setBackgroundImage(style.colors.normal.ext.image, for: .normal)
            base.setTitleColor(style.colors.text, for: .normal)
        case .facebookbutton:
            base.setupBorder(color: .white, borderWidth: 0, cornerRadius: 8)
            base.setBackgroundImage(style.colors.normal.ext.image, for: .normal)
            base.setTitleColor(style.colors.text, for: .normal)
        }
    }
}

extension Ext where Base: UIButton {
    
    static func imageTextButton(image:UIImage?, title: String?, target:AnyObject?, action:Selector?) -> UIButton {
        let button = UIButton(type: .system)
        button.ext.setStyle(.red)
        button.setImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        button.frame = CGRect(x:0, y:0, width:80, height:40)
        if let target = target, let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        return button
    }
}
