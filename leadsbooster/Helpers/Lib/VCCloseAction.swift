//
//  VCCloseAction.swift
//  Alaitisal
//
//  Created by Alex on 2019/7/23.
//  Copyright © 2019 JN. All rights reserved.
//

import Foundation

enum VCCloseAction {
    case none
    case dismiss((() -> ())?)
    case pop
    case pop2Root
    case pop2(UIViewController.Type)
}
