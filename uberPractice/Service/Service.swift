//
//  Service.swift
//  uberPractice
//
//  Created by 김현미 on 2022/03/01.
//

import Firebase
import CoreLocation
import GeoFire
let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")

struct Service {
    static let shared = Service()
    
    private init(){}
    
    
    func fetchUserdata(completion : @escaping (User)->Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        REF_USERS.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String:Any] else {return}
            let user = User.init(dictionary: data)
            
            completion(user)
        }
    }
    
    func fetchDrivers(location : CLLocation) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        REF_DRIVER_LOCATIONS.observe(.value) { snapshot in
            geofire.query(at: location, withRadius: 50).observe(.keyEntered,with: { uid, location in
                
            })
            
        }
    }
}
