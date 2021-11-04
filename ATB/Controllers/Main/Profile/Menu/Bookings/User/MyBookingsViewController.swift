//
//  MyBookingsViewController.swift
//  ATB
//
//  Created by YueXi on 10/13/20.
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit

class MyBookingsViewController: BaseViewController {
    
    static let kStoryboardID = "MyBookingsViewController"
    class func instance() -> MyBookingsViewController {
        let storyboard = UIStoryboard(name: "Bookings", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: MyBookingsViewController.kStoryboardID) as? MyBookingsViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    @IBOutlet weak var imvProfile: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnOK: UIButton!
    
    @IBOutlet weak var vTopRoundContainer: UIView!
    
    @IBOutlet weak var tblBookings: UITableView!
    
    var pastBookingShown: Bool = false
    
    let heightForDateViewCell: CGFloat = 26
    let heightForItemViewCell: CGFloat = 90
    let heightForSeparatorViewCell: CGFloat = 30
    let heightForLoadMoreViewCell: CGFloat = 180
    
    var allBookings = [BookingModel]()
    var comings = [Any]()
    var nexts = [Any]()
    var pasts = [Any]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
        getUserBookings()
        
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(didCancelBooking(_:)), name: .BookingCancelled, object: nil)
        defaultCenter.addObserver(self, selector: #selector(didUpdateBooking(_:)), name: .BookingUpdatedByUser, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        vTopRoundContainer.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
    }
    
    private func setupViews() {
        /// add gradient layer
        self.view.addGradientLayer(.colorPrimary, endColor: .colorBlue3, angle: 42, alphaValue: 1.0)
        
        imvProfile.layer.cornerRadius = 24
        imvProfile.layer.masksToBounds = true
        imvProfile.contentMode = .scaleAspectFill
        
        imvProfile.loadImageFromUrl(g_myInfo.profileImage, placeholder: "profile.placeholder")
        
        lblTitle.text = "My Bookings"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 26)
        lblTitle.textColor = .white
        
        btnOK.setTitle("OK", for: .normal)
        btnOK.setTitleColor(.white, for: .normal)
        btnOK.titleLabel?.font = UIFont(name: Font.SegoeUISemibold, size: 20)
        
        vTopRoundContainer.backgroundColor = .colorGray14
        
        tblBookings.backgroundColor = .colorGray14
        tblBookings.tableFooterView = UIView()
        tblBookings.separatorStyle = .none
        tblBookings.showsVerticalScrollIndicator = false
                
        tblBookings.register(ItemListHeaderView.self, forHeaderFooterViewReuseIdentifier: ItemListHeaderView.reuseIdentifier)
        tblBookings.register(SectionSeparatorViewCell.self, forCellReuseIdentifier: SectionSeparatorViewCell.reuseIdentifier)
        
        tblBookings.dataSource = self
        tblBookings.delegate = self
    }
    
    @IBAction func didTapOk(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    private func getUserBookings() {
        showIndicator()
        
        let user = g_myInfo
        APIManager.shared.getBookings(g_myToken, id: user.ID, isBusinenss: false, month: "") { result in
            self.hideIndicator()
            
            switch result {
            case .success(let bookings):
                if bookings.count == 0 {
                    self.showInfoVC("ATB", msg: "There is no any booking made yet!")
                    
                } else {
                    self.allBookings.removeAll()
                    for booking in bookings {
                        if booking.isActive {
                            // put only active bookings into the array
                            self.allBookings.append(booking)
                        }
                    }
                    
                    self.sortBookings()
                }
                
                
            case .failure(let error):
                self.showErrorVC(msg: error.localizedDescription)
            }
        }
    }
    
    private func sortBookings() {
        comings.removeAll()
        nexts.removeAll()
        pasts.removeAll()
                   
        var bookingsInComing = [BookingModel]()
        var bookingsInNext = [BookingModel]()
        var bookingsInPast = [BookingModel]()
        
        let today = Date()
        
        for booking in allBookings {
            let bookingDate = Date(timeIntervalSince1970: booking.date.doubleValue)
            
            if bookingDate >= today {
                if Calendar.current.isDateInThisWeek(bookingDate) {
                    bookingsInComing.append(booking)
                    
                } else {
                    bookingsInNext.append(booking)
                }
                
            } else {
                bookingsInPast.append(booking)
            }
        }
        
        // sort by booking date
        bookingsInComing = bookingsInComing.sorted { $0.date.doubleValue < $1.date.doubleValue }
        bookingsInNext = bookingsInNext.sorted { $0.date.doubleValue < $1.date.doubleValue }
        bookingsInPast = bookingsInPast.sorted { $0.date.doubleValue > $1.date.doubleValue }
        
        let calendar = Calendar.current
        for (i, booking) in bookingsInComing.enumerated() {
            if i == 0 {
                comings.append(booking.date)
                
            } else {
                guard let before = comings.last as? BookingModel else { continue }
                
                let beforeDate = Date(timeIntervalSince1970: before.date.doubleValue)
                let bookingDate = Date(timeIntervalSince1970: booking.date.doubleValue)
                
                if calendar.compare(bookingDate, to: beforeDate, toGranularity: .day) != .orderedSame {
                    comings.append(booking.date)
                }
            }
            
            comings.append(booking)
        }
        
        for (i, booking) in bookingsInNext.enumerated() {
            if i == 0 {
                nexts.append(booking.date)
                
            } else {
                guard let before = nexts.last as? BookingModel else { continue }
                
                let beforeDate = Date(timeIntervalSince1970: before.date.doubleValue)
                let bookingDate = Date(timeIntervalSince1970: booking.date.doubleValue)
                
                if calendar.compare(bookingDate, to: beforeDate, toGranularity: .day) != .orderedSame {
                    nexts.append(booking.date)
                }
            }
            
            nexts.append(booking)
        }
        
        for (i, booking) in bookingsInPast.enumerated() {
            if i == 0 {
                pasts.append(booking.date)
                
            } else {
                guard let before = pasts.last as? BookingModel else { continue }
                
                let beforeDate = Date(timeIntervalSince1970: before.date.doubleValue)
                let bookingDate = Date(timeIntervalSince1970: booking.date.doubleValue)
                
                if calendar.compare(bookingDate, to: beforeDate, toGranularity: .day) != .orderedSame {
                    pasts.append(booking.date)
                }
            }
            
            pasts.append(booking)
        }
        
        tblBookings.reloadData()
    }
    
    private func loadPastBookings() {
        showIndicator()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            self.hideIndicator()
            self.pastBookingShown = true
            
            self.tblBookings.reloadData()
        }
    }
    
    @objc private func didCancelBooking(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let bid = object["bid"] as? String,
              let index = allBookings.firstIndex(where: {
                  $0.id == bid
              }) else { return }
        
        allBookings.remove(at: index)
        
        DispatchQueue.main.async {
            self.sortBookings()
        }
    }
    
    @objc private func didUpdateBooking(_ notification: Notification) {
        guard let object = notification.object as? [String: Any],
              let bid = object["bid"] as? String,
              let updated = object["updated"] as? String,
              let index = allBookings.firstIndex(where: {
                  $0.id == bid
              }) else { return }
        
        allBookings[index].date = updated
        
        DispatchQueue.main.async {
            self.sortBookings()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: UITableViewDataSource, UITableViewDelegate
extension MyBookingsViewController: UITableViewDataSource, UITableViewDelegate {
       
    func numberOfSections(in tableView: UITableView) -> Int {
        return pastBookingShown ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return comings.count
            
        case 1:
            return nexts.count + 1
            
        default:
            return pasts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0, 2:
            let item = indexPath.section == 0 ? comings[indexPath.row] : pasts[indexPath.row]
            if item is String {
                let cell = tableView.dequeueReusableCell(withIdentifier: DateViewCell.reuseIdentifier, for: indexPath) as! DateViewCell
                // configure the cell
                cell.lblDate.text = Date(timeIntervalSince1970: (item as! String).doubleValue).toString("EEEE d MMMM", timeZone: .current)
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: BookingItemViewCell.reuseIdentifier, for: indexPath) as! BookingItemViewCell
                // configure the cell
                cell.configureCell(item as! BookingModel)

                return cell
            }
            
        default:
            if indexPath.row == nexts.count {
                if pastBookingShown {
                    let cell = tableView.dequeueReusableCell(withIdentifier: SectionSeparatorViewCell.reuseIdentifier, for: indexPath)
                    return cell
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: LoadMoreViewCell.reuseIdentifier, for: indexPath) as! LoadMoreViewCell
                    cell.loadMoreBlock = {
                        self.loadPastBookings()
                    }

                    return cell
                }
                
            } else {
                let item = nexts[indexPath.row]
                if item is String {
                    let cell = tableView.dequeueReusableCell(withIdentifier: DateViewCell.reuseIdentifier, for: indexPath) as! DateViewCell
                    // configure the cell
                    cell.lblDate.text = Date(timeIntervalSince1970: (item as! String).doubleValue).toString("EEEE d MMMM", timeZone: .current)
                    
                    return cell
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: BookingItemViewCell.reuseIdentifier, for: indexPath) as! BookingItemViewCell
                    // configure the cell
                    cell.configureCell(item as! BookingModel)

                    return cell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0, 2:
            let item = indexPath.section == 0 ? comings[indexPath.row] : pasts[indexPath.row]
            if item is String {
                return heightForDateViewCell
                
            } else {
                return heightForItemViewCell
            }
            
        default:
            if indexPath.row == nexts.count {
                if pastBookingShown {
                    return heightForSeparatorViewCell
                    
                } else {
                    return heightForLoadMoreViewCell
                }
                
            } else {
                let item = nexts[indexPath.row]
                if item is String {
                    return heightForDateViewCell
                    
                } else {
                    return heightForItemViewCell
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ItemListHeaderView.reuseIdentifier) as? ItemListHeaderView else { return nil }
        
        if section == 2 {
            headerView.titleLabel.text = "Past Bookings"
            headerView.titleLabel.textColor = .colorGray2
            
        } else {
            headerView.titleLabel.text = section == 0 ? "Coming Up" : "Next Week"
            headerView.titleLabel.textColor = .colorPrimary
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = .clear
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 1 ? 0 : 20
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selected: BookingModel!
        
        switch indexPath.section {
        case 0, 2:
            let item = indexPath.section == 0 ? comings[indexPath.row] : pasts[indexPath.row]
            guard let booking = item as? BookingModel else { return }
            
            selected = booking
            
        default:
            guard indexPath.row != nexts.count else { return }
            
            let item = nexts[indexPath.row]
            guard let booking = item as? BookingModel else { return }
            
            selected = booking
        }
        
        let detailsVC = BookingDetailsViewController.instance()
        detailsVC.selectedBooking = selected
        
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
