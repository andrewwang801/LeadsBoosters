//
//  TutorialVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/2/29.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import DropDown
import SCLAlertView
import AVKit

class TutorialVC: BaseVC {
    
    @IBOutlet var countryCode: UIView!
    @IBOutlet var countryFlag: UIImageView!
    @IBOutlet var countryCodeLabel: UILabel!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var phoneNumberTextField: UITextField!
    @IBOutlet weak var videoView: UIView!
    
    let dropDown = DropDown()
    var player: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    
    // MARK: view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onCountryCode))
        self.countryCode.addGestureRecognizer(gesture)
        
        phoneNumberTextField.addTarget(self, action: #selector(onPhoneNumberChange), for: .editingChanged)
        initVideo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(true)
         navigationController?.setNavigationBarHidden(true, animated: animated)
     }
     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(true)
         //navigationController?.setNavigationBarHidden(false, animated: animated)
     }
    
    func initVideo() {
        let videoURL = URL(string: "https://leadsboosters.com/intro.mp4")
        player = AVPlayer(url: videoURL!)
        let videoPlayer = AVPlayerViewController()
        self.addChild(videoPlayer)
        videoPlayer.player = player
        videoPlayer.view.frame = videoView.bounds
        videoView.addSubview(videoPlayer.view)
        videoPlayer.didMove(toParent: self)
        videoPlayer.player!.play()
    }
    
    // MARK: IBACtions
    @IBAction func doSignup(_ sender: Any) {
        gotoSignup()
    }
    
    @IBAction func doSignin(_ sender: Any) {
        gotoSignin()
    }
    
    @IBAction func onNext(_ sender: Any) {
        if hasConnectivity() == false {
            showNotification(text: "You don't have netework connectin now. Please check internet and try again.")
            return
        }
        
        let strPhoneNumber = (countryCodeLabel.text ?? "") + (phoneNumberTextField.text ?? "")
        let strUserName = usernameTextField.text ?? ""
        var params: [String: Any] = [:]
        params["phone_number"] = strPhoneNumber
        params["name"] = strUserName
        
        if isValidPhoneNumber(phoneNumber: strPhoneNumber) {
            let hud = activityHUD("Please waiting...")

            apiService.sendDemo(params: params)
                .subscribe{ [weak self] evt in
                    
                    switch(evt) {
                    case let .next(response):
                        if response.result == 1 {
                            SCLAlertView().showInfo("Success", subTitle: "We have sent Whatsapp to your mobile")
                        }
                        else {
                            SCLAlertView().showError("Falied", subTitle: response.message)
                        }
                        hud.hide(true)
                        break
                    case .error:
                        hud.hide(true)
                        SCLAlertView().showError("Login Falied", subTitle: "Login Filed. Please try again later")
                        break
                    default:
                        hud.hide(true)
                        break
                    }
            }.disposed(by: disposeBag)
        }
        else {
            showNotification(text: "Invalid Phone Number.")
        }
    }
    
    @objc func onCountryCode(sender:UITapGestureRecognizer) {
        setupDropDown()
        dropDown.show()
    }
    
    @objc func onPhoneNumberChange(sender: UITextField) {
        
        let strPhoneNumber = phoneNumberTextField.text ?? ""
        if isValidPhoneNumber(phoneNumber: strPhoneNumber) {
        }
        else{
        }
    }
    
    func setupDropDown() {
        //set dropdown
        dropDown.anchorView = countryCode
        dropDown.dataSource = kFlagValues
        dropDown.cellNib = UINib(nibName: "CountryCodeCell", bundle: nil)
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
           guard let cell = cell as? CountryCodeCell else { return }

           // Setup your custom UI components
            cell.countryFlag.image = UIImage(named: "flag_" + kFlagSuffix[index])
        }
        dropDown.selectionAction = {[unowned self] (index: Int, item: String) in
            self.countryFlag.image = UIImage(named: "flag_" + kFlagSuffix[index])
            self.countryCodeLabel.text = item
        }
    }
}
