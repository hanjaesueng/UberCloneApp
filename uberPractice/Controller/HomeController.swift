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
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIFUserIsLoggedIn()
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
        view.addSubview(mapView)
        mapView.frame = view.frame
    }
}
