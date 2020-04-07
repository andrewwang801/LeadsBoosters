//
//  InstanceCell.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/1.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import SCLAlertView
import RxSwift

class InstanceCell: UITableViewCell, ReusableView {

    @IBOutlet weak var instanceNameLabel: UILabel!
    @IBOutlet weak var instanceTypeLabel: UILabel!
    @IBOutlet weak var statusSwitch: UISwitch!
    
    var parentVC: DashboardVC?
    var delegate: ChangeValueDelegate?
    var row: Int?
    let disposeBag = DisposeBag()
    
    @IBAction func onRemove(_ sender: Any) {
        let confirmAlertView = SCLAlertView()
        confirmAlertView.addButton(L10n.yes) {
            var params: [String: String] = [:]
            params["token"] = AppSettings.string(kUserToken)
            params["id"] = String(self.item!.id)
            
            let hud = self.parentVC!.activityHUD()
            apiService.doDeleteInstance(params: params)
                .subscribe { [weak self] evt in
                    hud.hide(true)
                    guard let _self = self else { return }
                    switch evt {
                    case let .next(response):
                        if response.result == 1 {
                            NSLog("doDeleteInstance Success")
                            _self.delegate?.removeItem(row: _self.row!)
                        }
                        break
                    case .error:
                        NSLog("doDeleteInstance Error")
                        break
                    default:
                        break
                    }
            }.disposed(by: self.disposeBag)
        }
        confirmAlertView.showError("Confirmation", subTitle: "Really want to remove this?")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        statusSwitch.addTarget(self, action: #selector(completeChanged(completeSwitch:)), for: .valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func completeChanged(completeSwitch: UISwitch) {
        guard let info = item else { return }
        let oldStatus = info.status
        info.status = completeSwitch.isOn ? 1 : 0
        
        guard let _parentVC = parentVC else { return }
        let hud = _parentVC.activityHUD()
        
        var params: [String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        params["id"] = String(info.id)
        params["status"] = String(info.status)
        apiService.changeInstanceStatus(params: params)
            .subscribe { [weak self] evt in
                guard let _self = self else { return }
                hud.hide(true)
                switch evt {
                case let .next(response):
                    if response.result == 1 {
                        
                    }
                    else {
                        info.status = oldStatus
                        _self.delegate?.changeSwitchState(isOn: oldStatus, row: _self.row!)
                        ///reload tabledata
                        
                    }
                    break
                case .error:
                    info.status = oldStatus
                    _self.delegate?.changeSwitchState(isOn: oldStatus, row: _self.row!)
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    var item: InstanceInfo? {
        didSet {
            if let _item = item {
                self.updateUI(item: _item)
            }
        }
    }
    
    func updateUI(item: InstanceInfo) {
        instanceNameLabel.text = item.name
        instanceTypeLabel.text = "Facebook Leads Instance"
        statusSwitch.setOn(item.status == 1, animated: true)
    }
}
