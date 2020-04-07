//
//  WordpressLeadsVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import IBAnimatable
import JSQDataSourcesKit

class WordpressLeadsVC: BaseVC, UITableViewDelegate {

    @IBOutlet weak var keyTextField: AnimatableTextView!
    @IBOutlet weak var tableView: UITableView!
    
    var membershipInfo: MembershipInfo?
    var contactFormInfoList: [ContactFormInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.title = "Wordpress Leads Settings"
        self.tableView.tableFooterView = UIView()
        
        if self.revealViewController() != nil {
            let sideMenuButton = UIBarButtonItem(image: UIImage(named: "menu")?.itemImage(), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = sideMenuButton
        }
        
        initData()
        loadData()
    }
    
    func initData() {
        membershipInfo = MembershipInfo(json: parse(string: AppSettings.string(kUserMemberShip)))
    }
    
    @IBAction func onGenerate(_ sender: Any) {
        doGenerateKey()
    }
    
    func loadData() {
        let hud = activityHUD()
        var params:[String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        apiService.doGetWordPressSesttings(params: params)
            .subscribe {[weak self] evt in
                guard let _self = self else {return}
                hud.hide(true)
                _self.contactFormInfoList.removeAll()
                switch evt {
                case let .next(response):
                    if response.result == 1 {
                        _self.keyTextField.text = response.data.site_key
                        _self.contactFormInfoList.append(contentsOf: response.data.contact_form)
                        _self.showNotification(text: kSuccess)
                        _self.setupTableView()
                        _self.tableView.reloadData()
                    }
                    _self.updateUI()
                    hud.hide(true)
                    break
                case .error:
                    hud.hide(true)
                    _self.updateUI()
                    break
                default:
                    hud.hide(true)
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    func updateUI() {
        if contactFormInfoList.count == 0 {
            tableView.isHidden = true
        }
        else {
            setupTableView()
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    func doGenerateKey() {
        let hud = activityHUD()
        var params:[String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        apiService.doGenerateSiteKey(params: params)
            .subscribe {[weak self] evt in
                guard let _self = self else {return}
                hud.hide(true)
                _self.contactFormInfoList.removeAll()
                switch evt {
                case let .next(respose):
                    if respose.result == 1 {
                        _self.keyTextField.text = respose.site_key
                    }
                    _self.showNotification(text: kSuccess)
                    break
                case .error:
                    hud.hide(true)
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    ///Stored vars for TableViews
    typealias CellConfig = ReusableViewConfig<ContactFormInfo, WordpressLeadsCell>
    var dataSourceProvider: DataSourceProvider<DataSource<ContactFormInfo>, CellConfig, CellConfig>?
}

extension WordpressLeadsVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contactFormInfoList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    ///Campaign TableView
    func setupTableView() {
        
        var sectionList = [Section<ContactFormInfo>]()
        for item in contactFormInfoList {
            let section = Section(items:item)
            sectionList.append(section)
        }
        //let dataSource = DataSource(sections: sectionList)
        let dataSource = DataSource(sectionList)
        let cellConfig = ReusableViewConfig { (cell, info:ContactFormInfo?,  _, tableView, ip) -> WordpressLeadsCell in
            cell.item = info
            cell.parentVC = self
            cell.membershipInfo = self.membershipInfo
            return cell
        }
        dataSourceProvider = DataSourceProvider(dataSource: dataSource, cellConfig: cellConfig, supplementaryConfig: cellConfig)
        tableView.dataSource = dataSourceProvider?.tableViewDataSource
        tableView.delegate = self
    }
}
