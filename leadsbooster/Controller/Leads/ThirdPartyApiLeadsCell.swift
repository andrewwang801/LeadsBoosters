//
//  ThirdPartyApiLeadsCell.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import RxSwift

class ThirdPartyApiLeadsCell: UITableViewCell, ReusableView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var agentNumberLabel: UILabel!
    @IBOutlet weak var agentEmailLabel: UILabel!
    @IBOutlet weak var statusSwitch: UISwitch!
    
    let disposeBag = DisposeBag()
    var delegate: ThirdPartyApiDataDelegate?
    var thirdPartyId: String?
    var row: Int?
    var item: AgentDetailInfo? {
        didSet {
            if let _item = item {
                updateUI(item: _item)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        statusSwitch.addTarget(self, action: #selector(statusChanged(statusSwitch:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func statusChanged(statusSwitch: UISwitch) {
        guard let item = item else {return}
        let oldStatus = item.status
        item.status = statusSwitch.isOn ? 1: 0
        if let _thirdPartyId = thirdPartyId {
            var params: [String: String] = [:]
            params["token"] = AppSettings.string(kUserToken)
            do {
                let userInfo = try UserInfo(json: parse(string: AppSettings.string(kUserInfo)))
                params["user_id"] = String(userInfo.id)
            } catch {
                print("error")
            }
            params["third_party_id"] = _thirdPartyId
            params["agent_id"] = String(item.id)
            params["status"] = String(item.status)
            
            apiService.doRegisterThirdPartyBlockList(params: params)
                .subscribe {[weak self] evt in
                    guard let _self = self else {return}
                    switch evt {
                    case let .next(response):
                        if response.result == 1 {
                            
                            NSLog("register success")
                        }
                        else {
                            item.status = oldStatus
                            if let _delegate = _self.delegate, let _row = _self.row {
                                _delegate.statusSwitchChanged(status: oldStatus, row: _row)
                            }
                            NSLog("register failed")
                        }
                        break
                    case .error:
                        item.status = oldStatus
                        NSLog("register error")
                        break
                    default:
                        break
                    }
            }.disposed(by: disposeBag)
        }
        
    }
    
    func updateUI(item: AgentDetailInfo) {
        nameLabel.text = item.username
        agentNumberLabel.text = item.phone_number
        agentEmailLabel.text = item.email
        statusSwitch.setOn(item.status == 1, animated: true)
    }

}
