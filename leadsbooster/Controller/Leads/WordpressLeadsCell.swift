//
//  WordpressLeadsCell.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit

class WordpressLeadsCell: UITableViewCell, ReusableView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var leadsCountLabel: UILabel!
    @IBOutlet weak var costPerLeads: UILabel!
    
    var membershipInfo: MembershipInfo?
    var parentVC: WordpressLeadsVC?
    var item: ContactFormInfo? {
        didSet {
            guard let _item = item else {return}
            updateUI(item: _item)
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

    @IBAction func onVisit(_ sender: Any) {
        if let _membershipInfo = membershipInfo {
            if _membershipInfo.plans != "free" {
                ///goto Contact VC with param type of ContactFormInfo
                if let _parentVC = parentVC, let _item = item {
                    _parentVC.gotoContactForm(contactInfo: _item)
                }
            }
        }
    }
    
    func updateUI(item: ContactFormInfo) {
        nameLabel.text = item.name
        leadsCountLabel.text = item.leads_count
        costPerLeads.text = item.cf7_id
    }

}
