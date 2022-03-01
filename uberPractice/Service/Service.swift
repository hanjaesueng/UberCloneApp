//
//  Service.swift
//  uberPractice
//
//  Created by 김현미 on 2022/03/01.
//

import Firebase

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")

struct Service {
    static let shared = Service()
    
    private init(){}
    let currentUid = Auth.auth().currentUser?.uid
    
    func fetchUserdata(completion : @escaping (User)->Void) {
        guard let currentUid = currentUid else {return}
        REF_USERS.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            guard let data = snapshot.value as? [String:Any] else {return}
            let user = User.init(dictionary: data)
            
            completion(user)
        }
    }
}
