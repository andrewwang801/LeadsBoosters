//
//  MenuVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/20.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import IBAnimatable
import RxSwift
import SCLAlertView

class MenuVC: UITableViewController, Router {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var membershipLabel: UILabel!
    @IBOutlet weak var validataionDateLabel: UILabel!
    @IBOutlet weak var upgradeBtn: AnimatableButton!
    @IBOutlet weak var customReplyCell: UITableViewCell!
    
    enum TableRow {
        case cm, inquiry, noresp, defaultBot, customBot, facebook, wordpress, third, profile, logout, other
        
        init?(row: Int) {
            switch row {
            case 1:
                self = .cm
            case 3:
                self = .inquiry
            case 4:
                self = .noresp
            case 6:
                self = .defaultBot
            case 7:
                self = .customBot
            case 8:
                self = .facebook
            case 9:
                self = .wordpress
            case 10:
                self = .third
            case 11:
                self = .profile
            case 12:
                self = .logout
            default:
                return nil
            }
        }
    }
    
    let disposeBag = DisposeBag()
    var authorization = "sandbox_csghsc53_vmw2wzf63xpf5bc3"
    var userInfo: UserInfo?
    var membershipInfo: MembershipInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let memberTapGesture = UITapGestureRecognizer(target: self, action: #selector(onMembership))
        membershipLabel.addGestureRecognizer(memberTapGesture)
        let validateTapGesture = UITapGestureRecognizer(target: self, action: #selector(onMembership))
        validataionDateLabel.addGestureRecognizer(validateTapGesture)
        loadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        refreshMembership()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        deselectRow()
    }
    
    @objc func onMembership() {
        gotoMembership()
    }
    
    @IBAction func onUpgrade(_ sender: Any) {
        gotoMembership()
    }
    
    func _refreshMembership () {
        let hud = activityHUD()
        var params: [String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        apiService.doGetMembership(params: params)
            .subscribe {[weak self] evt in
                guard let _self = self else {return}
                switch evt {
                case let .next(response):
                    if response.result == 1 {

                        NSLog("doGetMembership(MenuVC) Response 0")
                        
                        _self.membershipInfo = response.data
                        if let _membershipInfo = _self.membershipInfo {
                            AppSettings.set(_membershipInfo.toString(), forKey: kUserMemberShip)
                            AppSettings.shared.membershipInfo = _membershipInfo
                            
                            _self.membershipLabel.text = _membershipInfo.plans
                            _self.validataionDateLabel.text = _membershipInfo.end_date
                            if _membershipInfo.expired {
                                _self.validataionDateLabel.textColor = .red
                            }
                            else {
                                _self.validataionDateLabel.textColor = .white
                            }
                            if _membershipInfo.plans == "free" || _membershipInfo.expired {
                                _self.upgradeBtn.isHidden = false
                            }
                            else {
                                _self.upgradeBtn.isHidden = true
                            }
                            if !_membershipInfo.expired {
                                _self.customReplyCell.isHidden = false
                                _self.customReplyCell.heightAnchor.constraint(equalToConstant: 43.5).isActive = true
                            }
                            else {
                                _self.customReplyCell.isHidden = true
                                _self.customReplyCell.heightAnchor.constraint(equalToConstant: 0).isActive = true
                            }
                        }
                    }
                    
                    break
                case .error:
                    NSLog("doGetMembership(MenuVC) Response Error")
                    break
                default:
                    hud.hide(true)
                    break
                }
        }.disposed(by: disposeBag)
    }
    
    func refreshMembership() {
        membershipInfo = MembershipInfo(json: parse(string: AppSettings.string(kUserMemberShip)))
        if let _membershipInfo = membershipInfo {
            
            membershipLabel.text = _membershipInfo.plans
            validataionDateLabel.text = _membershipInfo.end_date
            if _membershipInfo.expired {
                validataionDateLabel.textColor = .red
            }
            else {
                validataionDateLabel.textColor = .white
            }
            if _membershipInfo.plans == "free" || _membershipInfo.expired {
                upgradeBtn.isHidden = false
            }
            else {
                upgradeBtn.isHidden = true
            }
            if !_membershipInfo.expired {
                customReplyCell.isHidden = false
                customReplyCell.heightAnchor.constraint(equalToConstant: 43.5).isActive = true
            }
            else {
                customReplyCell.isHidden = true
                customReplyCell.heightAnchor.constraint(equalToConstant: 0).isActive = true
            }
        }
    }
    
    func loadData() {
        userInfo = UserInfo(json: parse(string: AppSettings.string(kUserInfo)))
        userNameLabel.text = userInfo?.username ?? ""
        membershipInfo = MembershipInfo(json: parse(string: AppSettings.string(kUserMemberShip)))
        guard let membershipInfo = membershipInfo else { return }
        membershipLabel.text = membershipInfo.plans
        validataionDateLabel.text = membershipInfo.end_date
        if !(membershipInfo.plans == "free") && !membershipInfo.expired {
            customReplyCell.isHidden = false
            customReplyCell.heightAnchor.constraint(equalToConstant: 43.5).isActive = true
        }
        else {
            customReplyCell.isHidden = true
            customReplyCell.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
        if membershipInfo.expired {
            validataionDateLabel.textColor = .red
        }
        else {
            validataionDateLabel.textColor = .white
        }
        if membershipInfo.plans == "free" || membershipInfo.expired {
            upgradeBtn.isHidden = false
        }
        else {
            upgradeBtn.isHidden = true
        }
    }
}

extension MenuVC {
    
    func deselectRow() {
        if let indexPath: IndexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menu = TableRow(row: indexPath.row) else {return}
        switch menu {
        case .cm:
            gotoDashboard()
            break
        case .inquiry:
            gotoInquiry()
            break
        case .noresp:
            gotoNoResponse()
            break
        case .defaultBot:
            gotoAutoReplyBot()
            break
        case .customBot:
            gotoCustomReply()
            break
        case .facebook:
            gotoFacebookLeads()
            break
        case .wordpress:
            gotoWordpressLeads()
            break
        case .third:
            gotoThird()
            break
        case .profile:
            gotoProfile()
            break
        case .logout:
            doLogout()
            break
        default:
            break
        }
    }
    
    func doLogout() {
        let alertView = SCLAlertView()
        alertView.addButton("Yes", action: {
            let hud = self.activityHUD()
            var params:[String: String] = [:]
            params["token"] = AppSettings.string(kUserToken)
            apiService.doLogout(params: params)
                .subscribe {[weak self] evt in
                    guard let _self = self else {return}
                    switch evt{
                    case let .next(response):
                        hud.hide(true)
                        AppSettings.set("", forKey: kUserToken)
                        _self.gotoTutorial()
                        break
                    case .error:
                        hud.hide(true)
                        AppSettings.set("", forKey: kUserToken)
                        _self.gotoTutorial()
                        break
                    default:
                        break
                    }
            }.disposed(by: self.disposeBag)
        })
        alertView.addButton("No", action: {
            return
        })
        alertView.showWarning("Logout", subTitle: "Do you want to logout now?")
    }
}
