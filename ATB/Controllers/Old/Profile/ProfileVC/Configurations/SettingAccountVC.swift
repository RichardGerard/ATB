//
//  SettingAccountVC.swift
//  ATB
//
//  Created by mobdev on 2019/5/23.
//  Copyright © 2019 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Stripe

class SettingAccountVC: UIViewController {
    
    @IBOutlet weak var tbl_payments: UITableView!
    @IBOutlet weak var tblHeight: NSLayoutConstraint!
    @IBOutlet weak var addbtnTopValue: NSLayoutConstraint!
    
    var array_cards:[PaymentMethodModel] = []
    var default_sourceID:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tblHeight.constant = 0.0
        self.loadCards()
    }
    
    func loadCards()
    {
        let params = [
            "token" : g_myToken
        ]
        
        _ = ATB_Alamofire.POST(LOAD_CARDS_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            self.view.isUserInteractionEnabled = true
            print(responseObject)
            
            if(result)
            {
                let cardDicts = responseObject.object(forKey: "msg")  as! [NSDictionary]
                
                for cardDict in cardDicts
                {
                    let cardModel = PaymentMethodModel(info: cardDict)
                    self.array_cards.append(cardModel)
                }
                self.reloadPaymentTable()
            }
            else
            {
                let msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if(msg == "")
                {
                    self.showErrorVC(msg: "Failed to load card details, please try again")
                }
                else
                {
                    self.showErrorVC(msg: "Server returned the error message: " + msg)
                }
            }
        }
    }
    
    func saveCard(cardToken:String, strCardType:String, cardRedactedNum:String, cardVC:STPAddCardViewController)
    {
        let params = [
            "token" : g_myToken,
            "kind" : "2",
            "title" : strCardType,
            "card_token" : cardToken,
            "card_number" : cardRedactedNum
        ]
        
        print(params)
        
        _ = ATB_Alamofire.POST(ADD_CARD_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            self.view.isUserInteractionEnabled = true
            print(responseObject)
            
            if(result)
            {
                let cardInfo = responseObject.object(forKey: "msg") as! NSDictionary
                let newcardModel = PaymentMethodModel(info: cardInfo)
                self.array_cards.append(newcardModel)
                self.showSuccessVC(msg: "Card was added successfully!")
                self.reloadPaymentTable()
                cardVC.dismiss(animated: true, completion: nil)
            }
            else
            {
                cardVC.dismiss(animated: true, completion: nil)
                let msg = responseObject.object(forKey: "msg") as? String ?? ""
                
                if(msg == "")
                {
                    self.showErrorVC(msg: "Failed to add card, please try again")
                }
                else
                {
                    self.showErrorVC(msg: "Server returned the error message: " + msg)
                }
                
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.view.layoutIfNeeded()
        view.layoutIfNeeded()
    }
    
    @IBAction func OnBtnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func OnBtnAddCard(_ sender: UIButton) {
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
    }
    
    func reloadPaymentTable()
    {
        self.tbl_payments.reloadData()
        self.tblHeight.constant = CGFloat(self.array_cards.count * 50)
        self.view.layoutIfNeeded()
    }
    
}

extension SettingAccountVC:STPAddCardViewControllerDelegate
{
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        dismiss(animated: true)
    }
    
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        let card_token = token.tokenId
        let card_brand = STPCard.string(from: token.card!.brand)
        
        self.saveCard(cardToken: card_token, strCardType: card_brand, cardRedactedNum: token.card!.last4, cardVC: addCardViewController)
    }
}

extension SettingAccountVC:UITableViewDelegate, UITableViewDataSource, PaymentMethodCellDelegate
{
    func onSelectedPayment(index:Int) {
        let alert = UIAlertController(title: "Alert", message: "Do you want to set this card as primary payment method?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.updatePrimary(index: index)
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            
        }))
        
        self.navigationController?.present(alert, animated: true)
    }
    
    func deleteCard(index:Int)
    {
        let alert = UIAlertController(title: "Alert", message: "Do you want to remove this card?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            let cardData = self.array_cards[index]
            let params = [
                "token" : g_myToken,
                "card_id" : cardData.CardID
            ]
            
            _ = ATB_Alamofire.POST(DELETE_CARD_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
                (result, responseObject) in
                self.view.isUserInteractionEnabled = true
                print(responseObject)
                
                if(result)
                {
                    self.showSuccessVC(msg: "Card was removed successfully.")
                    
                    self.array_cards = []
                    let cardDicts = responseObject.object(forKey: "msg")  as! [NSDictionary]
                    
                    for cardDict in cardDicts
                    {
                        let cardModel = PaymentMethodModel(info: cardDict)
                        self.array_cards.append(cardModel)
                    }
                    self.reloadPaymentTable()
                }
                else
                {
                    let msg = responseObject.object(forKey: "msg") as? String ?? ""
                    
                    if(msg == "")
                    {
                        self.showErrorVC(msg: "Failed to remove card, please try again")
                    }
                    else
                    {
                        self.showErrorVC(msg: "Server returned the error message: " + msg)
                    }
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            
        }))
        
        self.navigationController?.present(alert, animated: true)
    }
    
    func updatePrimary(index:Int)
    {
        let cardData = self.array_cards[index]
        let params = [
            "token" : g_myToken,
            "card_id" : cardData.CardID
        ]

        _ = ATB_Alamofire.POST(SET_PRIMARYCARD_API, parameters: params as [String : AnyObject],showLoading: true,showSuccess: false,showError: false){
            (result, responseObject) in
            self.view.isUserInteractionEnabled = true
            print(responseObject)

            if(result)
            {
                self.showSuccessVC(msg: "Primary payment method was updated successfully.")
                
                self.array_cards = []
                let cardDicts = responseObject.object(forKey: "msg")  as! [NSDictionary]
                
                for cardDict in cardDicts
                {
                    let cardModel = PaymentMethodModel(info: cardDict)
                    self.array_cards.append(cardModel)
                }
                self.reloadPaymentTable()
            }
            else
            {
                let msg = responseObject.object(forKey: "msg") as? String ?? ""

                if(msg == "")
                {
                    self.showErrorVC(msg: "Failed to set primary card, please try again")
                }
                else
                {
                    self.showErrorVC(msg: "Server returned the error message: " + msg)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.array_cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cardData = self.array_cards[indexPath.row]
        let paymentMethodCell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodTableViewCell",
                                                              for: indexPath) as! PaymentMethodTableViewCell
        paymentMethodCell.configureWithData(cardInfo: cardData, index: indexPath.row)
        paymentMethodCell.paymentCellDelegate = self
        
        if(cardData.isPrimary)
        {
            paymentMethodCell.setPaymentSelected()
        }
        
        return paymentMethodCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.deleteCard(index: indexPath.row)
        }
    }
}
