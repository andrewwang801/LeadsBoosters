//
//  InqueryCell.swift
//  leadsbooster
//
//  Created by Apple Developer on 2020/3/17.
//  Copyright © 2020 Apple Developer. All rights reserved.
//

import UIKit

class NoResponseCell: UITableViewCell, ReusableView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var txtLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var item: ChatRoom? {
        didSet {
            guard let _item = item else { return }
            updateUI(item: _item)
        }
    }
    
    func updateUI(item: ChatRoom) {
        
        if item.customer_name != "" {
            nameLabel.text = item.customer_name + "(" + item.customer + ")"
        }
        else {
            nameLabel.text = item.customer
        }
        phoneNumberLabel.text = item.project_name
        switch item.label {
        case 1:
            self.txtLabel.textColor = .black
            self.labelView.backgroundColor = UIColor(named: "indianred")
            txtLabel.text = "HIGH"
            break
        case 2:
            self.txtLabel.textColor = .black
            self.labelView.backgroundColor = UIColor(named: "lightblue")
            txtLabel.text = "LOW"
            break
        case 3:
            self.txtLabel.textColor = .black
            self.labelView.backgroundColor = UIColor(named: "yellow")
            txtLabel.text = "Follow Up"
            break
        case 4:
            self.txtLabel.textColor = .black
            self.labelView.backgroundColor = UIColor(named: "cyan")
            txtLabel.text = "Meet Up"
            break
        case 5:
            self.txtLabel.textColor = .white
            self.labelView.backgroundColor = UIColor(named: "purple")
            txtLabel.text = "Call"
            break
        case 6:
            self.txtLabel.textColor = .black
            self.labelView.backgroundColor = UIColor(named: "lightgreen")
            txtLabel.text = "Close"
            break
        default:
            break
        }
    }
}
