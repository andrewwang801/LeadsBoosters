//
//  CustomReplyBotCell.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/15.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit

class CustomReplyBotCell: UITableViewCell, ReusableView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var leadsCountLabel: UILabel!
    @IBOutlet weak var costPerLeadsLabel: UILabel!
    @IBOutlet weak var btnVisit: UIButton!
    
    var membershipInfo: MembershipInfo?
    var parentVC: CustomReplyBot?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        guard let _membershipInfo = membershipInfo else { return }
        if _membershipInfo.plans == "free" {
            btnVisit.isHidden = false
        }
        else {
            btnVisit.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onVisit(_ sender: Any) {
        /// goto VisitCampaignSettingsVC
        if let _parentVC = parentVC {
            _parentVC.gotoVisitCampaignSettings()
        }
    }
    
    var item: CampaignInfo? {
        didSet {
            guard let _item = item else { return }
            updateUI(item: _item)
        }
    }
    
    func updateUI(item: CampaignInfo) {
        nameLabel.text = item.campaign_name
        leadsCountLabel.text = item.leads_count
        costPerLeadsLabel.text = item.per_leads
    }
}
