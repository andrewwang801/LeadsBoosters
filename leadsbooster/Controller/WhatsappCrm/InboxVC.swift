//
//  InboxVC.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/19.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import DropDown
import JSQDataSourcesKit

class InboxVC: BaseVC, UITableViewDelegate {

    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    ///variables
    var chatRoom: ChatRoom?
    var last_load_message = 0
    var labelList:[Label] = []
    var userInfo: UserInfo?
    var isRunning = false
    let dropDown = DropDown()
    var dropDownButton = UIBarButtonItem()
    var dropDownLabel = UIBarButtonItem()
    
    var chatInfo: ChatRoom?
    var chatMessages: [ChatMessage] = []
    
    var imagePicker: ImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200
        
        ///init data
        isRunning = true
        userInfo = UserInfo(json: parse(string: AppSettings.string(kUserInfo)))
        buildLabels()
        initUI()
        loadMessages()
        
        imagePicker = ImagePicker(presentationController: self, delegate: self)
        messageTextField.addTarget(self, action: #selector(onMessageInput), for: .editingChanged)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        isRunning = false
    }
    
    override func initUI() {
        self.title = chatRoom?.project_name ?? ""
        self.ext.setBackShapedDismissButton().action = #selector(onBackPressed)
        
        dropDownButton = UIBarButtonItem(image: UIImage(named: "arror")?.itemImage(), style: .plain, target: self, action: #selector(onDropDown))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        dropDownLabel = UIBarButtonItem(customView: label)
        navigationItem.rightBarButtonItems = [dropDownLabel, dropDownButton]
        
        setupDropDown()
    }
    
    @objc func onMessageInput(textField: UITextField) {
        
    }
    
    @objc func onDropDown() {
        dropDown.show()
    }
    
    @objc func onBackPressed() {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func buildLabels() {
        labelList.append(Label(value: 1, label: "HIGH"))
        labelList.append(Label(value: 2, label: "LOW"))
        labelList.append(Label(value: 3, label: "Follow Up"))
        labelList.append(Label(value: 4, label: "Meet Up"))
        labelList.append(Label(value: 5, label: "Call"))
        labelList.append(Label(value: 6, label: "Close"))
    }
    
    func setupDropDown() {
        dropDown.anchorView = dropDownButton
        dropDown.dataSource = labelList.map({$0.label})
        dropDown.selectionAction = { (index: Int, item: String) in
            self.dropDownLabel.title = item
            
            if let chatRoom = self.chatRoom, index + 1 == chatRoom.label {
                var params:[String: String] = [:]
                params["token"] = AppSettings.string(kUserToken)
                params["chatId"] = chatRoom.chatId
                params["label"] = String(index + 1)
                
                apiService.doChangeLabel(params: params)
                    .subscribe {[weak self] evt in
                        guard let _self = self else {return}
                        switch evt {
                        case let .next(response):
                            if response.result == 1 {
                                chatRoom.label = index + 1
                                _self.chatRoom = chatRoom
                                NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateChatRoom), object: nil)
                                NSLog("doChangeLabel success")
                            }
                            else {
                                _self.showNotification(text: L10n.serverError)
                            }
                            break
                        case .error:
                            _self.showNotification(text: L10n.internetError)
                            break
                        default:
                            break
                        }
                }.disposed(by: self.disposeBag)
            }
        }
    }
    
    func uploadImageAndShow(image: UIImage) {
        let date = Date()
        let timeStamp = date.toDateString(format: "yyyyMMdd_HHmmss") ?? ""
        let fileName = "JPEG_" + timeStamp + ".jpg"
        let hud = activityHUD()
        
        ///Upload Image
        apiService.uploadMultipart(parameters: [:], image: image, fileName: fileName)
            .subscribe{ [weak self] evt in
                guard let _self = self else {return}
                switch evt {
                case let .next(response):
                    let chatMessage = ChatMessage()
                    chatMessage.body = response.image_path
                    chatMessage.author = "Me"
                    chatMessage.fromMe = true
                    if let _chatRoom = _self.chatRoom {
                        chatMessage.chatId = _chatRoom.chatId
                        chatMessage.chatName = _chatRoom.project_name
                    }
                    chatMessage.messageNumber = -1
                    chatMessage.type = "image"
                    let date = Date()
                    chatMessage.time = Int(date.timeIntervalSince1970 / 1000)
                    _self.chatMessages.append(chatMessage)
                    _self.setupTableView()
                    _self.tableView.reloadData()
                    _self.tableView.scrollToBottom()
                    hud.hide(true)
                    
                    ///Send message
                    var params:[String: String] = [:]
                    params["token"] = AppSettings.string(kUserToken)
                    params["chatId"] = _self.chatRoom?.chatId ?? ""
                    params["file_url"] = response.image_path
                    params["filename"] = fileName
                    
                    apiService.sendWhatsappFile(params: params)
                        .subscribe {[weak self] evt in
                            guard let _self = self else {return}
                            switch evt {
                            case let .next(response):
                                if response.result != 1 {
                                    _self.showNotification(text: "Sending Failed.")
                                    NSLog("sendWhatsAppFile failed")
                                }
                                break
                            case .error:
                                _self.showNotification(text: "Sending Error")
                                NSLog("sendWhatsAppFile Error")
                                break
                            default:
                                break
                            }
                    }.disposed(by: _self.disposeBag)
                    NSLog("uploadAndImageShow Success")
                    break
                    
                case .error:
                    _self.showNotification(text: "Sending Error")
                    NSLog("uploadAndImageShow Error")
                    hud.hide(true)
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
        
    }
    
    @IBAction func onAttachment(_ sender: Any) {
        self.imagePicker.present(from: sender as! UIView)
    }
    
    @IBAction func onSend(_ sender: Any) {
        
         ///Send message
        let chatMessage = ChatMessage()
        chatMessage.body = messageTextField.text ?? ""
        if !chatMessage.body.isEmpty {
            chatMessage.author = "Me"
            chatMessage.fromMe = true
            chatMessage.messageNumber = -1
            chatMessage.type = "chat"
            chatMessage.chatId = chatRoom?.chatId ?? ""
            chatMessage.chatName = chatRoom?.project_name ?? ""
            let date = Date()
            chatMessage.time = Int(date.timeIntervalSince1970 / 1000)
            chatMessages.append(chatMessage)
            setupTableView()
            tableView.reloadData()
            tableView.scrollToBottom()
            messageTextField.text = ""
            ///Scroll down to tableview

            var params:[String: String] = [:]
            params["token"] = AppSettings.string(kUserToken)
            params["chatId"] = chatRoom?.chatId ?? ""
            params["message"] = chatMessage.body
             
             apiService.sendWhatsappMessage(params: params)
                 .subscribe {[weak self] evt in
                     guard let _self = self else {return}
                     switch evt {
                     case let .next(response):
                         if response.result != 1 {
                             _self.showNotification(text: "Sending Failed.")
                            NSLog("sendWhatsappMessage failed")
                         }
                         break
                     case .error:
                        _self.showNotification(text: "Sending Error.")
                        NSLog("sendWhatsappMessage error")
                         break
                     default:
                         break
                     }
             }.disposed(by: disposeBag)
                
        }
    }
    
    func loadMessages() {
        
        var hud: ActivityHUDType?
        if last_load_message == 0 {
            hud = activityHUD()
        }
        
        var params:[String: String] = [:]
        params["token"] = AppSettings.string(kUserToken)
        params["chatId"] = chatRoom?.chatId
        params["lastMessageNumber"] = String(last_load_message)
        
        apiService.getChatHistory(params: params)
            .subscribe {[weak self] evt in
                guard let _self = self else {return}
                switch evt{
                case let .next(response):
                    if !_self.isRunning {
                        return
                    }
                    if _self.last_load_message == 0 {
                        if let _hud = hud {
                            _hud.hide(true)
                        }
                    }
                    if response.result == 1 {
                        if _self.chatMessages.count == 0 {
                            _self.chatMessages = response.messages
                            _self.chatInfo = response.chatInfo
                            _self.chatRoom?.customer_name = _self.chatInfo?.customer_name ?? ""
                        }
                        else {
                            if _self.last_load_message == 0 {
                                _self.chatMessages.append(contentsOf: response.messages)
                            }
                            else {
                                for item in response.messages {
                                    if !item.fromMe {
                                        _self.chatMessages.append(item)
                                    }
                                }
                            }
                        }
                        _self.last_load_message = _self.chatMessages[_self.chatMessages.count - 1].messageNumber
                        _self.setupTableView()
                        _self.tableView.reloadData()
                        _self.tableView.scrollToBottom()
                        ///scroll to bottom of tableview
                        ///send chatRoom, userInfo to Cell
                        NSLog("getChatHistory success")
                    }
                    else {
                        if _self.last_load_message == 0 {
                            _self.showNotification(text: response.message)
                        }
                        NSLog("getChatHistory failed")
                    }
                    if _self.isRunning {
                        _self.loadMessages()
                    }
                    
                    break
                case .error:
                    if _self.last_load_message == 0 {
                        _self.showNotification(text: L10n.internetError)
                    }
                    if _self.isRunning {
                        _self.loadMessages()
                    }
                    NSLog("getChatHistory Error")
                    break
                default:
                    break
                }
        }.disposed(by: disposeBag)
    }

    ///TableViewSection
    
    ///Stored vars for TableViews
    typealias CellConfig = ReusableViewConfig<ChatMessage, InboxCell>
    var dataSourceProvider: DataSourceProvider<DataSource<ChatMessage>, CellConfig, CellConfig>?
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    ///Campaign TableView
    func setupTableView() {
        
        var sectionList = [Section<ChatMessage>]()
        for item in chatMessages {
            let section = Section(items:item)
            sectionList.append(section)
        }
        //let dataSource = DataSource(sections: sectionList)
        let dataSource = DataSource(sectionList)
        let cellConfig = ReusableViewConfig { (cell, info:ChatMessage?,  _, tableView, ip) -> InboxCell in
            cell.userInfo = self.userInfo
            cell.chatRoom = self.chatRoom
            cell.chatMessage = info
            return cell
        }
        dataSourceProvider = DataSourceProvider(dataSource: dataSource, cellConfig: cellConfig, supplementaryConfig: cellConfig)
        tableView.dataSource = dataSourceProvider?.tableViewDataSource
        tableView.delegate = self
    }
}

extension InboxVC: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        if let _image = image {
            self.uploadImageAndShow(image: _image)
        }
    }
}

extension UITableView {

    func scrollToBottom(){

        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    func scrollToTop() {

        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}
