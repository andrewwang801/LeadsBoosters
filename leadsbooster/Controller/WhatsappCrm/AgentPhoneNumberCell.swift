//
//  TableViewCell.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit

class AgentPhoneNumberCell: UITableViewCell, ReusableView {

    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onRemove(_ sender: Any) {
        delegate?.removeItem(row: row!)
    }
    
    var delegate: ChangeDataDelegate?
    var row: Int?
    var item: AgentInfo? {
        didSet {
            if let _item = item {
                updateUI(item: _item)
            }
        }
    }
    
    func updateUI(item: AgentInfo) {
        phoneNumberLabel.text = item.phone_number
        emailLabel.text = item.email
    }
}
