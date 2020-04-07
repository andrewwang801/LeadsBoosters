//
//  InboxCell.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/19.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import IBAnimatable
import Kingfisher

class InboxCell: UITableViewCell, ReusableView {

    @IBOutlet weak var messageInfoLabel: UILabel!
    @IBOutlet weak var messageBodyLabel: UILabel!
    @IBOutlet weak var attachmentImage: AnimatableImageView!
    @IBOutlet weak var messageContainer: UIStackView!
    @IBOutlet weak var messageAuthorLabel: UILabel!
    
    var userInfo: UserInfo?
    var previousGetCount = 0
    var chatRoom: ChatRoom?
    var chatMessage: ChatMessage? {
        didSet {
            if let _chatMessage = chatMessage {
                updateChat(item: _chatMessage)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateChat(item: ChatMessage) {
        setIncomingOrOutgoingMessageAttributes(chatMessage: item)
        setMessageBody(chatMessage: item)
        setMessageInfo(chatMessage: item)
        setMessageAuthor(chatMessage: item)
        
//        if isIncoming(chatMessage: item) && !isRead(chatMessage: item) {
//            readMessage(chatMessage: item)
//        }
    }
    

    func setIncomingOrOutgoingMessageAttributes(chatMessage: ChatMessage) {
        let isIncome = isIncoming(chatMessage: chatMessage)
        let messageContainerBackgroundColor = isIncome ? UIColor(named: "incoming") : UIColor(named: "outcoming")
        if hasAttachments(chatMessage: chatMessage) {
            messageContainer.customize(backgroundColor: messageContainerBackgroundColor!, radiusSize: 5.0)
        }
        else {
            messageContainer.customize(backgroundColor: messageContainerBackgroundColor!, radiusSize: 5.0)
        }
        
        if isIncome && hasAttachments(chatMessage: chatMessage) {
            messageContainer.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
            messageContainer.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -100).isActive = true
        }
        else if isIncome {
            messageContainer.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
            messageContainer.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -100).isActive = true
            
        }
        else if !isIncome && hasAttachments(chatMessage: chatMessage){
            messageContainer.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 100).isActive = true
            messageContainer.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        }
        else if !isIncome {
            messageContainer.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 100).isActive = true
            messageContainer.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        }
        
        let textColor: UIColor = isIncome ? .white : .black
        messageBodyLabel.textColor = textColor
    }
    
    func setMessageBody(chatMessage: ChatMessage) {
        if hasAttachments(chatMessage: chatMessage) {
            messageContainer.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            messageContainer.isLayoutMarginsRelativeArrangement = true
            messageBodyLabel.text = ""
            messageBodyLabel.isHidden = true
            attachmentImage.isHidden = false
            if let url = URL(string: chatMessage.getURL()) {
                attachmentImage.kf.setImage(with: url, completionHandler: {
                    (image, _, _, _) in
                    if image == nil {
                        self.attachmentImage.image = UIImage(named: "error")
                    }
                })
            }
        }
        else {
            messageContainer.layoutMargins = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
            messageContainer.isLayoutMarginsRelativeArrangement = true
            messageBodyLabel.isHidden = false
            attachmentImage.isHidden = true
            messageBodyLabel.text = chatMessage.getBody()
            
        }
    }
    
    func setMessageInfo(chatMessage: ChatMessage) {
        messageInfoLabel.text = chatMessage.getDateAsHeaderId() + " " + chatMessage.getTimeSent()
    }
    
    func setMessageAuthor(chatMessage: ChatMessage) {
        if isIncoming(chatMessage: chatMessage) {
            messageAuthorLabel.text = chatMessage.getSenderName(userInfo: userInfo!, chatRoom: chatRoom!)
            messageAuthorLabel.isHidden = false
            
            if hasAttachments(chatMessage: chatMessage) {
                messageAuthorLabel.textColor = .white
            }
            else {
                messageAuthorLabel.textColor = .darkGray
            }
        }
        else {
            messageAuthorLabel.isHidden = true
        }
    }
    
    func hasAttachments(chatMessage: ChatMessage) -> Bool {
        return chatMessage.isAttachment()
    }
    
    func isIncoming(chatMessage: ChatMessage) -> Bool {
        return chatMessage.isIncoming(userInfo: userInfo!)
    }
    
    func isRead(chatMessage: ChatMessage) -> Bool {
        return true
    }
    
    func readMessage(chatMessage: ChatMessage) {
        
    }
}

extension InboxCell {
    func heightForView(text:String, font:UIFont, width:CGFloat, rect: CGRectEdge) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }
}

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)

    }
    
    func customize(backgroundColor: UIColor = .clear, radiusSize: CGFloat = 0) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = backgroundColor
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)

        subView.layer.cornerRadius = radiusSize
        subView.layer.masksToBounds = true
        subView.clipsToBounds = true
    }
}
