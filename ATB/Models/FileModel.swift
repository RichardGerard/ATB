//
//  FileModel.swift
//  ATB
//
//  Created by mobdev on 29/7/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit

class FileModel{
    var fileName: String = ""
    var fileData: Data = Data()
    var fileType: String = ""
    var fullFileName: String = ""
    var fileUrl: String = ""
    
    init(strFileUrl: String)
    {
        if let fileUrl = URL(string: DOMAIN_URL + strFileUrl)
        {
            let strFileName = fileUrl.lastPathComponent
            let strFileExtension = fileUrl.pathExtension
            let fileName = strFileName.replacingLastOccurrenceOfString("." + strFileExtension, with: "")
            
            self.fullFileName = strFileName
            self.fileType = strFileExtension
            self.fileName = fileName
            self.fileUrl = strFileUrl
            self.fileData = Data()
        }
        else
        {
            self.fileName = ""
            self.fileData = Data()
            self.fileType = ""
            self.fullFileName = ""
            self.fileUrl = ""
        }
    }
    
    init()
    {
        self.fileName = ""
        self.fileData = Data()
        self.fileType = ""
        self.fullFileName = ""
        self.fileUrl = ""
    }
}
