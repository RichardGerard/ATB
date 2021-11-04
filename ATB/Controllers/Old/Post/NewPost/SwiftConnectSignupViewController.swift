//
//  SwiftConnectSignupViewController.swift
//  ATB
//
//  Created by Zachary Powell on 03/12/2019.
//  Copyright © 2019 mobdev. All rights reserved.
//

import UIKit

class SwiftConnectSignupViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    let redirectURL = "https://connect.stripe.com/connect/default/oauth/test"
    
    var loadingStripe = true
    
    @IBAction func backBtnClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let birthday = g_myInfo.birthDay
        let birthdayParts = birthday.components(separatedBy: "-")
        
        
        var urlString = "https://connect.stripe.com/express/oauth/authorize?client_id=ca_DXkbn1kqnW0HxYAoEqSEBkHUYA9WfsJn&suggested_capabilities[]=card_payments"
        urlString += "&redirect_uri=" + redirectURL
        urlString += "&state=" + g_myInfo.ID
        urlString += "&stripe_user[email]=" + g_myInfo.emailAddress
        urlString += "&stripe_user[country]=GB"
        urlString += "&stripe_user[first_name]=" + g_myInfo.firstName
        urlString += "&stripe_user[last_name]=" + g_myInfo.lastName
        urlString += "&stripe_user[business_type]=individual"
        urlString += "&stripe_user[dob_day]=" + birthdayParts[0]
        urlString += "&stripe_user[dob_month]=" + birthdayParts[1]
        urlString += "&stripe_user[dob_year]=" + birthdayParts[2]
        urlString += "&stripe_user[product_description]=Selling goods and services on ATB"

        
        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)   {
            let request = URLRequest(url: url as URL)
            webView.loadRequest(request)
        }
        // Do any additional setup after loading the view.
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        let url = webView.request?.url?.absoluteString
        
        let startsWith = url?.starts(with: redirectURL) ?? false
        if (startsWith && loadingStripe){
            webView.isHidden = true
            loadingStripe = false
            let code = getQueryStringParameter(url: url ?? "", param: "code")
            
            let params = [
                "token" : g_myToken,
                "connect" : code!,
                ] as [String : Any]
            
            _ = ATB_Alamofire.POST(ADD_CONNECT_ACCOUNT, parameters: params as [String : AnyObject],showLoading: false,showSuccess: false,showError: false){
                (result, responseObject) in
                print(responseObject)
                
                if(result)
                {
                    let postDicts = responseObject.object(forKey: "msg")  as? String ?? ""
                    
                    //g_myInfo.stripe_connect_id = postDicts
                    
                    let alert = UIAlertController(title: "Success", message: "Stripe account created successfully!", preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.navigationController?.popViewController(animated: true)}))
                    self.navigationController?.present(alert, animated: true)
                    
                    
                }
                
            }
            
        }
        
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error)
    {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        

    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
}
