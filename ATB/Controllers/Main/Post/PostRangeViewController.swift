//
//  PostRangeViewController.swift
//  ATB
//
//  Created by YueXi on 5/6/21.
//  Copyright © 2021 mobdev. All rights reserved.
//

import UIKit
import MapKit

// MARK: - LocationInputDelegate
protocol LocationInputDelegate {
    
    func locationSelected(address: String, latitude: String, longitude: String, radius: Float)
}

class PostRangeViewController: BaseViewController {
    
    static let kStoryboardID = "PostRangeViewController"
    class func instance() -> PostRangeViewController {
        let storyboard = UIStoryboard(name: "Post", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: PostRangeViewController.kStoryboardID) as? PostRangeViewController {
            return vc
            
        } else {
            fatalError("can't find the file in the storyboard")
        }
    }
    
    // Navigation
    @IBOutlet weak var imvBack: UIImageView!
    @IBOutlet weak var imvNavIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    // These are hidden, not used here
    @IBOutlet weak var lblDescription: UILabel!
    
    // Search Bar
    @IBOutlet weak var rangeSearchBar: RangeSearchTextField!
    @IBOutlet weak var vLocationButtonContainer: UIView! { didSet {
        vLocationButtonContainer.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        vLocationButtonContainer.layer.cornerRadius = 5.0
        }}
    @IBOutlet weak var btnMyLocation: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    // Range Bar
    @IBOutlet weak var vRangeSlider: UIView!
    @IBOutlet weak var sliderPostRange: PostRangeSlider!
    @IBOutlet weak var lblRangeValue: UILabel!
    @IBOutlet weak var btnSaveSettings: GradientButton!
    
    // search result table view
    @IBOutlet weak var tblSearchResult: IntrinsicTableView! { didSet {
        tblSearchResult.dataSource = self
        tblSearchResult.delegate = self
        tblSearchResult.maxHeight = SCREEN_HEIGHT - 320 // top & bottom
        }}
    
    // range min and max value
    private let minRadius: Float = 1.0
    private let maxRadius: Float = 20.0
    // user radius saved in the setting or through sign up progress
    // the default as maxium
    private var radius: Float = 20.0
    
    // the selected placemark
    // getting an adddress from this placemark
    private var selectedAddress: MKPlacemark?
    
    var locationInputDelegate: LocationInputDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if g_myInfo.radius > 0.0 {
            radius = Float(g_myInfo.radius)
        }
        
        setupViews()
        
        LocationProvider.startUpdates()
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
        
        lblTitle.text = "Post Range"
        lblTitle.font = UIFont(name: Font.SegoeUISemibold, size: 27)
        lblTitle.textColor = .white
        
        // search field
        rangeSearchBar.textColor = .colorGray19
        rangeSearchBar.tintColor = .colorGray19
        rangeSearchBar.placeholder = "Search by town/city"
        rangeSearchBar.font = UIFont(name: Font.SegoeUILight, size: 18)
        if let labelInsideTextField = rangeSearchBar.value(forKey: "placeholderLabel") as? UILabel {
            labelInsideTextField.font = UIFont(name: Font.SegoeUILight, size: 18)
            labelInsideTextField.textColor = .colorGray11
        }
        rangeSearchBar.delegate = self
        rangeSearchBar.addTarget(self, action: #selector(searchFieldDidChange(_:)), for: .editingChanged)
           
        if #available(iOS 13.0, *) {
            btnMyLocation.setImage(UIImage(systemName: "location"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        btnMyLocation.tintColor = .white
        
        // bottom slider view
        vRangeSlider.addShadow(.top, opacity:0.15, radius: 2.0)
        
        lblRangeValue.textColor = .colorGray11
        lblRangeValue.font = UIFont(name: Font.SegoeUISemibold, size: 28)
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
        
        btnSaveSettings.setTitle("Done", for: .normal)
        btnSaveSettings.setTitleColor(.white, for: .normal)
        btnSaveSettings.titleLabel?.font = UIFont(name: Font.SegoeUIBold, size: 18)
        
        // Map view
        mapView.delegate = self
        mapView.showsUserLocation = false
        mapView.isUserInteractionEnabled = false

        // handle keyboard
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { notification in
            self.handleKeyboard(notification)
        }
        defaultCenter.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { notification in
            self.handleKeyboard(notification)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // update map location & add overlays
        if let lastLocation = LocationProvider.lastLocation {
            updateMapLocation(coordinate: lastLocation.coordinate, rangeValue: radius)

        } else {
            // set application default location or (0, 0)
            let userLat = g_myInfo.lat.doubleValue
            let userLong = g_myInfo.lng.doubleValue
            if userLat > 0.0 || userLong > 0.0 {
                updateMapLocation(coordinate: CLLocationCoordinate2D(latitude: userLat, longitude: userLat), rangeValue: radius)
                
            } else {
                // set any location if you want to set that can be used
                updateMapLocation(coordinate: CLLocationCoordinate2D(latitude: 21.282778, longitude: -157.829444), rangeValue: radius)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // This is the design value
    let rangeCircleRate: CGFloat = 0.7
    func updateMapLocation(coordinate: CLLocationCoordinate2D, rangeValue: Float) {
        // calculate meters to be displayed to set map region
        let meters = CGFloat(rangeValue) * 1000.0 / rangeCircleRate
        mapView.centerToLocation(coordinate, regionRadius: CLLocationDistance(meters))
    }
    
    func updateOverlays() {
        // remove existing overlay
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        
        // remove existing annonation
        mapView.removeAnnotations(mapView.annotations)
        
        // update map
        var coordinate = CLLocationCoordinate2D()
        if let selectedAddress = selectedAddress {
            coordinate = CLLocationCoordinate2D(latitude: selectedAddress.coordinate.latitude, longitude: selectedAddress.coordinate.longitude)

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
    
    var addressMatchingItems: [MKMapItem] = []
    @objc func searchFieldDidChange(_ textField: UITextField) {
        guard !textField.isEmpty() else {
            self.addressMatchingItems.removeAll()
            self.tblSearchResult.reloadData()
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = textField.text!
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard error == nil,
                let response = response else {
                    self.addressMatchingItems.removeAll()
                    self.tblSearchResult.reloadData()
                    return
            }
            
            self.addressMatchingItems = response.mapItems
            self.tblSearchResult.reloadData()
        }
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
        if let selected = selectedAddress {
            coordinate = CLLocationCoordinate2D(latitude: selected.coordinate.latitude, longitude: selected.coordinate.longitude)

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
    
    @IBAction func didTapMyLocation(_ sender: UIButton) {
        addressMatchingItems.removeAll()
        tblSearchResult.reloadData()
        
        rangeSearchBar.text = ""
        selectedAddress = nil
        
        let range = sliderPostRange.value
        
        if let lastLocation = LocationProvider.lastLocation {
            let geocoder = CLGeocoder()
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
                guard error == nil,
                      let placemarks = placemarks,
                      placemarks.count > 0 else {
                    // An error has been occurred during geocoding.
                    return }
                
                let firstLocation = placemarks[0]
                let placemark = MKPlacemark(placemark: firstLocation)
                self.selectedAddress = placemark
                
                self.rangeSearchBar.text = Utils.shared.address(placemark)
            })
                           
            updateMapLocation(coordinate: lastLocation.coordinate, rangeValue: range)
            
        } else {
            // set any location if you want to set that can be used
            updateMapLocation(coordinate: CLLocationCoordinate2D(latitude: 21.282778, longitude: -157.829444), rangeValue: range)
        }
    }
    
    @IBAction func didTapSave(_ sender: Any) {
        LocationProvider.stopUpdates()
        
        guard let selected = selectedAddress else {
            showErrorVC(msg: "Please selected a location")
            return
        }
        
        locationInputDelegate?.locationSelected(address: Utils.shared.simpleAddress(selected), latitude: "\(selected.coordinate.latitude)", longitude: "\(selected.coordinate.longitude)", radius: radius)
        
        navigationController?.popViewController(animated: true)
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
extension PostRangeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressMatchingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.kReuseIdentifier, for: indexPath) as! SearchResultCell
        // configure the cell
        cell.configureCell(addressMatchingItems[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchResultCell.kCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // resign
        rangeSearchBar.resignFirstResponder()
        
        let selected = addressMatchingItems[indexPath.row].placemark
        
        // update seleced address
        selectedAddress = selected
        
        // update searchbar text with selected location
        rangeSearchBar.text = Utils.shared.address(selected)
        
        // move map to selected location
        let selectedLocation = CLLocationCoordinate2D(latitude: selected.coordinate.latitude, longitude: selected.coordinate.longitude)
        updateMapLocation(coordinate: selectedLocation, rangeValue: sliderPostRange.value)
        
        // reload data
        addressMatchingItems.removeAll()
        tblSearchResult.reloadData()
    }
}

// MARK: -  MKMapViewDelegate
extension PostRangeViewController: MKMapViewDelegate {
    
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
extension PostRangeViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: - MKMapView Extension
extension MKMapView {
    
    func centerToLocation(_ coordinate: CLLocationCoordinate2D, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

// MARK: - PostRangeSlider
class PostRangeSlider: UISlider {
    
    var trackHeight: CGFloat = 20.0
    
    private lazy var thumbView: UIView = {
        let thumb = UIView()
        thumb.backgroundColor = self.thumbTintColor
        return thumb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let originalRect = super.trackRect(forBounds: bounds)
        let newTrackRect = CGRect(x: 0, y: originalRect.origin.y - (trackHeight - originalRect.height)/2.0, width: originalRect.width, height: trackHeight)
        
        return newTrackRect
    }
}

// MARK: - RangeSearchTextField
class RangeSearchTextField: UITextField {
    
    var cornerRadius: CGFloat = 5.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupTextField()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTextField()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = cornerRadius
    }
    
    func setupTextField() {
        backgroundColor = .white
        
        let imageView = UIImageView()
        imageView.contentMode = .center
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate)
        } else {
            // Fallback on earlier versions
        }
        imageView.tintColor = .colorGray11

        self.rightView = imageView
        self.rightViewMode = .always
        
        self.returnKeyType = .done
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.rightViewRect(forBounds: bounds)
        textRect.origin.x -= 12
        return textRect
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let padding = bounds.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 32))
        return padding
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let padding = bounds.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 32))
        return padding
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let padding = bounds.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 32))
        return padding
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size.width = 3
        rect.size.height = self.font != nil ? self.font!.lineHeight : rect.size.height

        return rect
    }
}

// MARK: - SearchResultCell
class SearchResultCell: UITableViewCell {
    
    static let kReuseIdentifier = "SearchResultCell"
    static let kCellHeight: CGFloat = 60
    
    @IBOutlet weak var lblPlaceName: UILabel! { didSet {
        lblPlaceName.font = UIFont(name: "SegoeUI-Semibold", size: 17)
        lblPlaceName.textColor = .colorGray19
        }}
    @IBOutlet weak var lblPlaceAddress: UILabel! { didSet {
        lblPlaceAddress.font = UIFont(name: "SegoeUI-Light", size: 17)
        lblPlaceAddress.textColor = .colorGray11
        }}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ item: MKMapItem) {
        lblPlaceName.text = item.placemark.name
        lblPlaceAddress.text = Utils.shared.address(item.placemark)
    }
    
    func configureCell(_ town: TownModel) {
        lblPlaceName.text = town.region.trimmedString
        lblPlaceAddress.text = "\(town.region.trimmedString), \(town.county), \(town.country)"
    }
}
