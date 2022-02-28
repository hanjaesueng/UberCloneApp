//
//  HomeController.swift
//  uberPractice
//
//  Created by 김현미 on 2022/02/28.
//

import UIKit
import Firebase
import MapKit

class HomeController : UIViewController {
    
    //MARK: - properties
    
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIFUserIsLoggedIn()
        enableLocationServices()
//        signOut()
    }
    
    //MARK: - API
    
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
            configureUI()
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: Error Signing out")
        }
    }
    
    //MARK: - Helper Functions
    
    
    
    func configureUI(){
        configureMapView()
    }
    
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
}

// MARK: - LocationServices
extension HomeController : CLLocationManagerDelegate{
    
    
    func enableLocationServices() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("DEBUG: Not determined..")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            print("DEBUG: Auth always..")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth when in use..")
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
}
