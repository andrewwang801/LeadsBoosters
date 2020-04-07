//
//  FacebookLeadsSetupCell.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import RxSwift

class FacebookLeadsSetupCell: UITableViewCell, ReusableView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var completeSwitch: UISwitch!
    
    let disposeBag = DisposeBag()
    var parentVC: FacebookLeadsSetupVC?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        completeSwitch.addTarget(self, action: #selector(completeStatusChanged(completeSwitch:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func completeStatusChanged(completeSwitch: UISwitch) {
        var params:[String: String] = [:]
        
        if completeSwitch.isOn {
        
            params["token"] = AppSettings.string(kUserToken)
            params["page_id"] = item!.id
            params["page_token"] = item!.access_token
            params["page_name"] = item!.name
            apiService.subscribepage(params: params)
                .subscribe {[weak self] evt in
                    guard let _self = self else { return }
                    switch evt {
                    case let .next(response):
                        if response.result == 1 {
                            let fbSubscribedItem = FBSubscribedItem()
                            fbSubscribedItem.name = _self.item!.name
                            fbSubscribedItem.page_id = _self.item!.id
                            fbSubscribedItem.page_token = _self.item!.access_token
                            _self.parentVC!.subscribedItemMap[_self.item!.id] = fbSubscribedItem
                            _self.parentVC!.setupTableView()
                            _self.parentVC!.tableView.reloadData()
                            NSLog("subscribePage success")
                        }
                        else {
                            _self.parentVC!.subscribedItemMap.removeValue(forKey: _self.item!.id)
                            _self.parentVC!.setupTableView()
                            _self.parentVC!.tableView.reloadData()
                            NSLog("subscribePage falied")
                        }
                        break
                    case .error:
                        _self.parentVC!.subscribedItemMap.removeValue(forKey: _self.item!.id)
                        _self.parentVC!.setupTableView()
                        _self.parentVC!.tableView.reloadData()
                        NSLog("subscribePage error")
                        break
                    default:
                        break
                    }
            }.disposed(by: disposeBag)
        }
        else {
            params["token"] = AppSettings.string(kUserToken)
            params["page_id"] = item!.id
            apiService.unSubscribe(params: params)
              .subscribe {[weak self] evt in
                  guard let _self = self else { return }
                  switch evt {
                  case let .next(response):
                      if response.result == 1 {
                          _self.parentVC!.subscribedItemMap.removeValue(forKey: _self.item!.id)
                          _self.parentVC!.setupTableView()
                          _self.parentVC!.tableView.reloadData()
                          NSLog("unsubscribePage success")
                      }
                      else {
                          _self.parentVC!.setupTableView()
                          _self.parentVC!.tableView.reloadData()
                          NSLog("unsubscribePage failed")
                      }
                      break
                  case .error:
                    _self.parentVC!.setupTableView()
                      _self.parentVC!.tableView.reloadData()
                      NSLog("unsubscribePage error")
                      break
                  default:
                      break
                  }
            }.disposed(by: disposeBag)
        }
    }
    
    var item: FBpageItem? {
        didSet {
            guard let _item = item else {return}
            updateUI(item: _item)
        }
    }
    
    var subscribedItem: FBSubscribedItem? {
        didSet {
            if let _ = subscribedItem {
                completeSwitch.setOn(true, animated: true)
            }
            else {
                completeSwitch.setOn(false, animated: true)
            }
        }
    }
    
    func updateUI(item: FBpageItem) {
        nameLabel.text = item.name
    }
    
}
