//
//  UITableViewExt.swift
//  Alaitisal
//
//  Created by Alex on 2019/7/22.
//  Copyright © 2019 JN. All rights reserved.
//

import UIKit

extension Ext where Base: UITableView {
    func eliminateSeparator(){
        base.tableFooterView = UIView(frame: .zero)
    }
}
