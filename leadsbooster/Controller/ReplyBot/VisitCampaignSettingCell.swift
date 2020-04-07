//
//  VisitCampaignSettingCell.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/16.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import DropDown
import RxSwift

class VisitCampaignSettingCell: UITableViewCell, ReusableView {

    @IBOutlet weak var agentNameLabel: UILabel!
    @IBOutlet weak var agentNumberLabel: UILabel!
    @IBOutlet weak var agentEmailLabel: UILabel!
    @IBOutlet weak var statusSwitch: UISwitch!
    @IBOutlet weak var gravityView: UIView!
    @IBOutlet weak var grativyDropDownBtn: UIButton!
    @IBOutlet weak var gravityLabel: UILabel!
    
    let disposeBag = DisposeBag()
    var row: Int?
    var delegate: VisitCampaignDelgate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var campaignInfo: CampaignInfo = CampaignInfo()
    var item: CampaignAgentInfo? {
        didSet {
            guard let _item = item else { return }
            self.updateUI(item: _item)
        }
    }
    
    func updateUI(item: CampaignAgentInfo) {
        agentNameLabel.text = item.username
        agentNumberLabel.text = item.phone_number
        agentEmailLabel.text = item.email
        statusSwitch.setOn(item.status == 1, animated: true)
        dropDown.selectRow(item.gravity - 1)
        setupDropDown()
    }
    
    @IBAction func onDropDown(_ sender: Any) {
        dropDown.show()
    }
    
    ///Gravity Dropdown section
    let dropDown = DropDown()
    let gravityArray = ["1", "2", "3", "4", "5"]
    var selectedGravity = ""
    func setupDropDown() {
        dropDown.anchorView = self.gravityView
        dropDown.dataSource = gravityArray
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) -> Void in
            self.selectedGravity = self.gravityArray[index]
            self.gravityLabel.text = self.gravityArray[index]
            guard let _info = self.item else { return }
            if _info.gravity != index + 1 {
                let oldGravity = _info.gravity
                _info.gravity = index + 1
                var params: [String: String] = [:]
                params["token"] = AppSettings.string(kUserToken)
                params["campaign_id"] = self.campaignInfo.id
                params["user_id"] = String(_info.user_id)
                params["agent_id"] = String(_info.id)
                params["gravity"] = String(_info.gravity)
                
                if hasConnectivity() {
                    apiService.doRegisterGravityForAgent(params: params)
                        .subscribe { [weak self] evt in
                            guard let _self = self else { return }
                            switch evt {
                            case let .next(response):
                                if response.result == 1 {
                                    NSLog("doRegisterGravityForAgent Success")
                                }
                                else {
                                    _info.gravity = oldGravity
                                    _self.item = _info
                                    _self.delegate?.gravityChanged(gravity: oldGravity, row: _self.row!)
                                    NSLog("doRegisterGravityForAgent Failed")
                                }
                                break
                            case .error:
                                NSLog("doRegisterGravityForAgent Error")
                                _info.gravity = oldGravity
                                _self.item = _info
                                _self.delegate?.gravityChanged(gravity: oldGravity, row: _self.row!)
                                break
                            default:
                                break
                            }
                    }
                }
                else {
                    
                }
            }
        }
    }
    
    ///status switch delegate
    func setStatusSwitch() {
        statusSwitch.addTarget(self, action: #selector(statusChanged), for: .valueChanged)
    }
    
    @objc func statusChanged(mySwitch: UISwitch) {
        guard let info = item  else { return }
        let oldStatus = info.status
        info.status = mySwitch.isOn ? 1 : 0
        var params: [String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        params["campaign_id"] = self.campaignInfo.id
        params["user_id"] = String(info.user_id)
        params["agent_id"] = String(info.id)
        params["status"] = String(info.status)
        apiService.doRegisterCampaignBlockList(params: params)
            .subscribe { [weak self] evt in
                guard let _self = self else { return }
                switch evt{
                case let .next(response):
                    if response.result == 1 {

                        NSLog("doRegisterGravityForAgent Success")
                    }
                    else {
                        NSLog("doRegisterGravityForAgent Failed")
                        info.status = oldStatus
                        _self.item = info
                        _self.delegate?.statusSwitchChanged(isOn: oldStatus, row: _self.row!)
                    }
                    break
                case .error:
                NSLog("doRegisterGravityForAgent Error")
                    info.status = oldStatus
                    _self.item = info
                    _self.delegate?.statusSwitchChanged(isOn: oldStatus, row: _self.row!)
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }
}
