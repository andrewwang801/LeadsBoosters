//
//  AppNotification.swift
//  Alaitisal
//
//  Created by JinMing on 7/25/19.
//  Copyright © 2019 JN. All rights reserved.
//

import Foundation
import CRToast

// MARK: - SecureTribe Notification Style
enum NotificationStyle{
    case error          // Error (RedColor with exclamation mark)
    case notice         //
    case custom(UIImage?, UIColor)
}

// MARK: - Extend SecureTribe Notification Style
extension NotificationStyle {
    var icon:UIImage?{
        switch self {
        case .error:
            return UIImage(named:"ic_toast_alert")
        case .notice:
            return nil
        case let .custom(image, _):
            return image
        }
    }
    
    var backgroundColor:UIColor{
        switch self {
        case .error:
            return .red
        case .notice:
            // In case of notice, it's flat mint color
            return UIColor(named: "flatMint")!
        case let .custom(_, color):
            return color
        }
    }
}

protocol CRToastNotificationPresenterType { }

extension CRToastNotificationPresenterType {
    /**
     Show Toast Style notification
     - Parameter style : SCNotification Style  : Default .Notice
     - Parameter title : Alert Title  : Default Nil
     - Parameter text : Message Content
     - Parameter dismissPreviousNotifications : Flag whether dismiss all notifications first. Default true
     */
    func showNotification(style:NotificationStyle = .notice, title:String? = nil, text:String, dismissPreviousNotifications:Bool = true){
        if dismissPreviousNotifications {
            CRToastManager.dismissNotification(true)
        }
        var options:[AnyHashable:Any] = [:]
        if let title = title {
            options[kCRToastTextKey] = title
            options[kCRToastSubtitleTextKey] = text
        } else {
            options[kCRToastTextKey] = text
        }
        
        if let icon = style.icon {
            options[kCRToastImageKey] = icon
        }
        options[kCRToastBackgroundColorKey] = style.backgroundColor
        CRToastManager.showNotification(options: options, apperanceBlock: nil, completionBlock: nil)
    }
    
    /**
     Shows error notification with Error Style
     - Parameter title : SCNotification title, Defaults nil
     - Parameter text : Message Content
     */
    func showNotification(title:String? = nil, errorMessage message:String){
        showNotification(style: .error, title: title, text: message)
    }
    
    /**
     Shows Error
     */
    func showNotification(title:String? = nil, error:Error){
        showNotification(title: title, errorMessage: error.localizedDescription)
    }
}

// MARK: - Extend UIApplication
extension UIApplication : CRToastNotificationPresenterType {}

// MARK: - Extend UIViewController
extension UIViewController : CRToastNotificationPresenterType {}
