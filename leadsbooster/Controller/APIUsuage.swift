////
////  ChangePasswordVC.swift
////  Alaitisal
////
////  Created by JinMing on 8/6/19.
////  Copyright © 2019 JN. All rights reserved.
////
//
//import UIKit
//import RxSwift
//import Alamofire
//import SwiftyJSON
//import CoreLocation
//
//class EditProfileVC: BaseVC, CommonActionsVCProtocol, CLLocationManagerDelegate {
//
//
//    var userImageUpdateHandler:(()->Void)?
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        title = L10n.editProfile()
//        getUserData()
//    }
//
//    override func initUI() {
//    }
//
//    func refreshItems(_ response:LoginResponse) {
//    }
//
//    func loadCountryData() {
//
//        let hud = activityHUD(L10n.loading())
//        countryPicker.text = L10n.country()
//        apiService.getCountryList()
//            .subscribe{[weak self] evt in
//                guard let _self = self else { return }
//                hud.hide(true)
//                switch(evt){
//                case let .next(response):
//                    _self.countryItems = response
//
//                    _self.countryNames = (self?.countryItems.map{$0.country})!
//                    _self.countryNames.insert(L10n.country(), at: 0)
//                    _self.countryPicker.pickerDataSource = _self.countryNames
//
//                    let item = response.first(where:{$0.id == _self.selCountryId})
//                    self?.countryPicker.text = item?.country
//
//                default:
//                    break
//                }
//            }.disposed(by: self.disposeBag)
//    }
//
//    func loadCityData() {
//
//        let hud = activityHUD(L10n.loading())
//        self.cityPicker.text = L10n.city()
//        apiService.getCityList(selCountryId)
//            .subscribe{[weak self] evt in
//
//                hud.hide(true)
//
//                guard let _self = self else { return }
//
//                switch(evt){
//                case let .next(response):
//                    _self.cityItems = response
//
//                    _self.cityNames = _self.cityItems.map{$0.city_name}
//                    _self.cityNames.insert(L10n.city(), at: 0)
//                    _self.cityPicker.pickerDataSource = _self.cityNames
//
//                    let item = response.first(where:{$0.city_id == _self.selCityId})
//                    if item != nil && item?.city_id != "0" {
//                        _self.cityPicker.text = item?.city_name
//                    }
//                default:
//                    break
//                }
//            }.disposed(by: self.disposeBag)
//    }
//
//    func uploadUserImage(_ image:UIImage) {
//
//        let hud = activityHUD(L10n.pleaseWait())
//        let headers: HTTPHeaders = [
//            "Content-type": "multipart/form-data"
//        ]// getting data from local path
//
//        let data = (image.jpegData(compressionQuality: JPG_ZIP_QUALITY))!
//
//        let uploadUrl = kApiUploadUserRegisterImage + "&u_id=" + AppSettings.userId
//        let URL = try! URLRequest(url: uploadUrl, method: .post, headers: headers)
//
//            Alamofire.upload(multipartFormData: { (multipartFormData) in
//                multipartFormData.append(data, withName: "uploaded_file", fileName: "file.jpg", mimeType: "image/jpg")
//
//            }, with: URL, encodingCompletion: { result in
//
//                switch result {
//                case .success(let upload, _, _):
//                    hud.hide(true)
//                    upload.responseJSON { response in
//
//                        guard response.result.isSuccess, let value = response.result.value else {
//                            print("Error while uploading file: \(String(describing: response.result.error))")
//                            return
//                        }
//
//                        let json = JSON(value)
//                        let status = json["status"].stringValue
//                        let message = json["message"].stringValue
//                        if status == "0" {
//                            let data = json["data"]
//                            let newImgUrl = data["u_img"].stringValue
//
//                            if !newImgUrl.contains(find: "no_img.png") {
//                                AppSettings.userImgUrl = newImgUrl
//                                self.userImageButton.setImage(image, for: .normal)
//                                self.userImageUpdateHandler?()
//                            }
//                        } else if message.isNotEmpty {
//                            self.showNotification(text: message)
//                        }
//                    }
//
//                case .failure( _):
//                    self.showNotification(errorMessage: L10n.pleaseUploadAtLeast())
//                }
//
//            })
//
//    }
//
//    func verifyDialog(_ type:String) {
//        var msgString = L10n.doYouWantToVerifyYourPhone()
//
//        if type == VERIFY_TYPE_EMAIL {
//            msgString = L10n.doYouWantToVerifyYourEmail()
//        }
//        let alert = UIAlertController.alert(title: L10n.confirmation(), message: msgString, cancelTitle: L10n.later(),otherTitles: [L10n.verifyNow()]) {[weak self] result in
//
//            guard let _self = self else { return }
//
//            if case .default = result.style {
//                let vc = StoryboardScene.Landing.verification.instantiate()
//
//                if type == VERIFY_TYPE_PHONE {
//                    vc.extraPhone = _self.countryCodePicker.text! + _self.contactNoField.text!
//                } else {
//                    vc.extraEmail = _self.emailField.text!
//                }
//                vc.verificationSuccessHandler = {[weak self] in
//                    gotoBackPage(topVC: vc)
//                    self?.getUserData()
//                }
//                _self.show(vc, sender: nil)
//            }
//        }
//        present(alert, animated: true)
//    }
//
//    @IBAction func onContactNoVerify(_ sender: Any) {
//        if contactNoVerifiedLabel.text == L10n.notVerified() {
//            verifyDialog(VERIFY_TYPE_PHONE)
//        }
//    }
//
//    @IBAction func onEmailVerify(_ sender: Any) {
//        if emailVerifiedLabel.text == L10n.notVerified() {
//            verifyDialog(VERIFY_TYPE_EMAIL)
//        }
//    }
//
//    @IBAction func onPickerUserImage(_ sender: Any) {
//
//        let mediaPicker = ImagePickerControllerWrapper(config: .default)
//
//        let imageOb:Observable<UIImage> = self.rx.actionSheet(
//            cancelTitle: L10n.cancel(),
//            otherTitles: [L10n.cameraRollImage(), L10n.takePhoto()],
//            popoverConfig: PopoverConfig(source: .view(self.view)))
//            .map{ style, index -> MediaPickerType? in
//                guard case .default = style else { return nil }
//                return (index == 0) ? .cameraRollImage : .takePhoto
//            }.filterNil()
//            .flatMapLatest{[weak self] type -> Observable<PickedMedia?> in
//                guard let _self = self else { return Observable.empty() }
//                return mediaPicker.rx.pick(from: _self, type: type)
//            }.map {
//                $0?.image}
//            .filterNil()
//
//        imageOb.subscribe(
//            onNext: {[weak self] image in
//                guard let _self = self else {return}
//                //_self.userImageButton.setImage(image, for: .normal)
//                _self.uploadUserImage(image)
//
//        }).disposed(by: self.disposeBag)
//    }
//
//    func getUserData() {
//        guard hasConnectivity() else {
//            showNotification(errorMessage: L10n.pleaseCheckYourInternetConnection())
//            return
//        }
//
//        let hud = activityHUD()
//        apiService.getUserProfile(self)
//            .subscribe{[weak self] evt in
//                guard let _self = self else { return }
//                hud.hide(true)
//                switch evt {
//                case let .next(response):
//                    if response.status == "0" {
//                        _self.refreshItems(response)
//                    }
//                default:
//                    break
//                }
//            }.disposed(by: disposeBag)
//    }
//
//    @IBAction func onUpdate(_ sender: Any) {
//        let firstName = firstNameField.text!
//        let lastName = lastNameField.text!
//        let contactNo = contactNoField.text!
//        let email = emailField.text!
//        let countryName = countryPicker.text!
//        let cityName = cityPicker.text!
//        let location = locationField.text!
//        var gender = "M"
//        if genderSelector.selectedSegmentIndex == 1 {
//            gender = "F"
//        }
//
//        guard firstName.isNotEmpty else {
//            showNotification(errorMessage: L10n.firstNameIsRequired())
//            firstNameField.becomeFirstResponder()
//            return
//        }
//
//        guard lastName.isNotEmpty else {
//            showNotification(errorMessage: L10n.lastNameIsRequired())
//            lastNameField.becomeFirstResponder()
//            return
//        }
//
//        guard email.isNotEmpty else {
//            showNotification(errorMessage: L10n.emailRequired())
//            emailField.becomeFirstResponder()
//            return
//        }
//
//        if countryCodePicker.text!.isEmpty {
//            showNotification(errorMessage: L10n.countryCodeIsRequired())
//            countryCodePicker.becomeFirstResponder()
//            return
//        }
//
//        if contactNoField.text!.isEmpty {
//            showNotification(errorMessage: L10n.contactNoIsRequired())
//            contactNoField.becomeFirstResponder()
//            return
//        }
//
//        guard location.isNotEmpty else {
//            return
//        }
//
//        var countryId = "0"
//        if countryName != L10n.country() {
//            let item = countryItems.first(where:{$0.country == countryName})
//            countryId = item!.id
//        }
//
//        var cityId = "0"
//        if cityName != L10n.city() {
//            let item = cityItems.first(where:{$0.city_name == cityName})
//            cityId = item!.city_id
//        }
//
//        let params:[String:Any] = [
//            "action" : kActionUserProfile,
//            "mr_device_token" : DEVICE_TOKEN,
//            "u_id" : AppSettings.userId,
//            "u_address" : location,
//            "u_email" : email,
//            "u_first_name" : firstName,
//            "u_last_name" : lastName,
//            "u_city" : cityId,
//            "u_phone" : AppSettings.userPhone,
//            "u_postcode" : AppSettings.userPostCode,
//            "u_country" : countryId,
//            "u_is_notification_sound" : AppSettings.userIsNotificationSound,
//            "u_latitute" : AppSettings.userLatitute,
//            "u_longitute" : AppSettings.userLongitute,
//            "u_gender" : gender,
//            "lang" : AppSettings.language.rawValue,
//            "emailChange" : email.elementsEqual(AppSettings.userEmail) ? "0" : "1",
//            "phoneChange" : contactNo.elementsEqual(AppSettings.userPhone) ? "0" : "1",
//            "u_country_code" : countryCodePicker.text!,
//            "u_type" : (AppSettings.userType == .buyer) ? "1" : "2"
//        ]
//
//        let hud = activityHUD(L10n.pleaseWait())
//        apiService.updateUserProfile(params, self)
//            .subscribe{[weak self] evt in
//
//                hud.hide(true)
//                self?.navigationController?.popViewController(animated: true)
//                self?.dismiss(animated: true, completion: nil)
//
//                switch(evt){
//                case let .next(response):
//                    AppSettings.userFirstName = response.u_first_name
//                    AppSettings.userLastName = response.u_last_name
//                    AppSettings.userName = response.u_first_name + " " + AppSettings.userLastName
//                    AppSettings.userEmail = response.u_email
//                    AppSettings.userAddr = response.u_address
//                    AppSettings.userCountry = response.u_country
//                    AppSettings.userCity = response.u_city
//                    AppSettings.userGender = response.u_gender
//                    AppSettings.userLatitute = response.u_latitute
//                    AppSettings.userLongitute = response.u_longitute
//                    break
//                default:
//                    break
//                }
//            }.disposed(by: self.disposeBag)
//
//
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let userLocation :CLLocation = locations[0] as CLLocation
//
//        u_latitute = String(userLocation.coordinate.latitude)
//        u_longitute = String(userLocation.coordinate.longitude)
//    }
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("Error \(error)")
//    }
//}
//
//extension EditProfileVC: UITextFieldDelegate, PickerTextFieldDelegate {
//    func pickerTextField(_ pickerField: PickerTextField, didSelectedRow selectedRow: Int, selectedValue value: String) {
//
//    }
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        return false
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        if textField == countryPicker {
//            let item = countryItems.first(where:{$0.country == textField.text})
//            if item != nil {
//                selCountryId = item!.id
//                selCityId = "0"
//                loadCityData()
//            }
//        }
//        return true
//    }
//}
