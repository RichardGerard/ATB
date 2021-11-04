//
//  MyFeedTableViewCell.swift
//  ATB
//
//  Created by mobdev on 2019/5/14.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

protocol FeedCellDelegate {
    func clickedOnFeedCell(index:Int, selected:Bool)
}

class MyFeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgCheckMark: UIImageView!
    @IBOutlet weak var cellView: RoundView!
    @IBOutlet weak var cellBtn: UIButton!
    @IBOutlet weak var lblFeedTitle: UILabel!
    var cellChecked:Bool = false
    var feedModel:FeedModel = FeedModel()
    var index:Int = 0
    var feedcellDelegate:FeedCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.hideCheck()
        self.cellView.backgroundColor = UIColor.atbFeedBackgroundColor
        
//        self.cellBtn.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        self.cellBtn.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
//        self.cellBtn.addTarget(self, action: #selector(buttonUp), for: .touchUpOutside)
    }
    
    func configureWithData(model:FeedModel, index:Int)
    {
        self.index = index
        self.feedModel = model
        self.lblFeedTitle.text = model.Title
        
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
    
//    @objc func buttonDown(_ sender: UIButton) {
//        UIView.animate(withDuration: 0.05, delay: 0, options: .curveLinear, animations: {
//            self.cellView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//        }) { (isCompleted) in
//
//        }
//    }
    
    @objc func buttonClick(_ sender: UIButton) {
        UIView.animate(withDuration: 0.06, delay: 0, options: .curveLinear, animations: {
            self.cellView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }) { (isCompleted) in
            UIView.animate(withDuration: 0.03, delay: 0, options: .curveLinear, animations: {
                if(self.cellChecked)
                {
                    self.setUncheck()
                }
                else
                {
                    self.setChecked()
                }
            }) { (isCompleted) in
                if(self.cellChecked)
                {
                    self.showCheckAnimation()
                }
                else
                {
                    self.hideCheckAnimation()
                }
            }
        }
    }
    
//    @objc func buttonUp(_ sender: UIButton) {
//        UIView.animate(withDuration: 0.03, delay: 0, options: .curveLinear, animations: {
//            if(self.cellChecked)
//            {
//                self.setChecked()
//            }
//            else
//            {
//                self.setUncheck()
//            }
//        }) { (isCompleted) in
//
//        }
//    }
    
    func setChecked()
    {
        self.cellChecked = true
        self.cellView.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.cellView.backgroundColor = UIColor.primaryButtonColor
        self.lblFeedTitle.textColor = UIColor.white
    }
    
    func setUncheck()
    {
        self.cellChecked = false
        self.cellView.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.cellView.backgroundColor = UIColor.atbFeedBackgroundColor
        self.lblFeedTitle.textColor = UIColor.textFieldPlaceHolderColor
    }
    
    func showCheckAnimation()
    {
        UIView.animate(withDuration: 0.08, delay: 0, options: .curveLinear, animations: {
            self.showCheck()
        }) { (isCompleted) in
            self.feedcellDelegate.clickedOnFeedCell(index: self.index, selected: self.cellChecked)
        }
    }
    
    func hideCheckAnimation()
    {
        UIView.animate(withDuration: 0.08, delay: 0, options: .curveLinear, animations: {
            self.hideCheck()
        }) { (isCompleted) in
            self.feedcellDelegate.clickedOnFeedCell(index: self.index, selected: self.cellChecked)
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
