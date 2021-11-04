//
//  PollMediaCell.swift
//  ATB
//
//  Created by YueXi on 8/17/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class PollMediaCell: UICollectionViewCell {
    
    static let reusableIdentifier = "PollMediaCell"
    
    @IBOutlet weak var vMediaContainer: UIView! { didSet {
        vMediaContainer.layer.cornerRadius = 5
        vMediaContainer.clipsToBounds = true
        }}
    @IBOutlet weak var imvMedia: UIImageView! { didSet {
        imvMedia.contentMode = .scaleAspectFill
        }}
    @IBOutlet weak var btnDelete: UIButton! { didSet {
        
        }}
    
    
    var deleteBlock: (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
    }
    
    
    @IBAction func didTapDelete(_ sender: Any) {
        deleteBlock?()
    }
    
}
