//
//  FileListVC.swift
//  ATB
//
//  Created by mobdev on 6/8/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import PDFReader
import Lightbox

class FileListVC: UIViewController{
    
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var tblContainer: UIView!
    @IBOutlet weak var tblFileList: UITableView!
    @IBOutlet weak var heightConstraintForTblContainer: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    
    var fileList:[FileModel] = []
    var titleString:String = ""
    var selectedFile:FileModel = FileModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = viewBackground.bounds
        blurEffectView.alpha = 0.7
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.viewBackground.addSubview(blurEffectView)

        tblContainer.backgroundColor = .clear
        tblFileList.layer.borderColor = UIColor.primaryButtonColor.cgColor
        tblFileList.layer.borderWidth = 1.0
        
        tblContainer.layer.shadowOffset = CGSize(width: 1, height: 5)
        tblContainer.layer.shadowColor = UIColor.black.cgColor
        tblContainer.layer.shadowOpacity = 0.8
        tblContainer.layer.shadowRadius = 5.0
        
        self.lblTitle.text = titleString
        
        if(self.fileList.count > 0)
        {
            self.tblFileList.allowsSelection = true
            self.tblFileList.allowsMultipleSelection = false
        }
        else
        {
            self.tblFileList.allowsSelection = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tblFileList.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        if(self.fileList.count > 0)
        {
            heightConstraintForTblContainer.constant = CGFloat(50 * self.fileList.count)
        }
        else
        {
            heightConstraintForTblContainer.constant = 50.0
        }
        super.view.layoutIfNeeded()
    }
    
    @IBAction func onBtnClose(_ sender: UIButton) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension FileListVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.fileList.count > 0)
        {
            return self.fileList.count
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fileCell = tableView.dequeueReusableCell(withIdentifier: "FileListTableViewCell",
                                                            for: indexPath) as! FileListTableViewCell
        if(self.fileList.count > 0)
        {
            fileCell.textLabel?.text = self.fileList[indexPath.row].fullFileName
        }
        else
        {
            fileCell.textLabel!.text = "No Files"
            fileCell.textLabel!.textAlignment = .center
        }
        
        return fileCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFile = self.fileList[indexPath.row]
        
        if(selectedFile.fileType.lowercased() == "pdf")
        {
            //self.showIndicator()
            if let remotePDFDocumentURL = URL(string: DOMAIN_URL + selectedFile.fileUrl), let document = PDFDocument(url: remotePDFDocumentURL) {
                //self.hideIndicator()
                let image = UIImage(named: "")
                let docViewVC = PDFViewController.createNew(with: document, title: "", actionButtonImage: image, actionStyle: .activitySheet)
                self.navigationController?.pushViewController(docViewVC, animated: true)
            } else {
                self.showErrorVC(msg: "Unable to open the pdf file.")
            }
        }
        else
        {
            let imageUrl = self.selectedFile.fileUrl
            let images = [
                LightboxImage(imageURL: URL(string: DOMAIN_URL + imageUrl)!)]
            let imageViewerVC = LightboxController(images: images)
            imageViewerVC.dynamicBackground = true
            self.navigationController?.present(imageViewerVC, animated: true, completion: nil)
        }
    }
}
