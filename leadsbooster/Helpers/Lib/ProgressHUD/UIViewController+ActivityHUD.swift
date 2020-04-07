//
//  UIViewController+ActivityHUD.swift
//  AutoCorner
//
//  Created by Alex on 1/2/2016.
//  Copyright © 2016 stockNumSystems. All rights reserved.
//

import Foundation

// MARK: - UIViewController Activity Extension
extension UIViewController{
    /**
     Shows Activity From UIViewController
     - Parameter message : Message for hud
     - Parameter detailMessage : Detailed message for hud
     - Parameter contentView : Content View to be displayed on hud.
    */
    func activityHUD(_ message:String? = nil, detailMessage:String? = nil, contentView:UIView? = nil) -> ActivityHUDType{
        //let hud = MBActivityHUD(frontVC: (navigationController ?? self))  // This is good because many vcs are embedded in nav vc.
        let hud = MBActivityHUD(frontVC: self)
        hud.message = message
        hud.detailMessage = detailMessage
        hud.contentView = contentView
        hud.show(true)
        return hud
    }
    
    /**
     Shows Activity
     - Parameter message : Message for hud
     - Parameter detailMessage : Detailed message for hud
     - Parameter contentView : Content View to be displayed on hud.
     - Parameter containerView : View that is contains hud
     */
    func activityHUD(_ message:String? = nil, detailMessage:String? = nil, contentView:UIView? = nil, containerView: UIView? = nil) -> ActivityHUDType{
        //let hud = MBActivityHUD(frontVC: (navigationController ?? self))  // This is good because many vcs are embedded in nav vc.
        let hud: MBActivityHUD
        if let _containerView = containerView {
            hud = MBActivityHUD(frontView: _containerView)
        } else {
            hud = MBActivityHUD(frontVC: self)
        }
        
        hud.message = message
        hud.detailMessage = detailMessage
        hud.contentView = contentView
        hud.show(true)
        return hud
    }
    
    /**
     Shows Activity Indicator Covering Root View Controller (To disable all user interactions)
    */
    func activityHUDTopMost(_ message:String? = nil, detailMessage:String? = nil, contentView:UIView? = nil) -> ActivityHUDType{
        //let hud = MBActivityHUD(frontVC: (navigationController ?? self))  // This is good because many vcs are embedded in nav vc.
        let hud = MBActivityHUD(frontView: UIApplication.shared.keyWindow!)
        hud.message = message
        hud.detailMessage = detailMessage
        hud.contentView = contentView
        hud.show(true)
        return hud
    }
}
