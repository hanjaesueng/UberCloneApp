//
//  LocationHandler.swift
//  uberPractice
//
//  Created by 김현미 on 2022/03/01.
//

import CoreLocation

class LocationHandler : NSObject, CLLocationManagerDelegate{
    static let shared = LocationHandler()
    
    
    var locationManager : CLLocationManager!
    var location : CLLocation?
    
    private override init() {
        super.init()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
}
