//
//  UIViewController+Ext.swift
//  Alaitisal
//
//  Created by Alex on 2019/7/21.
//  Copyright © 2019 JN. All rights reserved.
//

import MessageUI

// MARK: - Logo Title View
extension Ext where Base:UIViewController {
    func setLogoTitleView(){
        base.navigationItem.titleView = UIImageView(image:UIImage(named:"logo2"))
    }
}

// MARK: - Root ViewController
extension Ext where Base: UIViewController {
    // MARK: - Transit Root View Controller
    /**
     Change application's rootview controller with current viewcontroller with CrossDissolve transition
     */
    func setAsRoot(animated:Bool = true){
        if animated {
            _setAsRootVCAnimated()
        } else {
            _setAsRoot()
        }
    }
    
    private func _setAsRootVCAnimated(){
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        let originalVC = window.rootViewController
        UIView.transition(with: window,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { () -> Void in
                            let oldState = UIView.areAnimationsEnabled
                            UIView.setAnimationsEnabled(false)
                            window.rootViewController = self.base
                            UIView.setAnimationsEnabled(oldState)
        }){_ in
            originalVC?.dismiss(animated: false, completion: nil)
        }
    }
    
    /**
     Set as root view controller
     */
    private func _setAsRoot(){
        let originalVC = UIApplication.shared.keyWindow?.rootViewController
        UIApplication.shared.keyWindow?.rootViewController = base
        originalVC?.dismiss(animated: false, completion: nil)
    }
}

// MARK: - Set No Titled Back Item
extension Ext where Base: UIViewController {
    @discardableResult
    func setNoTitledBackItem() -> UIBarButtonItem {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        base.navigationItem.backBarButtonItem = item
        return item
    }
    
    // Place Label without setting title property
    func setTitle(_ title: String){
        let lbl = UILabel(frame: CGRect.zero)
        lbl.text = title
        lbl.textColor = UINavigationBar.appearance().tintColor
        lbl.sizeToFit()
        base.navigationItem.titleView = lbl
    }
    
    // Set Back Button Shaped Dismiss Button
    @discardableResult
    func setBackShapedDismissButton() -> UIBarButtonItem {
        let image = UIImage(named: "ic_nav_back")
        let item = UIBarButtonItem(image: image?.itemImage(), style: .plain, target: base, action: nil)
        base.navigationItem.leftBarButtonItem = item
        return item
    }
}

extension Ext where Base: UIViewController {
    func parentViewController<T:UIViewController>(of type:T.Type) -> T? {
        var _parent = base.parent
        while(_parent != nil){
            if let vc = _parent as? T {
                return vc
            }
            _parent = _parent?.parent
        }
        return nil
    }
}
