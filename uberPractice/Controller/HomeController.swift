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
private let annotationIdentifire = "DriverAnno"

class HomeController : UIViewController {
    
    //MARK: - properties
    
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    
    private var searchResults = [MKPlacemark]()
    
    private var user : User? {
        didSet {
            locationInputView.user = user
        }
    }
    
    private final let locationInputViewHeight:CGFloat = 200
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIFUserIsLoggedIn()
        enableLocationServices()
        
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
        fetchDrivers()
    }
    
    func configureUI(){
        configureMapView()
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(in: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top:view.safeAreaLayoutGuide.topAnchor,paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        
        UIView.animate(withDuration: 1) {
            self.inputActivationView.alpha = 1
        }
        configuteTableView()
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
        
        
        UIView.animate(withDuration: 0.3) {[weak self] in
            guard let self = self else {return}
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        } completion: { _ in
            self.locationInputView.removeFromSuperview()
            UIView.animate(withDuration: 0.3) {[weak self] in
                guard let self = self else {return}
                self.inputActivationView.alpha = 1
            }
            
        }

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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        if indexPath.section == 1 {
            
            cell.placemark = searchResults[indexPath.row]
        }
        return cell
    }
    
}

//MARK: - MKMapViewDelegate

extension HomeController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotaion = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifire)
            view.image = UIImage(named: "chevron-sign-to-right")
            return view
        }
        return nil
    }
}
