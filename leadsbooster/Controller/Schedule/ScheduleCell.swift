//
//  TableViewCell.swift
//  project
//
//  Created by Apple Developer on 2020/1/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit
import Kingfisher

class ScheduleCell: UITableViewCell, ReusableView {
    
    @IBOutlet var team1Title: UILabel!
    @IBOutlet var team2Title: UILabel!
    @IBOutlet var scheduleDate: UILabel!
    @IBOutlet var result: UILabel!
    
    override func awakeFromNib() {
        self.ext.setupBorder(color: UIColor(r: 0, g: 0, b: 0, a: 1.0), width: 1.0, cornerRadius: 0)
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var item: Schedule? {
        didSet {
            guard let _item = item else { return }
            updateUI(schedule: _item)
        }
    }
    
    func updateUI (schedule: Schedule) {
        team1Title.text = schedule.firstTeamName
        team2Title.text = schedule.secondTeamName
        scheduleDate.text = schedule.date
        result.text = schedule.result
        
        self.hideSkeleton()
    }

}
