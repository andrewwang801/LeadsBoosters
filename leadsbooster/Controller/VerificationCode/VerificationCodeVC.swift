//
//  VerificationCodeVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/1.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import SCLAlertView

class VerificationCodeVC: BaseVC {

    @IBOutlet var vericicationCodeTextField: UITextField!
    var token = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func onResendVerificationCode(_ sender: Any) {
        
        //send verification code
        var params: [String: Any] = [:]
        params["token"] = token
        
        apiService.sendVerificationCode(params: params)
            .subscribe{ [weak self] evt in
                
                guard let _self = self else { return }
                switch(evt) {
                case let .next(response):
                    if response == 1 {

                        NSLog("sendVerificationCode Success")
                    }
                    else {
                        NSLog("sendVerificationCode Failed")
                        SCLAlertView().showError("Failed to send verification code", subTitle: "We have not sent verification code to your whatsapp num...")
                    }
                    break
                case .error:
                    NSLog("sendVerificationCode Error")
                    SCLAlertView().showError("Failed to send verification code", subTitle: "We have not sent verification code to your whatsapp num...")
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    @IBAction func onVerify(_ sender: Any) {
        
        //verify
        var params: [String: Any] = [:]
        params["token"] = token
        params["code"] = self.vericicationCodeTextField.text ?? ""
        
        apiService.verify(params: params)
            .subscribe{ [weak self] evt in
                
                guard let _self = self else { return }
                switch(evt) {
                case let .next(response):
                    if response.result == 1 {
                        NSLog("verify Success")
                        
                        AppSettings.set(_self.token, forKey: kUserToken)
//                        _self.goToMain()
                    }
                    else {
                        NSLog("verify Failed")
                        SCLAlertView().showError("Failed to send verification code", subTitle: "We have not sent verification code to your whatsapp num...")
                    }
                    break
                case .error:
                NSLog("verify Error")
                    SCLAlertView().showError("Failed to send verification code", subTitle: "We have not sent verification code to your whatsapp num...")
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
        
    }
}
