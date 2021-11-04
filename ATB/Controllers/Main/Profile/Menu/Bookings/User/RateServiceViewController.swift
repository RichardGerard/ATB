//
//  RateBusinessViewController.swift
//  ATB
//
//  Created by YueXi on 11/2/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import Cosmos
import PopupDialog
import Kingfisher

class RateServiceViewController: BaseViewController {
    
    static let kStoryboardID = "RateServiceViewController"
    class func instance() -> RateServiceViewController {
        let storyboard = UIStoryboard(name: "Bookings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: RateServiceViewController.kStoryboardID) as? RateServiceViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var gradientView: UIView!
    
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")
        } else {
            // Fallback on earlier versions
        }
        
        imvBack.tintColor = .white
    }}
     
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView! { didSet {
        scrollView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
    }}
    
    @IBOutlet weak var vMediaCard: CardView! { didSet {
        vMediaCard.cornerRadius = 10
        vMediaCard.shadowOpacity = 0.35
        vMediaCard.shadowOffsetHeight = 3
        vMediaCard.shadowRadius = 3
    }}
    @IBOutlet weak var vServiceMedia: UIView! { didSet {
        vServiceMedia.layer.cornerRadius = 10
        vServiceMedia.layer.masksToBounds = true
    }}
    @IBOutlet weak var imvServiceMedia: UIImageView! { didSet {
        imvServiceMedia.contentMode = .scaleAspectFill
    }}
    
    @IBOutlet weak var lblServiceTitle: UILabel!
    @IBOutlet weak var imvCalendar: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imvClock: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var vRatingContainer: UIView!
    
    @IBOutlet weak var vStarRating: CosmosView!
    
    @IBOutlet weak var lblRatingTitle: UILabel!
    @IBOutlet weak var txvRatingDesc: RoundRectTextView!
    
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnProblem: UIButton!
    
    private lazy var inputAccessoryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 60)
        button.backgroundColor = .colorPrimary
        button.setTitle("Send Rating", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        button.addTarget(self, action: #selector(didTapInputAccessoryButton(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @IBOutlet weak var vPlay: UIView!
    
    var selectedBooking: BookingModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        vRatingContainer.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
        gradientView.addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 73)
        
        lblTitle.text = "How Was The Service?"
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 29)
        lblTitle.textColor = .white
        
        if let selectedService = selectedBooking.service {
            let url = selectedService.Post_Media_Urls.count > 0 ? selectedService.Post_Media_Urls[0] : ""
            if selectedService.isVideoPost {
                vPlay.isHidden = false
                
                // set placeholder
                imvServiceMedia.image = UIImage(named: "post.placeholder")
                
                if ImageCache.default.imageCachedType(forKey: url).cached {
                    ImageCache.default.retrieveImage(forKey: url) { result in
                        switch result {
                        case .success(let cacheResult):
                            if let image = cacheResult.image {
                                let animation = CATransition()
                                animation.type = .fade
                                animation.duration = 0.25
                                self.imvServiceMedia.layer.add(animation, forKey: "transition")
                                self.imvServiceMedia.image = image
                            }
                            
                            break
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                            break
                        }
                    }
                    
                } else {
                    // thumbnail is not cached, get thumbnail from video url
                    Utils.shared.getThumbnailImageFromVideoUrl(url) { thumbnail in
                        if let thumbnail = thumbnail {
                            let animation = CATransition()
                            animation.type = .fade
                            animation.duration = 0.3
                            self.imvServiceMedia.layer.add(animation, forKey: "transition")
                            self.imvServiceMedia.image = thumbnail
                            
                            ImageCache.default.store(thumbnail, forKey: url)
                        }
                    }
                }
                
            } else {
                vPlay.isHidden = true
                imvServiceMedia.loadImageFromUrl(url, placeholder: "post.placeholder")
            }
        }
        
        lblServiceTitle.text = selectedBooking.service.Post_Title.capitalizingFirstLetter
        lblServiceTitle.font = UIFont(name: Font.SegoeUILight, size: 29)
        lblServiceTitle.textColor = .white
        
        if #available(iOS 13.0, *) {
            imvCalendar.image = UIImage(systemName: "calendar")
        } else {
            // Fallback on earlier versions
        }
        imvCalendar.tintColor = .white
        
        let bookingDate = Date(timeIntervalSince1970: selectedBooking.date.doubleValue)
        lblDate.text = bookingDate.toString("EEEE d MMMM", timeZone: .current)
        lblDate.font = UIFont(name: Font.SegoeUILight, size: 19)
        lblDate.textColor = .white
        
        if #available(iOS 13.0, *) {
            imvClock.image = UIImage(systemName: "clock")
        } else {
            // Fallback on earlier versions
        }
        imvClock.tintColor = .white
        lblTime.text = bookingDate.toString("h:mm a", timeZone: .current)
        lblTime.font = UIFont(name: Font.SegoeUILight, size: 19)
        lblTime.textColor = .white
        
        vRatingContainer.backgroundColor = .colorGray14
        
        vStarRating.settings.totalStars = 5
        vStarRating.settings.filledImage = UIImage(named: "star.rating.fill")
        vStarRating.settings.emptyImage = UIImage(named: "star.rating.empty")
        vStarRating.settings.fillMode = .precise
        vStarRating.settings.starSize = 40
        vStarRating.rating = 4
        
        lblRatingTitle.text = "Let us know how was it"
        lblRatingTitle.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        lblRatingTitle.textColor = .colorGray5
        
        txvRatingDesc.text = ""
        txvRatingDesc.font = UIFont(name: Font.SegoeUILight, size: 18)
        txvRatingDesc.textColor = .colorGray19
        txvRatingDesc.tintColor = .colorGray19
        txvRatingDesc.placeholder = "Leave an optional comment, so the other user can read your personal advise"
//        txvRatingDesc.inputAccessoryView = inputAccessoryButton
        txvRatingDesc.delegate = self
        
        btnSend.setTitle("Send Rating", for: .normal)
        btnSend.setTitleColor(.white, for: .normal)
        btnSend.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        btnSend.backgroundColor = .colorPrimary
        btnSend.layer.cornerRadius = 5
        btnSend.layer.masksToBounds = true
        
        btnProblem.setAttributedTitle(NSAttributedString(string: "I had a problem with the service", attributes: [
            .foregroundColor: UIColor.colorPrimary,
            .font: UIFont(name: Font.SegoeUILight, size: 20)!,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.colorPrimary
        ]), for: .normal)
    }
    
    @objc private func didTapInputAccessoryButton(_ sender: Any) {
        
    }
    
    @IBAction func didTapSend(_ sender: Any) {
        guard let business = selectedBooking.business else { return }
        showIndicator()
        
        let buid = business.ID
        let rating = vStarRating.rating
        let review = txvRatingDesc.text!
        
        APIManager.shared.rateBusiness(g_myToken, buid: buid, rating: "\(rating)", comment: review) { result in
            self.hideIndicator()
            
            switch result {
            case .success(_):
                self.didSendRating()
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private func didSendRating() {
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius = 5
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color = .colorPrimary
        overlayAppearance.alpha = 0.85
        overlayAppearance.blurRadius = 8
        
        let doneVC = RatingDoneViewController(nibName: "RatingDoneViewController", bundle: nil)
        doneVC.backBlock = {
            self.gotoMyBookings()
        }
        
        let doneDialogVC = PopupDialog(viewController: doneVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(doneDialogVC, animated: true, completion: nil)
    }
    
    private func gotoMyBookings() {
        guard let navigationController = self.navigationController else { return }
        
        var viewControllers = navigationController.viewControllers
        // pop up RateServiceViewController
        viewControllers.removeLast()
        
        // pop up BookingDetailsViewController
        viewControllers.removeLast()
        
        navigationController.setViewControllers(viewControllers, animated: true)
    }
    
    @IBAction func didTapProblem(_ sender: Any) {
        let containerAppearance = PopupDialogContainerView.appearance()
        containerAppearance.cornerRadius = 5
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        overlayAppearance.color = .black
        overlayAppearance.alpha = 0.55
        overlayAppearance.blurRadius = 8
        
        let reportVC = ReportProblemViewController(nibName: "ReportProblemViewController", bundle: nil)
        reportVC.selectedBooking = selectedBooking
        reportVC.delegate = self
        
        let reportDialogVC = PopupDialog(viewController: reportVC, transitionStyle: .zoomIn, preferredWidth: SCREEN_WIDTH - 32, tapGestureDismissal: true, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        
        present(reportDialogVC, animated: true, completion: nil)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextViewDelegate
extension RateServiceViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
}

// MARK: - ReportProblemDelegate
extension RateServiceViewController: ReportProblemDelegate {
    
    func didReportProblem() {
        showSuccessVC(msg: "The report has been sent to ATB admin!")
    }
}
