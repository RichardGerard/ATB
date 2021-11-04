//
//  CreateBookingViewController.swift
//  ATB
//
//  Created by YueXi on 10/25/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import ARNTransitionAnimator

// Create a manual booking by busiensses
class CreateBookingViewController: AnimationBaseViewController {
    
    static let kStoryboardID = "CreateBookingViewController"
    class func instance() -> CreateBookingViewController {
        let storyboard = UIStoryboard(name: "Bookings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: CreateBookingViewController.kStoryboardID) as? CreateBookingViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var navigationView: UIView! { didSet {
        navigationView.layer.shadowOffset = CGSize(width: 0, height: -2)
        navigationView.layer.shadowRadius = 4.0
        navigationView.layer.shadowColor = UIColor.gray.cgColor
        navigationView.layer.shadowOpacity = 0.4
    }}
    
    @IBOutlet weak var imvBack: UIImageView! { didSet {
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")
            
        } else {
            // Fallback on earlier versions
        }        
        imvBack.tintColor = .colorPrimary
    }}
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imvCalendar: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var imvClock: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet weak var lblWhatService: UILabel!
    @IBOutlet weak var vSearchBarContainer: UIView!
    
    @IBOutlet weak var tblServices: UITableView!
    
    weak var selectedImageView : UIImageView?
    
    var animator : ARNTransitionAnimator?
    
    var bookingDate: Date!
    
    // a flag that represents whether search is active or not
    var isSearchActive: Bool = false
    
    var services = [PostModel]()
    var filteredServices = [PostModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        getServices()
    }
    
    private func setupViews() {
        view.backgroundColor = .colorGray14
        
        lblTitle.text = "You're Creating A Booking"
        lblTitle.font = UIFont(name: Font.SegoeUILight, size: 25)
        lblTitle.textColor = .colorGray1
        
        if #available(iOS 13.0, *) {
            imvCalendar.image = UIImage(systemName: "calendar")
        } else {
            // Fallback on earlier versions
        }
        imvCalendar.tintColor = .colorBlue8
        lblDate.text = bookingDate.toString("EEEE d MMMM", timeZone: .current)
        lblDate.font = UIFont(name: Font.SegoeUILight, size: 16)
        lblDate.textColor = .colorBlue8
        
        if #available(iOS 13.0, *) {
            imvClock.image = UIImage(systemName: "clock")
        } else {
            // Fallback on earlier versions
        }
        imvClock.tintColor = .colorBlue8
        lblTime.text = bookingDate.toString("h:mm a", timeZone: .current)
        lblTime.font = UIFont(name: Font.SegoeUILight, size: 16)
        lblTime.textColor = .colorBlue8
        
        lblWhatService.text = "What service will you book?"
        lblWhatService.font = UIFont(name: Font.SegoeUISemibold, size: 19)
        lblWhatService.textColor = .colorGray5
        
        // add an animating search bar
        let animatingSearchBar = AnimatingSearchBar(frame: CGRect(x: SCREEN_WIDTH - 32 - 50, y: 0, width: 50, height: 50))
        animatingSearchBar.delegate = self
        animatingSearchBar.searchBarOnColor = .colorGray4
        animatingSearchBar.searchBarOffColor = .colorGray4
        animatingSearchBar.searchBarOnBorderColor = .colorGray4
        animatingSearchBar.searchBarOffBorderColor = .colorGray4
        animatingSearchBar.searchOnColor = .colorGray8
        animatingSearchBar.searchOffColor = .colorGray8
        animatingSearchBar.searchBarPlaceholder = "Filter a service"
        animatingSearchBar.searchBarFont = UIFont(name: Font.SegoeUILight, size: 17)
        vSearchBarContainer.addSubview(animatingSearchBar)
        
        tblServices.backgroundColor = .clear
        tblServices.tableFooterView = UIView()
        tblServices.showsVerticalScrollIndicator = false
        tblServices.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tblServices.separatorStyle = .none
        
        tblServices.dataSource = self
        tblServices.delegate = self
    }
    
    private func getServices() {
        let params = [
            "token": g_myToken,
            "user_id": g_myInfo.ID
        ]

        _ = ATB_Alamofire.POST(GET_USER_SERVICES, parameters: params as [String: AnyObject], showLoading: true, showSuccess: false, showError: false, completionHandler: { (result, response) in
            
            guard result else { return }
            
            self.services.removeAll()
            
            let serviceDicts = response.object(forKey: "extra") as? [NSDictionary] ?? []
            for serviceDict in serviceDicts {
                let service = PostModel(info: serviceDict)
                
                self.services.append(service)
                
                if service.is_multi {
                    for serviceInGroup in service.group_posts {
                        self.services.append(serviceInGroup)
                    }
                }
            }
            
            self.tblServices.reloadData()
        })
    }
    
    // MARK: - ImageTransitionZoomable
    override func createTransitionImageView() -> UIImageView {
        let imageView = UIImageView(image: selectedImageView!.image)
        
        imageView.contentMode = selectedImageView!.contentMode
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.frame = selectedImageView!.convert(selectedImageView!.frame, to: self.view)
        
        return imageView
    }
    
    @objc override func presentationBeforeAction() {
        selectedImageView?.isHidden = true
    }
    
    override func presentationCompletionAction(didComplete: Bool) {
        selectedImageView?.isHidden = true
    }
    
    @objc override func dismissalBeforeAction() {
        selectedImageView?.isHidden = true
    }
    
    override func dismissalCompletionAction(didComplete: Bool) {
        selectedImageView?.isHidden = false
    }
    
    private func createBooking(withService selected: PostModel) {
        let detailsVC = CreateBookingDetailsViewController.instance()
        detailsVC.bookingDate = bookingDate
        detailsVC.selectedService = selected
        
        let animation = ImageZoomAnimation<AnimationBaseViewController>(rootVC: self, modalVC: detailsVC)
        let animator = ARNTransitionAnimator(duration: 0.35, animation: animation)
        
        self.navigationController?.delegate = animator
        self.animator = animator
        
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        navigationController?.delegate = nil
        
        navigationController?.popViewController(animated: true)
    }
}

extension CreateBookingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchActive ? filteredServices.count : services.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BookingServiceItemCell.reuseIdentifier, for: indexPath) as! BookingServiceItemCell
        // configure the cell
        let service = isSearchActive ? filteredServices[indexPath.row] : services[indexPath.row]
        // configure the cell
        cell.configureCell(service)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BookingServiceItemCell else { return }
        
        selectedImageView = cell.imvService
        
        let selectedService = isSearchActive ? filteredServices[indexPath.row] : services[indexPath.row]
        createBooking(withService: selectedService)
    }
}

// MARK: AnimatingSearchBarDelegate
extension CreateBookingViewController: AnimatingSearchBarDelegate {
    
    func destinationFrameForSearchBar(_ searchBar: AnimatingSearchBar) -> CGRect {
        return CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 32, height: 50)
    }
    
    func searchBar(_ searchBar: AnimatingSearchBar, willStartTransitioningToState destinationState: AnimatingSearchBarState) {
        // Do whatever you deem necessary.
    }
    
    func searchBar(_ searchBar: AnimatingSearchBar, didEndTransitioningFromState previousState: AnimatingSearchBarState) {
        // Do whatever you deem necessary.
    }
    
    func searchBarDidTapReturn(_ searchBar: AnimatingSearchBar) {
        // Do whatever you deem necessary.
        // Access the text from the search bar like searchBar.searchField.text
        guard let text = searchBar.searchField.text,
              !text.isEmpty else {
            isSearchActive = false
            searchBar.hideSearchBar(nil)
            return }
        
        searchBar.searchField.resignFirstResponder()
    }
    
    func searchBarTextDidChange(_ searchBar: AnimatingSearchBar) {
        // Do whatever you deem necessary.
        // Access the text from the search bar like searchBar.searchField.text
        guard let text = searchBar.searchField.text,
              !text.isEmpty else {
            isSearchActive = false
            tblServices.reloadData()
            return
        }
        
        isSearchActive = true
        filteredServices = services.filter {
            $0.Post_Title.range(of: text, options: .caseInsensitive) != nil
        }
        
        tblServices.reloadData()
    }
}
 
