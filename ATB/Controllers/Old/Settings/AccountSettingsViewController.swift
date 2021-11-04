//
//  AccountSettingsViewController.swift
//  ATB
//
//  Created by YueXi on 5/20/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import Foundation
import UIKit
import Stripe

class AccountSettingsViewController: BaseViewController {
    
    static let kStoryboardID = "AccountSettingsViewController"
    class func instance() -> AccountSettingsViewController {
        let storyboard = UIStoryboard(name: "OutdatedProfile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: AccountSettingsViewController.kStoryboardID) as? AccountSettingsViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    // navigation
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var imvAccountSettings: UIImageView!
    @IBOutlet weak var lblPaymentMethods: UILabel!
    
    @IBOutlet weak var lblSelectPayment: UILabel!
    
    @IBOutlet weak var tblPaymentMethod: UITableView!
    
    
    // add button
    @IBOutlet weak var btnAdd: GradientButton!
    
    var array_cards:[PaymentMethodModel] = []
    var default_sourceID:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        loadCards()
        
        //tblPaymentMethod.reloadData()
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
                self.tblPaymentMethod.reloadData()
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
                self.tblPaymentMethod.reloadData()
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
    
    private func setupViews() {
        // background color
        self.view.backgroundColor = .colorGray7
        
        // navigation
        lblTitle.font = UIFont(name: "SegoeUI-Semibold", size:27)
        lblTitle.text = "Account Settings"
        lblTitle.textColor = .colorGray2
        
        btnBack.setImage(UIImage(named: "Back"), for: .normal)
        btnBack.setTitle("    ", for: .normal)
        btnBack.tintColor = .colorPrimary
        
        if #available(iOS 13.0, *) {
            imvAccountSettings.image = UIImage(systemName: "creditcard")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvAccountSettings.tintColor = .colorPrimary
        
        lblPaymentMethods.textColor = .colorPrimary
        lblPaymentMethods.text = "Payment Methods"
        lblPaymentMethods.font = UIFont(name: "SegoeUI-Semibold", size: 21)
        
        lblSelectPayment.text = "Select your preferred payment method"
        lblSelectPayment.font = UIFont(name: "SegoeUI-Light", size: 15)
        lblSelectPayment.textColor = .colorGray2
        
        // tableview
        tblPaymentMethod.backgroundColor = .clear
        tblPaymentMethod.separatorStyle = .none
        tblPaymentMethod.showsVerticalScrollIndicator = false
        tblPaymentMethod.tableFooterView = UIView()
        
        tblPaymentMethod.delegate = self
        tblPaymentMethod.dataSource = self
        
        
        // add button
        if #available(iOS 13.0, *) {
            btnAdd.setImage(UIImage(systemName: "creditcard"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnAdd.setTitle("  Add a New Card", for: .normal)
        btnAdd.titleLabel?.font = UIFont(name: "SegoeUI-Bold", size: 18)
        btnAdd.tintColor = .white
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func didTapAdd(_ sender: Any) {
        let addCardViewController = STPAddCardViewController()
        addCardViewController.delegate = self
        
        // Present add card view controller
        let navigationController = UINavigationController(rootViewController: addCardViewController)
        present(navigationController, animated: true)
    } 
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension AccountSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array_cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PaymentMethodCell.kReuseIdentifier, for: indexPath) as! PaymentMethodCell
        // configure the cell
        cell.configureCell(array_cards[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PaymentMethodCell.kCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
}


class PaymentMethodCell: UITableViewCell {
    
    static let kReuseIdentifier = "PaymentMethodCell"
    static let kCellHeight: CGFloat = 72.0
    
    @IBOutlet weak var vCard: CardView!
    @IBOutlet weak var imvCard: UIImageView!
    @IBOutlet weak var lblName: UILabel! { didSet {
        lblName.textColor = .black
        lblName.font = UIFont(name: "SegoeUI-Light", size: 17)
        }}
    @IBOutlet weak var imvSelected: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
        backgroundColor = .clear
        
        if #available(iOS 13.0, *) {
            imvSelected.image = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvSelected.tintColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ card: PaymentMethodModel) {
        imvCard.image = nil
        
        switch card.type {
        case .ApplePay:
            imvCard.image = UIImage(named: "card.apple")?.withRenderingMode(.alwaysTemplate)
            break
            
        case .Amex:
            imvCard.image = UIImage(named: "card.amex")?.withRenderingMode(.alwaysTemplate)
            break
            
        case .Visa:
            imvCard.image = UIImage(named: "card.visa")?.withRenderingMode(.alwaysTemplate)
            break
            
        case .Discover:
            imvCard.image = UIImage(named: "card.discover")?.withRenderingMode(.alwaysTemplate)
            break
            
        case .MasterCard:
            // MasterCard
            imvCard.image = UIImage(named: "card.master")?.withRenderingMode(.alwaysTemplate)
            break
        }
        
        let blackAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Light", size: 17)!,
            .foregroundColor: UIColor.black
        ]
        
        let whiteBoldAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Bold", size: 17)!,
            .foregroundColor: UIColor.white
        ]
        
        let whiteAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Light", size: 17)!,
            .foregroundColor: UIColor.white
        ]
        
        let grayAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "SegoeUI-Light", size: 17)!,
            .foregroundColor: UIColor.colorGray11
        ]
        
        let attributedStr = card.CardNumber == "" ? NSMutableAttributedString(string: card.type.rawValue) : NSMutableAttributedString(string: card.type.rawValue + " Ending in " + card.CardNumber)
        
        if card.isPrimary {
            imvCard.tintColor = .white
            vCard.backgroundColor = .colorPrimary
            // checkbox
            imvSelected.isHidden = false
            
            attributedStr.addAttributes(whiteBoldAttrs, range: NSRange(location: 0, length: card.type.rawValue.count))
            
            if card.CardNumber != "" {
                attributedStr.addAttributes(whiteAttrs, range: NSRange(location: card.type.rawValue.count + 1, length: 9))
                attributedStr.addAttributes(whiteBoldAttrs, range: NSRange(location: card.type.rawValue.count + 11, length: card.CardNumber.count))
            }
            
        } else {
            imvCard.tintColor = .colorGray15
            vCard.backgroundColor = .white
            // checkbox
            imvSelected.isHidden = true
            
            attributedStr.addAttributes(blackAttrs, range: NSRange(location: 0, length: card.type.rawValue.count))
            
            if card.CardNumber != "" {
                attributedStr.addAttributes(grayAttrs, range: NSRange(location: card.type.rawValue.count + 1, length: 9))
                attributedStr.addAttributes(blackAttrs, range: NSRange(location: card.type.rawValue.count + 11, length: card.CardNumber.count))
            }
        }
        
        lblName.attributedText = attributedStr
    }
}

extension AccountSettingsViewController:STPAddCardViewControllerDelegate
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
