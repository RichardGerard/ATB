//
//  LocationViewController.swift
//  ATB
//
//  Created by YueXi on 5/17/20.
//  Updated by YueXi on 3/26/21
//  Copyright © 2020 mobdev. All rights reserved.
//

import UIKit
import MapKit
import SwiftCSVExport

class LocationViewController: BaseViewController {
    
    static let kStoryboardID = "LocationViewController"
    class func instance() -> LocationViewController {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: LocationViewController.kStoryboardID) as? LocationViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    // Navigation
    @IBOutlet weak var imvBack: UIImageView!
    @IBOutlet weak var imvNavIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    // SearchBar
    @IBOutlet weak var rangeSearchBar: RangeSearchTextField!
    
    @IBOutlet weak var mapView: MKMapView!
    
    // RangeBar
    @IBOutlet weak var vRangeSlider: UIView!
    @IBOutlet weak var sliderPostRange: PostRangeSlider!
    @IBOutlet weak var lblRangeValue: UILabel!
    @IBOutlet weak var btnSaveSettings: GradientButton!
    
    var locationInputDelegate: LocationInputDelegate?
    
    // search result tableview
    @IBOutlet weak var tblSearchResult: IntrinsicTableView! { didSet {
        tblSearchResult.dataSource = self
        tblSearchResult.delegate = self
        tblSearchResult.maxHeight = SCREEN_HEIGHT - 368 // top & bottom
        }}
    
    // range min and max value
    let minRadius: Float = 1.0
    let maxRadius: Float = 20.0
    // user radius saved in the setting or through sign up progress
    // the default as maxium
    var radius: Float = 20.0
    
    // the selected address
    var selectedAddress = ""
    private var selectedTown: TownModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        LocationProvider.startUpdates()
        
        if g_myInfo.radius > 0.0 {
            radius = Float(g_myInfo.radius)
        }
        
        loadTowns()
        
        setupViews()
    }
    
    private func setupViews() {
        // navigation
        if #available(iOS 13.0, *) {
            imvBack.image = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        
        imvBack.tintColor = .white
        imvBack.contentMode = .scaleAspectFit
        
        if #available(iOS 13.0, *) {
            imvNavIcon.image = UIImage(systemName: "mappin.and.ellipse")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imvNavIcon.tintColor = .white
        
        lblTitle.text = "Location & Radius"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 27)
        lblTitle.textColor = .white
            
        lblDescription.text = "Tell us your location and radius.\nATB will then be able to provide you with relevant posts and connect you with businesses in your local area."
        lblDescription.font = UIFont(name: Font.SegoeUILight, size: 15)
        lblDescription.textColor = .white
        lblDescription.numberOfLines = 0
        lblDescription.setLineSpacing(lineHeightMultiple: 0.75)
        lblDescription.textAlignment = .center
        
        // search field
        if !selectedAddress.isEmpty {
            let selected = selectedAddress.split(separator: ",")
            if selected.count > 0 {
                rangeSearchBar.text = String(selected[0])
            }
        }
        rangeSearchBar.textColor = .colorGray19
        rangeSearchBar.tintColor = .colorGray19
        rangeSearchBar.placeholder = "Search by town/city"
        rangeSearchBar.font = UIFont(name: Font.SegoeUILight, size: 18)
        if let labelInsideTextField = rangeSearchBar.value(forKey: "placeholderLabel") as? UILabel {
            labelInsideTextField.font = UIFont(name: "SegoeUI-Light", size: 18)
            labelInsideTextField.textColor = .colorGray11
        }
        rangeSearchBar.delegate = self
        rangeSearchBar.addTarget(self, action: #selector(searchFieldDidChange(_:)), for: .editingChanged)
              
        // bottom slider view
        vRangeSlider.addShadow(.top, opacity:0.15, radius: 2.0)
        
        lblRangeValue.textColor = .colorGray11
        lblRangeValue.font = UIFont(name: "SegoeUI-Semibold", size: 28)
        lblRangeValue.textAlignment = .right
        
        if radius > maxRadius  {
            lblRangeValue.text = "∞ KM"
            
        } else {
            lblRangeValue.text = "\(Int(radius))KM"
        }
        
        // setup range slider
        sliderPostRange.minimumValue = minRadius
        sliderPostRange.maximumValue = maxRadius
        sliderPostRange.value = radius
        sliderPostRange.tintColor = .colorPrimary
        sliderPostRange.thumbTintColor = .colorPrimary
        let thumbImage = circleImageFromView(40, tintColor: .colorPrimary)
        sliderPostRange.setThumbImage(thumbImage, for: .normal)
        sliderPostRange.setThumbImage(thumbImage, for: .highlighted)
        
        btnSaveSettings.setTitle("Save Settings", for: .normal)
        btnSaveSettings.setTitleColor(.white, for: .normal)
        btnSaveSettings.titleLabel?.font = UIFont(name: "SegoeUI-Bold", size: 18)
        
        // MapView
        mapView.showsUserLocation = false
        mapView.isUserInteractionEnabled = false
        mapView.delegate = self

        // handle keyboard
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil
        , queue: .main) { (notification) in
            self.handleKeyboard(notification)
        }
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
            self.handleKeyboard(notification)
        }
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var coordinate = CLLocationCoordinate2D()
        if let selected = selectedTown {
            coordinate = CLLocationCoordinate2D(latitude: Double(selected.latitude), longitude: Double(selected.longitude))

        } else {
            if let lastLocation = LocationProvider.lastLocation {
                coordinate = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)

            } else {
                // set application default location
                coordinate = CLLocationCoordinate2D(latitude: 21.282778, longitude: -157.829444)
            }
        }

        updateMapLocation(coordinate: coordinate, rangeValue: radius)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private var towns = [TownModel]()
    private func loadTowns() {
        guard let filePath = Bundle.main.path(forResource: "uk-towns", ofType: "csv") else {
            showErrorVC(msg: "It's been failed to load counties and regions, please try again later!")
            return }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let townsCSV = CSVExport.readCSV(filePath)
            
            for row in townsCSV.rows {
                guard let townDict =  row as? NSDictionary else { continue }
                
                let town = TownModel(with: townDict)
                self.towns.append(town)
            }
            
            if !self.selectedAddress.isEmpty {
                let address = self.selectedAddress.split(separator: ",")
                
                if address.count > 1 {
                    let county = String(address[1]).trimmedString
                    let region = String(address[0]).trimmedString
                    
                    self.selectedTown = self.towns.first(where: {
                        $0.region.contains(region) && $0.county.contains(county)
                    })
                }
            }
        }
    }
    
    // This is the design value
    let rangeCircleRate: CGFloat = 0.7
    func updateMapLocation(coordinate: CLLocationCoordinate2D, rangeValue: Float) {
        // calculate meters to be displayed to set map region
        let meters = CGFloat(rangeValue) * 1000.0 / rangeCircleRate
        mapView.centerToLocation(coordinate, regionRadius: CLLocationDistance(meters))
    }
    
    func updateOverlays() {
        if !selectedAddress.isEmpty && selectedTown == nil { return }
        
        // remove existing overlay
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        // remove existing annonation
        mapView.removeAnnotations(mapView.annotations)
        
        // update map
        var coordinate = CLLocationCoordinate2D()
        if let selected = selectedTown {
            coordinate = CLLocationCoordinate2D(latitude: Double(selected.latitude), longitude: Double(selected.longitude))

        } else {
            if let lastLocation = LocationProvider.lastLocation {
                coordinate = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)

            } else {
                // set application default location
                coordinate = CLLocationCoordinate2D(latitude: 21.282778, longitude: -157.829444)
            }
        }

        // add new one on the updated location
        let radius = CGFloat(sliderPostRange.value) * 1000.0 / 2.0
        let radiusCircle = MKCircle(center: coordinate, radius: CLLocationDistance(radius))
        mapView.addOverlay(radiusCircle)

        let dotCircle = MKPointAnnotation()
        dotCircle.coordinate = coordinate
        mapView.addAnnotation(dotCircle)
    }
    
    private var filteredTowns: [TownModel] = []
    @objc func searchFieldDidChange(_ textField: UITextField) {
        searchFor(textField.text!)
    }
    
    private func searchFor(_ search: String) {
        guard !search.isEmpty,
              search.trimmedString.count > 0 else {
            self.filteredTowns.removeAll()
            self.tblSearchResult.reloadData()
            return
        }
        
        let searchText = search.trimmedString.localizedLowercase
        filteredTowns = towns.filter({
            $0.region.localizedLowercase.contains(searchText) || $0.county.localizedLowercase.contains(searchText)
        })
        
        filteredTowns.sort(by: {
            $0.region.localizedCaseInsensitiveCompare($1.region) == .orderedAscending
        })
        
        tblSearchResult.reloadData()
    }
    
    @objc func handleKeyboard(_ notification: Notification) {
        // 1
        guard notification.name == UIResponder.keyboardWillChangeFrameNotification else {
            let rate = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
            UIView.animate(withDuration: rate!) {
                self.tblSearchResult.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
            return
        }
        
        guard
            let info = notification.userInfo,
            let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            else {
                return
        }
        
        // 2
        // little custom as we have already set the max height by considering bottom range setting view
        let keyboardHeight = keyboardFrame.cgRectValue.size.height - 160
        UIView.animate(withDuration: 0.1, animations: { ()-> Void in
            self.tblSearchResult.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        })
    }
    
    private func updateRangeValue(_ value: Float) {
        radius = value
        
        if value > maxRadius {
            lblRangeValue.text = "∞ KM"
            
        } else {
            lblRangeValue.text = "\(Int(value))KM"
        }
        
        var coordinate = CLLocationCoordinate2D()
        if let selected = selectedTown {
            coordinate = CLLocationCoordinate2D(latitude: Double(selected.latitude), longitude: Double(selected.longitude))

        } else {
            if let lastLocation = LocationProvider.lastLocation {
                coordinate = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)

            } else {
                // set application default location
                coordinate = CLLocationCoordinate2D(latitude: 21.282778, longitude: -157.829444)
            }
        }

        updateMapLocation(coordinate: coordinate, rangeValue: radius)
    }
    
    @IBAction func sliderRangeUpdated(_ sender: UISlider) {
        updateRangeValue(sender.value)
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        LocationProvider.stopUpdates()
        
        guard let selected = selectedTown else {
            showErrorVC(msg: "Please selected a location")
            return
        }
               
        let address = selected.region.trimmedString + ", " + selected.county.trimmedString + ", " + selected.country.trimmedString
        selectedAddress = address
        
        if let delegate = locationInputDelegate {
            delegate.locationSelected(address: address, latitude: "\(selected.latitude)", longitude: "\(selected.longitude)", radius: radius)
            
            navigationController?.popViewController(animated: true)
            
        } else {
            saveLocation(address, latitude: "\(selected.latitude)", longitude: "\(selected.longitude)", radius: "\(radius)")
        }
    }
    
    private func saveLocation(_ address: String, latitude: String, longitude: String, radius: String) {
        let params = [
            "token": g_myToken,
            "address": address,
            "lat": latitude,
            "lng": longitude,
            "range": radius
        ]
        
        _ = ATB_Alamofire.POST(SET_POST_RANGE_API, parameters: params as [String: AnyObject], showLoading: true, completionHandler: { (result, response) in
            guard result else {
                self.showErrorVC(msg: "It's been failed to update your location settings, please try again later!")
                return
            }
            
            g_myInfo.address = address
            g_myInfo.lat = latitude
            g_myInfo.lng = longitude
            g_myInfo.radius = radius.floatValue
            
            self.showInfoVC("ATB", msg: "Your location settings has been updated successfully!")
        })
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func circleImageFromView(_ radius: CGFloat, tintColor: UIColor) -> UIImage {
        let thumbView = UIView()
        thumbView.backgroundColor = tintColor
        // Set proper frame
        // y: radius / 2 will correctly offset the thumb
        thumbView.frame = CGRect(x: 0, y: 0, width: radius, height: radius)
        thumbView.layer.cornerRadius = radius / 2

        // Convert thumbView to UIImage
        // See this: https://stackoverflow.com/a/41288197/7235585
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)

        return renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension LocationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTowns.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.kReuseIdentifier, for: indexPath) as! SearchResultCell
        // configure the cell
        cell.configureCell(filteredTowns[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchResultCell.kCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // resign
        rangeSearchBar.resignFirstResponder()
        
        let selected = filteredTowns[indexPath.row]

        // update seleced address
        selectedTown = selected

        // update searchbar text with selected location
        rangeSearchBar.text = selected.region.trimmedString

        // move map to selected location
        let selectedLocation = CLLocationCoordinate2D(latitude: Double(selected.latitude), longitude: Double(selected.longitude))
        updateMapLocation(coordinate: selectedLocation, rangeValue: sliderPostRange.value)

        // reload data
        filteredTowns.removeAll()
        tblSearchResult.reloadData()
    }
}

// MARK: - MKMapViewDelegate
extension LocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard overlay is MKCircle else { return MKOverlayRenderer() }
        
        let circle = MKCircleRenderer(overlay: overlay as! MKCircle)

        circle.strokeColor = .colorPrimary
        circle.fillColor = UIColor.colorPrimary.withAlphaComponent(0.25)
        circle.lineWidth = 2
        return circle
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let dotAnnotationIdentifier = "dotAnnotationIdentifier"
        let dotView = mapView.dequeueReusableAnnotationView(withIdentifier: dotAnnotationIdentifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: dotAnnotationIdentifier)
        dotView.canShowCallout = false
        dotView.annotation = annotation
        dotView.image = circleImageFromView(36, tintColor: .colorPrimary)
            
        return dotView
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        updateOverlays()
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        updateOverlays()
    }
}

// MARK: - UITextFieldDelegate
extension LocationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchFor(textField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
