//
//  VisitContactFormInfoVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/18.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import JSQDataSourcesKit
import DropDown
import IBAnimatable

protocol ThirdPartyApiDataDelegate {
    func statusSwitchChanged(status: Int, row: Int)
}
class ThirdPartyApiLeadsVC: BaseVC, UITableViewDelegate, ThirdPartyApiDataDelegate {

    @IBOutlet weak var tablView: UITableView!
    @IBOutlet weak var dropDownView: AnimatableView!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var btnEnable: AnimatableButton!
    @IBOutlet weak var leadsView: UIView!
    
    var agentInfoList:[AgentDetailInfo] = []
    var membershipInfo: MembershipInfo?
    var companyInfoList:[ThirdPartyCompanyInfo] = []
    var enableCompanyApply = false
    let dropDown = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Third Party Api Leads"
        self.tablView.tableFooterView = UIView()
        
        if self.revealViewController() != nil {
            let sideMenuButton = UIBarButtonItem(image: UIImage(named: "menu")?.itemImage(), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = sideMenuButton
        }
        
        initData()
    }
    
    func initData() {
        membershipInfo = MembershipInfo(json: parse(string: AppSettings.string(kUserMemberShip)))
        loadData()
    }
    
    func initDropDown() {
        setupDropDown()
        if companyInfoList.count > 0 {
            companyLabel.text = companyInfoList[0].company_name
            dropDown.selectRow(0)
            updateUI()
        }
    }
    
    @IBAction func onEnable(_ sender: Any) {
        var params:[String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        
        guard let index = dropDown.indexForSelectedRow?.int32 else {return}
        
        params["third_party_id"] = companyInfoList[Int(index)].id
        let hud = activityHUD()
        apiService.doRegisterThirdParty(params: params)
            .subscribe {[weak self] evt in
                guard let _self = self else {return}
                hud.hide(true)
                switch evt {
                case let .next(response):
                    _self.updateUI()
                    NSLog("doRegisterThirdParty Success")
                    break
                case .error:
                    NSLog("doRegisterThirdParty Error")
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    @IBAction func onDropDown(_ sender: Any) {
        dropDown.show()
    }
    
    func statusSwitchChanged(status: Int, row: Int) {
        agentInfoList[row].status = status
        self.setupTableView()
        self.tablView.reloadData()
    }
    
    func loadData() {
        let hud = activityHUD()
        var params: [String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        
        apiService.doGetThridPartySettings(params: params)
            .subscribe {[weak self] evt in
                hud.hide(true)
                guard let _self = self else {return}
                switch evt{
                case let .next(response):
                    if response.result == 1 {
                        if !response.data.isEmpty {
                            _self.companyInfoList.removeAll()
                            _self.companyInfoList.append(contentsOf: response.data)
                            ///reload dropdown
                            _self.initDropDown()
                        }
                        _self.showNotification(text: "Get DropDown Success")
                        NSLog("doGetThridPartySettings Success")
                    }
                    else {
                        NSLog("doGetThridPartySettings Failed")
                    }
                    break
                case .error:
                    _self.showNotification(text: "Getting Data Error")
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    func updateUI() {
        guard let index = dropDown.indexForSelectedRow?.int32 else {return}
        
        var params: [String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        params["third_party_id"] = companyInfoList[Int(index)].id
        
        let hud = activityHUD()
        
        apiService.doGetThridPartyStatus(params: params)
            .subscribe {[weak self] evt in
                guard let _self = self else {return}
                switch evt {
                case let .next(response):
                    if response.result == 1 {
                        _self.enableCompanyApply = response.data.third_party_apply
                        if _self.enableCompanyApply {
                            _self.btnEnable.setTitleForAllState(title: "Disable")
                        }
                        else {
                            _self.btnEnable.setTitleForAllState(title: "Enable")
                        }
                        if let membershipInfo = _self.membershipInfo, membershipInfo.plans != "free", _self.enableCompanyApply {
                            _self.leadsView.isHidden = false
                            _self.agentInfoList.removeAll()
                            _self.agentInfoList.append(contentsOf: response.data.agent_list)
                            _self.setupTableView()
                            _self.tablView.reloadData()
                        }
                        else {
                            _self.leadsView.isHidden = true
                        }
                        _self.showNotification(text: kSuccess)
                    }
                    hud.hide(true)
                    break
                case .error:
                    hud.hide(true)
                    break
                default:
                    hud.hide(true)
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    func setupDropDown() {
        dropDown.anchorView = dropDownView
        dropDown.dataSource = companyInfoList.map({$0.company_name})
        dropDown.selectionAction = {(index: Int, item: String) in
            self.companyLabel.text = item
            self.updateUI()
        }
    }
    
    ///Stored vars for TableViews
    typealias CellConfig = ReusableViewConfig<AgentDetailInfo, ThirdPartyApiLeadsCell>
    var dataSourceProvider: DataSourceProvider<DataSource<AgentDetailInfo>, CellConfig, CellConfig>?
    
    ///TableView Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return agentInfoList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    ///TableView
    func setupTableView() {
        
        var sectionList = [Section<AgentDetailInfo>]()
        for item in agentInfoList {
            let section = Section(items:item)
            sectionList.append(section)
        }
        //let dataSource = DataSource(sections: sectionList)
        let dataSource = DataSource(sectionList)
        let cellConfig = ReusableViewConfig { (cell, info:AgentDetailInfo?,  _, tableView, ip) -> ThirdPartyApiLeadsCell in
            cell.item = info
            cell.delegate = self
            if let companyIdx = self.dropDown.indexForSelectedRow?.int32 {
                cell.thirdPartyId = self.companyInfoList[Int(companyIdx)].id
            }
            cell.row = self.agentInfoList.firstIndex(where: {$0 === info})
            return cell
        }
        dataSourceProvider = DataSourceProvider(dataSource: dataSource, cellConfig: cellConfig, supplementaryConfig: cellConfig)
        self.tablView.dataSource = dataSourceProvider?.tableViewDataSource
        self.tablView.delegate = self
    }
}
