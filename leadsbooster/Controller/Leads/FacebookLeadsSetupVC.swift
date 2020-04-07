//
//  FacebookLeadsSetupVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import IBAnimatable
import JSQDataSourcesKit
import FBSDKLoginKit

protocol FBCompleteStatusDelegate {
    func completeStatusChanged(key: String, item: FBSubscribedItem)
}
class FacebookLeadsSetupVC: BaseVC, UITableViewDelegate, FBCompleteStatusDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var fbConnectBtn: AnimatableButton!
    @IBOutlet weak var completeSetup: AnimatableButton!
    
    var pageItemList: [FBpageItem] = []
    var subscribedItemMap: [String:FBSubscribedItem] = [:]
    var bConnectFB = false
    let loginManager: LoginManager = LoginManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Facebook Leads Setup"
        tableView.tableFooterView = UIView()
        
        if self.revealViewController() != nil {
            let sideMenuButton = UIBarButtonItem(image: UIImage(named: "menu")?.itemImage(), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = sideMenuButton
        }
        
        loadData()
    }
    
    func completeStatusChanged(key: String, item: FBSubscribedItem) {
        subscribedItemMap[key] = item
    }
    
    @IBAction func onComplete(_ sender: Any) {
        gotoDashboard()
    }
    
    @IBAction func onFacebookConnect(_ sender: Any) {
        if bConnectFB {
            doDisconnect()
        }
        else {
            doConnect()
        }
    }
    
    ///TODO
    func doDisconnect() {
        var params: [String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        let hud = activityHUD()
        apiService.disconnectFacebook(params: params)
            .subscribe {[weak self] evt in
                guard let _self = self else {return}
                switch evt{
                case let .next(response):
                    if response.result == 1 {
                        _self.bConnectFB = false
                        _self.updateUI()
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
    
    func doConnect() {
        let loginManager = LoginManager()
        loginManager.logIn(
            permissions: [.email, .adsRead, "leads_retrieval", "manage_pages", "business_management", "ads_management"],
            viewController: self
        ) { result in
            self.loginManagerDidComplete(result)
        }
    }
    
    func loginManagerDidComplete(_ result: LoginResult) {
        switch result {
        case .cancelled:
            break
        case .failed(let _):
            break
        case .success(let grantedPermissions, _, let token):
            var params:[String: String] = [:]
            params["token"] = AppSettings.string(kUserToken)
            params["access_token"] = token.tokenString
            let hud = activityHUD()
            apiService.registerToken(params: params)
                .subscribe {[weak self] evt in
                    guard let _self = self else {return}
                    switch evt {
                    case let .next(response):
                        
                        if response.result == 1 {
                            _self.loadData()
                        }
                        _self.doDisconnect()
                        hud.hide(true)
                        break
                    case .error:
                        _self.doDisconnect()
                        hud.hide(true)
                        break
                    default:
                        break
                    }
            }.disposed(by: disposeBag)
            break
        }
    }

    func loadData() {
        let hud = activityHUD()
        var params:[String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        apiService.doGetFacebookPages(params: params)
            .subscribe { [weak self] evt in
                guard let _self = self else {return}
                hud.hide(true)
                switch evt {
                case let .next(response):
                    if response.result == 2 {
                        _self.bConnectFB = false
                        _self.updateUI()
                    }
                    else if response.result == 1 {
                        _self.bConnectFB = true
                        _self.pageItemList.removeAll()
                        _self.pageItemList.append(contentsOf: response.data.fb_pages)
                        _self.subscribedItemMap.removeAll()
                        for item in response.data.fb_subscribed {
                            _self.subscribedItemMap[item.page_id] = item
                        }
                        _self.setupTableView()
                        _self.tableView.reloadData()
                        _self.updateUI()
                        _self.showNotification(text: kSuccess)
                    }
                    break
                    
                case .error:
                    _self.showNotification(text: L10n.internetError)
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    func updateUI() {
        if bConnectFB {
            fbConnectBtn.setTitleForAllState(title: "Disconnect From Facebook")
            completeSetup.isHidden = false
//            fbConnectBtn.setBackgroundImage(UIColor.green.ext.image, for: .normal)
            
            if pageItemList.count == 0 {
                setupTableView()
                tableView.isHidden = true
                tableView.reloadData()
            }
            else {
                tableView.isHidden = false
            }
        }
        else {
            fbConnectBtn.setTitleForAllState(title: "Connect with Facebook")
            completeSetup.isHidden = true
//            fbConnectBtn.setBackgroundImage(UIColor.blue.ext.image, for: .normal)
            setupTableView()
            tableView.isHidden = true
            tableView.reloadData()
        }
    }
    
    ///Stored vars for TableViews
    typealias CellConfig = ReusableViewConfig<FBpageItem, FacebookLeadsSetupCell>
    var dataSourceProvider: DataSourceProvider<DataSource<FBpageItem>, CellConfig, CellConfig>?
}


///TableView section
extension FacebookLeadsSetupVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return pageItemList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    ///Campaign TableView
    func setupTableView() {
        
        var sectionList = [Section<FBpageItem>]()
        for item in pageItemList {
            let section = Section(items:item)
            sectionList.append(section)
        }
        //let dataSource = DataSource(sections: sectionList)
        let dataSource = DataSource(sectionList)
        let cellConfig = ReusableViewConfig { (cell, info:FBpageItem?,  _, tableView, ip) -> FacebookLeadsSetupCell in
            cell.parentVC = self
            cell.item = info
            if let _info = info {
                cell.subscribedItem = self.subscribedItemMap[_info.id]
            }
            return cell
        }
        dataSourceProvider = DataSourceProvider(dataSource: dataSource, cellConfig: cellConfig, supplementaryConfig: cellConfig)
        tableView.dataSource = dataSourceProvider?.tableViewDataSource
        tableView.delegate = self
    }
}
