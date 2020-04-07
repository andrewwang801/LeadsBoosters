//
//  UIBarButtonItemExt.swift
//  Alaitisal
//
//  Created by Alex on 2019/7/22.
//  Copyright © 2019 JN. All rights reserved.
//

import Foundation
import UIKit

extension Ext where Base:UIBarButtonItem {
//    static func imageButton(name:String, target:AnyObject?, action:Selector?) -> UIBarButtonItem {
//        return imageButton(image: UIImage(named: name), target: target, action: action)
//    }
    static func imageButton(name:String, target:AnyObject?, action:Selector?) -> UIBarButtonItem {
        return imageButton(image: UIImage(named: name)?.itemImage(), target: target, action: action)
    }
    
    static func imageButton(image:UIImage?, target:AnyObject?, action:Selector?) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.frame = CGRect(x:0, y:0, width:22, height:40)
        let result = UIBarButtonItem(customView: button)
        if let target = target, let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
        return result
    }
    
}

extension Ext where Base:UIBarButtonItem {
    
    static func notificationButton(name:String, target:AnyObject?, action:Selector?) -> UIBarButtonItem {
        return notificationButton(image: UIImage(named: name), target: target, action: action)
    }
    
    static func notificationButton(image:UIImage?, target:AnyObject?, action:Selector?) -> UIBarButtonItem {
        let view = UIView(frame: CGRect(x:0, y:0, width:25, height:40))
        
        let alertButton = UIButton(type: .system)
        alertButton.setImage(image, for: .normal)
        alertButton.frame = CGRect(x:0, y:0, width:22, height:40)
        view.addSubview(alertButton)
        
        let notificationImageView = UIImageView(frame: CGRect(x:18, y:5, width:13, height:13))
        notificationImageView.image = UIImage(named: "ic_notification")
        view.addSubview(notificationImageView)
        notificationImageView.isHidden = true
        
        let notificationCountLabel = UILabel(frame: CGRect(x:18, y:5, width:13, height:13))
        notificationCountLabel.textAlignment = .center
        notificationCountLabel.textColor = UIColor.red
        notificationCountLabel.font = notificationCountLabel.font.withSize(6)
        view.addSubview(notificationCountLabel)
        notificationCountLabel.isHidden = true
        
        let result = UIBarButtonItem(customView: view)
        if let target = target, let action = action {
            alertButton.addTarget(target, action: action, for: .touchUpInside)
        }
        return result
    }
    
    func setNotificationCount(notificationCount:Int) {
        let base = self.base as UIBarButtonItem
        for subview in base.customView!.subviews  {
            let notificationImageView = (subview as? UIImageView)
            if  notificationImageView != nil{
                if notificationCount == 0 {
                    notificationImageView!.isHidden = true
                } else {
                    notificationImageView!.isHidden = false
                }
            }
            
            guard let notificationCountLabel = (subview as? UILabel) else { continue }
            if notificationCount > 99 {
                notificationCountLabel.text = "99+"
            } else {
                notificationCountLabel.text = String(notificationCount)
            }
            
            if notificationCount > 99 {
                notificationCountLabel.font = notificationCountLabel.font.withSize(6)
            } else if notificationCount > 9 {
                notificationCountLabel.font = notificationCountLabel.font.withSize(8)
            } else {
                notificationCountLabel.font = notificationCountLabel.font.withSize(10)
            }
            
            if notificationCount == 0 {
                notificationCountLabel.isHidden = true
            } else {
                notificationCountLabel.isHidden = false
            }
            
            return
        }
    }
}
