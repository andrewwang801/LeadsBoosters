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

class DateTimePickerField : UITextField {
    fileprivate let iav = ListPickerFieldAccessoryView.shared
    let disposeBag = DisposeBag()
    
    fileprivate lazy var datePicker:UIDatePicker = {
        return UIDatePicker().then{
            $0.datePickerMode = .dateAndTime
        }
    }()
    
    fileprivate lazy var dateFormatter:DateFormatter = {
        return DateFormatter().then{
            $0.timeStyle = .short
            $0.dateStyle = .full
        }
    }()
    
    var date:Date?{
        didSet {
            guard let date = self.date else {
                text = ""
                return
            }
            dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:SS"
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
        
        // Set input View
        initPicker()
        
//        // Set input View
//        inputView = datePicker
//
//        //Select Date if text field value is valid
//        if let date = dateFormatter.date(from: text ?? "") {
//            datePicker.date = date
//        }
//
//        // Should skip first item
//        datePicker
//            .rx.date
//            .skip(1)
//            .distinctUntilChanged()
//            .subscribe(onNext:{[weak self] date in
//                self?.date = date
//            }).addDisposableTo(disposeBag)
    }
    
    @objc func didScreenOrientationChanged() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        initPicker()
        self.reloadInputViews()
    }
    
    func initPicker() {
        inputView = datePicker
        
        //Select Date if text field value is valid
        if let date = dateFormatter.date(from: text ?? "") {
            datePicker.date = date
        }
        
        iav.then{
            inputAccessoryView = $0
            $0.delegate = self
            $0.title = placeholder ?? ""
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
        guard let textField = notification.object as? DateTimePickerField, self == textField else { return }
       iav.delegate = nil  //Clear Delegate
        
    }
    
    @objc func textFieldDidBeginEditing(_ notification:Notification){
        guard let textField = notification.object as? DateTimePickerField, self == textField else { return }
        
//        iav.then{
//            inputAccessoryView = $0
//            $0.delegate = self
//            $0.title = placeholder ?? ""
//        }
        
        if let date = dateFormatter.date(from: text ?? "") {
            datePicker.date = date
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension DateTimePickerField:ListPickerFieldAccessoryViewDelegate {
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
