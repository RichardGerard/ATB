//
//  FeedListTableViewCell.swift
//  ATB
//
//  Created by mobdev on 2019/5/21.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

protocol FeedListCellDelegate {
    func clickedOnFeed(index:Int, selected:Bool)
}

class FeedListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgCheckMark: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnCell: UIButton!
    @IBOutlet weak var cellView: UIView!
    
    var feedModel:FeedModel = FeedModel()
    var index:Int = 0
    var feedlistDelegate:FeedListCellDelegate!
    var cellChecked:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.hideCheck()
        
        self.btnCell.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
    }
    
    func configureWithData(model:FeedModel, index:Int)
    {
        self.index = index
        self.feedModel = model
        self.lblTitle.text = model.Title
        
        if(model.Checked)
        {
            self.setChecked()
            self.showCheck()
        }
        else
        {
            self.setUncheck()
            self.hideCheck()
        }
    }
    
    @objc func buttonClick(_ sender: UIButton) {
        if(self.cellChecked)
        {
            self.setUncheck()
            self.hideCheckAnimation()
        }
        else
        {
            self.setChecked()
            self.showCheckAnimation()
        }
    }
    
    func setChecked()
    {
        self.cellChecked = true
        self.lblTitle.textColor = UIColor.primaryButtonColor
    }
    
    func setUncheck()
    {
        self.cellChecked = false
        self.lblTitle.textColor = UIColor.textFieldPlaceHolderColor
    }
    
    func showCheckAnimation()
    {
        UIView.animate(withDuration: 0.08, delay: 0, options: .curveLinear, animations: {
            self.showCheck()
        }) { (isCompleted) in
            self.feedlistDelegate.clickedOnFeed(index: self.index, selected: self.cellChecked)
        }
    }
    
    func hideCheckAnimation()
    {
        UIView.animate(withDuration: 0.08, delay: 0, options: .curveLinear, animations: {
            self.hideCheck()
        }) { (isCompleted) in
            self.feedlistDelegate.clickedOnFeed(index: self.index, selected: self.cellChecked)
        }
    }
    
    func hideCheck()
    {
        self.imgCheckMark.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
    }
    
    func showCheck()
    {
        self.imgCheckMark.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.setUncheck()
        self.hideCheck()
    }
}
