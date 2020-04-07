//
//  SigninVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/1.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import DropDown
import SCLAlertView

class SigninVC: BaseVC {
    
    let dropDown = DropDown()
    
    @IBOutlet var countryCode: UIView!
    @IBOutlet var countryFlag: UIImageView!
    @IBOutlet var countryCodeLabel: UILabel!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet var verificationCodeTextField: UITextField!
    
    
    @IBAction func doSendVerificationCode(_ sender: Any)
    {
        let strPhoneNumber = (countryCodeLabel.text ?? "") + (phoneNumberTextField.text ?? "")
        
        if hasConnectivity() == false {
            SCLAlertView().showError("Network Error", subTitle: "Please check internet connection")
        }
        
        if isValidPhoneNumber(phoneNumber: strPhoneNumber) {
            let hud = activityHUD("Please waiting...")

            apiService.genVerificationCode(phoneNumber: strPhoneNumber)
                .subscribe{ [weak self] evt in
                    switch(evt) {
                    case let .next(response):
                        if response == 1 {
                            NSLog("genVerificationCode Success")
                        }
                        hud.hide(true)
                        break
                    case .error:
                        NSLog("genVerificationCode Error")
                        hud.hide(true)
                        SCLAlertView().showError("Login Falied", subTitle: "Verification Failed")
                        break
                    default:
                        hud.hide(true)
                        break
                    }
            }.disposed(by: disposeBag)
        }
        else {
            showNotification(text: "Invalid Phone Number.")
        }
    }
    
    @IBAction func doLogin(_ sender: Any) {
        
        if hasConnectivity() == false {
            showNotification(text: "You don't have netework connectin now. Please check internet and try again.")
            return
        }
        
        let strPhoneNumber = (countryCodeLabel.text ?? "") + (phoneNumberTextField.text ?? "")
        let strPassword = verificationCodeTextField.text ?? ""
        
        if isValidPhoneNumber(phoneNumber: strPhoneNumber) {
            let hud = activityHUD("Please waiting...")

            apiService.login(phoneNumber: strPhoneNumber, password: strPassword)
                .subscribe{ [weak self] evt in
                    guard let _self = self else {return}
                    switch(evt) {
                    case let .next(response):
                        if response.result == 1 {
                            AppSettings.set(response.data.token, forKey: kUserToken)
                            AppSettings.set(response.data.toString(), forKey: kUserInfo)
                            _self.gotoDashboard()
                        }
                        else {
                            SCLAlertView().showError("Login Falied", subTitle: response.message)
                        }
                        break
                        hud.hide(true)
                    case .error:
                        hud.hide(true)
                        SCLAlertView().showError("Login Falied", subTitle: "Login Filed. Please try again later")
                        break
                    default:
                        hud.hide(true)
                        break
                    }
            }.disposed(by: disposeBag)
        }
        else {
            showNotification(text: "Invalid Phone Number.")
        }
    }
    
    @IBAction func doSignup(_ sender: Any) {
        gotoSignup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set action to countryCode view
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onCountryCode))
        self.countryCode.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func onCountryCode(sender:UITapGestureRecognizer) {
        setupDropDown()
        dropDown.show()
    }
    
    func setupDropDown() {
        
        //set dropdown
        dropDown.anchorView = countryCode
        dropDown.dataSource = kFlagValues
        dropDown.cellNib = UINib(nibName: "CountryCodeCell", bundle: nil)
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? CountryCodeCell else { return }

           // Setup your custom UI components
            cell.countryFlag.image = UIImage(named: "flag_" + kFlagSuffix[index])
        }
        dropDown.selectionAction = {[unowned self] (index: Int, item: String) in
            self.countryFlag.image = UIImage(named: "flag_" + kFlagSuffix[index])
            self.countryCodeLabel.text = item
        }
    }
}
