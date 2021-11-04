//
//  UploadedFileTableViewCell.swift
//  ATB
//
//  Created by mobdev on 29/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class UploadedFileTableViewCell: UITableViewCell {
    var index:Int!
    var fileData:FileModel = FileModel()
    var tableViewType:Int = 0
    var fileCellDelegate:FileCellDelegate!
    
    @IBOutlet weak var imgFileType: UIImageView!
    @IBOutlet weak var lblFileName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureWithData(index:Int, fileData:FileModel, tableViewType:Int)
    {
        self.fileData = fileData
        self.index = index
        self.tableViewType = tableViewType
        
        if(fileData.fileType.lowercased() == "pdf")
        {
            self.imgFileType.image = UIImage(named: "file_pdf")
        }
        else
        {
            self.imgFileType.image = UIImage(named: "file_img")
        }
        
        self.lblFileName.text = self.fileData.fullFileName
    }
    
    @IBAction func onBtnRemove(_ sender: UIButton) {
        self.fileCellDelegate.fileDeleted(index: self.index, tableViewType: self.tableViewType)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
