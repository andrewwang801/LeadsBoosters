//
//  DateSelectableTextField.swift
//  AutoCorner
//
//  Created by Alex on 21/5/2017.
//  Copyright © 2017 stockNumSystems. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class TimePickerField : UITextField {
    fileprivate let iav = ListPickerFieldAccessoryView.shared
    let disposeBag = DisposeBag()
    
    fileprivate lazy var datePicker:UIDatePicker = {
        return UIDatePicker().then{
            $0.datePickerMode = .time
        }
    }()
    
    fileprivate lazy var dateFormatter:DateFormatter = {
        return DateFormatter().then{
            $0.timeStyle = .short
            $0.dateStyle = .none
        }
    }()
    
    var date:Date?{
        didSet {
            guard let date = self.date else {
                text = ""
                return
            }
            text = dateFormatter.string(from: date)
            if datePicker.date != date {
                // reset date.
                datePicker.date = date
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textFieldDidBeginEditing(_:)),
            name: UITextField.textDidBeginEditingNotification, //.UITextFieldTextDidBeginEditing,
            object: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didScreenOrientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        initPicker()
        /*
        // Set input View
        inputView = datePicker
        
        //Select Date if text field value is valid
        if let date = dateFormatter.date(from: text ?? "") {
            datePicker.date = date
        }
        
        // Should skip first item
        datePicker
            .rx.date
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext:{[weak self] date in
                self?.date = date
            }).addDisposableTo(disposeBag)*/
    }
    
    @objc func didScreenOrientationChanged() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        initPicker()
        self.reloadInputViews()
    }
    
    func initPicker() {
        inputView = datePicker
        iav.then{
            inputAccessoryView = $0
            $0.delegate = self
            $0.title = placeholder ?? ""
            
            if $0.subviews.count > 0 && $0.subviews[0].subviews.count > 0 {
                // ($0.subviews[0].subviews[0] as? UIButton)?.setTitle(L10n.done(), for: .normal) // English Only
                ($0.subviews[0].subviews[0] as? UIButton)?.setTitle(L10n.done, for: .normal) // Multiple Language
            }
        }
        
        //Select Date if text field value is valid
        if let date = dateFormatter.date(from: text ?? "") {
            datePicker.date = date
        }
        
        // Should skip first item
        datePicker
            .rx.date
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext:{[weak self] date in
                self?.date = date
            }).disposed(by:disposeBag)
    }
    
    func textFieldDidEndEditing(_ notification:Notification){
        guard let textField = notification.object as? TimePickerField, self == textField else { return }
        iav.delegate = nil  //Clear Delegate
    }
    
    @objc func textFieldDidBeginEditing(_ notification:Notification){
        guard let textField = notification.object as? TimePickerField, self == textField else { return }
        
        iav.then{
            inputAccessoryView = $0
            $0.delegate = self
            $0.title = placeholder ?? ""
        }
        
        if let date = dateFormatter.date(from: text ?? "") {
            datePicker.date = date
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TimePickerField:ListPickerFieldAccessoryViewDelegate {
    func didDoneButtonTapped(_ view: ListPickerFieldAccessoryView) {
        if let delegateFunc = delegate?.textFieldShouldReturn {
            // Call Should Return
            _ = delegateFunc(self)
        } else {
            // Resign First Responder.
            resignFirstResponder()
        }
    }
}
