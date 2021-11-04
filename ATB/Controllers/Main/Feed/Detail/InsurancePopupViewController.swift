//
//  InsurancePopupViewController.swift
//  ATB
//
//  Created by YueXi on 11/13/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import MobileCoreServices
import QuickLook
import Photos

class InsurancePopupViewController: BaseViewController {
    
    @IBOutlet weak var imvSeal: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblExpire: UILabel!
    
    @IBOutlet weak var imvThumbnail: UIImageView!
    
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var btnOk: UIButton!
    
    var isInsurance: Bool = true
    
    var urlString: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initView()
    }
    
    private func initView() {
        if #available(iOS 13.0, *) {
            imvSeal.image = UIImage(systemName: "checkmark.seal.fill")
        } else {
            // Fallback on earlier versions
        }
        imvSeal.tintColor = .colorPrimary
        
        
        
        lblName.text = isInsurance ? "Electrical Insurance" : "Electrical Support"
        lblName.font = UIFont(name: Font.SegoeUISemibold, size: 23)
        lblName.textColor = .colorGray2
        
        lblExpire.text = isInsurance ? "Insurance Until 4th May 2020" : "Qualified Since 4th May 2015"
        lblExpire.font = UIFont(name: Font.SegoeUISemibold, size: 15)
        lblExpire.textColor = .colorPrimary
        
        btnDownload.backgroundColor = .colorGray14
        btnDownload.layer.cornerRadius = 5
        btnDownload.setTitle("Download", for: .normal)
        btnDownload.setTitleColor(.colorPrimary, for: .normal)
        btnDownload.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        
        btnOk.backgroundColor = .colorPrimary
        btnOk.layer.cornerRadius = 5
        btnOk.setTitle("Ok", for: .normal)
        btnOk.setTitleColor(.white, for: .normal)
        btnOk.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        
        imvThumbnail.contentMode = .scaleAspectFill
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let fileURL = URL(string: urlString),
           let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileURL.pathExtension as CFString, nil) {
            if UTTypeConformsTo(uti.takeRetainedValue(), kUTTypeImage) {
                imvThumbnail.loadImageFromUrl(urlString, placeholder: "post.placeholder")
                
            } else {
                showIndicator()
                
                getThumbnailFrom(url: fileURL) { thumbnail in
                    self.hideIndicator()
                    
                    if let thumbnail = thumbnail {
                        self.imvThumbnail.image = thumbnail
                        
                    } else {
                        
                    }
                }
            }
        }
    }
    
    func getThumbnailFrom(url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let pdf: CGPDFDocument = CGPDFDocument(url as CFURL),
               let firstPage = pdf.page(at: 1) {
                let width = SCREEN_WIDTH - 44
                var pageRect:CGRect = firstPage.getBoxRect(CGPDFBox.mediaBox)
                let pdfScale:CGFloat = width/pageRect.size.width
                pageRect.size = CGSize(width: pageRect.size.width*pdfScale, height: pageRect.size.height*pdfScale)
                pageRect.origin = CGPoint.zero
                
                UIGraphicsBeginImageContext(pageRect.size)
                
                if let context:CGContext = UIGraphicsGetCurrentContext() {
                    // White BG
                    context.setFillColor(red: 1.0,green: 1.0,blue: 1.0,alpha: 1.0)
                    context.fill(pageRect)
                    
                    context.saveGState()
                    
                    // Next 3 lines makes the rotations so that the page look in the right direction
                    context.translateBy(x: 0.0, y: pageRect.size.height)
                    context.scaleBy(x: 1.0, y: -1.0)
                    context.concatenate((firstPage.getDrawingTransform(CGPDFBox.mediaBox, rect: pageRect, rotate: 0, preserveAspectRatio: true)))
                    
                    context.drawPDFPage(firstPage)
                    context.restoreGState()
                    
                    if let thumbnail = UIGraphicsGetImageFromCurrentImageContext() {
                        UIGraphicsEndImageContext();
                        DispatchQueue.main.async {
                            completion(thumbnail)
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
    @IBAction func didTapDownload(_ sender: Any) {
        guard let fileURL = URL(string: urlString),
              let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileURL.pathExtension as CFString, nil) else { return }
        
        showIndicator()
        if UTTypeConformsTo(uti.takeRetainedValue(), kUTTypeImage) {
            downloadImageFromURL(fileURL) { result in
                DispatchQueue.main.async {
                    self.hideIndicator()

                    switch result {
                    case .success(let downloaded):
                        self.downloadCompleted(downloaded)

                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
            
        } else {
            // save PDF to document folder
            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
            let downloadTask = urlSession.downloadTask(with: fileURL)
            downloadTask.resume()
        }
    }
    
    @IBAction func didTapOk(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func downloadImageFromURL(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let sharedSession = URLSession.shared
        let _ = sharedSession.dataTask(with: url) { data, response, error in
            guard error == nil,
                  let downloaded = data else {
                completion(.failure(error!))
                return
            }
            
            completion(.success(downloaded))
        }.resume()
    }
    
    private func downloadCompleted(_ data: Data) {
        CustomPhotoAlbum.shared.save(image: UIImage(data: data)!) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.showSuccessVC(msg: "The file has been downloaded and saved successfully!")
                    
                case .failure(let error):
                    self.showErrorVC(msg: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: URLSesssionDownloadDelegate
extension InsurancePopupViewController: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.async {
            self.hideIndicator()
        }
        
        guard let url = downloadTask.originalRequest?.url,
              let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let directoryPath = documentsPath.appendingPathComponent("ATB's")
        let directoryExist = FileManager.default.fileExists(atPath: directoryPath.path)
        if !directoryExist {
            do {
                try FileManager.default.createDirectory(at: directoryPath, withIntermediateDirectories: true, attributes: nil)
                
            } catch let error {
                print("An error has been occured while creating the document directory: \(error.localizedDescription)")
            }
        }
        
        let destinationURL = directoryPath.appendingPathComponent(url.lastPathComponent)

        // delete original copy
        try? FileManager.default.removeItem(at: destinationURL)

        // copy from temp to Document
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)

            DispatchQueue.main.async {
                self.showSuccessVC(msg: "The file has been downloaded and saved successfully!")
            }

        } catch let error {
            print(error.localizedDescription)

            DispatchQueue.main.async {
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
}

class CustomPhotoAlbum: NSObject {
    static let albumName = "ATB"
    static let shared = CustomPhotoAlbum()

    private var assetCollection: PHAssetCollection!

    override init() {
        super.init()

        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
        }
    }

    private func checkAuthorizationWithHandler(completion: @escaping ((_ success: Bool) -> Void)) {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                self.checkAuthorizationWithHandler(completion: completion)
            })
            
        } else if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.createAlbumIfNeeded()
            completion(true)
            
        } else {
            completion(false)
        }
    }

    private func createAlbumIfNeeded() {
        if let assetCollection = fetchAssetCollectionForAlbum() {
            // Album already exists
            self.assetCollection = assetCollection
            
        } else {
            PHPhotoLibrary.shared().performChanges({
                PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: CustomPhotoAlbum.albumName)   // create an asset collection with the album name
            }) { success, error in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                    
                } else {
                    // Unable to create album
                }
            }
        }
    }

    private func fetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", CustomPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)

        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        
        return nil
    }

    func save(image: UIImage, completion: @escaping (Result<Bool, Error>) -> Void) {
        self.checkAuthorizationWithHandler { success in
            if success, self.assetCollection != nil {
                PHPhotoLibrary.shared().performChanges({
                    let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
                    let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                    let enumeration: NSArray = [assetPlaceHolder!]
                    albumChangeRequest!.addAssets(enumeration)

                }, completionHandler: { result, error in
                    guard result,
                          error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    
                    completion(.success(true))
                })
                
            } else {
                completion(.failure("Access to Photo Library has been denied!"))
            }
        }
    }
}

// MARK: String
extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
