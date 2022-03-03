//
//  Trip.swift
//  uberPractice
//
//  Created by 김현미 on 2022/03/03.
//

import CoreLocation

enum TripState : Int {
    case requested
    case accepted
    case inProgress
    case completed
}

struct Trip {
    var pickupCoordinate : CLLocationCoordinate2D!
    var destinationCoordinate : CLLocationCoordinate2D!
    let passengerUid : String!
    var driverUid : String?
    var state : TripState!
    
    init(passengerUid : String,dictionary : [String:Any]){
        self.passengerUid = passengerUid
        if let pickuplocation = dictionary["pickupCoordinates"] as? NSArray {
            guard let lat = pickuplocation[0] as? CLLocationDegrees else {return}
            guard let lng = pickuplocation[1] as? CLLocationDegrees else {return}
            self.pickupCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
         
        if let destinationCoordinates = dictionary["destinationCoordinates"] as? NSArray {
            guard let lat = destinationCoordinates[0] as? CLLocationDegrees else {return}
            guard let lng = destinationCoordinates[1] as? CLLocationDegrees else {return}
            self.destinationCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        
        self.driverUid = dictionary["driverUid"] as? String ?? ""
        if let state = dictionary["state"] as? Int {
            self.state = TripState(rawValue: state)
        }
    }
}
