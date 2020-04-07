//
//  DashboardVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/1.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import DropDown
import JSQDataSourcesKit

protocol ChangeValueDelegate {
    func changeSwitchState(isOn: Int, row: Int)
    func removeItem(row: Int)
}

class DashboardVC: BaseVC, UITableViewDelegate, ChangeValueDelegate  {
    func changeSwitchState(isOn: Int, row: Int) {
        instanceInfoArray[row].status = isOn
        setupTableView()
        DispatchQueue.main.async { self.instanceTableView.reloadData() }
    }
    
    func removeItem(row: Int) {
        instanceInfoArray.remove(at: row)
        setupTableView()
        DispatchQueue.main.async { self.instanceTableView.reloadData() }
    }
    

    @IBOutlet weak var newsContentViewPager: ViewPager!
    @IBOutlet weak var newsContentViewPagerHeight: NSLayoutConstraint!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var plusMembersBtn: UIButton!
    @IBOutlet weak var campaignTableView: UITableView!
    @IBOutlet weak var campaignView: UIView!
    @IBOutlet weak var instanceTableView: UITableView!
    @IBOutlet weak var instanceView: UIView!
    @IBOutlet weak var dropDownLabel: UILabel!
    
    var instanceInfoArray: [InstanceInfo] = []
    var campaignInfoArray: [CampaignInfo] = []
    var newsArray: [NewsInfo] = []
    var accountInfoArray: [AccountInfo] = []
    var memberShipInfo: MembershipInfo?

    ///Dropdown
    var dropDown = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        instanceTableView.tableFooterView = UIView()
        self.title = "Campaign Manager"
        
        if self.revealViewController() != nil {
            let sideMenuButton = UIBarButtonItem(image: UIImage(named: "menu")?.itemImage(), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = sideMenuButton
        }
        
        loadData()
        doRefreshCampaign()
        initNewsUI()
    }
    
    func initDropDown() {
        //Dropdown
        setupDropDown()
        if accountInfoArray.count > 0 {
            dropDown.selectRow(0)
            dropDownLabel.text = accountInfoArray[0].name
        }
    }
    
    func initNewsUI() {
        newsContentViewPager.dataSource = self
        newsContentViewPager.animationNext()
    }
    
    func updateUI() {
        if newsArray.count == 0 {
            newsContentViewPager.isHidden = true
            newsContentViewPagerHeight.constant = 0
        }
        else {
            newsContentViewPager.isHidden = false
            //newsContentViewPagerHeight.constant = self.view.frame.height * 0.1
            newsContentViewPager.reloadData()
        }
        if instanceInfoArray.count == 0 && campaignInfoArray.count == 0{
            instanceTableView.isHidden = true
            
            campaignTableView.isHidden = true
        }
        else if instanceInfoArray.count != 0 && campaignInfoArray.count == 0 {
            campaignTableView.isHidden = true
            //campaignTableView.heightAnchor.constraint(equalToConstant: 0).isActive = true
            
            instanceTableView.isHidden = false
            //instanceTableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true
            setupTableView()
            instanceTableView.reloadData()
        }
        else if instanceInfoArray.count == 0 && campaignInfoArray.count != 0 {
            instanceTableView.isHidden = true
            //instanceTableView.heightAnchor.constraint(equalToConstant: 0).isActive = true
            
            campaignTableView.isHidden = false
            //campaignTableView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8).isActive = true
            setupTableView()
            campaignTableView.reloadData()
        }
    }
    
    @IBAction func onPlusMember(_ sender: Any) {
        let hud = activityHUD()
        var params: [String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        apiService.doGetProfile(params: params)
            .subscribe { [weak self] evt in
                hud.hide(true)
                guard let _self = self else { return }
                switch evt {
                case let .next(response):
                    if response.result == 1 {
                        NSLog("doGetProfile Success")
                        _self.memberShipInfo = response.membership
                        ///goto AgentPhoneNumberSettingsVC
                        _self.gotoAgentPhoneNumberSettingVC(param: response.agent_phone_numbers)
                    }
                    else {
                        _self.showNotification(text: response.message)
                        NSLog("doGetProfile Failed")
                    }
                    hud.hide(true)
                    break
                case .error:
                    hud.hide(true)
                    NSLog("doGetProfile Error")
                    _self.showNotification(text: "Error")
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    @IBAction func onDropDown(_ sender: Any) {

        dropDown.show()
    }
    
    func setupDropDown() {
        dropDown.anchorView = dropDownButton
        dropDown.dataSource = accountInfoArray.map( { $0.name } )
        dropDown.width = 200
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.dropDownLabel.text = item
            self.doRefreshCampaign()
        }
    }
    ///Stored vars for TableViews
    typealias CellConfig = ReusableViewConfig<InstanceInfo, InstanceCell>
    var dataSourceProvider: DataSourceProvider<DataSource<InstanceInfo>, CellConfig, CellConfig>?
    
    typealias CampaignCellConfig = ReusableViewConfig<CampaignInfo, CampaginCell>
    var campaignDataSourceProvider: DataSourceProvider<DataSource<CampaignInfo>, CampaignCellConfig, CampaignCellConfig>?
}

///load data for tableviews
extension DashboardVC {
    func loadData() {
        
        let hud = activityHUD()
        var params: [String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        
        apiService.doGetInstanceList(params: params)
            .subscribe { [weak self] evt in
                guard let _self = self else { return }
                switch evt {
                case let .next(response):
                    if response.result == 1 {
                        NSLog("doGetInstanceList Success")
                        for item in response.data.instances {
                            if item.type == 5 {
                                _self.instanceInfoArray.append(item)
                            }
                        }
                        _self.newsArray.append(contentsOf: response.data.news)
                        _self.accountInfoArray.append(contentsOf: response.data.fb_account_list)
                        _self.initDropDown()
                        _self.updateUI()
                    }
                    break
                case .error:
                    NSLog("doGetInstanceList Error")
                    hud.hide(true)
                    break
                default:
                    hud.hide(true)
                    break
                }
        }.disposed(by: disposeBag)
        
        let hud1 = activityHUD()
        var _params: [String: String] = [:]
        _params["token"] = AppSettings.string(kUserToken)
        apiService.doGetMembership(params: _params)
           .subscribe {evt in
               switch evt {
               case let .next(response):
                   if response.result == 1 {
                       NSLog("doGetMembership Success")
                        AppSettings.set(response.data.toString(), forKey: kUserMemberShip)
                        AppSettings.shared.membershipInfo = response.data
                    }
                    hud1.hide(true)
               case .error(_):
                    NSLog("doGetMembership Error")
                    hud1.hide(true)
               case .completed:
                    hud1.hide(true)
            }
        }.disposed(by: disposeBag)
    }
    
    func doRefreshCampaign() {
        guard let position = dropDown.indexForSelectedRow?.int32 else {return}
        let accountInfo = accountInfoArray[Int(position)]
        campaignInfoArray.removeAll()
        
        var params:[String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        params["account_id"] = accountInfo.id
        params["account_name"] = accountInfo.name
        params["ignore_zero_leads"] = "0"
        
        let hud = activityHUD()
        apiService.doGetCampaignList(params: params)
            .subscribe { [weak self] evt in
                hud.hide(true)
                guard let _self = self else { return }
                switch evt {
                case let .next(response):
                    if response.data.count > 0 {
                        NSLog("doGetCampaignList Success")
                        
                        _self.campaignInfoArray.append(contentsOf: response.data)
                        _self.setupCampaignTableView()
                        _self.campaignTableView.reloadData()
                        ///reload tableview
                        ///setup tableview
                    }
                    if _self.campaignInfoArray.count == 0 {
                        ///show no campaign text
                        _self.campaignTableView.isHidden = true
                    }
                    else {
                        ///hide not data label
                        _self.campaignTableView.isHidden = false
                    }
                    break
                case .error:
                    NSLog("doGetCampaignList Error")
                    ///show no campaign text
                    hud.hide(true)
                    _self.campaignTableView.isHidden = true
                    break
                default:
                    hud.hide(true)
                    break
                }
        }.disposed(by: disposeBag)
    }
}


///view pager section
extension DashboardVC: ViewPagerDataSource {
    func numberOfItems(viewPager: ViewPager) -> Int {
        return newsArray.count
    }
    
    func viewAtIndex(viewPager: ViewPager, index: Int, view: UIView?) -> UIView {
        var newView = view
        var newsText: UITextView?
        if newView == nil {
            newView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
            newsText = UITextView(frame: newView!.bounds)
            newsText?.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            newsText?.font = UIFont.boldSystemFont(ofSize: 17)
            newsText?.tag = 1
            newView?.addSubview(newsText!)
        }
        else {
            newsText = newView?.viewWithTag(1) as? UITextView
        }
        newsText?.text = newsArray[index].news
        return newView!
    }
}

///TableView Section
extension DashboardVC {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == instanceTableView {
            return instanceInfoArray.count
        }
        else {
            return campaignInfoArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    ///Instance TableView
    func setupTableView() {
        
        var sectionList = [Section<InstanceInfo>]()
        for item in instanceInfoArray {
            let section = Section(items:item)
            sectionList.append(section)
        }
        //let dataSource = DataSource(sections: sectionList)
        let dataSource = DataSource(sectionList)
        let cellConfig = ReusableViewConfig { (cell, info:InstanceInfo?,  _, tableView, ip) -> InstanceCell in
            cell.item = info
            cell.delegate = self
            cell.parentVC = self
            cell.row = self.instanceInfoArray.firstIndex(where: { $0 === info })
            return cell
        }
        dataSourceProvider = DataSourceProvider(dataSource: dataSource, cellConfig: cellConfig, supplementaryConfig: cellConfig)
        instanceTableView.dataSource = dataSourceProvider?.tableViewDataSource
        instanceTableView.delegate = self
    }
    
    ///Campaign TableView
    func setupCampaignTableView() {
        
        var sectionList = [Section<CampaignInfo>]()
        for item in campaignInfoArray {
            let section = Section(items:item)
            sectionList.append(section)
        }
        //let dataSource = DataSource(sections: sectionList)
        let dataSource = DataSource(sectionList)
        let cellConfig = ReusableViewConfig { (cell, info:CampaignInfo?,  _, tableView, ip) -> CampaginCell in
            cell.item = info
            cell.memberShipInfo = self.memberShipInfo
            cell.parentVC = self
            return cell
        }
        campaignDataSourceProvider = DataSourceProvider(dataSource: dataSource, cellConfig: cellConfig, supplementaryConfig: cellConfig)
        campaignTableView.dataSource = campaignDataSourceProvider?.tableViewDataSource
        campaignTableView.delegate = self
    }
}

