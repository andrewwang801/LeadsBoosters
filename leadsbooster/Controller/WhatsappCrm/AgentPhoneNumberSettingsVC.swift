//
//  AgentPhoneNumberSettingsVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import DropDown
import IBAnimatable
import PhoneNumberKit
import SCLAlertView
import JSQDataSourcesKit

protocol ChangeDataDelegate {
    func removeItem(row: Int)
}

class AgentPhoneNumberSettingsVC: BaseVC, UITableViewDelegate, ChangeDataDelegate {
    func removeItem(row: Int) {
        agentInfoList.remove(at: row)
        setupTableView()
        tableView.reloadData()
    }
    
    @IBOutlet weak var countryCode: UIView!
    @IBOutlet weak var countryFlag: UIImageView!
    @IBOutlet weak var countryCodeLabel: UILabel!
    @IBOutlet weak var userNameTextField: AnimatableTextField!
    @IBOutlet weak var emailTextField: AnimatableTextField!
    @IBOutlet weak var phoneNumberTextField: AnimatableTextField!
    @IBOutlet weak var verificationCodeTextField: AnimatableTextField!
    @IBOutlet weak var imgCheck: AnimatableButton!
    @IBOutlet weak var verificationView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let dropDown = DropDown()
    
    ///set by calling VC
    var agentInfoList: [AgentInfo] = []
    var countryZipCodeStr = "+65"
    var userInfo: UserInfo?
    var phoneNumberStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.title = "AgentPhoneNumberSettings"

        self.ext.setBackShapedDismissButton().action = #selector(onBackPresses)
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onCountryCode(sender:)))
        countryCode.addGestureRecognizer(tapGesture)
        
        phoneNumberTextField.addTarget(self, action: #selector(phoneNumberChanged(textField:)), for: .editingChanged)
    }
    
    override func initUI() {
//        emailTextField.text = ""
//        phoneNumberTextField.text = ""
        imgCheck.isHidden = true
    }
    
    @objc func onBackPresses() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onCountryCode(sender: UITapGestureRecognizer) {
        setupDropDown()
        dropDown.show()
    }
    
    @objc func phoneNumberChanged(textField: UITextField) {
        phoneNumberStr = countryZipCodeStr + (phoneNumberTextField.text ?? "")
        if isValidPhoneNumber(phoneNumber: phoneNumberStr) {
            imgCheck.isHidden = false
        }
        else {
            imgCheck.isHidden = true
        }
    }
    
    @IBAction func onImageCheck(_ sender: Any) {
        
        let strPhoneNumber = (countryCodeLabel.text ?? "") + (phoneNumberTextField.text ?? "")
        
        if hasConnectivity() == false {
            SCLAlertView().showError("Network Error", subTitle: "Please check internet connection")
        }
        
        if isValidPhoneNumber(phoneNumber: strPhoneNumber) {
            let hud = activityHUD("Please waiting...")

            apiService.genVerificationCode(phoneNumber: strPhoneNumber)
                .subscribe{ [weak self] evt in
                    
                    guard let _self = self else { return }
                    
                    switch(evt) {
                    case let .next(response):
                        if response == 1 {
                            _self.verificationView.isHidden = false
                            NSLog("genVerificationCode sucess")
                        }
                        hud.hide(true)
                        break
                    case .error:
                        hud.hide(true)
                        SCLAlertView().showError("Login Falied", subTitle: "Verification failed")
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
    
    @IBAction func onRegister(_ sender: Any) {
        let hud = activityHUD()
        var params: [String: String] = [:]
        params["verification_code"] = verificationCodeTextField.text ?? ""
        params["phone_number"] = phoneNumberStr
//        params["email"] = emailTextField.text ?? ""
//        params["username"] = userNameTextField.text ?? ""
        params["token"] = AppSettings.string(kUserToken)
        
        apiService.doRegisterPhoneNumber(params: params)
            .subscribe {[weak self] evt in
                guard let _self = self else {return}
                switch evt {
                case let .next(response):
                    if response.result == 1 {
                        _self.verificationView.isHidden = true
                        
                        let info = AgentInfo()
                        info.email = _self.emailTextField.text ?? ""
                        info.phone_number = _self.phoneNumberStr
                        info.id = response.id
                        _self.agentInfoList.append(info)
                        ///tableview setup & reload
                        _self.setupTableView()
                        _self.tableView.reloadData()
                        _self.initUI()
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
    
    ///Stored vars for TableViews
    typealias CellConfig = ReusableViewConfig<AgentInfo, AgentPhoneNumberCell>
    var dataSourceProvider: DataSourceProvider<DataSource<AgentInfo>, CellConfig, CellConfig>?
    
}

extension AgentPhoneNumberSettingsVC {
    
    func setupDropDown() {
        
        //set dropdown
        dropDown.anchorView = countryCode
        dropDown.width = 120
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
            self.countryZipCodeStr = item
        }
    }
}


///tableView Section
extension AgentPhoneNumberSettingsVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return agentInfoList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    ///Campaign TableView
    func setupTableView() {
        
        var sectionList = [Section<AgentInfo>]()
        for item in agentInfoList {
            let section = Section(items:item)
            sectionList.append(section)
        }
        //let dataSource = DataSource(sections: sectionList)
        let dataSource = DataSource(sectionList)
        let cellConfig = ReusableViewConfig { (cell, info:AgentInfo?,  _, tableView, ip) -> AgentPhoneNumberCell in
            cell.item = info
            cell.delegate = self
            cell.row = self.agentInfoList.firstIndex(where: {$0 === info})
            return cell
        }
        dataSourceProvider = DataSourceProvider(dataSource: dataSource, cellConfig: cellConfig, supplementaryConfig: cellConfig)
        tableView.dataSource = dataSourceProvider?.tableViewDataSource
        tableView.delegate = self
    }
}


