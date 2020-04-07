//
//  BaseVC.swift
//  Alaitisal
//
//  Created by Alex on 2019/7/15.
//  Copyright © 2019 JN. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class BaseVC: UIViewController, Router {
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    func initUI(){
        if self.revealViewController() != nil {
            let sideMenuButton = UIBarButtonItem(image: UIImage(named: "RevealMenu")?.itemImage(), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = sideMenuButton
        }
    }
}
