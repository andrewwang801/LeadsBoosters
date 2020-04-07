//
//  autoReplyCell.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/5.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import RxSwift
import SCLAlertView

class autoReplyCell: UITableViewCell, ReusableView {

    @IBOutlet var keyWordLabel: UILabel!
    @IBOutlet var replyLabel: UILabel!
    
//    let disposeBag = DisposeBag()
    var parentVC: AutoReplyBots?
    var delegate: UpdateTable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onEdit(_ sender: Any) {
        
        guard let _parentVC = parentVC else { return }
        _parentVC.currentReplyBot = item
        _parentVC.updateUI()
    }
    
    @IBAction func onRemove(_ sender: Any) {
        
        let alertView = SCLAlertView()
        alertView.addButton(L10n.remove) {
            
            guard let _parentVC = self.parentVC else { return }
            let hud = _parentVC.activityHUD()
            var params: [String: Any] = [:]
            params["token"] = AppSettings.string(kUserToken)
            params["id"] = self.item?.id
            
            apiService.doDeleteAutoReplyBot(params: params)
                .subscribe { [weak self] evt in
                    
                    guard let _self = self else { return }
                    switch evt {
                    case let .next(response):
                        
                        if response.result == 1 {
                            let index = _parentVC.autoReplyInfoList.firstIndex(where: {$0 === _self.item})
                            if let _index = index {
                                //_parentVC.autoReplyInfoList.remove(at: _index)
                                _self.delegate?.reloadTableView(at: _index)
                            }
                            NSLog("doDeleteAutoReplyBot Success")
                        }
                        else {
                            _parentVC.showNotification(text: response.message)
                            NSLog("doDeleteAutoReplyBot Failed")
                        }
                        hud.hide(true)
                        break
                    case .error:
                        hud.hide(true)
                        _parentVC.showNotification(text: L10n.internetError)
                        NSLog("doDeleteAutoReplyBot Error")
                        break
                    default:
                        hud.hide(true)
                        break
                    }
                    
            }.disposed(by: _parentVC.disposeBag)
        }
        alertView.showWarning("Confirm", subTitle: "Do you want to delete this auto reply  now?")
    }
    
    var item: AutoReplyInfo? {
        didSet {
            guard let _item = item else { return }
            self.updateUI(autoReplyInfo: _item)
        }
    }
    
    func updateUI(autoReplyInfo: AutoReplyInfo) {
        
        keyWordLabel.text = autoReplyInfo.keywork
        replyLabel.text = autoReplyInfo.reply
    }
    
}
