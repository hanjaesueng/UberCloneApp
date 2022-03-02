//
//  User.swift
//  uberPractice
//
//  Created by 김현미 on 2022/03/01.
//

import CoreLocation

struct User {
    let fullname : String
    let email : String
    let accountType : Int
    var location : CLLocation?
    let uid : String
    
    init(uid : String, dictionary : [String:Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.accountType = dictionary["accountType"] as? Int ?? 0
    }
}
