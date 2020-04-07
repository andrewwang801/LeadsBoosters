//
//  AutoReplyBot.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/5.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import IBAnimatable

class AutoReplyBot: BaseVC {

    @IBOutlet var editReplyBot: AnimatableTextView!
    @IBOutlet var btnTitleEmoji: UISwitch!
    @IBOutlet var btnMessageEmoji: UISwitch!
    @IBOutlet var checkReminder: AnimatableCheckBox!
    @IBOutlet var editReminderText: UITextField!
    @IBOutlet var btnSave: AnimatableButton!
    @IBOutlet var btnAutoReplyBot: AnimatableButton!
    
    var replyBotData: ReplyBotData?
    var titleEmoji = 0
    var messageEmoji = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Auto Reply Bot"
        
        self.ext.setBackShapedDismissButton().action = #selector(onBack)
        
        if self.revealViewController() != nil {
            let sideMenuButton = UIBarButtonItem(image: UIImage(named: "menu")?.itemImage(), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = sideMenuButton
        }
        
        loadData()
        btnTitleEmoji.addTarget(self, action: #selector(onTitleEmojiChange), for: .valueChanged)
    }
    
    @objc func onBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCheck(_ sender: Any) {
        if !checkReminder.checked {
            checkReminder.setBackgroundImage(UIImage(named: "green_check"), for: .normal)
            editReminderText.isEnabled = true
        }
        else {
            checkReminder.setBackgroundImage(UIColor.white.ext.image, for: .normal)
            editReminderText.isEnabled = false
        }
    }
    
    @IBAction func onSave(_ sender: Any) {
        doSave()
    }
    
    @IBAction func onAutoReplyBot(_ sender: Any) {
        doAutoReplyBot()
    }
    
    @objc func onTitleEmojiChange(mySwitch: UISwitch) {
        titleEmoji = mySwitch.isOn.intValue
    }
    
    @objc func onMessageEmojiChange(mySwitch: UISwitch) {
        messageEmoji = mySwitch.isOn.intValue
    }
    
    func refreshView() {
        if let _replyBotData = replyBotData {
            editReplyBot.text = _replyBotData.message
            editReminderText.text = _replyBotData.reminder
            btnTitleEmoji.setOn(_replyBotData.title_emoji.boolValue, animated: true)
            btnMessageEmoji.setOn(_replyBotData.message_emoji.boolValue, animated: true)
            checkReminder.checked = _replyBotData.is_reminder.boolValue
            if !checkReminder.checked {
                checkReminder.setBackgroundImage(UIImage(named: "green_check"), for: .normal)
            }
            else {
                checkReminder.setBackgroundImage(UIColor.white.ext.image, for: .normal)
            }
            editReminderText.isEnabled = _replyBotData.is_reminder.boolValue
        }
        else {
            editReplyBot.text = ""
            editReminderText.text = ""
            btnTitleEmoji.setOn(true, animated: true)
            btnMessageEmoji.setOn(true, animated: true)
            checkReminder.checked = false
            checkReminder.setBackgroundImage(UIColor.white.ext.image, for: .normal)
            editReminderText.isEnabled = false
        }
    }
    
    func loadData() {
        
        let hud = activityHUD()
        var param: [String: Any] = [:]
        param["token"] = AppSettings.string(kUserToken)
        
        apiService.getReplyBot(params: param)
            .subscribe { [weak self] evt in
                
                guard let _self = self else { return }
                
                switch evt {
                case let .next(response):
                    hud.hide(true)
                    if response.result == 1 {
                        _self.replyBotData = response.response
                        NSLog("getReplyBot Success")
                    }
                    _self.refreshView()
                    hud.hide(true)
                    break
                case .error:
                NSLog("getReplyBot Error")
                    hud.hide(true)
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    func doAutoReplyBot() {
        gotoAutoReplyBots()
    }
    
    func doSave() {
        
        let hud = activityHUD()
        var param: [String: Any] = [:]
        param["token"] = AppSettings.string(kUserToken)
        param["message"] = editReplyBot.text
        param["message_emoji"] = messageEmoji
        param["title_emoji"] = titleEmoji
        param["is_reminder"] = checkReminder.checked.intValue
        
        if checkReminder.checked {
            param["reminder"] = editReminderText.text ?? ""
        }
        else {
            param["reminder"] = ""
        }
        
        apiService.saveReplyBot(params: param)
            .subscribe { [weak self] evt in
                
                guard let _self = self else { return }
                
                switch evt {
                case let .next(response):
                    hud.hide(true)
                    if response.result == 1 {
                        _self.showNotification(text: kSuccess)
                        NSLog("saveReplyBot Success")
                    }
                    else {
                        _self.showNotification(text: response.message)
                        NSLog("saveReplyBot Failed")
                    }
                    break
                case .error:
                    hud.hide(true)
                    _self.showNotification(text: "You don't have network connection now. Please check internetion connection and try again")
                    NSLog("saveReplyBot Error")
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }
}
