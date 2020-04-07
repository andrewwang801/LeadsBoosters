//
//  VisitContactFormInfoCell.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/18.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import RxSwift

class VisitContactFormInfoCell: UITableViewCell, ReusableView {

    @IBOutlet weak var agentNameLabel: UILabel!
    @IBOutlet weak var agentNumberLabel: UILabel!
    @IBOutlet weak var agentEmailLabel: UILabel!
    @IBOutlet weak var statusSwitch: UISwitch!
    @IBOutlet weak var dropDownButton: UIButton!
    @IBOutlet weak var dropDownView: UIView!
    
    let disposeBag = DisposeBag()
    var contactFormInfo: ContactFormInfo?
    var delegate: VisitContactDataDelegate?
    var row: Int?
    
    var item: AgentDetailInfo? {
        didSet {
            guard let _item = item else {return}
            updateUI(item: _item)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        statusSwitch.addTarget(self, action: #selector(onStatusChanged(statusSwitch:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func onStatusChanged(statusSwitch: UISwitch) {
        guard let item = item else {return}
        let oldStatus = item.status
        item.status = statusSwitch.isOn ? 1: 0
        var params:[String:String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        
        if let contactFormInfo = contactFormInfo {

            params["cf7_id"] = contactFormInfo.cf7_id
            params["site_key"] = contactFormInfo.site_key
        }
        params["agent_id"] = String(item.id)
        params["status"] = String(item.status)
        
        apiService.doRegisterContactBlockList(params: params)
            .subscribe {[weak self] evt in
                guard let _self = self else {return}
                switch evt {
                case let .next(response):
                    if response.result == 1 {

                        NSLog("doRegisterContactBlockList sucess")
                    }
                    else {
                        item.status = oldStatus
                        if let _delegate = _self.delegate, let _row = _self.row {
                            _delegate.statusSwitchChanged(status: oldStatus, row: _row)
                        }
                        NSLog("doRegisterContactBlockList failed")
                    }
                    break
                case .error:
                    item.status = oldStatus
                    if let _delegate = _self.delegate, let _row = _self.row {
                        _delegate.statusSwitchChanged(status: oldStatus, row: _row)
                    }
                    NSLog("doRegisterContactBlockList error")
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }


    func updateUI(item: AgentDetailInfo) {
        agentNameLabel.text = item.username
        agentNumberLabel.text = item.phone_number
        agentEmailLabel.text = item.email
        statusSwitch.setOn(item.status == 1, animated: true)
    }
}
