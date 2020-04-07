//
//  MBActivityHUD.swift
//  AutoCorner
//
//  Created by Alex on 30/1/2016.
//  Copyright © 2016 stockNumSystems. All rights reserved.
//

import Foundation

class MBActivityHUD{
    var contentView:UIView? = nil{
        didSet{
            if let v = contentView {
                hud?.mode = .customView
                hud?.customView = v
            }
        }
    }
    
    var message:String? = ""{
        didSet{
            hud?.labelText = message ?? ""
        }
    }
    
    var detailMessage:String? = ""{
        didSet{
            hud?.detailsLabelText = detailMessage ?? ""
        }
    }
    
    let frontView:UIView?          // This would be first considered
    let frontVC:UIViewController?  // If frontView is nil, then this would be considered, and if this is nil, then will cover root vc's view.
    var hud:MBProgressHUD?
    
    init (frontView:UIView){
        self.frontView = frontView
        frontVC = nil
    }
    
    init (frontVC:UIViewController){
        frontView = nil
        self.frontVC = frontVC
    }
}

extension MBActivityHUD:ActivityHUDType{
    func show(_ animated:Bool){
        let view =     (frontView ?? frontVC?.view) ??  UIApplication.shared.keyWindow
        let hud = MBProgressHUD(view: view)
        hud?.then{
            view?.addSubview(hud!)
            $0.labelText = message ?? ""
            $0.detailsLabelText = detailMessage ?? ""
            if let contentView = contentView {
                $0.mode = .customView
                $0.customView = contentView
            }
            $0.show(animated)
            $0.removeFromSuperViewOnHide = true
            self.hud = $0
        }
    }
    
    // Hide
    func hide(_ animated:Bool){
        hud?.hide(true)
    }
    
    func hide(_ animated:Bool, delay : TimeInterval){
        hud?.hide(true, afterDelay: delay)
    }
    
    // Fail / Success
    func setFail(){
        hud?.then{
            $0.mode = .customView
            $0.customView = UIImageView(image: UIImage(named: "ic_hud_fail"))
        }
    }
    
    func setFail(_ hideAfter:TimeInterval){
        setFail()
        hud?.hide(true, afterDelay: hideAfter)
    }
    
    func setSuccess(){
        hud?.then{
            $0.mode = .customView
            $0.customView = UIImageView(image: UIImage(named: "ic_hud_success"))
        }
    }
    
    func setSuccess(_ hideAfter:TimeInterval){
        setSuccess()
        hud?.hide(true, afterDelay: hideAfter)
    }
}
