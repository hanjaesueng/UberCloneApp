//
//  DriverAnnotation.swift
//  uberPractice
//
//  Created by jaeseung han on 2022/03/02.
//

import MapKit

class DriverAnnotation : NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var uid : String
    
    init(uid : String, coordinate : CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    func updateAnnotationPosition(with coordinates: CLLocationCoordinate2D) {
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinates
        }
    }
}

