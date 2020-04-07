//
//  ProfileVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/23.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import IBAnimatable
import DropDown

class ProfileVC: BaseVC {

    @IBOutlet weak var userNameTextField: AnimatableTextField!
    @IBOutlet weak var emailTextField: AnimatableTextField!
    @IBOutlet weak var phoneNumberTextField: AnimatableTextField!
    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var industryLabel: UILabel!
    @IBOutlet weak var imageCheck: UIButton!
    
    @IBOutlet weak var agentPhoneNumberTextField: AnimatableTextField!
    @IBOutlet weak var agentFlag: UIImageView!
    @IBOutlet weak var agentCountryCodeLabel: UILabel!
    @IBOutlet weak var agentImageCheck: AnimatableButton!
    
    @IBOutlet weak var agentCountryCode: UIView!
    @IBOutlet weak var countryCode: UIView!
    @IBOutlet weak var verificationCodeView: UIView!
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var agentSettingView: UIView!
    @IBOutlet weak var verificationCodeTextField: AnimatableTextField!
    @IBOutlet weak var mobileVerificationCodeTextField: AnimatableTextField!
    @IBOutlet weak var industryDropDownView: AnimatableView!
    @IBOutlet weak var mobileVerificationCode: UIView!
    
    @IBOutlet weak var leadsTypeView: UIView!
    @IBOutlet weak var subEmailRadio: AnimatableButton!
    @IBOutlet weak var masterEmailRadio: AnimatableButton!
    
    var subEmail = true
    
    let mobileDropDown = DropDown()
    let agentMobileDropDown = DropDown()
    let industryDropDown = DropDown()
    
    var strCountryZipCode = "+65"
    var strAgentCountryZipCode = "+65"
    var userInfo: UserInfo?
    var membershipInfo: MembershipInfo?
    var industryInfoList: [IndustryInfo] = []
    var agentInfoList: [AgentInfo] = []
    var masterSimList: [ServerInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Profile"
        
        if self.revealViewController() != nil {
            let sideMenuButton = UIBarButtonItem(image: UIImage(named: "menu")?.itemImage(), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = sideMenuButton
        }
         
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onMobileDropDown))
        countryCode.addGestureRecognizer(tapGesture)
        let agentTapGesture = UITapGestureRecognizer(target: self, action: #selector(onAgentMobileDropDown))
        agentCountryCode.addGestureRecognizer(agentTapGesture)
        
        phoneNumberTextField.addTarget(self, action: #selector(onPhoneNumebrChange), for: .editingChanged)
        agentPhoneNumberTextField.addTarget(self, action: #selector(onAgentPhoneNumberChange), for: .editingChanged)
        
        initData()
        initDropDown()
        loadData()
    }
    
    func loadData() {
        var params: [String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        let hud = activityHUD()
        apiService.doGetProfile(params: params)
            .subscribe {[weak self] evt in
                guard let _self = self else {return}
                switch evt {
                case let .next(response):
                    if response.result == 1 {
                        _self.membershipInfo = response.membership
                        _self.agentInfoList.removeAll()
                        _self.agentInfoList.append(contentsOf: response.agent_phone_numbers)
                        
                        _self.industryInfoList.removeAll()
                        _self.industryInfoList.append(contentsOf: response.industries)
                        _self.setupIndustryDropDown()
                        _self.updateUI()
                    }
                    else {
                        _self.showNotification(text: L10n.serverError)
                    }
                    hud.hide(true)
                    break
                case .error:
                    _self.showNotification(text: L10n.internetError)
                    hud.hide(true)
                    break
                default:
                    hud.hide(true)
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    @IBAction func onSubEmailRadio(_ sender: Any) {
        selectSubEmailRadio()
    }
    
    @IBAction func onMasterEmailRadio(_ sender: Any) {
        selectMasterEmailRadio()
    }
    
    func selectSubEmailRadio() {
        subEmailRadio.setBackgroundImage(UIImage(named: "radio_selected"), for: .normal)
        masterEmailRadio.setBackgroundImage(UIImage(named: "radio_normal"), for: .normal)
        subEmail = true
    }
    
    func selectMasterEmailRadio() {
        subEmailRadio.setBackgroundImage(UIImage(named: "radio_normal"), for: .normal)
        masterEmailRadio.setBackgroundImage(UIImage(named: "radio_selected"), for: .normal)
        masterEmailRadio.setBackgroundImage(UIImage(named: "radio_selected"), for: .selected)
        subEmail = false
    }
    
    func updateUI() {
        for (index, item) in industryInfoList.enumerated() {
            if self.userInfo?.industry == item.industry {
                industryDropDown.selectRow(index)
                industryLabel.text = item.industry
            }
        }
        
        if membershipInfo?.plans != "free" {
            leadsTypeView.isHidden = false
            if userInfo?.send_type == 0 {
                selectSubEmailRadio()
            }
            else {
                selectMasterEmailRadio()
            }
            agentSettingView.isHidden = false
        }
        else {
            leadsTypeView.isHidden = true
            agentSettingView.isHidden = true
        }
        
        if let userInfo = userInfo, !userInfo.secondary_phone_number.isEmpty {
            let phoneNumber = parsePhoneNumber(phoneNumberString: userInfo.secondary_phone_number)
            if let _phoneNumber = phoneNumber {
                let countryCode = _phoneNumber.countryCode
                let number = _phoneNumber.nationalNumber
                agentCountryCodeLabel.text = String(countryCode).countryCode
                let flagIndex = kFlagValues.firstIndex(of: String(countryCode).countryCode) ?? 0
                agentFlag.image = UIImage(named: "flag_" + kFlagSuffix[flagIndex])
                agentPhoneNumberTextField.text = String(number)
                if let index = kFlagSuffix.firstIndex(of: String(countryCode)) {
                    agentMobileDropDown.selectRow(index)
                }
            }
        }
    }
    
    func initData() {
        userInfo = UserInfo(json: parse(string: AppSettings.string(kUserInfo)))
    }
    
    func initDropDown() {
        setupMobileDropDown()
        setupAgentMobileDropDown()
//        mobileDropDown.selectRow(0)
//        agentMobileDropDown.selectRow(0)
    }
    
    @objc func onPhoneNumebrChange(textField: UITextField) {
        let strPhoneNumber = strCountryZipCode + (textField.text ?? "")
        if strPhoneNumber == userInfo?.phone_number {
            return
        }
        if isValidPhoneNumber(phoneNumber: strPhoneNumber) {
            imageCheck.isHidden = false
        }
        else {
            imageCheck.isHidden = true
        }
    }
    
    @objc func onAgentPhoneNumberChange(textField: UITextField) {
        let strPhoneNumber = strCountryZipCode + (textField.text ?? "")
        if isValidPhoneNumber(phoneNumber: strPhoneNumber) {
            agentImageCheck.isHidden = false
        }
        else {
            agentImageCheck.isHidden = true
        }
    }
    
    @objc func onMobileDropDown() {
        mobileDropDown.show()
    }
    
    @objc func onAgentMobileDropDown() {
        agentMobileDropDown.show()
    }
    
    @IBAction func imgCheck(_ sender: Any) {
        if !isValidPhoneNumber(phoneNumber: strCountryZipCode + (phoneNumberTextField.text ?? "")) {
            showNotification(text: "Phone Number Format is not correct")
        }
        var params:[String: String] = [:]
        params["phone_number"] = userInfo?.phone_number
        params["new_phone_number"] = strCountryZipCode + (phoneNumberTextField.text ?? "")
        let hud = activityHUD()
        apiService.doGenerateVerifyCode(params: params)
            .subscribe {[weak self] evt in
                guard let _self = self else {return}
                switch evt {
                case let .next(response):
                    if response.result == 1 {
                        _self.mobileVerificationCode.isHidden = false
                    }
                    else {
                        _self.showNotification(text: response.message)
                    }
                    break
                    hud.hide(true)
                case .error:
                    hud.hide(true)
                    _self.showNotification(text: L10n.serverError)
                    break
                default:
                    hud.hide(true)
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    @IBAction func agentImgCheck(_ sender: Any) {
        if !isValidPhoneNumber(phoneNumber: strAgentCountryZipCode + (agentPhoneNumberTextField.text ?? "")) {
            showNotification(text: "Phone Number Format is not correct")
        }
        var params:[String: String] = [:]
        params["phone_number"] = strAgentCountryZipCode + (agentPhoneNumberTextField.text ?? "")
        let hud = activityHUD()
        apiService.doGenerateConfirmCode(params: params)
            .subscribe {[weak self] evt in
                guard let _self = self else {return}
                switch evt {
                case let .next(response):
                    if response.result == 1 {
                        _self.verificationCodeView.isHidden = false
                    }
                    else {
                        _self.showNotification(text: response.message)
                    }
                    break
                    hud.hide(true)
                case .error:
                    hud.hide(true)
                    _self.showNotification(text: L10n.serverError)
                    break
                default:
                    hud.hide(true)
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    @IBAction func onSave(_ sender: Any) {
        let strUserName = userNameTextField.text ?? ""
        let strEmail = emailTextField.text ?? ""
        let strPhoneNumber = phoneNumberTextField.text ?? ""
        let strVerificationCode = mobileVerificationCodeTextField.text ?? ""
        var industryIndex = 0
        if let index = industryDropDown.indexForSelectedRow?.int32 {
            industryIndex = Int(index)
        }
        let strIndustry = industryInfoList[industryIndex].industry
        let strSecondaryPhoneNumber = agentPhoneNumberTextField.text ?? ""
        if strUserName.isEmpty {
            showNotification(text: "Please input username")
            return
        }
        if strEmail.isEmpty {
            showNotification(text: "Please input email address")
            return
        }
        if (strCountryZipCode + strPhoneNumber) == userInfo?.phone_number && strVerificationCode.isEmpty {
            showNotification(text: "Please input verification code")
            return
        }
        var params: [String: String] = [:]
        params["new_phone_number"] = strCountryZipCode + strPhoneNumber
        params["phone_number"] = userInfo?.phone_number
        if !strSecondaryPhoneNumber.isEmpty {
            params["secondary_phone_number"] = strAgentCountryZipCode + strSecondaryPhoneNumber
        }
        else {
            params["secondary_phone_number"] = ""
        }
        params["verification_code"] = strVerificationCode
        params["username"] = strUserName
        params["email"] = strEmail
        params["industry"] = strIndustry
        
        if membershipInfo?.plans != "free" {
            if subEmail {
                params["send_type"] = "0"
            }
            else {
                params["send_type"] = "1"
            }
            
        }
        
        let hud = activityHUD()
        apiService.doModifyUserProfile(params: params)
            .subscribe {[weak self] evt in
                guard let _self = self else {return}
                switch evt{
                case let .next(response):
                    if response.result == 1 {
                        _self.userInfo?.phone_number = _self.strCountryZipCode + strPhoneNumber
                        _self.userInfo?.username = strUserName
                         _self.userInfo?.email = strEmail
                         _self.userInfo?.industry = strIndustry
                        if  strSecondaryPhoneNumber.isEmpty {
                             _self.userInfo?.secondary_phone_number = ""
                        }
                        else {
                            _self.userInfo?.secondary_phone_number = _self.strAgentCountryZipCode +  strSecondaryPhoneNumber
                        }
                        if  _self.membershipInfo?.plans != "free" {
                            if  _self.subEmail {
                                 _self.userInfo?.send_type = 0
                            }
                            else {
                                 _self.userInfo?.send_type = 0
                            }
                        }
                        else {
                             _self.userInfo?.send_type = 0
                        }
                        AppSettings.set( _self.userInfo?.toString() ?? "", forKey: kUserInfo)
                        AppSettings.set(response.token, forKey: kUserToken)
                        _self.showNotification(text: "Successfully saved.")
                    }
                    else {
                        _self.showNotification(text: response.message)
                    }
                    hud.hide(true)
                    break
                case .error:
                    hud.hide(true)
                    _self.showNotification(text: L10n.internetError)
                    break
                default:
                    hud.hide(true)
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    @IBAction func onAgentSettings(_ sender: Any) {
        gotoAgentPhoneNumberSettingVC(param: agentInfoList)
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        var params: [String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        params["phonne_number"] = strAgentCountryZipCode + (agentPhoneNumberTextField.text ?? "")
        params["verification_code"] = verificationCodeTextField.text ?? ""
        let hud = activityHUD()
        apiService.doRegisterPhoneNumber(params: params)
            .subscribe{[weak self] evt in
                guard let _self = self else {return}
                switch evt {
                case let .next(response):
                    if response.result == 1 {
                        _self.verificationCodeView.isHidden = true
                        _self.showNotification(text: "Successfully saved.")
                    }
                    else {
                        _self.showNotification(text: response.message)
                    }
                    hud.hide(true)
                    break
                case .error:
                    _self.showNotification(text: L10n.serverError)
                    hud.hide(true)
                    break
                default:
                    hud.hide(true)
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    @IBAction func onIndustry(_ sender: Any) {
        industryDropDown.show()
    }
    
    ///Setup mobile dropdown
    func setupMobileDropDown() {
        //set dropdown
        mobileDropDown.anchorView = countryCode
        mobileDropDown.width = 100
        mobileDropDown.dataSource = kFlagValues
        mobileDropDown.cellNib = UINib(nibName: "CountryCodeCell", bundle: nil)
        mobileDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? CountryCodeCell else { return }

           // Setup your custom UI components
            cell.countryFlag.image = UIImage(named: "flag_" + kFlagSuffix[index])
        }
        mobileDropDown.selectionAction = {[unowned self] (index: Int, item: String) in
            self.flag.image = UIImage(named: "flag_" + kFlagSuffix[index])
            self.countryCodeLabel.text = item
            self.strCountryZipCode = item
        }
    }
    ///Setup agent mobile dropdown
    func setupAgentMobileDropDown() {
        //set dropdown
        agentMobileDropDown.anchorView = agentCountryCode
        agentMobileDropDown.width = 100
        agentMobileDropDown.dataSource = kFlagValues
        agentMobileDropDown.cellNib = UINib(nibName: "CountryCodeCell", bundle: nil)
        agentMobileDropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? CountryCodeCell else { return }

           // Setup your custom UI components
            cell.countryFlag.image = UIImage(named: "flag_" + kFlagSuffix[index])
        }
        agentMobileDropDown.selectionAction = {[unowned self] (index: Int, item: String) in
            self.agentFlag.image = UIImage(named: "flag_" + kFlagSuffix[index])
            self.agentCountryCodeLabel.text = item
            self.strAgentCountryZipCode = item
        }
    }
    ///Setup industry dropdown
    func setupIndustryDropDown() {
        industryDropDown.anchorView = industryDropDownView
        industryDropDown.dataSource = industryInfoList.map({$0.industry})
        industryDropDown.selectionAction = {[unowned self] (index: Int, item:String) in
            //action for Car Selection
            self.industryLabel.text = self.industryInfoList[index].industry
        }
    }
}
