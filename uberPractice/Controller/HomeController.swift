//
//  HomeController.swift
//  uberPractice
//
//  Created by 김현미 on 2022/02/28.
//

import UIKit
import Firebase
import MapKit

private let reuseIdentifier = "LocationCell"
private let annotationIdentifire = "DriverAnnotation"

private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

class HomeController : UIViewController {
    
    //MARK: - properties
    
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivationView()
    private let rideActionView = RideActionView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private final let locationInputViewHeight:CGFloat = 200
    private final let rideActionViewHeight : CGFloat = 300
    private var actionBtnConfig = ActionButtonConfiguration()
    private var route : MKRoute?
    
    private var user : User? {
        didSet {
            locationInputView.user = user
            if user?.accountType == .passenger {
                fetchDrivers()
                configureLocationInputActivationView()
            }
        }
    }
    
    private let actionButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "baseline_menu_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionBtnPressed), for: .touchUpInside)
        return button
    }()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIFUserIsLoggedIn()
        enableLocationServices()
        signOut()
    }
    
    //MARK: - Selectors
    
    @objc func actionBtnPressed(){
        switch actionBtnConfig {
        case .showMenu:
            print("DEBUG: Handle show Menu..")
        case .dismissActionView:
            removeAnnotationsAndOverlays()
            mapView.showAnnotations(mapView.annotations, animated: true)
            UIView.animate(withDuration: 0.3) {[weak self] in
                guard let self = self else {return}
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.animateRideActionView(shouldShow: false)
            }
            
        }
    }
     
    //MARK: - API
    
    
    
    func fetchUserData(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserdata(uid:currentUid) {[weak self] user in
            guard let self = self else {return}
            self.user = user
            
        }
    }
    
    func fetchDrivers(){
        
        guard let location = locationManager?.location else {return}
        Service.shared.fetchDrivers(location: location, completion: { driver in
            guard let coordinate = driver.location?.coordinate else {return}
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            var driverIsVisible : Bool {
                return self.mapView.annotations.contains { annotation -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else {return false}
                    if driverAnno.uid == driver.uid {
                        driverAnno.updateAnnotationPosition(with: coordinate)
                        return true
                    }
                    return false
                }
            }
            if !driverIsVisible {
                self.mapView.addAnnotation(annotation)
            } 
            
        })
    }
    
    func checkIFUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            /// main 에서 실행해야함
            DispatchQueue.main.async {[weak self] in
                guard let self = self else {return}
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav,animated: true,completion: nil)
            }
        } else {
            configure()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {[weak self] in
                guard let self = self else {return}
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav,animated: true,completion: nil)
            }
        } catch {
            print("DEBUG: Error Signing out")
        }
    }
    
    
    
    //MARK: - Helper Functions

    func configure(){
        configureUI()
        fetchUserData()
        
    }
    
    fileprivate func configureActionButton(config : ActionButtonConfiguration) {
        switch config {
        case .showMenu:
            actionButton.setImage(UIImage(named: "baseline_menu_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
            actionBtnConfig = .showMenu
            
        case .dismissActionView:
            actionButton.setImage(UIImage(named: "baseline_arrow_back_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
            actionBtnConfig = .dismissActionView
        }
    }
    
    func configureUI(){
        configureMapView()
        
        configureRiedActionView()
        
        view.addSubview(actionButton)
        actionButton.anchor(top:view.safeAreaLayoutGuide.topAnchor,left: view.leftAnchor,paddingTop: 16,paddingLeft: 20,width: 30,height: 30)
        
        
        
        
        configuteTableView()
    }
    
    func configureLocationInputActivationView(){
        view.addSubview(inputActivationView)
        inputActivationView.centerX(in: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top:actionButton.bottomAnchor,paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        UIView.animate(withDuration: 1) {
            self.inputActivationView.alpha = 1
        }
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    func configureLocationInputView() {
        view.addSubview(locationInputView)
        locationInputView.anchor(top:view.topAnchor,left: view.leftAnchor,right: view.rightAnchor,height: locationInputViewHeight)
        locationInputView.alpha = 0
        locationInputView.delegate = self
        
        UIView.animate(withDuration: 0.5) {[weak self] in
            guard let self = self else {return}
            self.locationInputView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {[weak self] in
                guard let self = self else {return}
                self.tableView.frame.origin.y = self.locationInputViewHeight


            }
        }

    }
    
    func configureRiedActionView() {
        view.addSubview(rideActionView)
       
        rideActionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
        rideActionView.delegate = self
    }
    
    func configuteTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        view.addSubview(tableView)
    }
    
    func dismissLocationView(completion : ((Bool)->Void)? = nil){
        
        UIView.animate(withDuration: 0.3,animations: {[weak self] in
            guard let self = self else {return}
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
        }, completion:completion)

    }
    
    func animateRideActionView(shouldShow : Bool,destination : MKPlacemark? = nil) {
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        if shouldShow {
            guard let destination = destination else {
                return
            }
            self.rideActionView.destination = destination
        }
        UIView.animate(withDuration: 0.3) {[weak self] in
            guard let self = self else {return}
            self.rideActionView.frame.origin.y = yOrigin
        }
    }
}

// MARK: - map helper Functions

private extension HomeController {
   
    
    func searchBy(naturalLanguageQuery : String, completion : @escaping ([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {return}
            guard error == nil else {return}
            response.mapItems.forEach { item in
                results.append(item.placemark)
               
            }
            
            completion(results)
        }
    }
    
    func generatePolyline(toDestination destination : MKMapItem){
        
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { response, error in
            guard error == nil else {return}
            guard let response = response else {return}
            self.route = response.routes.first
            guard let polyline = self.route?.polyline else {return}
            self.mapView.addOverlay(polyline)
            
        }
    }
    
    func removeAnnotationsAndOverlays(){
        mapView.annotations.forEach { annotation in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
}

// MARK: - LocationServices
extension HomeController {
    
    
    func enableLocationServices() {
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: Not determined..")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always..")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use..")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    
    
}

//MARK: - LocationInputActivationDelegate

extension HomeController : LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
}


//MARK: - LocationInputViewDelegate
extension HomeController :LocationInputViewDelegate {
    func excuteSearch(query: String) {
        searchBy(naturalLanguageQuery: query) {[weak self] placemarks in
            guard let self = self else {return}
            self.searchResults = placemarks
            self.tableView.reloadData()
            
        }
    }
    
    func dismissLocationInputView() {
        
        dismissLocationView{ _ in
            UIView.animate(withDuration: 0.5) {[weak self] in
                guard let self = self else {return}
                self.inputActivationView.alpha = 1
            }
        }
    }
}


//MARK: - MKMapViewDelegate

extension HomeController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: DriverAnnotation.self)  {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifire)
            view.image = UIImage(named: "chevron-sign-to-right")
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}

//MARK: - UITableViewDelegate/DataSource

extension HomeController : UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : searchResults.count
    }
    
    // tableView를 쓸때는 설정을 다 해줘야한다 resue하기때문에 다른 cell의 속성이 발현된다. collectionView도 마찬가지
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        } else {
            cell.placemark = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placemark = searchResults[indexPath.row]
        

        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: placemark)
        generatePolyline(toDestination: destination)
        
        dismissLocationView {[weak self] _ in
            guard let self = self else {return}
            let annotaion = MKPointAnnotation()
            annotaion.coordinate = placemark.coordinate
            self.mapView.addAnnotation(annotaion)
            self.mapView.selectAnnotation(annotaion, animated: true)
            
            let annotations = self.mapView.annotations.filter { !$0.isKind(of: DriverAnnotation.self) }
            
            self.mapView.zoomToFit(annotations: annotations)
            self.animateRideActionView(shouldShow: true,destination: placemark)
        }
        
    }
}

// MARK: - RideActionViewDelegate
extension HomeController : RideActionViewDelegate {
    func uploadTrip(_ view : RideActionView) {
        guard let pickupCoords = locationManager?.location?.coordinate else {return}
        guard let destinationCoords = view.destination?.coordinate else {return}
        Service.shared.uploadTrip(pickupCoords, destinationCoords) { error, reference in
            guard error == nil else {
                print("DEBUG:Failed to upload trip with error : \(error)")
                return
            }
            print("DEBUG:Did upload trip")
        }
    }
}
