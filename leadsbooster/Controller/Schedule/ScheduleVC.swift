//
//  TableViewController.swift
//  project
//
//  Created by Apple Developer on 2020/1/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import JSQDataSourcesKit
import SkeletonView

class ScheduleVC: BaseVC , UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var items = [Schedule]()
    var itemsAll = [Schedule]()
    var week = 1
    var weekNum = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ext.setTitle("1. krog")
        let topInset = 10
        self.tableView.contentInset = UIEdgeInsets(top: CGFloat(topInset), left: 0, bottom: 0, right: 0)
        self.tableView.showAnimatedSkeleton()
//        self.loadData()
    }
    
    override func initUI(){
        if self.revealViewController() != nil {
            let sideMenuButton = UIBarButtonItem(image: UIImage(named: "RevealMenu")?.itemImage(), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            let weekLeftArrow = UIBarButtonItem(image: UIImage(named: "ic_nav_back")?.itemImage(), style: .plain, target: self, action: #selector(reloadScheduelByWeekDis))
            navigationItem.leftBarButtonItems = [ sideMenuButton, weekLeftArrow]
            
            let weekRightArrow = UIBarButtonItem(image: UIImage(named: "ic_nav_back_ar")?.itemImage(), style: .plain, target: self, action: #selector(reloadScheduelByWeekInc))
            let blank = UIBarButtonItem(image: UIImage(named: "blank"), style: .plain, target: self, action: nil)
            navigationItem.rightBarButtonItems = [blank, weekRightArrow]
        }
    }
    
    func itemImage(name:String) -> UIImage?{
        return UIImage(named: name)?.scaleToSize(25.0)?.withRenderingMode(.alwaysOriginal)
    }

    
    @objc func reloadScheduelByWeekDis() {
        if week > 1 {
            week -= 1
        }
        //self.items = self.itemsAll.filter({ $0.week == week })
        //self.setupTableView()
//        self.loadSchedules()
        self.ext.setTitle(String(week) + "." + "krog")
        self.tableView.reloadData()
    }
    
    @objc func reloadScheduelByWeekInc() {
        if week < weekNum {
            week += 1
        }
        //self.items = self.itemsAll.filter({ $0.week == week })
        //self.setupTableView()
//        self.loadSchedules()
        self.ext.setTitle(String(week) + "." + "krog")
        self.tableView.reloadData()
    }
    
//    func loadData() {
//        if hasConnectivity() {
//            apiService.getWeekCount(leagueId: AppSettings.shared.leagueId)
//                .subscribe{ [weak self] evt in
//                    guard let _self = self else { return }
//                    switch evt {
//                    case let .next(response):
//                        _self.weekNum = response
//                        _self.loadSchedules()
//                    case .error(_) :
//                        print("getWeekCount error.")
//                    default:
//                        break
//                    }
//            }.disposed(by: self.disposeBag)
//        } else {
//            showNotification(errorMessage: "Network Error...")
//        }
//
//    }
//
//    func loadSchedules() {
//        if hasConnectivity() {
//            apiService.getSchedule(leagueId: AppSettings.shared.leagueId, week: self.week)
//                .subscribe{ [weak self] evt in
//                    guard let _self = self else { return }
//                    switch(evt) {
//                    case let .next(response):
//                        _self.items = response
//                        _self.setupTableView()
//                        _self.tableView.hideSkeleton()
//                        _self.tableView.reloadData()
//                    case .error(_):
//                        print("getRegions error.")
//                    default:
//                        break
//                    }
//            }.disposed(by: self.disposeBag)
//        } else {
//            showNotification(errorMessage: "Network Error...")
//        }
//    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    typealias CellConfig = ReusableViewConfig<Schedule, ScheduleCell>
    var dataSourceProvider: DataSourceProvider<DataSource<Schedule>, CellConfig, CellConfig>?
    func setupTableView() {
        
        var sectionList = [Section<Schedule>]()
        for item in items {
            let section = Section(items:item)
            sectionList.append(section)
        }
        //let dataSource = DataSource(sections: sectionList)
        let dataSource = DataSource(sectionList)
        let cellConfig = ReusableViewConfig { (cell, info:Schedule?,  _, tableView, ip) -> ScheduleCell in
            cell.item = info
            return cell
        }
        dataSourceProvider = DataSourceProvider(dataSource: dataSource, cellConfig: cellConfig, supplementaryConfig: cellConfig)
        tableView.dataSource = dataSourceProvider?.tableViewDataSource
        tableView.delegate = self
    }
}

