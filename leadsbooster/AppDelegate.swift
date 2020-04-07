//
//  AppDelegate.swift
//  Alaitisal
//
//  Created by Alex on 2019/7/13.
//  Copyright © 2019 JN. All rights reserved.
//

import UIKit
import CRToast
import DropDown
import RxSwift
import Stripe
import SCLAlertView
import FBSDKCoreKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    /*func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //UIView.appearance().semanticContentAttribute = .forceRightToLeft
        setupTheme()
        
        BTAppSwitch.setReturnURLScheme("com.your-company.Your-App.payments")
        //ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }*/

    let disposeBag = DisposeBag()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupTheme()
        STPPaymentConfiguration.shared().publishableKey = "pk_live_8B5PzbfCUxPW0Efcy3UfozW3006D1iFP95"
        DropDown.startListeningToKeyboard()
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions,completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        
        if isServiceAvailable() {
            gotoNextVC()
        }
        else {
            DispatchQueue.main.async {
                self.showAlert()
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return true
    }
    
    var window: UIWindow?
    
    var restrictRotation:UIInterfaceOrientationMask = .portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask
    {
        return self.restrictRotation
    }
    

    // If you support iOS 8, add the following method.
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        return ApplicationDelegate.shared.application(application, open: url as URL, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)
    }


}

extension AppDelegate {
    func setupTheme(){
        UIApplication.shared.statusBarStyle = .lightContent
        
        UINavigationBar.appearance().barTintColor = UIColor(named: "incoming")
        UINavigationBar.appearance().tintColor = UIColor(named: "incoming")
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        UITabBar.appearance().barTintColor = UIColor(named: "incoming")
        UITabBar.appearance().tintColor = UIColor(named: "incoming")
        
        CRToastManager.setDefaultOptions(CRToastManager.defaultOptions)
    }
}

extension CRToastManager{
    /// Default option for secure tribe.
    class var defaultOptions:[AnyHashable:Any]{
        return [
            kCRToastTimeIntervalKey:2.5,    // should show for 2.5 seconds
            kCRToastUnderStatusBarKey:true, // Should not override status bar.
            kCRToastKeepNavigationBarBorderKey:false,
            kCRToastNotificationPresentationTypeKey:CRToastPresentationType.cover.rawValue,
            kCRToastNotificationTypeKey:CRToastType.navigationBar.rawValue,
            kCRToastImageAlignmentKey:CRToastAccessoryViewAlignment.left.rawValue,
            kCRToastInteractionRespondersKey:[CRToastInteractionResponder(interactionType: [.tap], automaticallyDismiss: true, block: nil) as AnyObject],    // Tap to dismiss (Convert to AnyObject is super, super important or app will crash due to silly behaviour of swift beta 3)
            kCRToastAnimationInDirectionKey:CRToastAnimationDirection.top.rawValue,     // Should appear from top
            kCRToastAnimationOutDirectionKey:CRToastAnimationDirection.top.rawValue,    // Should disappear to top
            kCRToastAnimationInTypeKey:CRToastAnimationType.gravity.rawValue,           // When appearing, should gravity
            kCRToastAnimationOutTypeKey:CRToastAnimationType.linear.rawValue,           // Linear
            kCRToastTextAlignmentKey:NSTextAlignment.left.rawValue,
            kCRToastSubtitleTextAlignmentKey:NSTextAlignment.left.rawValue,
            
            // Font
            kCRToastFontKey:UIFont.systemFont(ofSize: 14)
        ]
    }
}

extension AppDelegate {
    
    func showAlert() {
        let alertController = UIAlertController(title: "", message: "You have not installed Whatsapp or your device can not connect Whatsapp Service. Please confirm it and try again.", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                UIAlertAction in
                exit(0)
            }
        alertController.addAction(okAction)
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func appInstalledOrNot(appName: String) -> Bool {
        let appScheme = "\(appName)://app"
        let appUrl = URL(string: appScheme)
        
        if UIApplication.shared.canOpenURL(appUrl! as URL)
        {
            return true
        }
        else {
            return false
        }
    }
    
    func isConnectedServer(urlStr: String, timeOut: Int) -> Bool {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)
        let url = URL(string: urlStr)!
        let (_ , _, error) = session.synchronousDataTask(with: url)
        if error != nil {
            return false
        }
        return true
    }
    
    func isNetworkConnected() -> Bool {
        return hasConnectivity()
    }
    
    func isServiceAvailable() -> Bool {
        let installed = appInstalledOrNot(appName: "whatsapp")
        if !installed {
            return false
        }
        if !isNetworkConnected() {
            return false
        }
        if !isConnectedServer(urlStr: "https://www.whatsapp.com", timeOut: 1000 * 10) {
            return false
        }
        return true
    }
    
    func gotoNextVC() {
        if !AppSettings.string(kUserToken).isEmpty {

            var params: [String: String] = [:]
            params["token"] = AppSettings.string(kUserToken)
            apiService.doCheckToken(params: params)
                .subscribe {[weak self] evt in
                    guard let _self = self else {return}
                    switch evt {
                    case let .next(response):
                        if response.result == 1 {
                            _self.gotoDashboard()
                        }
                        else {
                            ///gotoLogin
                            _self.gotoLogin()
                        }
                        break
                    case .error:
                        ///gotoLogin
                        _self.gotoLogin()
                        break
                    default:
                        break
                    }
            }.disposed(by: disposeBag)
        }
        else {
            self.gotoTutorial()
        }
    }
    
    func gotoTutorial() {
        let _vcRoot = BHStoryboard.Main.tutorialVC.instantiate()
        let _vcNav = UINavigationController(rootViewController: _vcRoot)

        _vcNav.interactivePopGestureRecognizer?.isEnabled = true
        _vcNav.interactivePopGestureRecognizer?.delegate = nil
        
        self.window?.rootViewController = _vcNav
        self.window?.makeKeyAndVisible()
    }
    
    func gotoDashboard() {
        let _vcRoot = BHStoryboard.WhatsCrm.dashboardVC.instantiate()
        let _vcNav = UINavigationController(rootViewController: _vcRoot)

        _vcNav.interactivePopGestureRecognizer?.isEnabled = true
        _vcNav.interactivePopGestureRecognizer?.delegate = nil

        let menuVC = BHStoryboard.Menu.menuVC.instantiate()
        let menuNavController = UINavigationController(rootViewController: menuVC)

        let mainRevealController:SWRevealViewController = SWRevealViewController(rearViewController: menuNavController, frontViewController: _vcNav)
        UIApplication.shared.keyWindow?.rootViewController = mainRevealController
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
    
    func gotoLogin() {
        
        let _vcRoot = BHStoryboard.Main.loginVC.instantiate()
        let _vcNav = UINavigationController(rootViewController: _vcRoot)

        _vcNav.interactivePopGestureRecognizer?.isEnabled = true
        _vcNav.interactivePopGestureRecognizer?.delegate = nil
        UIApplication.shared.keyWindow?.rootViewController = _vcNav
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
}

extension URLSession {
    func synchronousDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: url) {
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        }
        dataTask.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return (data, response, error)
    }
}

extension AppDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("\(#function)")
        completionHandler([.alert, .badge, .sound])
    }
}
extension AppDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}
