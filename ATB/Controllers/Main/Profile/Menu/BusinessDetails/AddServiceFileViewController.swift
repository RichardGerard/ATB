//
//  AddInsuranceViewController.swift
//  ATB
//
//  Created by YueXi on 7/21/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

// MARK: Protocol - AddServiceFileDelegate
protocol AddServiceFileDelegate {
    
    func didAddServiceFile(_ added: ServiceFileModel)    
    func didUpdateServiceFile(_ updated: ServiceFileModel)
}

class AddServiceFileViewController: BaseViewController {
    
    static let kStoryboardID = "AddServiceFileViewController"
    class func instance() -> AddServiceFileViewController {
        let storyboard = UIStoryboard(name: "BusinessDetails", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: AddServiceFileViewController.kStoryboardID) as? AddServiceFileViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var topRoundView: UIView!
    
    /// Navigation
    @IBOutlet weak var imvNavLogo: UIImageView!
    @IBOutlet weak var lblNavTitle: UILabel!
    @IBOutlet weak var imvClose: UIImageView!
    
    @IBOutlet weak var txfName: RoundRectTextField!
    @IBOutlet weak var txfReference: RoundRectTextField!
    @IBOutlet weak var txfExpiry: RoundRectTextField!
    
    @IBOutlet weak var imvServiceFile: UIImageView!
    @IBOutlet weak var lblServiceFileName: UILabel!
    
    @IBOutlet weak var btnAdd: UIButton!
    
    var isInsurance: Bool =  true
        
    let imagePicker = UIImagePickerController()
    
    // (FileName, FileType, Data or URL string)
    // "application/pdf" or "image/jpeg image/png"
    var serviceFile: (String, String, Any?)? = nil
    
    // this will be passed when editing the file
    var selectedFile: ServiceFileModel!
    
    var delegate: AddServiceFileDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image"]
        
        setupViews()
        
        // user gets this page to update the selected service file
        if let selectedFile = selectedFile {
            updateViews(withSelectedServiceFile: selectedFile)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        topRoundView.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 30)
    }
    
    private func setupViews() {
        self.view.backgroundColor = .clear
        
        topRoundView.backgroundColor = .colorGray14
        
        if #available(iOS 13.0, *) {
            imvNavLogo.image = UIImage(systemName: "checkmark.seal.fill")
        } else {
            // Fallback on earlier versions
        }
        imvNavLogo.contentMode = .scaleAspectFit
        imvNavLogo.tintColor = .colorPrimary
        
        if #available(iOS 13.0, *) {
            imvClose.image = UIImage(systemName: "xmark.circle.fill")
        } else {
            // Fallback on earlier versions
        }
        imvClose.tintColor = .colorGray4
        
        if isInsurance {
            lblNavTitle.text = "Add An Insurance"
            
            setupInputField(txfName, placeholder: "Insurance Company")
            setupInputField(txfReference, placeholder: "Insurance Number")
            setupInputField(txfExpiry, placeholder: "Insurance Expiry")
            
            btnAdd.setTitle(" Add this Insurance", for: .normal)
            
        } else {
            lblNavTitle.text = "Add A Certification"
            
            setupInputField(txfName, placeholder: "Qualified Service Name")
            setupInputField(txfReference, placeholder: "Certification Number")
            
            setupInputField(txfExpiry, placeholder: "Qualified Since")
            
            btnAdd.setTitle(" Add this Certification", for: .normal)
        }
        
        txfName.autocapitalizationType = .words
        
        lblNavTitle.font = UIFont(name: Font.SegoeUISemibold, size: 18)
        txfReference.autocapitalizationType = .allCharacters
        
        // create a UIDatePicker
        let datePicker = UIDatePicker()
        datePicker.sizeToFit()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            // add conditions for iOS 14
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.backgroundColor = .colorGray7
        datePicker.setValue(UIColor.colorGray19, forKey: "textColor")
        
        // create a tool bar and assign it to inputAccessoryView
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        toolbar.barTintColor = .colorGray7
        toolbar.layer.borderWidth = 1
        toolbar.layer.borderColor = UIColor.colorGray17.cgColor
        toolbar.clipsToBounds = true
        
        let boldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Semibold", size: 18)!,
            .foregroundColor: UIColor.colorGray19
        ]
        
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Light", size: 18)!,
            .foregroundColor: UIColor.colorGray19
        ]
        
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nibName, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dateSelected))
        doneButton.setTitleTextAttributes(boldAttrs, for: .normal)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dateCancelled))
        cancelButton.setTitleTextAttributes(normalAttrs, for: .normal)
        toolbar.setItems([cancelButton, flexible, doneButton], animated: false)
        
        txfExpiry.inputView = datePicker
        txfExpiry.inputAccessoryView = toolbar
        
        if #available(iOS 13.0, *) {
            imvServiceFile.image = UIImage(systemName: "paperclip")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        
        imvServiceFile.tintColor = .white
        lblServiceFileName.text = "Add a file"
        lblServiceFileName.textColor = .white
        lblServiceFileName.font = UIFont(name: Font.SegoeUILight, size: 18)
                
        btnAdd.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        btnAdd.layer.cornerRadius = 5.0
        if #available(iOS 13.0, *) {
            btnAdd.setImage(UIImage(systemName: "plus"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        
        updateAddButton(false)
    }
    
    private func updateViews(withSelectedServiceFile serviceFile: ServiceFileModel) {
        txfName.text = serviceFile.name
        txfReference.text = serviceFile.reference
        txfExpiry.text = serviceFile.expiry
        if !serviceFile.fileName.isEmpty {
            lblServiceFileName.text = serviceFile.fileName
        }
        
        if isInsurance {
            lblNavTitle.text = "Update Insurance"
            btnAdd.setTitle(" Update this Insurance", for: .normal)
            
        } else {
            lblNavTitle.text = "Update Cerification"
            btnAdd.setTitle(" Update this Certification", for: .normal)
        }
        
        if #available(iOS 13.0, *) {
            btnAdd.setImage(UIImage(systemName: "arrow.2.circlepath"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        
        updateAddButton(true)
    }
    
    @objc func dateSelected() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "d MMM yyyy"
        
        guard let datePicker = txfExpiry.inputView as? UIDatePicker else {
            return
        }
        
        txfExpiry.text = dateFormatter.string(from: datePicker.date)
        txfExpiry.resignFirstResponder()
        
        checkValidation()
    }
    
    @objc func dateCancelled() {
        txfExpiry.text = ""
        txfExpiry.resignFirstResponder()
        
        checkValidation()
    }
    
    /// Setup input textfield
    private func setupInputField(_ textField: RoundRectTextField, placeholder: String) {
        textField.backgroundColor = .white
        textField.borderColor = .colorGray17
        textField.borderWidth = 1
       
        textField.placeholder = placeholder
        textField.tintColor = .colorGray19
        textField.textColor = .colorGray19
        textField.font = UIFont(name: "SegoeUI-Light", size: 18) // 23 (design size) looks little weird
        textField.inputPadding = 16
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
    }
    
    /// TextFieldDidChanged - called when text is changed
    /// always check validation and update 'Save Business Details' button
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // update validation here whenever text is changed or just call this on DidEndEditing if you want
        checkValidation()
    }
    
    private func checkValidation() {
//        guard !txfCompanyName.isEmpty(),
//            !txfReference.isEmpty(),
//            !txfExpiry.isEmpty(),
//            let _ = serviceFile else {
//                updateAddButton(false)
//                return
//        }
        
        guard !txfName.isEmpty(),
           !txfReference.isEmpty(),
           !txfExpiry.isEmpty() else {
               updateAddButton(false)
               return
       }
        
        updateAddButton(true)
    }
    
    private func updateAddButton(_ isEnabled: Bool) {
        if isEnabled {
            btnAdd.backgroundColor = .colorBlue5
            btnAdd.setTitleColor(.white, for: .normal)
            btnAdd.tintColor = .white
            
        } else {
            btnAdd.backgroundColor = UIColor.colorBlue5.withAlphaComponent(0.5)
            btnAdd.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
            btnAdd.tintColor = UIColor.white.withAlphaComponent(0.5)
        }
    }
    
    @IBAction func didTapAddFile(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
      
        let explore = UIAlertAction(title: "Explore Files", style: .default) { _ in
            self.openDocumentPicker()
        }
        actionSheet.addAction(explore)
        
        let picture = UIAlertAction(title: "Take a Picture", style: .default) { _ in
            self.openCamera()
        }
        actionSheet.addAction(picture)

        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancel)
        
        // button color
        actionSheet.view.tintColor = .colorPrimary
        
        self.present(actionSheet, animated: true)
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }
        
        imagePicker.sourceType = .camera
        DispatchQueue.main.async {
            self.present(self.imagePicker, animated: true)
        }
    }
    
    private func openDocumentPicker() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["PDF", "com.adobe.pdf"], in: .import)
        documentPicker.delegate = self
        DispatchQueue.main.async {
            self.present(documentPicker, animated: true)
        }
    }
    
    private func isValid() -> Bool {
        if txfName.isEmpty() {
            showErrorVC(msg: isInsurance ? "Please enter the insurance company name." : "Please enter the qualified service name.")
            return false
        }
        
        let prefix = isInsurance ? "insurance" : "certification"
        if txfReference.isEmpty() {
            showErrorVC(msg: "Please enter the \(prefix) number.")
            return false
        }
        
        if txfExpiry.isEmpty() {
            showErrorVC(msg: isInsurance ? "Please enter the insurance expiry date." : "Please enter the qualified-since date.")
            return false
        }
        
//        if serviceFile == nil {
//            showErrorVC(msg: "Please attach the \(prefix) document.")
//            return false
//        }
        
        return true
    }
    
    @IBAction func didTapAdd(_ sender: Any) {
        guard isValid() else { return }
        
        let type = isInsurance ? "0" : "1"
        let name = txfName.text!.trimmedString
        let reference = txfReference.text!.trimmedString
        let expiry = txfExpiry.text!
        let formattedExpiry = expiry.toDateString(fromFormat: "d MMM yyyy", toFormat: "YYYY/MM/dd")
        
        showIndicator()
        
        if let selectedServiceFile = selectedFile {
            APIManager.shared.updateServiceFile(g_myToken, id: selectedServiceFile.id, type: type, name: name, reference: reference, expiry: formattedExpiry, serviceFile: serviceFile) { (result, message) in
                self.hideIndicator()
                
                if result {
                    let newServiceFile = ServiceFileModel()
                    newServiceFile.id = selectedServiceFile.id
                    newServiceFile.type = type
                    newServiceFile.name = name
                    newServiceFile.reference = reference
                    newServiceFile.expiry = expiry
                    
                    if let serviceFile = self.serviceFile {
                        newServiceFile.fileName = serviceFile.0
                    }
                    
                    self.dismissSemiModalViewWithCompletion {
                        self.delegate?.didUpdateServiceFile(newServiceFile)
                    }
                    
                } else {
                    if let message = message {
                        self.showErrorVC(msg: message)
                    }
                }
            }
            
        } else {
            APIManager.shared.addServiceFile(g_myToken, type: type, name: name, reference: reference, expiry: formattedExpiry, serviceFile: serviceFile) { (result, message, value) in
                self.hideIndicator()
                
                if result,
                    let serviceFileID = value {
                    
                    let newServiceFile = ServiceFileModel()
                    newServiceFile.id = "\(serviceFileID)"
                    newServiceFile.type = type
                    newServiceFile.name = name
                    newServiceFile.reference = reference
                    newServiceFile.expiry = expiry
                    
                    if let serviceFile = self.serviceFile {
                        newServiceFile.fileName = serviceFile.0
                    }
                    
                    self.dismissSemiModalViewWithCompletion {
                        self.delegate?.didAddServiceFile(newServiceFile)
                    }
                     
                } else {
                    if let message = message {
                        self.showErrorVC(msg: message)
                    }
                }
            }
        }
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        dismissSemiModalView()
    }
}

// MARK: UITextFieldDelegate
extension AddServiceFileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txfName {
            txfReference.becomeFirstResponder()
        }
        
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: UIImagePickerControllerDelegate
extension AddServiceFileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage,
            let imageData = image.jpegData(compressionQuality: 0.75) else {
            return
        }
        
        let fileName = isInsurance ? "Insurance.jpeg" : "Qualification.jpeg"
        serviceFile = (fileName, "image/jpeg", imageData)
        lblServiceFileName.text = fileName
        
        checkValidation()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: UIDocumentPickerDelegate
extension AddServiceFileViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true, completion: nil)
        
        guard urls.count > 0 else { return }
        
        let fileURL = urls.first!
        guard let fileData = try? Data(contentsOf: fileURL) else {
            return
        }
        
        let serviceFileName = fileURL.lastPathComponent
        serviceFile = (serviceFileName, "application/pdf", fileData)
        lblServiceFileName.text = serviceFileName
        
        checkValidation()
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
//        serviceFile = nil
//        lblServiceFileName.text = "Add a file"
    }
}

/*
let docsTypes = ["public.text",
                        "com.apple.iwork.pages.pages",
                        "public.data",
                        "kUTTypeItem",
                        "kUTTypeContent",
                        "kUTTypeCompositeContent",
                        "kUTTypeData",
                        "public.database",
                        "public.calendar-event",
                        "public.message",
                        "public.presentation",
                        "public.contact",
                        "public.archive",
                        "public.disk-image",
                        "public.plain-text",
                        "public.utf8-plain-text",
                        "public.utf16-external-plain-​text",
                        "public.utf16-plain-text",
                        "com.apple.traditional-mac-​plain-text",
                        "public.rtf",
                        "com.apple.ink.inktext",
                        "public.html",
                        "public.xml",
                        "public.source-code",
                        "public.c-source",
                        "public.objective-c-source",
                        "public.c-plus-plus-source",
                        "public.objective-c-plus-​plus-source",
                        "public.c-header",
                        "public.c-plus-plus-header",
                        "com.sun.java-source",
                        "public.script",
                        "public.assembly-source",
                        "com.apple.rez-source",
                        "public.mig-source",
                        "com.apple.symbol-export",
                        "com.netscape.javascript-​source",
                        "public.shell-script",
                        "public.csh-script",
                        "public.perl-script",
                        "public.python-script",
                        "public.ruby-script",
                        "public.php-script",
                        "com.sun.java-web-start",
                        "com.apple.applescript.text",
                        "com.apple.applescript.​script",
                        "public.object-code",
                        "com.apple.mach-o-binary",
                        "com.apple.pef-binary",
                        "com.microsoft.windows-​executable",
                        "com.microsoft.windows-​dynamic-link-library",
                        "com.sun.java-class",
                        "com.sun.java-archive",
                        "com.apple.quartz-​composer-composition",
                        "org.gnu.gnu-tar-archive",
                        "public.tar-archive",
                        "org.gnu.gnu-zip-archive",
                        "org.gnu.gnu-zip-tar-archive",
                        "com.apple.binhex-archive",
                        "com.apple.macbinary-​archive",
                        "public.url",
                        "public.file-url",
                        "public.url-name",
                        "public.vcard",
                        "public.image",
                        "public.fax",
                        "public.jpeg",
                        "public.jpeg-2000",
                        "public.tiff",
                        "public.camera-raw-image",
                        "com.apple.pict",
                        "com.apple.macpaint-image",
                        "public.png",
                        "public.xbitmap-image",
                        "com.apple.quicktime-image",
                        "com.apple.icns",
                        "com.apple.txn.text-​multimedia-data",
                        "public.audiovisual-​content",
                        "public.movie",
                        "public.video",
                        "com.apple.quicktime-movie",
                        "public.avi",
                        "public.mpeg",
                        "public.mpeg-4",
                        "public.3gpp",
                        "public.3gpp2",
                        "public.audio",
                        "public.mp3",
                        "public.mpeg-4-audio",
                        "com.apple.protected-​mpeg-4-audio",
                        "public.ulaw-audio",
                        "public.aifc-audio",
                        "public.aiff-audio",
                        "com.apple.coreaudio-​format",
                        "public.directory",
                        "public.folder",
                        "public.volume",
                        "com.apple.package",
                        "com.apple.bundle",
                        "public.executable",
                        "com.apple.application",
                        "com.apple.application-​bundle",
                        "com.apple.application-file",
                        "com.apple.deprecated-​application-file",
                        "com.apple.plugin",
                        "com.apple.metadata-​importer",
                        "com.apple.dashboard-​widget",
                        "public.cpio-archive",
                        "com.pkware.zip-archive",
                        "com.apple.webarchive",
                        "com.apple.framework",
                        "com.apple.rtfd",
                        "com.apple.flat-rtfd",
                        "com.apple.resolvable",
                        "public.symlink",
                        "com.apple.mount-point",
                        "com.apple.alias-record",
                        "com.apple.alias-file",
                        "public.font",
                        "public.truetype-font",
                        "com.adobe.postscript-font",
                        "com.apple.truetype-​datafork-suitcase-font",
                        "public.opentype-font",
                        "public.truetype-ttf-font",
                        "public.truetype-collection-​font",
                        "com.apple.font-suitcase",
                        "com.adobe.postscript-lwfn​-font",
                        "com.adobe.postscript-pfb-​font",
                        "com.adobe.postscript.pfa-​font",
                        "com.apple.colorsync-profile",
                        "public.filename-extension",
                        "public.mime-type",
                        "com.apple.ostype",
                        "com.apple.nspboard-type",
                        "com.adobe.pdf",
                        "com.adobe.postscript",
                        "com.adobe.encapsulated-​postscript",
                        "com.adobe.photoshop-​image",
                        "com.adobe.illustrator.ai-​image",
                        "com.compuserve.gif",
                        "com.microsoft.bmp",
                        "com.microsoft.ico",
                        "com.microsoft.word.doc",
                        "com.microsoft.excel.xls",
                        "com.microsoft.powerpoint.​ppt",
                        "com.microsoft.waveform-​audio",
                        "com.microsoft.advanced-​systems-format",
                        "com.microsoft.windows-​media-wm",
                        "com.microsoft.windows-​media-wmv",
                        "com.microsoft.windows-​media-wmp",
                        "com.microsoft.windows-​media-wma",
                        "com.microsoft.advanced-​stream-redirector",
                        "com.microsoft.windows-​media-wmx",
                        "com.microsoft.windows-​media-wvx",
                        "com.microsoft.windows-​media-wax",
                        "com.apple.keynote.key",
                        "com.apple.keynote.kth",
                        "com.truevision.tga-image",
                        "com.sgi.sgi-image",
                        "com.ilm.openexr-image",
                        "com.kodak.flashpix.image",
                        "com.j2.jfx-fax",
                        "com.js.efx-fax",
                        "com.digidesign.sd2-audio",
                        "com.real.realmedia",
                        "com.real.realaudio",
                        "com.real.smil",
                        "com.allume.stuffit-archive",
                        "org.openxmlformats.wordprocessingml.document",
                        "com.microsoft.powerpoint.​ppt",
                        "org.openxmlformats.presentationml.presentation",
                        "com.microsoft.excel.xls",
                        "org.openxmlformats.spreadsheetml.sheet",
                       
  
]
*/
