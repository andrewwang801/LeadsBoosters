//
//  VisitContactFormInfoVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/18.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import JSQDataSourcesKit

protocol  VisitContactDataDelegate {
    func statusSwitchChanged(status: Int, row: Int)
}
class VisitContactFormInfoVC: BaseVC, UITableViewDelegate, VisitContactDataDelegate {

    @IBOutlet weak var tablView: UITableView!
    
    var agentInfoList:[AgentDetailInfo] = []
    var contactFormInfo: ContactFormInfo = ContactFormInfo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///initUI
        self.title = "VisitContactFormInfo"
        self.ext.setBackShapedDismissButton().action = #selector(onBack)
        self.tablView.tableFooterView = UIView()
        
        loadData()
    }
    
    @objc func onBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func statusSwitchChanged(status: Int, row: Int) {
        agentInfoList[row].status = status
        setupTableView()
        self.tablView.reloadData()
    }
    
    func loadData() {
        let hud = activityHUD()
        var params: [String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        params["site_key"] = contactFormInfo.site_key
        params["cf7_id"] = contactFormInfo.cf7_id
        
        apiService.doGetSiteKeyInfo(params: params)
            .subscribe {[weak self] evt in
                hud.hide(true)
                guard let _self = self else {return}
                switch evt{
                case let .next(response):
                    if response.result == 1 {
                        if !response.data.isEmpty {
                            _self.agentInfoList.removeAll()
                            _self.agentInfoList.append(contentsOf: response.data)
                            _self.setupTableView()
                            _self.tablView.reloadData()
                            NSLog("doGetSiteKeyInfo sucess")
                        }
                    }
                    break
                case .error:
                    _self.showNotification(text: "Getting Data Error")
                    NSLog("doGetSiteKeyInfo error")
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    
    ///Stored vars for TableViews
    typealias CellConfig = ReusableViewConfig<AgentDetailInfo, VisitContactFormInfoCell>
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
        let cellConfig = ReusableViewConfig { (cell, info:AgentDetailInfo?,  _, tableView, ip) -> VisitContactFormInfoCell in
            cell.item = info
            cell.contactFormInfo = self.contactFormInfo
            cell.row = self.agentInfoList.firstIndex(where: {$0 === info})
            return cell
        }
        dataSourceProvider = DataSourceProvider(dataSource: dataSource, cellConfig: cellConfig, supplementaryConfig: cellConfig)
        self.tablView.dataSource = dataSourceProvider?.tableViewDataSource
        self.tablView.delegate = self
    }
}
