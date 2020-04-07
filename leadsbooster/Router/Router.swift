//
//  CommonActions.swift
//  Alaitisal
//
//  Created by Alex on 2019/7/23.
//  Copyright © 2019 JN. All rights reserved.
//

import Foundation
import UIKit

protocol Router {}

extension Router where Self: UIViewController {
    private func _showNavigationVCReturn<ViewController>(_ scene: SceneType<ViewController>) -> ViewController {
        let vc = scene.instantiate()
        let ctrl = UINavigationController(rootViewController: vc as! UIViewController)
        ctrl.modalPresentationStyle = .fullScreen
        present(ctrl, animated: true)
        return vc
    }
    
    private func _showNavigationVC<ViewController>(_ scene: SceneType<ViewController>){
        let vc = scene.instantiate()
        let ctrl = UINavigationController(rootViewController: vc as! UIViewController)
        ctrl.modalPresentationStyle = .fullScreen
        present(ctrl, animated: true)
    }
    
    private func _showRevealVC<ViewController>(_ scene: SceneType<ViewController>) {
        let _vcRoot = scene.instantiate()
        let _vcNav = UINavigationController(rootViewController: _vcRoot as! UIViewController)

        _vcNav.interactivePopGestureRecognizer?.isEnabled = true
        _vcNav.interactivePopGestureRecognizer?.delegate = nil

        let menuVC = BHStoryboard.Menu.menuVC.instantiate()
        let menuNavController = UINavigationController(rootViewController: menuVC)

        let mainRevealController:SWRevealViewController = SWRevealViewController(rearViewController: menuNavController, frontViewController: _vcNav)
        UIApplication.shared.keyWindow?.rootViewController = mainRevealController
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
    
    func gotoSignup() {
        let vc = BHStoryboard.Main.signupVC
        _showNavigationVC(vc)
    }
    
    func gotoSignin() {
        let vc = BHStoryboard.Main.loginVC
        _showNavigationVC(vc)
    }
    
    func gotoVerificationCode(token: String) {
        let vc = BHStoryboard.Main.verificationCodeVC.instantiate()
        vc.token = token
        let ctrl = UINavigationController(rootViewController: vc)
        ctrl.modalPresentationStyle = .fullScreen
        present(ctrl, animated: true)
    }
    
    func gotoMembership() {
        if let _membership = AppSettings.shared.membershipInfo, _membership.plans == "Single" {
            _showNavigationVC(BHStoryboard.Membership.singleMembershipInfo)
        }
        else {
            _showNavigationVC(BHStoryboard.Membership.membershipVC)
        }
    }
    
    func gotoSingleMembership() {
        _showNavigationVC(BHStoryboard.Membership.singleMembershipInfo)
    }
    
    func gotoDashboard() {
        _showRevealVC(BHStoryboard.WhatsCrm.dashboardVC)
    }
    
    func gotoAutoReplyBot() {
        _showRevealVC(BHStoryboard.AutoReplyBot.autoReplyBotDefault)
    }
    
    func gotoAutoReplyBots() {
        _showNavigationVC(BHStoryboard.AutoReplyBot.autoReplyBot)
    }
    
    func gotoCustomReply() {
        _showRevealVC(BHStoryboard.AutoReplyBot.customReplyBot)
    }
    
    
    func gotoWordpressLeads() {
        _showRevealVC(BHStoryboard.Leads.wordpressLeadsVC)
    }
    
    func gotoFacebookLeads() {
        _showRevealVC(BHStoryboard.Leads.facebookLeadsSetupVC)
    }
    
    func gotoThird() {
        _showRevealVC(BHStoryboard.Leads.thirdPartyApiLeadsVC)
    }
    
    func gotoInquiry() {
        _showRevealVC(BHStoryboard.WhatsCrm.inquiryVC)
    }
    
    func gotoNoResponse() {
        _showRevealVC(BHStoryboard.WhatsCrm.noResponseVC)
    }
    
    func gotoTutorial() {
        let _vcRoot = BHStoryboard.Main.tutorialVC
        _showNavigationVC(_vcRoot)
    }
    
    func gotoAgentPhoneNumberSettingVC(param: [AgentInfo]) {
        let scene = BHStoryboard.WhatsCrm.agentPhoneNumberSettingsVC
        let vc = scene.instantiate()
        vc.agentInfoList = param
        let ctrl = UINavigationController(rootViewController: vc as! UIViewController)
        ctrl.modalPresentationStyle = .fullScreen
        present(ctrl, animated: true)
    }
    
    func gotoVisitCampaignSettings() {
        _showNavigationVC(BHStoryboard.AutoReplyBot.visitCampaignSettingsVC)
    }
    
    func gotoContactForm(contactInfo: ContactFormInfo) {
        let scene = BHStoryboard.Leads.visitContactFormInfoVC
        let vc = scene.instantiate()
        vc.contactFormInfo = contactInfo
        let ctrl = UINavigationController(rootViewController: vc as! UIViewController)
        ctrl.modalPresentationStyle = .fullScreen
        present(ctrl, animated: true)
    }
    
    func gotoProfile() {
        _showRevealVC(BHStoryboard.Leads.profileVC)
    }
    
    func gotoInbox(param: ChatRoom) {
        let scene = BHStoryboard.WhatsCrm.inboxVC
        let vc = scene.instantiate()
        vc.chatRoom = param
        let ctrl = UINavigationController(rootViewController: vc as! UIViewController)
        ctrl.modalPresentationStyle = .fullScreen
        present(ctrl, animated: true)
    }
}
