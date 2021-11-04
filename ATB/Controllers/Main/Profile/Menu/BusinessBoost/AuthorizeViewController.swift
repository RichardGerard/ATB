//
//  AuthorizeViewController.swift
//  ATB
//
//  Created by YueXi on 5/13/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import TOWebViewController

protocol PaymentAuthorizationDelegate {
    
    func didAuthorizePayment()
    func didCancelAuthorization()
}

class AuthorizeViewController: TOWebViewController {
    
    var approvalLink: String = ""
    
    var delegate: PaymentAuthorizationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Authorization"
        
        showUrlWhileLoading = false
        
        showPageTitles = false
        
        loadingBarTintColor = .colorPrimary
        
        buttonTintColor = .colorPrimary
        
        guard let approvalURL = URL(string: approvalLink) else { return }
        
        self.url = approvalURL
        
        self.modalCompletionHandler = {
            self.delegate?.didCancelAuthorization()
        }
        
        let redirectUrl = DOMAIN_URL + "payment/"
        self.shouldStartLoadRequestHandler = { (request, navigationType) in
            if let loadUrl = request.url,
               let _ = loadUrl.absoluteString.range(of: redirectUrl) {
                print(loadUrl.absoluteString)
                
                self.dismiss(animated: true) {
                    if loadUrl.absoluteString.contains("success") {
                        self.delegate?.didAuthorizePayment()
                        
                    } else {
                        self.delegate?.didCancelAuthorization()
                    }
                }
                
                return false
            }
            
            return true
        }
        
        self.didFinishLoadHandler = { (webView) in
            
        }
    }

}
