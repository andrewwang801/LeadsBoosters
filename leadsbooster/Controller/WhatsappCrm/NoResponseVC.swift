//
//  InquiryVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import IBAnimatable
import DropDown
import SCLAlertView
import JSQDataSourcesKit

class NoResponseVC: BaseVC, UITableViewDelegate {

    @IBOutlet weak var campaignDropDownView: AnimatableView!
    @IBOutlet weak var labelDropDownView: AnimatableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var campaignLabel: UILabel!
    @IBOutlet weak var labelLabel: UILabel!
    
    ///Dropdowns
    var campaignDropDown = DropDown()
    var labelDropDown = DropDown()
    var campaignList: [InboxCampaignInfo] = []
    var labelList: [Label] = []
    var chatRoomList: [ChatRoom] = []
    var campaignDropDownIndex = -1
    var labelDropDownIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "NoResponse"
        
        if self.revealViewController() != nil {
            let sideMenuButton = UIBarButtonItem(image: UIImage(named: "menu")?.itemImage(), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = sideMenuButton
        }
        
        tableView.tableFooterView = UIView()

        // Do any additional setup after loading the view.
        loadData()
    }
    
    func initDropDown() {
        setupCampaignDropDown()
        setupLabelDropDown()
        if campaignList.count != 0 {
            campaignDropDown.selectRow(0)
            campaignLabel.text = campaignList[0].project_name
            refreshInbox()
        }
        if labelList.count != 0 {
            labelDropDown.selectRow(0)
            labelLabel.text = labelList[0].label
            refreshInbox()
        }
    }
    
    @IBAction func onCampaignDropDown(_ sender: Any) {
        campaignDropDown.show()
    }
    
    @IBAction func onLabelDropDown(_ sender: Any) {
        labelDropDown.show()
    }
    
    func refreshInbox() {
        guard let index = campaignDropDown.indexForSelectedRow?.int32 else {return}
        var campaign = ""
        if index == 0 {
            campaign = "-1"
        }
        else {
            campaign = campaignList[Int(index)].project_name
        }
        
        guard let indexLabel = labelDropDown.indexForSelectedRow?.int32 else {return}
        let label = labelList[Int(indexLabel)].value
        
        var params: [String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        params["campaigns"] = campaign
        params["label"] = String(label)
        
        let hud = activityHUD()
        apiService.getInquryChatRooms(params: params)
            .subscribe {[weak self] evt in
                guard let _self = self else {return}
                hud.hide(true)
                switch evt{
                case let .next(response):
                    if response.result == 1 {
                        _self.chatRoomList.removeAll()
                        _self.chatRoomList.append(contentsOf: response.chatrooms)
                        NSLog("getInquryChatRooms success")
                        ///setup tableview and reload table view data
                        _self.setupTableView()
                        _self.tableView.reloadData()
                    }
                    else {
                        _self.showNotification(text: response.message)
                    }
                    break
                case .error:
                    _self.showNotification(text: L10n.serverError)
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    func loadData() {
        let hud = activityHUD()
        
        var params:[String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        params["type"] = "2"
        apiService.getCampaignListForInbox(params: params)
            .subscribe { [weak self] evt in
                hud.hide(true)
                guard let _self = self else {return}
                switch evt {
                case let .next(response):
                    if response.result == 1 {
                        _self.campaignList.removeAll()
                        _self.campaignList.append(contentsOf: response.campaigns)
                        _self.initDropDown()
                        if _self.campaignList.count == 0 {
                            _self.showNotification(text: "There is no campaigns registered yet")
                        }
                        else {
                            _self.setupTableView()
                            _self.tableView.reloadData()
                            _self.campaignDropDown.selectRow(0)
                            _self.labelDropDown.selectRow(0)
                            _self.refreshInbox()
                        }
                    }
                    else {
                        _self.showNotification(text: response.message)
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
    
    func doUpdateChatroomInfo(chatId: String, label: Int) {
        for item in chatRoomList {
            if item.chatId == chatId {
                item.label = label
                tableView.reloadData()
                break
            }
        }
    }
    
    
    ///Stored vars for TableViews
    typealias CellConfig = ReusableViewConfig<ChatRoom, NoResponseCell>
    var dataSourceProvider: DataSourceProvider<DataSource<ChatRoom>, CellConfig, CellConfig>?
    
}

///dropdown section
extension NoResponseVC {
    func setupCampaignDropDown() {
        let campaignInfo = InboxCampaignInfo()
        campaignInfo.project_name = "All Campaigns"
        campaignList.insert(campaignInfo, at: 0)
        campaignDropDown.dataSource = campaignList.map({$0.project_name})
        campaignDropDown.anchorView = campaignDropDownView
        campaignDropDown.selectionAction = { (index: Int, item: String) in
            self.refreshInbox()
            self.campaignLabel.text = item
            self.campaignDropDownIndex = index
        }
    }
    
    func initLabelDropDownData() {
        labelList.append(Label(value: -1, label: "All Labels"))
        labelList.append(Label(value: 1, label: "HIGH"))
        labelList.append(Label(value: 2, label: "LOW"))
        labelList.append(Label(value: 3, label: "Follow Up"))
        labelList.append(Label(value: 4, label: "Meet Up"))
        labelList.append(Label(value: 5, label: "Call"))
        labelList.append(Label(value: 6, label: "Close"))
    }
    
    func setupLabelDropDown() {
        initLabelDropDownData()
        labelDropDown.anchorView = campaignDropDownView
        labelDropDown.selectRow(0)
        labelDropDown.dataSource = labelList.map({$0.label})
        labelDropDown.selectionAction = { (index: Int, item: String) in
            self.refreshInbox()
            self.labelLabel.text = item
            self.labelDropDownIndex = index
        }
    }
}


///tableview section
extension NoResponseVC {
    
     func numberOfSections(in tableView: UITableView) -> Int {
         return chatRoomList.count
     }
     
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 80
     }
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         self.tableView.deselectRow(at: indexPath, animated: true)
         gotoInbox(param: chatRoomList[indexPath.row])
     }
     
     ///Campaign TableView
     func setupTableView() {
         
         var sectionList = [Section<ChatRoom>]()
         for item in chatRoomList {
             let section = Section(items:item)
             sectionList.append(section)
         }
         //let dataSource = DataSource(sections: sectionList)
         let dataSource = DataSource(sectionList)
         let cellConfig = ReusableViewConfig { (cell, info:ChatRoom?,  _, tableView, ip) -> NoResponseCell in
             cell.item = info
             return cell
         }
         dataSourceProvider = DataSourceProvider(dataSource: dataSource, cellConfig: cellConfig, supplementaryConfig: cellConfig)
         tableView.dataSource = dataSourceProvider?.tableViewDataSource
         tableView.delegate = self
     }
}
