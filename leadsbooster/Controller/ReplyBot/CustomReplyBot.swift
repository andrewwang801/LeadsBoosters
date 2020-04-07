//
//  CustomReplyBot.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/5.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import DropDown
import JSQDataSourcesKit

class CustomReplyBot: BaseVC, UITableViewDelegate {

    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var campaignLabel: UILabel!
    
    @IBOutlet weak var campaignDropDownView: UIView!
    @IBOutlet weak var dropDownBtn: UIButton!
    
    @IBOutlet weak var campaignTableView: UITableView!
    
    var campaignInfoList:[CampaignInfo] = []
    var accountInfoList: [AccountInfo] = []
    let dropDown = DropDown()
    var dropDownIndex = -1
    var membershipInfo: MembershipInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Facebook Campaigns"
        
        if self.revealViewController() != nil {
            let sideMenuButton = UIBarButtonItem(image: UIImage(named: "menu")?.itemImage(), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = sideMenuButton
        }
        
        campaignTableView.tableFooterView = UIView()
        membershipInfo = MembershipInfo(json: parse(string: AppSettings.string(kUserMemberShip)))
        
        loadDropDownData()
    }
    func initDropDown() {
        setupDropDown()
        if accountInfoList.count > 0 {
            dropDown.selectRow(0)
            campaignLabel.text = accountInfoList[0].name
            loadCapaignData()
        }
    }
    @IBAction func onDropDown(_ sender: Any) {
        dropDown.show()
    }
    
    func loadCapaignData() {
        guard let position = dropDown.indexForSelectedRow?.int32 else {return}
        if Int(position) != -1 {
            let accountInfo = accountInfoList[Int(position)]
            campaignInfoList.removeAll()
            var params: [String: String] = [:]
            params["token"] = AppSettings.string(kUserToken)
            params["account_id"] = accountInfo.id
            params["account_name"] = accountInfo.name
            params["ingore_zero_leads"] = "0"
            
            let hud = activityHUD()
            if hasConnectivity() {
                apiService.doGetCampaignList(params: params)
                    .subscribe { [weak self] evt in
                        hud.hide(true)
                        guard let _self = self else { return }
                        switch evt {
                        case let .next(response):
                            if response.data.count > 0 {
                                _self.campaignInfoList.append(contentsOf: response.data)
                                //reload table
                                _self.setupTableView()
                                _self.campaignTableView.reloadData()
                            }
                            if _self.campaignInfoList.count == 0 {
                                _self.noDataLabel.isHidden = false
                            }
                            else {
                                _self.noDataLabel.isHidden = true
                            }
                            NSLog("doGetCampaignList  Success")
                            break
                        case .error:
                            NSLog("doGetCampaignList  Error")
                            _self.noDataLabel.isHidden = false
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
    }
    
    func loadDropDownData() {
        let hud = activityHUD()
        var params: [String:String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        
        if hasConnectivity() {
            
            apiService.doGetInstanceList(params: params)
                .subscribe { [weak self] evt in
                    guard let _self = self else { return }
                    switch evt {
                    case let .next(response):
                        hud.hide(true)
                        if response.result == 1 {
                            _self.accountInfoList.append(contentsOf: response.data.fb_account_list)
                            _self.initDropDown()
                            NSLog("doGetInstanceList  Success")
                        }
                        else {
                            _self.showNotification(text: response.message)
                            NSLog("doGetInstanceList  Failed" + response.message)
                        }
                        break
                    case .error:
                        hud.hide(true)
                        _self.showNotification(text: L10n.internetError)
                        NSLog("doGetInstanceList  Error")
                        break
                    default:
                        break
                    }
            }.disposed(by: disposeBag)
        }
        else {
        }
    }

    func setupDropDown() {
        dropDown.anchorView = campaignDropDownView
        dropDown.dataSource = accountInfoList.map({$0.name})
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.campaignLabel.text = item
            self.loadCapaignData()
        }
    }
    
    ///tableView Section
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return campaignInfoList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    typealias CellConfig = ReusableViewConfig<CampaignInfo, CustomReplyBotCell>
    var dataSourceProvider: DataSourceProvider<DataSource<CampaignInfo>, CellConfig, CellConfig>?
    func setupTableView() {
        
        var sectionList = [Section<CampaignInfo>]()
        for item in campaignInfoList {
            let section = Section(items:item)
            sectionList.append(section)
        }
        //let dataSource = DataSource(sections: sectionList)
        let dataSource = DataSource(sectionList)
        let cellConfig = ReusableViewConfig { (cell, info:CampaignInfo?,  _, tableView, ip) -> CustomReplyBotCell in
            cell.item = info
            cell.parentVC = self
            cell.membershipInfo = self.membershipInfo
            return cell
        }
        dataSourceProvider = DataSourceProvider(dataSource: dataSource, cellConfig: cellConfig, supplementaryConfig: cellConfig)
        campaignTableView.dataSource = dataSourceProvider?.tableViewDataSource
        campaignTableView.delegate = self
    }
}
