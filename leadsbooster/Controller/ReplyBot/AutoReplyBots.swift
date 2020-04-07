//
//  AutoReplyBots.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/5.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import JSQDataSourcesKit

protocol UpdateTable {
    func reloadTableView(at: Int)
}

class AutoReplyBots: BaseVC, UITableViewDelegate, UpdateTable {

    @IBOutlet var keyWordEditText: UITextField!
    @IBOutlet var replyEditText: UITextField!
    @IBOutlet var autoRepliesTableView: UITableView!
    @IBOutlet weak var autoReplyTableView: UITableView!
    
    var currentReplyBot: AutoReplyInfo?
    var autoReplyInfoList: [AutoReplyInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Auto Reply Bot"
        self.ext.setBackShapedDismissButton().action = #selector(onBack)
        
        if self.revealViewController() != nil {
            let sideMenuButton = UIBarButtonItem(image: UIImage(named: "menu")?.itemImage(), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = sideMenuButton
        }
        
        autoReplyTableView.tableFooterView = UIView()
            
        loadData()
    }
    
    @objc func onBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onAddAutoReply(_ sender: Any) {
        
        let strKeyword = keyWordEditText.text ?? ""
        let strReply = replyEditText.text ?? ""
        
        if strKeyword.isEmpty {
            self.showNotification(text: L10n.keywordMissed)
            return
        }
        if strReply.isEmpty {
            showNotification(text: L10n.replyMissed)
            return
        }
        
        let hud = activityHUD()
        var params: [String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        if let currentReplyBot = currentReplyBot {
            params["id"] = String(currentReplyBot.id)
        }
        params["keyword"] = strKeyword
        params["reply"] = strReply
        
        if hasConnectivity() {
            
            apiService.doSaveAutoReplyBot(params: params)
                .subscribe { [weak self] evt in
                    guard let _self = self else { return }
                    switch evt {
                    case let .next(response):
                        if response.result == 1 {
                            if let _currentReplyBot = self?.currentReplyBot {
                                _currentReplyBot.keywork = strKeyword
                                _currentReplyBot.reply = strReply
                                _self.currentReplyBot = nil
                                _self.updateUI()
                                //reload table
                                _self.setupTableView()
                                _self.autoReplyTableView.reloadData()
                                NSLog("doSaveAutoReplyBot Success")
                            }
                            else {
                                let autoReplyInfo = AutoReplyInfo()
                                autoReplyInfo.id = response.id
                                autoReplyInfo.keywork = strKeyword
                                autoReplyInfo.reply = strReply
                                _self.autoReplyInfoList.append(autoReplyInfo)
                                _self.currentReplyBot = nil
                                _self.updateUI()
                                //reload table
                                _self.setupTableView()
                                _self.autoReplyTableView.reloadData()
                            }
                            _self.showNotification(text: kSuccess)
                        }
                        else {
                            _self.showNotification(text: response.message)
                            NSLog("doSaveAutoReplyBot Failed")
                        }
                        hud.hide(true)
                        break
                    case .error:
                        NSLog("doSaveAutoReplyBot Error")
                        hud.hide(true)
                        break
                    default:
                        hud.hide(true)
                        break
                    }
            }.disposed(by: disposeBag)
        }
        else {
            hud.hide(true)
            showNotification(text: L10n.internetError)
        }
    }
    
    @IBAction func onReset(_ sender: Any) {
        doReset()
    }
    
    func updateUI() {
        if let _currentReplyBot = currentReplyBot {
            keyWordEditText.text = _currentReplyBot.keywork
            replyEditText.text = _currentReplyBot.reply
        }
        else {
            keyWordEditText.text = ""
            replyEditText.text = ""
        }
    }
    
    func loadData() {
        
        let hud = activityHUD()
        var params: [String: Any] = [:]
        params["token"] = AppSettings.string(kUserToken)
        if hasConnectivity() {
            
            apiService.doGetReplyBot(params: params)
                .subscribe { [weak self] evt in
                    
                    guard let _self = self else { return }
                    
                    switch evt {
                    case let .next(response):
                        
                        if response.result == 1 {
                            _self.autoReplyInfoList.removeAll()
                            _self.autoReplyInfoList.append(contentsOf: response.data)
                            //reload tableview
                            _self.setupTableView()
                            _self.autoReplyTableView.reloadData()
                            NSLog("doGetReplyBot(AutoReplyBots) success")
                        }
                        else {
                            _self.showNotification(text: response.message)
                            NSLog("doGetReplyBot(AutoReplyBots) Failed" + response.message)
                        }
                        hud.hide(true)
                        break
                    case .error:
                        hud.hide(true)
                        _self.showNotification(text: L10n.internetError)
                        NSLog("doGetReplyBot(AutoReplyBots) Error")
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
    
    func doReset() {
        currentReplyBot = nil
        updateUI()
    }
    
    
    ///tableView section
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return autoReplyInfoList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    typealias CellConfig = ReusableViewConfig<AutoReplyInfo, autoReplyCell>
    var dataSourceProvider: DataSourceProvider<DataSource<AutoReplyInfo>, CellConfig, CellConfig>?
    func setupTableView() {
        
        var sectionList = [Section<AutoReplyInfo>]()
        for item in autoReplyInfoList {
            let section = Section(items:item)
            sectionList.append(section)
        }
        //let dataSource = DataSource(sections: sectionList)
        let dataSource = DataSource(sectionList)
        let cellConfig = ReusableViewConfig { (cell, info:AutoReplyInfo?,  _, tableView, ip) -> autoReplyCell in
            cell.item = info
            cell.parentVC = self
            cell.delegate = self
            return cell
        }
        dataSourceProvider = DataSourceProvider(dataSource: dataSource, cellConfig: cellConfig, supplementaryConfig: cellConfig)
        autoReplyTableView.dataSource = dataSourceProvider?.tableViewDataSource
        autoReplyTableView.delegate = self
    }
    
    func reloadTableView(at: Int) {
        self.autoReplyInfoList.remove(at: at)
        setupTableView()
        DispatchQueue.main.async {  self.autoReplyTableView.reloadData() }
    }
}
