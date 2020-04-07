//
//  MembershipVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/20.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import Stripe

class MembershipVC: BaseVC {
    
    @IBOutlet weak var cardInputView: UIView!
    @IBOutlet weak var upgradeTitle: UILabel!
    @IBOutlet weak var upgradeAccount: UILabel!
    
    @IBOutlet weak var newPlanLabel: UILabel!
    @IBOutlet weak var validationDate: UILabel!
    @IBOutlet weak var newPlanBudget: UILabel!
    @IBOutlet weak var checkAmount: UILabel!
    
    @IBOutlet weak var annuallyRadio: UIButton!
    @IBOutlet weak var monthlyRadio: UIButton!
    
    let cardField = STPPaymentCardTextField()
    var theme = STPTheme.default()
    var membershipInfo: MembershipInfo?
    
    var userInfo: UserInfo?
    var payType = 1
    var amount = 0.0
    var agent_count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Membership"
        self.ext.setBackShapedDismissButton().action = #selector(onBack)

        // Do any additional setup after loading the view.
        cardInputView.addSubview(cardField)
        cardField.rightAnchor.constraint(equalTo: cardInputView.rightAnchor, constant: 0).isActive = true
        cardField.leftAnchor.constraint(equalTo: cardInputView.leftAnchor, constant: 0).isActive = true
        cardField.topAnchor.constraint(equalTo: cardInputView.topAnchor, constant: 0).isActive = true
        cardField.bottomAnchor.constraint(equalTo: cardInputView.bottomAnchor, constant: 0).isActive = true
        cardField.backgroundColor = theme.secondaryBackgroundColor
        cardField.textColor = theme.primaryForegroundColor
        cardField.placeholderColor = theme.secondaryForegroundColor
        cardField.borderColor = theme.accentColor
        cardField.borderWidth = 1.0
        cardField.textErrorColor = theme.errorColor
        cardField.postalCodeEntryEnabled = true
        cardInputView.layoutIfNeeded()
        
        initData()
    }
    
    @objc func onBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func initData() {
        membershipInfo = MembershipInfo(json: parse(string: AppSettings.string(kUserMemberShip)))
        userInfo = UserInfo(json: parse(string: AppSettings.string(kUserInfo)))
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let padding: CGFloat = 0
        cardField.frame = CGRect(x: padding, y: padding, width: cardInputView.bounds.width, height: cardInputView.bounds.height)
    }
    
    @IBAction func onMonthly(_ sender: Any) {
        payType = 1
        monthlyRadio.setImage(UIImage(named: "radio_selected"), for: .normal)
        annuallyRadio.setImage(UIImage(named: "radio_normal"), for: .normal)
        self.updateUI()
    }
    
    @IBAction func onAnnually(_ sender: Any) {
        payType = 0
        annuallyRadio.setImage(UIImage(named: "radio_selected"), for: .normal)
        monthlyRadio.setImage(UIImage(named: "radio_normal"), for: .normal)
        self.updateUI()
    }
    
    @IBAction func onContinue(_ sender: Any) {
        let cardParams = STPCardParams()
        cardParams.number = cardField.cardNumber
        cardParams.expMonth = cardField.expirationMonth
        cardParams.expYear = cardField.expirationYear
        cardParams.cvc = cardField.cvc
        if cardField.isValid {
            let hud = activityHUD()
            STPAPIClient.shared().createToken(withCard: cardParams) { [weak self] (token: STPToken?, error: Error?) in
                guard let _self = self else {
                    hud.hide(true)
                    return
                }
                guard let token = token, error == nil else {
                    hud.hide(true)
                    return
                }
                
                var params:[String: String] = [:]
                params["stripeToken"] = token.tokenId
                params["token"] = AppSettings.string(kUserToken)
                params["plan"] = "Starter"
                params["plan_type"] = _self.payType == 0 ? "annual" : "monthly"
                params["agent_count"] = String(_self.agent_count)
                params["stripe_type"] = "live"
                apiService.doPayWithCard(params: params)
                    .subscribe {[weak self] evt in
                        switch evt {
                        case let .next(response):
                            if response.result == 1 {
                                _self.refreshMembership()
                                _self.showNotification(text: kSuccess)
                            }
                            else {
                                
                            }
                            break
                        case .error:
                            break
                        default:
                            hud.hide(true)
                            break
                        }
                }.disposed(by: _self.disposeBag)
            }
            
        } else {
            self.showNotification(text: "Input Correct Card")
        }
    }
    
    func loadData() {
        upgradeTitle.text = "Upgrade to Regular Plan"
        upgradeAccount.text = "Upgrade account : " + (userInfo?.email ?? "")
        newPlanLabel.text = "Regular Plan"
        self.updateUI()
    }
    
    func updateUI() {
        var totalAmount = 0.0
        if payType == 1 {
            let date = Date()
            let validation = Calendar.current.date(byAdding: Calendar.Component.month, value: 1, to: date)
            validationDate.text = validation?.toDateString(format: "YYYY-M-D")
            totalAmount = 21
        }
        else {
            let date = Date()
            let validation = Calendar.current.date(byAdding: Calendar.Component.year, value: 1, to: date)
            validationDate.text = validation?.toDateString(format: "YYYY-M-D")
            totalAmount = 216
        }
        newPlanBudget.text = totalAmount.moneyString
        amount = totalAmount
        checkAmount.text = amount.moneyString
    }
    
    
    func refreshMembership () {
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
}
