//
//  SizeSelectorVC.swift
//  ATB
//
//  Created by mobdev on 11/2/19.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import PDFReader
import Lightbox

protocol SizeSelectorDelegate {
    func sizeSelected(val:String)
}

class SizeSelectorVC: UIViewController {

    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var collection_size: UICollectionView!
    
    var titleString = "Select Size"
    var sizeOptions = ["N/A", "One Size" , "4", "6", "8", "10", "12", "14", "16", "18", "20", "22", "24", "26", "28", "32", "XXS", "XS", "S", "M", "L", "XL", "XXL", "XXXL", "Other"]
    var sizeDelegate:SizeSelectorDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = viewBackground.bounds
        blurEffectView.alpha = 0.7
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.viewBackground.addSubview(blurEffectView)
        
        self.viewContainer.layer.cornerRadius = 25
        self.viewContainer.layer.shadowOffset = CGSize(width: 1, height: 5)
        self.viewContainer.layer.shadowColor = UIColor.lightGray.cgColor
        self.viewContainer.layer.shadowOpacity = 0.5
        self.viewContainer.layer.shadowRadius = 5.0
        self.viewContainer.layer.borderColor = UIColor.primaryButtonColor.cgColor
        self.viewContainer.layer.borderWidth = 1.0
        
        self.lblTitle.text = titleString
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.view.layoutIfNeeded()
    }
    
    @IBAction func onBtnClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SizeSelectorVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sizeOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SizeCollectionViewCell", for: indexPath) as! SizeCollectionViewCell
        cell.configureWithData(sizeVal: self.sizeOptions[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedSize = self.sizeOptions[indexPath.row]
        self.sizeDelegate.sizeSelected(val: selectedSize)
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let containerWidth = collectionView.frame.width
        let cellWidth = (containerWidth - 20) / 3
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10
    }
}
