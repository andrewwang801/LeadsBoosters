//
//  VisitCampaignSettingsVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/16.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import IBAnimatable
import JSQDataSourcesKit

protocol VisitCampaignDelgate {
    func gravityChanged(gravity: Int, row: Int)
    func statusSwitchChanged(isOn: Int, row: Int)
}
class VisitCampaignSettingsVC: BaseVC, UITableViewDelegate, VisitCampaignDelgate {
    func gravityChanged(gravity: Int, row: Int) {
        agentInfoArray[row].gravity = gravity
        setupTableView()
        tableView.reloadData()
    }
    
    func statusSwitchChanged(isOn: Int, row: Int) {
        agentInfoArray[row].status = isOn
        setupTableView()
        tableView.reloadData()
    }
    
    ///First Section
    @IBOutlet weak var campaignNameLabel: UILabel!
    @IBOutlet weak var campaignIDLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var welcomeBotTextField: UITextField!
    @IBOutlet weak var saveBtn: AnimatableButton!
    
    ///Second Section
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var randomBtn: AnimatableButton!
    
    ///Third Section
    @IBOutlet weak var tableView: UITableView!
    
    var strWelcomeBot = ""
    
    /// set from caller ViewController
    var campaignInfo = CampaignInfo()
    var agentInfoArray: [CampaignAgentInfo] = []
    var userInfo: UserInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "VisitCampaignSettings"
        
        self.ext.setBackShapedDismissButton().action = #selector(onBack)

        // Do any additional setup after loading the view.
        userInfo = UserInfo(json: parse(string: AppSettings.string(kUserInfo)))
        loadData()
    }
    
    @objc func onBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func initFirstUI() {
        welcomeBotTextField.text = strWelcomeBot
        campaignNameLabel.text = campaignInfo.campaign_name
        campaignIDLabel.text = campaignInfo.id
        accountNameLabel.text = campaignInfo.ad_account
        welcomeBotTextField.addTarget(self, action: #selector(welcomeTxtChanged), for: .editingChanged)
    }
    @objc func welcomeTxtChanged(_ textField: UITextField) {
        strWelcomeBot = textField.text ?? ""
    }
    
    func secondUI() {
        titleLabel.text = L10n.robinSetting
    }
    
    @IBAction func onSave(_ sender: Any) {
        var params:[String: Any] = [:]
        params["token"] = AppSettings.string(kUserToken)
        params["campaign_id"] = campaignInfo.id
        params["message"] = strWelcomeBot
    }
    
    @IBAction func onRandomize(_ sender: Any) {
        doRandomize()
    }
    
    func loadData() {
        var params: [String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        params["campaign_id"] = campaignInfo.id
        
        let hud = activityHUD()
        if hasConnectivity() {
            apiService.getCampaignInfo(params: params)
                .subscribe { [weak self] evt in
                    guard let _self = self else { return }
                    hud.hide(true)
                    switch evt {
                    case let .next(response):
                        if response.result == 1 {
                            _self.strWelcomeBot = response.data.campaign_welcome_bot
                            _self.agentInfoArray.removeAll()
                            _self.agentInfoArray.append(contentsOf: response.data.agents)
                            //tableview reload data
                            _self.setupTableView()
                            _self.tableView.reloadData()
                            NSLog("getCampaignInfo Success")
                        }
                        else {
                            NSLog("getCampaignInfo Failed")
                            _self.showNotification(text: response.message)
                        }
                        break
                    case .error:
                        NSLog("getCampaignInfo Error")
                        _self.showNotification(text: L10n.serverError)
                        break
                    default:
                        break
                    }
            }.disposed(by: disposeBag)
        }
        else {
            showNotification(text: L10n.internetError)
        }
    }
    
    func doRandomize() {
        var params:[String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        params["campaign_id"] = campaignInfo.id
        if let _userInfo = userInfo {
            params["user_id"] = String(_userInfo.id)
        }
        
        let hud = activityHUD()
        
        if hasConnectivity() {
            apiService.doRandomAgentSequence(params: params)
                .subscribe { [weak self] evt in
                    hud.hide(true)
                    guard let _self = self else { return }
                    switch evt {
                    case let .next(response):
                        if response.result == 1 {
                            _self.agentInfoArray.removeAll()
                            _self.agentInfoArray.append(contentsOf: response.agents)
                            //reload table data
                            _self.setupTableView()
                            _self.tableView.reloadData()
                            
                            NSLog("doRandomAgentSequence Success")
                        }
                        else {
                            _self.showNotification(text: response.message)
                            NSLog("doRandomAgentSequence Failed")
                        }
                        break
                    case .error:
                        _self.showNotification(text: L10n.serverError)
                        NSLog("doRandomAgentSequence Error")
                        break
                    default:
                        break
                    }
            }.disposed(by: disposeBag)
        }
        else {
            hud.hide(true)
            showNotification(text: L10n.internetError)
        }
    }
    
    ///table section
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return agentInfoArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    typealias CellConfig = ReusableViewConfig<CampaignAgentInfo, VisitCampaignSettingCell>
    var dataSourceProvider: DataSourceProvider<DataSource<CampaignAgentInfo>, CellConfig, CellConfig>?
    func setupTableView() {
        
        var sectionList = [Section<CampaignAgentInfo>]()
        for item in agentInfoArray {
            let section = Section(items:item)
            sectionList.append(section)
        }
        //let dataSource = DataSource(sections: sectionList)
        let dataSource = DataSource(sectionList)
        let cellConfig = ReusableViewConfig { (cell, info:CampaignAgentInfo?,  _, tableView, ip) -> VisitCampaignSettingCell in
            cell.item = info
            cell.delegate = self
            cell.row = self.agentInfoArray.firstIndex(where: {$0 === info})
            return cell
        }
        dataSourceProvider = DataSourceProvider(dataSource: dataSource, cellConfig: cellConfig, supplementaryConfig: cellConfig)
        tableView.dataSource = dataSourceProvider?.tableViewDataSource
        tableView.delegate = self
    }
}
