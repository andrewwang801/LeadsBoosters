//
//  SignupVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/1.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import DropDown
import IBAnimatable
import SCLAlertView

class SignupVC: BaseVC {
    
    @IBOutlet var countryCode: UIView!
    @IBOutlet var countryFlag: UIImageView!
    @IBOutlet var countryCodeLabel: UILabel!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var phoneNumberTextField: AnimatableTextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var carView: UIView!
    @IBOutlet var industryLabel: UILabel!
    
    var carDataSource: [String] = []
    let dropDown = DropDown()
    let carDropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onCountryCode))
        self.countryCode.addGestureRecognizer(gesture)
        
        let carGesture = UITapGestureRecognizer(target: self, action: #selector(onCar))
        self.carView.addGestureRecognizer(carGesture)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //IBActions
    @IBAction func doLogin(_ sender: Any) {
        gotoSignin()
    }
    
    @IBAction func doSignup(_ sender: Any) {
        let strPhoneNumber = (countryCodeLabel.text ?? "") + (phoneNumberTextField.text ?? "")
        let strUserName = userNameTextField.text ?? ""
        let strEmail = emailTextField.text ?? ""
        let strIndustry = industryLabel.text ?? ""
        
        if hasConnectivity() == false {
            SCLAlertView().showError(kConnectionTitleMessage, subTitle: kConnectionBodyMessage)
        }
        
        if strUserName.isEmpty {
            showNotification(text: "Please Input UserName")
            return
        }
        if !strEmail.isValidEmail {
            showNotification(text: "Please Valid Email Address")
            return
        }
        if !(carDataSource.contains(strIndustry)) {
            showNotification(text: "Please select industry")
            return
        }
        
        if isValidPhoneNumber(phoneNumber: strPhoneNumber) {
            let hud = activityHUD()
            
            var params: [String: Any] = [:]
            params["phone_number"] = strPhoneNumber
            params["name"] =  strUserName
            params["email"] = strEmail
            params["industry"] = strIndustry
            
            apiService.signUp(params: params)
                .subscribe { [weak self] evt in
                    
                    guard let _self = self else { return }
                    switch(evt) {
                    case let .next(response):
                        if response.result == 1 {
                            NSLog("signUp Response 1")
                            
                            //send verification code
                            var params: [String: Any] = [:]
                            params["token"] = response.data.token
                            
                            AppSettings.set(response.data.toString(), forKey: kUserInfo)
                            apiService.sendVerificationCode(params: params)
                                .subscribe{ [weak self] evt in
                                    guard let _self = self else {return}
                                    switch(evt) {
                                    case let .next(signupResponse):
                                        if signupResponse == 1 {
                                            _self.showNotification(text: "Have sent verification")
                                        }
                                        else {
                                            SCLAlertView().showError("Failed to send verification code", subTitle: "We have not sent verification code to your whatsapp num...")
                                        }
                                        hud.hide(true)
                                        break
                                    case .error:
                                        hud.hide(true)
                                        SCLAlertView().showError("Failed to send verification code", subTitle: "We have not sent verification code to your whatsapp num...")
                                        break
                                    default:
                                        hud.hide(true)
                                        break
                                    }
                            }.disposed(by: _self.disposeBag)
                            
                            //goto VerificationCodeVC
                            _self.gotoVerificationCode(token: response.data.token)
                        }
                        else {
                            NSLog("signUp Response 0")
                            
                            hud.hide(true)
                            SCLAlertView().showError("Sign Failed", subTitle: response.message)
                        }
                        break
                    case .error:
                        NSLog("signUp Response Error")
                        hud.hide(true)
                        SCLAlertView().showError("Sign Failed", subTitle: "Please try again.")
                        break
                    default:
                        hud.hide(true)
                        break
                    }
            }.disposed(by: disposeBag)
        }
        
    }
    
    //actions
    @objc func onCountryCode(sender:UITapGestureRecognizer) {
        setupDropDown()
        dropDown.show()
    }
    
    @objc func onCar(sender: UITapGestureRecognizer) {
        setupCarDropDown()
        carDropDown.show()
    }
    
    //dropdown setup functions
    func loadCarData() {
        
        if hasConnectivity() == false {
            SCLAlertView().showError(kConnectionTitleMessage, subTitle: kConnectionBodyMessage)
        }
        else {
            apiService.getIndustries()
                .subscribe { [weak self] evt in
                    
                    guard let _self = self else { return }
                    switch(evt) {
                    case let .next(response):
                        if response.result == 1 {
                            NSLog("getIndustries Response 1")
                            
                            _self.carDataSource = response.items
                        }
                        else {
                            NSLog("getIndustries Response 0")
                            
                            SCLAlertView().showError("Get Industry Data Failed", subTitle: response.message)
                        }
                        break
                    case .error:
                        NSLog("getIndustries Response Error")
                    
                        SCLAlertView().showError("Data Error", subTitle: "Get Industry Data Failed")
                        break
                    default:
                        break
                    }
                    
            }.disposed(by: disposeBag)
        }
        
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
    
    func setupCarDropDown() {
        
        loadCarData()
        carDropDown.anchorView = carView
        carDropDown.dataSource = carDataSource
        carDropDown.selectionAction = {[unowned self] (index: Int, item:String) in
            //action for Car Selection
            self.industryLabel.text = self.carDataSource[index]
        }
    }
}
