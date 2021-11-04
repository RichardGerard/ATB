//
//  SelectGroupViewController.swift
//  ATB
//
//  Created by YueXi on 3/29/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit

protocol SelectGroupDelegate {
    
    func didSelectGroup(_ selected: String)
}

class SelectGroupViewController: BaseViewController {
    
    static let kStoryboardID = "SelectGroupViewController"
    class func instance() -> SelectGroupViewController {
        let storyboard = UIStoryboard(name: "BusinessBoost", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: SelectGroupViewController.kStoryboardID) as? SelectGroupViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var optionContainer: UIView!
    @IBOutlet weak var cancelContainer: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tblCategories: UITableView!
    @IBOutlet weak var lblCancel: UILabel!
    
    var selected: String = ""
    var delegate: SelectGroupDelegate?
    
    private let groups = g_StrFeeds.filter({ $0 != "My ATB"})

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .clear
        
        optionContainer.layer.cornerRadius = 16
        optionContainer.layer.masksToBounds = true
        
        lblTitle.text = "Please select a group:"
        lblTitle.font = UIFont(name: Font.SegoeUIBold, size: 18)
        lblTitle.textColor = .colorGray1
        
        tblCategories.showsVerticalScrollIndicator = false
        tblCategories.alwaysBounceVertical = false
        tblCategories.tableFooterView = UIView()
        tblCategories.separatorColor = .colorGray7
        tblCategories.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tblCategories.register(SelectGroupCell.self, forCellReuseIdentifier: SelectGroupCell.reuseIdentifer)
        tblCategories.dataSource = self
        tblCategories.delegate = self
        
        cancelContainer.layer.cornerRadius =  16
        cancelContainer.layer.masksToBounds = true
        
        lblCancel.text = "Cancel"
        lblCancel.font = UIFont(name: Font.SegoeUISemibold, size: 17)
        lblCancel.textColor = .colorPrimary
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SelectGroupViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelectGroupCell.reuseIdentifer, for: indexPath) as! SelectGroupCell
        let category = groups[indexPath.row]
        cell.configureCell(category, selected: category == selected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: {
            self.delegate?.didSelectGroup(self.groups[indexPath.row])
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}


class SelectGroupCell: UITableViewCell {
    
    static let reuseIdentifer = "SelectGroupCell"
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        selectionStyle = .none
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setupViews() {
        addSubview(categoryLabel)
        
        addConstraintWithFormat("H:|-8-[v0]-8-|", views: categoryLabel)
        addConstraintWithFormat("V:|[v0]|", views: categoryLabel)
    }
    
    func configureCell(_ category: String, selected: Bool) {
        categoryLabel.text = category
        
        categoryLabel.font = selected ? UIFont(name: Font.SegoeUISemibold, size: 16) : UIFont(name: Font.SegoeUILight, size: 16)
        categoryLabel.textColor = selected ? .colorPrimary : .colorGray2
    }
}
