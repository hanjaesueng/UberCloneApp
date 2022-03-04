//
//  PickupController.swift
//  uberPractice
//
//  Created by jaeseung han on 2022/03/04.
//

import UIKit
import MapKit

protocol PickupControllerDelegate : AnyObject {
    func didAcceptTrip(_ trip : Trip)
}

class PickupController : UIViewController {
    //MARK: - Properties
    
    private let mapView = MKMapView()
    
    let trip : Trip
    
    weak var delegate : PickupControllerDelegate?
    
    private let cancelButton : UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(handleDissmissal), for: .touchUpInside)
        return btn
    }()
    
    private let pickupLabel : UILabel = {
        let label = UILabel()
        label.text = "would you like to pickup this passenger?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let acceptTripBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .white
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("ACCEPT TRIP", for: .normal)
        btn.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
        return btn
    }()
    
    
    //MARK: - Lifecycle
    
    init(trip : Trip){
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureMapView()
    }
    
    // 해당 뷰컨에서 상단에 status bar 를 없애준다
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Selectors
    
    @objc func handleDissmissal(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleAcceptTrip(){
        Service.shared.acceptTrip(trip: trip) {[weak self] error, reference in
            guard let self = self else {return}
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    
    //MARK: - Helper Functions
    
    func configureMapView(){
        let region = MKCoordinateRegion(center: trip.pickupCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        
        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickupCoordinate
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
    }
    
    func configureUI() {
        view.backgroundColor = .backgroundColor
        view.addSubview(cancelButton)
        cancelButton.anchor(top:view.safeAreaLayoutGuide.topAnchor,left:view.leftAnchor,paddingLeft:16)
        view.addSubview(mapView)
        mapView.setDimensions(height: 270, width: 270)
        mapView.layer.cornerRadius = 270/2
        mapView.centerX(in: view)
        mapView.centerY(in: view,constant: -200)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(in: view)
        pickupLabel.anchor(top:mapView.bottomAnchor,paddingTop: 16)
        
        view.addSubview(acceptTripBtn)
        acceptTripBtn.anchor(top:pickupLabel.bottomAnchor,left:view.leftAnchor,right: view.rightAnchor,paddingTop: 16,paddingLeft: 32,paddingRight: 32,height: 50)
    }
}
