//
//  SingleMembershipInfo.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/19.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import Stripe

class SingleMembershipInfo: BaseVC {

    @IBOutlet weak var depositAmount: UITextField!
    @IBOutlet weak var upgradeAccount: UILabel!
    @IBOutlet weak var cardInputView: UIView!
    
    let cardField = STPPaymentCardTextField()
    var theme = STPTheme.default()
    var membershipInfo: MembershipInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "SingleMembership"
        self.ext.setBackShapedDismissButton().action = #selector(onBack)

        // Do any additional setup after loading the view.
        cardInputView.addSubview(cardField)
        cardField.backgroundColor = theme.secondaryBackgroundColor
        cardField.textColor = theme.primaryForegroundColor
        cardField.placeholderColor = theme.secondaryForegroundColor
        cardField.borderColor = theme.accentColor
        cardField.borderWidth = 1.0
        cardField.textErrorColor = theme.errorColor
        cardField.postalCodeEntryEnabled = true
        
        //init membership
        membershipInfo = MembershipInfo(json: parse(string: AppSettings.string(kUserMemberShip)))
    }
    @objc func onBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let padding: CGFloat = 0
        cardField.frame = CGRect(x: padding, y: padding, width: cardInputView.bounds.width, height: cardInputView.bounds.height)
    }
    
    @IBAction func onContinue(_ sender: Any) {
        let depositAmountStr = depositAmount.text ?? ""
        if depositAmountStr.isEmpty {
            showNotification(text: "Please input Deposit Amount")
        }
        
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
                    params["pay_amount"] = depositAmountStr
                    params["stripe_type"] = "live"
                    apiService.doPayWithCard(params: params)
                     .subscribe {[weak self] evt in
                        guard let _self = self else {return}
                         switch evt {
                         case let .next(response):
                             if response.result == 1 {
                                _self.showNotification(text: kSuccess)
                                _self._refreshMembership()
                             }
                             else {
                                _self.showNotification(text: "Declined Payment!")
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
        }
        else {
            self.showNotification(text: "Input Correct Card")
        }
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
