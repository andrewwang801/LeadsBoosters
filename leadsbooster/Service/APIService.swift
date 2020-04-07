////
////  APIService.swift
////  Alaitisal
////
////  Created by JinMing on 7/25/19.
////  Copyright © 2019 JN. All rights reserved.
////

import Foundation
import SwiftyJSON
import RxSwift
import Alamofire
import ObjectMapper

let apiService = APIService()


class APIService {
    
    fileprivate lazy var manager:Alamofire.SessionManager = {
        return Alamofire.SessionManager.default
    }()

    //signin
    func login(phoneNumber: String, password: String) -> Observable<LoginResponse> {
        let params: [String: Any] = [
            "phone_number": phoneNumber,
            "password": password
        ]
        
        return manager.rx.data(kAPIEndPoint + "doLogin/", .post, parameters: params)
            .map{ d -> LoginResponse in
                let json = JSON(d)
                //let response = LoginResponse(json: d)
                let response = LoginResponse(json: json)
                return response
        }
    }
    
    func genVerificationCode(phoneNumber: String) -> Observable<Int> {
        
        let params: [String:Any] = [
            "phone_number": phoneNumber
        ]
        
        return manager.rx.data(kAPIEndPoint + "doGenerateVerifyCode/", .post, parameters: params)
            .map{ d -> Int in
                let json = JSON(d)
                let response = json["result"].int ?? 0
                return response
        }
    }
    
    func sendVerificationCode(params: [String: Any]) -> Observable<Int> {
        
        return manager.rx.data(kAPIEndPoint + "doSendVerificationCode/", .get, parameters: params)
            .map{ d -> Int in
                let json = JSON(d)
                let response = json["result"].int ?? 0
                return response
        }
    }
    func verify(params: [String: Any]) -> Observable<BaseResponse> {
        
        return manager.rx.data(kAPIEndPoint + "doVerify/", .post, parameters: params)
            .map{ d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    //signup
    func getIndustries() -> Observable<IndustryResponse> {
        
        return manager.rx.data(kAPIEndPoint + "doGetIndustries/", .get)
            .map{ d -> IndustryResponse in
                let json = JSON(d)
                return IndustryResponse(data: json)
        }
    }
    
    func signUp(params: [String: Any]) -> Observable<SignupResponse> {
        return manager.rx.data(kAPIEndPoint + "doRegister/", .post, parameters: params)
            .map{ d -> SignupResponse in
                let json = JSON(d)
                let response = SignupResponse(json: json)
                return response
        }
    }
    
    //sendDemo
    func sendDemo(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doSendDemo/", .post, parameters: params)
            .map{ d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    //AutoReplyBot
    func getReplyBot(params: [String: Any]) -> Observable<ReplyBotResponse> {
        
        return manager.rx.data(kAPIEndPoint + "getReplyBot/", .post, parameters: params)
            .map { d -> ReplyBotResponse in
                let json = JSON(d)
                let response = ReplyBotResponse(json: json)
                return response
        }
    }
    
    func saveReplyBot(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "saveReplyBots/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    //AutoReplyBots
    func doGetReplyBot(params: [String: Any]) -> Observable<AutoReplyBotResponse> {
        return manager.rx.data(kAPIEndPoint + "doGetAutoReplyBot/", .post, parameters: params)
            .map { d -> AutoReplyBotResponse in
                let json = JSON(d)
                let response = AutoReplyBotResponse(json: json)
                return response
        }
    }
    
    func doSaveAutoReplyBot(params: [String: Any]) -> Observable<SaveAutoReplyBotResponse> {
        return manager.rx.data(kAPIEndPoint + "doSaveAutoReplyBot/", .post, parameters: params)
            .map { d -> SaveAutoReplyBotResponse in
                let json = JSON(d)
                let response = SaveAutoReplyBotResponse(json: json)
                return response
        }
    }
    
    func doDeleteAutoReplyBot(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doDeleteAutoReplyBot/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    ///CustomReplyBotFramework
    func doGetInstanceList(params: [String: Any]) -> Observable<InstanceResponse> {
        return manager.rx.data(kAPIEndPoint + "doGetInstanceList/", .post, parameters:  params)
            .map { d -> InstanceResponse in
                let json = JSON(d)
                let response = InstanceResponse(json: json)
                return response
        }
    }
    
    func doGetCampaignList(params: [String: Any]) -> Observable<CampaignListResponse> {
        return manager.rx.data(kAPIEndPoint + "doGetCampaignInfo/", .post, parameters: params)
            .map { d -> CampaignListResponse in
                let json = JSON(d)
                let response = CampaignListResponse(json: json)
                return response
        }
    }
    
    /// VisitCampaignSettingsVC
    func getCampaignInfo(params: [String: Any]) -> Observable<CampaignInfoResponse> {
        return manager.rx.data(kAPIEndPoint + "getCampaignInfo/", .post, parameters: params)
            .map { d -> CampaignInfoResponse in
                let json = JSON(d)
                let response = CampaignInfoResponse(json: json)
                return response
        }
    }
    
    func doRandomAgentSequence(params: [String: Any]) -> Observable<RandomAgentListResponse> {
        return manager.rx.data(kAPIEndPoint + "doRandomAgentSequence/", .post, parameters: params)
            .map { d -> RandomAgentListResponse in
                let json = JSON(d)
                let response = RandomAgentListResponse(json: json)
                return response
        }
    }
    
    func saveCampaignReplyBots(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "saveCampaignReplyBots/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    func doRegisterGravityForAgent(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doRegisterGravityForAgent/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    func doRegisterCampaignBlockList(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doRegisterCampaignBlockList/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    ///Whatsapp Crm -> Dashboard
    func changeInstanceStatus(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "changeInstanceStatus/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    func doDeleteInstance(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doDeleteInstance/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    func doGetProfile(params: [String: Any]) -> Observable<GetProfileResponse> {
        return manager.rx.data(kAPIEndPoint + "doGetProfile/", .post, parameters: params)
            .map { d -> GetProfileResponse in
                let json = JSON(d)
                let response = GetProfileResponse(json: json)
                return response
        }
    }
    
    ///AgentPhoneNumberSettings
    func doRegisterPhoneNumber(params: [String: Any]) -> Observable<RegisterPhoneNumberResponse> {
        return manager.rx.data(kAPIEndPoint + "doRegisterPhoneNumber/", .post, parameters: params)
            .map { d -> RegisterPhoneNumberResponse in
                let json = JSON(d)
                let response = RegisterPhoneNumberResponse(json: json)
                return response
        }
    }
    
    ///InquryVC
    func getInquryChatRooms(params: [String: Any]) -> Observable<InboxInfoResponse> {
        return manager.rx.data(kAPIEndPoint + "getInquiryChatRooms/", .post, parameters: params)
            .map { d -> InboxInfoResponse in
                let json = JSON(d)
                let response = InboxInfoResponse(json: json)
                return response
        }
    }
    
    func getCampaignListForInbox(params: [String: Any]) -> Observable<InboxCampaignInfoResponse> {
        return manager.rx.data(kAPIEndPoint + "getCampaignListForInbox/", .post, parameters: params)
            .map { d -> InboxCampaignInfoResponse in
                let json = JSON(d)
                let response = InboxCampaignInfoResponse(json: json)
                return response
        }
    }
    
    ///FacebookLeadsSetup
    func doGetFacebookPages(params: [String: Any]) -> Observable<FBPageResponse> {
        return manager.rx.data(kAPIEndPoint + "getFacebookLeadsInfo/", .get, parameters: params)
            .map { d -> FBPageResponse in
                let json = JSON(d)
                let response = FBPageResponse(json: json)
                return response
        }
    }
    
    func registerToken(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doRegisterFBtoken/", .get, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    func disconnectFacebook(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doDisconnectFB/", .get, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    func subscribepage(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doSubscribePage/", .get, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    func unSubscribe(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doUnsubscribePage/", .get, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    ///WordPressLeads
    
    func doGenerateSiteKey(params: [String: Any]) -> Observable<GenerateSiteKeyResponse> {
        return manager.rx.data(kAPIEndPoint + "doGenerateSiteKey/", .post, parameters: params)
            .map { d -> GenerateSiteKeyResponse in
                let json = JSON(d)
                let response = GenerateSiteKeyResponse(json: json)
                return response
        }
    }
    func doGetWordPressSesttings(params: [String: Any]) -> Observable<WordPressDataResponse> {
        return manager.rx.data(kAPIEndPoint + "doGetWordPressSettings/", .post, parameters: params)
            .map { d -> WordPressDataResponse in
                let json = JSON(d)
                let response = WordPressDataResponse(json: json)
                return response
        }
    }
    
    ///VisitContactFormVC
    func doGetSiteKeyInfo(params: [String: Any]) -> Observable<GetSiteKeyInfoResponse> {
        return manager.rx.data(kAPIEndPoint + "doGetSiteKeyInfo/", .post, parameters: params)
            .map { d -> GetSiteKeyInfoResponse in
                let json = JSON(d)
                let response = GetSiteKeyInfoResponse(json: json)
                return response
        }
    }
    func doRegisterContactBlockList(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doRegisterContactBlockList/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    ///ThirdPartyApiLeadsVC
    func doRegisterThirdParty(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doRegisterThirdParty/", .get, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    func doGetThridPartySettings(params: [String: Any]) -> Observable<GetThirdPartySettingsResponse> {
        return manager.rx.data(kAPIEndPoint + "doGetThirdPartySettings/", .post, parameters: params)
            .map { d -> GetThirdPartySettingsResponse in
                let json = JSON(d)
                let response = GetThirdPartySettingsResponse(json: json)
                return response
        }
    }
    
    func doGetThridPartyStatus(params: [String: Any]) -> Observable<ThirdPartyStatusResponse> {
        return manager.rx.data(kAPIEndPoint + "getThirdPartyStatus/", .get, parameters: params)
            .map { d -> ThirdPartyStatusResponse in
                let json = JSON(d)
                let response = ThirdPartyStatusResponse(json: json)
                return response
        }
    }
    
    func doRegisterThirdPartyBlockList(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doRegisterThirdPartyBlockList/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    ///InboxVC
    func getChatHistory(params: [String: Any]) -> Observable<ChatHistoryResponse> {
        return manager.rx.data(kAPIEndPoint + "getChathistory/", .post, parameters: params)
            .map { d -> ChatHistoryResponse in
                let json = JSON(d)
                let response = ChatHistoryResponse(json: json)
                return response
        }
    }
    func sendWhatsappMessage(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "sendWhatsappMessage/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    func sendWhatsappFile(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "sendWhatsappFile/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    func doChangeLabel(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doChangeLabel/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    func uploadMultipart(_ url: String = kAPIEndPoint + "doUploadImage/", parameters params:[String: Any], method: HTTPMethod = .post, image: UIImage? = nil, imageName: String = "image_file", fileName: String = "photo_file.jpg") -> Observable<UploadImageResponse> {
        let ob = Observable<UploadImageResponse>.create { observer -> Disposable in
            self.manager.upload(
                multipartFormData: { multipartFormData in
                    if let _image = image {
                        multipartFormData.append(_image.jpegData(compressionQuality: 1.0)!, withName: imageName, fileName: fileName, mimeType: "image/jpeg")
                    }
                    for (key, value) in params {
                        multipartFormData.append(String(describing: value).data(using: .utf8)!, withName: key)
                    }
            },
                to: url,
                method: method,
                encodingCompletion: { result in
                    switch result {
                    case .success(let upload, _, _):
                        upload.responseData(completionHandler: { responseData in
                            do {
                                let response = UploadImageResponse(json: JSON(responseData.data!))
                                observer.onNextAndCompleted(response)
                            }
                            catch {
                            }
                        })
                    case let .failure(error):
                        observer.onError(error)
                    }
            })
            
            return Disposables.create()
        }
        return ob
    }

    ///Payment
    
    func doPayWithCard(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doPayWithCard/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    func doDepositWithCard(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doDepositWithCard/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    ///MainVC
    
    func doGetMembership(params: [String: Any]) -> Observable<MembershipResponse> {
        return manager.rx.data(kAPIEndPoint + "doGetMembership/", .post, parameters: params)
            .map { d -> MembershipResponse in
                let json = JSON(d)
                let response = MembershipResponse(json: json)
                return response
        }
    }
    
    func doCheckToken(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "checkTokenValidation/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    ///LogOut
    func doLogout(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doLogout/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    
    
    ///Profile
    func doModifyUserProfile(params: [String: Any]) -> Observable<ModifyUserResponse> {
        return manager.rx.data(kAPIEndPoint + "doModifyUserProfile/", .post, parameters: params)
            .map { d -> ModifyUserResponse in
                let json = JSON(d)
                let response = ModifyUserResponse(json: json)
                return response
        }
    }
    
    func doGenerateConfirmCode(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doGenerateConfirmCode/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
    func doGenerateVerifyCode(params: [String: Any]) -> Observable<BaseResponse> {
        return manager.rx.data(kAPIEndPoint + "doGenerateVerifyCode/", .post, parameters: params)
            .map { d -> BaseResponse in
                let json = JSON(d)
                let response = BaseResponse(json: json)
                return response
        }
    }
}
