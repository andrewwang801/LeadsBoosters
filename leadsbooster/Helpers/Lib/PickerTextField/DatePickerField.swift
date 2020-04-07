//
//  DatePickerField.swift
//  SecureTribe
//
//  Created by Alex on 25/3/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class DatePickerField : /*NoCaretTextField*/ UITextField {
    fileprivate let iav = ListPickerFieldAccessoryView.shared
    let disposeBag = DisposeBag()
    
    fileprivate lazy var datePicker:UIDatePicker = {
        return UIDatePicker().then{
            $0.datePickerMode = .date
        }
    }()
    
    fileprivate lazy var dateFormatter:DateFormatter = {
        return DateFormatter().then{
            $0.timeStyle = .none
            $0.dateStyle = .medium
        }
    }()
    
    var date:Date?{
        didSet {        
            guard let date = self.date else {
                text = ""
                return
            }
            dateFormatter.dateFormat = "YYYY-MM-dd"
            text = dateFormatter.string(from: date)
            if datePicker.date != date {
                // reset date.
                datePicker.date = date
            }
        }
    }
    
    var maximumDate: Date? {
        didSet {
            guard let _ = self.maximumDate else {
                return
            }
            
            datePicker.maximumDate = self.maximumDate
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textFieldDidBeginEditing(_:)),
            name: UITextField.textDidBeginEditingNotification,
            object: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didScreenOrientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // Set input View
        initPicker()
    }
    
    @objc func didScreenOrientationChanged() {
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        initPicker()
        self.reloadInputViews()
    }
    
    func initPicker() {
        // Set input View
        inputView = datePicker
        
        //Select Date if text field value is valid
        if let date = dateFormatter.date(from: text ?? "") {
            datePicker.date = date
        }
        
        iav.then{
            inputAccessoryView = $0
            $0.delegate = self
            $0.title = placeholder ?? ""
            
            if $0.subviews.count > 0 && $0.subviews[0].subviews.count > 0 {
                // ($0.subviews[0].subviews[0] as? UIButton)?.setTitle("Done", for: .normal) // English Only
                ($0.subviews[0].subviews[0] as? UIButton)?.setTitle(L10n.done, for: .normal) // Multiple language
            }
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
        guard let textField = notification.object as? DatePickerField, self == textField else { return }
        iav.delegate = nil  //Clear Delegate
    }
    
    @objc func textFieldDidBeginEditing(_ notification:Notification){
        guard let textField = notification.object as? DatePickerField, self == textField else { return }
        
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

extension DatePickerField:ListPickerFieldAccessoryViewDelegate {
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
