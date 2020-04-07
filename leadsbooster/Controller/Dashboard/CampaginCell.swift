//
//  CampaginCell.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/1.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit

class CampaginCell: UITableViewCell, ReusableView {

    @IBOutlet weak var campaignNameLabel: UILabel!
    @IBOutlet weak var leadsCountLabel: UILabel!
    @IBOutlet weak var costPerLeadLabel: UILabel!
    @IBOutlet weak var visitBtn: UIButton!
    
    var parentVC: DashboardVC?
    
    @IBAction func onVisit(_ sender: Any) {
        /// goto VisitCampaignSettingsVC
        if let _parentVC = parentVC {
            _parentVC.gotoVisitCampaignSettings()
        }
    }
    
    var memberShipInfo: MembershipInfo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var item: CampaignInfo? {
        didSet {
            guard let _item = item else { return }
            updateUI(item: _item)
        }
    }

    func updateUI(item: CampaignInfo) {
        campaignNameLabel.text = item.campaign_name
        leadsCountLabel.text = "Leads Counts: " + item.leads_count
        costPerLeadLabel.text = "Cost Per Leads: " + item.per_leads
        
        if let _memberShipInfo = memberShipInfo {
            if _memberShipInfo.plans == "free" {
                self.visitBtn.isHidden = false
            }
            else {
                self.visitBtn.isHidden = true
            }
        }
    }
}
