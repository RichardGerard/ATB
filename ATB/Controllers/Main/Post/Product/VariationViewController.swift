//
//  VariationViewController.swift
//  ATB
//
//  Created by YueXi on 11/11/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import NBBottomSheet

protocol VariationUpdateDelegate: class {
    
    func variationAdded(name:String, options:String)
    func variationUpdated(name:String, updatedName: String, options:String)
    func variationDeleted(name:String)
}

class VariationViewController: BaseViewController {
    
    static let kStoryboardID = "VariationViewController"
    class func instance() -> VariationViewController {
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: VariationViewController.kStoryboardID) as? VariationViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    // Variation Name
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var nameField: RoundRectTextField!
    @IBOutlet weak var deleteContainer: UIView!
    @IBOutlet weak var imvDelete: UIImageView!
    
    // Variation Options
    @IBOutlet weak var lblOptions: UILabel!
    
    // Add a new option
    @IBOutlet weak var imvAddNew: UIImageView!
    @IBOutlet weak var lblAddNew: UILabel!
    
    @IBOutlet weak var btnUpdate: UIButton!
    
    @IBOutlet weak var tblOptions: UITableView!
    
    var delegate: VariationUpdateDelegate?

    var configuration: NBBottomSheetConfiguration!
        
    var isAdding: Bool = true
    var variantToUpdate: [String: String] = [:]
    
    private let defaultOptionsCount: Int = 3
    
    var variationOptions = [String]()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if isAdding {
            for _ in 0 ..< defaultOptionsCount {
                variationOptions.append("")
            }
            
        } else {
            if let options = variantToUpdate["values"] {
                let optionsArr = options.components(separatedBy: ",")
                
                for option in optionsArr {
                    variationOptions.append(String(option))
                }
            }
        }
        
        setupViews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 24)
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray7
        
        lblName.text = "Variation Name"
        lblName.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblName.textColor = .colorGray1
        
        if #available(iOS 13.0, *) {
            btnClose.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnClose.tintColor = .colorGray20
        
        if #available(iOS 13.0, *) {
            imvDelete.image = UIImage(systemName: "trash.fill")
        } else {
            // Fallback on earlier versions
        }
        imvDelete.tintColor = .colorRed1
        
        deleteContainer.backgroundColor = UIColor.colorRed1.withAlphaComponent(0.09)
        deleteContainer.layer.cornerRadius = 5
        
        lblOptions.text = "Variation Options"
        lblOptions.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblOptions.textColor = .colorGray1
             
        if #available(iOS 13.0, *) {
            imvAddNew.image = UIImage(systemName: "plus.app")
        } else {
            // Fallback on earlier versions
        }
        imvAddNew.tintColor = .colorPrimary
        
        lblAddNew.text = "Add a new option"
        lblAddNew.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        lblAddNew.textColor = .colorPrimary
        
        tblOptions.showsVerticalScrollIndicator = false
        tblOptions.separatorStyle = .none
        tblOptions.tableFooterView = UIView()
        tblOptions.backgroundColor = .clear
        tblOptions.bounces = false
        
        tblOptions.dataSource = self
        tblOptions.delegate = self
        
        btnUpdate.setTitle(isAdding ? "Add Variation" : "Update Variation", for: .normal)
        btnUpdate.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        btnUpdate.setTitleColor(.white, for: .normal)
        btnUpdate.layer.cornerRadius = 5
        btnUpdate.backgroundColor = .colorPrimary
        
        setupTextField(nameField, placeholder: "Name")
        
        nameField.text = isAdding ? "" : variantToUpdate["attribute_name"]!
    }
    
    private func setupTextField(_ textField: RoundRectTextField, placeholder: String? = nil) {
        textField.backgroundColor = .white
        textField.borderColor = .colorGray17
        textField.borderWidth = 1
        textField.autocapitalizationType = .words
        
        textField.placeholder = placeholder
        textField.tintColor = .colorGray5
        textField.textColor = .colorGray5
        
        textField.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        textField.inputPadding = 16
    }
    
    @IBAction func didTapDelete(_ sender: Any) {
        guard !isAdding else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        guard let name = variantToUpdate["attribute_name"] else { return }
        dismiss(animated: true) {
            self.delegate?.variationDeleted(name: name)
        }
    }
    
    private let expandableMaxCount = 4
    private let maxOptionsCount = 8
    @IBAction func didTapAddNewOption(_ sender: Any) {
        guard variationOptions.count < maxOptionsCount else {
            showErrorVC(msg: "You can add up to \(maxOptionsCount) options.")
            return
        }
        
        variationOptions.append("")
        tblOptions.reloadData {
            self.tblOptions.scroll(to: .bottom, animated: true)
        }
    }
    
    private func didDeleteVariationOption(_ index: Int) {
        if variationOptions.count == 1 {
            variationOptions[index] = ""
            tblOptions.reloadData()
            
        } else {
            variationOptions.remove(at: index)
            
            tblOptions.beginUpdates()
            tblOptions.deleteSections([index], with: .fade)
            tblOptions.endUpdates()
        }
    }
    
    private func isValid() -> Bool {
        guard let name = nameField.text,
              !name.isEmpty else {
            showErrorVC(msg: "Please enter the valid variation name.")
            return false
        }
        
        var noneSpaceOptions = [String]()
        for option in variationOptions {
            if !option.isEmpty {
                noneSpaceOptions.append(option)
            }
        }
        
        guard noneSpaceOptions.count > 0 else {
            showErrorVC(msg: "Please add variation options.")
            return false
        }
        
        guard noneSpaceOptions.isDistinct() else {
            showErrorVC(msg: "Options should be unique.")
            return false
        }
        
        return true
    }
    
    @IBAction func didTapUpdate(_ sender: Any) {
        guard isValid() else { return }
        
        var noneSpaceOptions = [String]()
        for option in variationOptions {
            if !option.isEmpty {
                noneSpaceOptions.append(option)
            }
        }
        
        var options = ""
        for option in noneSpaceOptions {
            options += "," + option
        }
        options = String(options.dropFirst())
        
        let name = nameField.text!.trimmedString
        
        dismiss(animated: true) {
            if self.isAdding {
                self.delegate?.variationAdded(name: name, options: options)
                
            } else {
                guard let oldName = self.variantToUpdate["attribute_name"] else { return }
                self.delegate?.variationUpdated(name: oldName, updatedName: name, options: options)
            }
        }
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension VariationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return variationOptions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VariationAttributeCell.reuseIdentifier, for: indexPath) as! VariationAttributeCell
        // configure cell
        cell.optionField.text = variationOptions[indexPath.section]
        cell.optionDeleted = {
            self.didDeleteVariationOption(indexPath.section)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let attributeCell = cell as? VariationAttributeCell {
            attributeCell.setTextFieldDelegate(self, indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = .clear
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}

// MARK: - UITextFieldDelegate
extension VariationViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let value = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        let index = textField.tag - 500
        guard index >= 0,
              index < variationOptions.count else { return true }
        
        variationOptions[index] = value.trimmedString
        
        return true
    }
}

// MARK: - Sequence
extension Sequence where Element: Hashable {
    
    /// Returns true if no element is equal to any other element.
    func isDistinct() -> Bool {
        var set = Set<Element>()
        for e in self {
            if set.insert(e).inserted == false { return false }
        }
        
        return true
    }
}
