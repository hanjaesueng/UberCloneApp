//
//  Service.swift
//  uberPractice
//
//  Created by 김현미 on 2022/03/01.
//

import Firebase
import CoreLocation
import GeoFire
import UIKit
let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")
let REF_TRIPS = DB_REF.child("trips")

struct Service {
    static let shared = Service()
    
    private init(){}
    
    
    func fetchUserdata(uid:String,completion : @escaping (User)->Void) {
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String:Any] else {return}
            let user = User.init(uid: uid, dictionary: data)
            
            completion(user)
        }
    }
    // 데이터 변경될때마다 호출
    func fetchDrivers(location : CLLocation,completion : @escaping (User)->Void) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        REF_DRIVER_LOCATIONS.observe(.value) { snapshot in
            geofire.query(at: location, withRadius: 50).observe(.keyEntered,with: { uid, location in
                self.fetchUserdata(uid: uid) { user in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
            
        }
    }
    
    func uploadTrip(_ pickupCoordinates : CLLocationCoordinate2D, _ destinationCoordinates : CLLocationCoordinate2D, completion : @escaping(Error?,DatabaseReference ) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let pickupArray = [pickupCoordinates.latitude,pickupCoordinates.longitude]
        let destinationArray = [destinationCoordinates.latitude,destinationCoordinates.longitude]
        
        let value = ["pickupCoordinates":pickupArray,
                     "destinationCoordinates":destinationArray,
                     "state":TripState.requested.rawValue] as [String:Any]
        
        REF_TRIPS.child(uid).updateChildValues(value,withCompletionBlock: completion)
    }
    
    func observeTrips(completion : @escaping (Trip) -> Void) {
        REF_TRIPS.observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String:Any] else {return}
            let uid = snapshot.key
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            
            completion(trip)
        }
    }
    
    func acceptTrip(trip : Trip,completion : @escaping (Error?,DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let values = ["driverUid":uid,"state":TripState.accepted.rawValue] as [String : Any]
        
        REF_TRIPS.child(trip.passengerUid).updateChildValues(values, withCompletionBlock: completion)
    }
}
