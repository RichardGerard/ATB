//
//  RoundDropDown.swift
//  ATB
//
//  Created by mobdev on 2019/5/13.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import DropDown

protocol DropdownDelegate {
    func dropdownValueChanged(dropDown: RoundDropDown)
}

class RoundDropDown: UITextField {
    var dataStr:[String] = []
    let dropDown = DropDown()
    var searchText = ""
    var isSearchEnabled:Bool = true
    var dropdownDelegate: DropdownDelegate!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.delegate = self
        setupDropDown()
    }
    
    required override init(frame: CGRect){
        super.init(frame: frame)
        
        self.delegate = self
        setupDropDown()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        //To apply corner radius
        dropDown.topOffset = CGPoint(x: 0, y:-(self.frame.height) - 5)
        dropDown.bottomOffset = CGPoint(x: 0, y:(self.frame.height) + 5)
        
        layer.cornerRadius = 5
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds)
        let padding = bounds.inset(by: UIEdgeInsets.init(top: 0, left: (self.frame.size.height / 2) * 0.8, bottom: 0, right: (self.frame.size.height / 2) * 0.8))
        return padding
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        let padding = bounds.inset(by: UIEdgeInsets.init(top: 0, left: (self.frame.size.height / 2) * 0.8, bottom: 0, right: (self.frame.size.height / 2) * 0.8))
        return padding
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        super.placeholderRect(forBounds: bounds)
        let padding = bounds.inset(by: UIEdgeInsets.init(top: 0, left: (self.frame.size.height / 2) * 0.8, bottom: 0, right: (self.frame.size.height / 2) * 0.8))
        return padding
    }
    
    func getValue()->Int?
    {
        let txtVal = self.text!
        return self.dataStr.firstIndex(of: txtVal)
    }
    
    func setupDropDown()
    {
        layer.borderWidth = 0.0
        layer.borderColor = UIColor.lightGray.cgColor
        
        let appearance = DropDown.appearance()
        
        appearance.cellHeight = self.frame.height
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.cornerRadius = 5
        appearance.shadowColor = UIColor.lightGray
        
        appearance.shadowOffset = CGSize(width: 1, height: 5)
        appearance.shadowOpacity = 0.5
        appearance.shadowRadius = 5.0
        
        appearance.separatorColor = UIColor.lightGray
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
        appearance.textFont = UIFont(name: "SegoeUI-Light", size: 17.0)!
        
        dropDown.anchorView = self
        // You can also use localizationKeysDataSource instead. Check the docs.
        dropDown.dataSource = dataStr
        
        // Action triggered on selection
        dropDown.selectionAction = { [weak self] (index, item) in
            self?.text = item
            if(!(self?.isSearchEnabled)!)
            {
                self?.dropdownDelegate.dropdownValueChanged(dropDown: self!)
            }
            self?.resignFirstResponder()
        }
        
        // Action triggered on dropdown cancelation (hide)
        dropDown.cancelAction = { [unowned self] in
            if(self.isSearchEnabled)
            {
                if(!self.dataStr.contains(self.text!))
                {
                    self.text = ""
                }
            }
            else
            {
                if(self.text == "")
                {
                    self.layer.shadowOpacity = 0.0
                    self.layer.borderColor = UIColor.lightGray.cgColor
                }
                else
                {
                    self.layer.shadowOpacity = 0.5
                    self.layer.borderColor = UIColor.primaryButtonColor.cgColor
                }
            }
            if(!self.isSearchEnabled)
            {
                self.dropdownDelegate.dropdownValueChanged(dropDown: self)
            }
            self.resignFirstResponder()
        }
    }
}

extension RoundDropDown : UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        superview?.endEditing(true)
        self.dropdownDelegate.dropdownValueChanged(dropDown: self)
        return false
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        showDrop(textField:textField)
        return isSearchEnabled
    }

    func showDrop(textField: UITextField)
    {
        if(isSearchEnabled)
        {
            if(textField.text != "")
            {
                if(dataStr.contains(textField.text!))
                {
                    self.searchText = textField.text!
                    dropDown.dataSource = self.dataStr.filter{$0.lowercased().hasPrefix(self.searchText.lowercased())}
                }
                else
                {
                    textField.text = ""
                }
            }
            
            if(textField.text == "")
            {
                self.searchText = ""
                dropDown.dataSource = self.dataStr
            }
        }
        else
        {
            dropDown.dataSource = self.dataStr
        }
        
        layer.shadowOffset = CGSize(width: 1, height: 5)
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5.0
        layer.borderColor = UIColor.primaryButtonColor.cgColor
        layer.borderWidth = 0.0
        
        dropDown.show()
        dropDown.reloadAllComponents()
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if(textField.text != "")
//        {
//            if(!dataStr.contains(textField.text!))
//            {
//                textField.text = ""
//            }
//        }
//
//        if(textField.text == "")
//        {
//            layer.shadowOpacity = 0.0
//            layer.borderColor = UIColor.lightGray.cgColor
//
//        }
//        else
//        {
//            layer.shadowOpacity = 0.5
//            layer.borderColor = UIColor.primaryButtonColor.cgColor
//        }
//        self.dropdownDelegate.dropdownValueChanged(dropDown: self)
//        dropDown.hide()
//    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if(textField.text != "")
        {
            if(!dataStr.contains(textField.text!))
            {
                textField.text = ""
            }
        }
        
        if(textField.text == "")
        {
            layer.shadowOpacity = 0.0
            layer.borderColor = UIColor.lightGray.cgColor
        }
        else
        {
            layer.shadowOpacity = 0.5
            layer.borderColor = UIColor.primaryButtonColor.cgColor
        }
        
        dropDown.hide()
        self.dropdownDelegate.dropdownValueChanged(dropDown: self)
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string != "" {
            self.searchText = self.text! + string
        }else{
            let subText = self.text?.dropLast()
            self.searchText = String(subText!)
        }
        
        if(searchText == "")
        {
            dropDown.dataSource = self.dataStr
        }
        else
        {
            dropDown.dataSource = self.dataStr.filter{$0.lowercased().hasPrefix(self.searchText.lowercased())}
        }
        
        dropDown.show()
        return true
    }
    
}
