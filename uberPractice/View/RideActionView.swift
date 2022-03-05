//
//  RideActionView.swift
//  uberPractice
//
//  Created by 김현미 on 2022/03/03.
//

import UIKit
import MapKit

protocol RideActionViewDelegate : AnyObject {
    func uploadTrip(_ view :RideActionView)
}

enum RideActionViewConfiguration {
    case requestRide
    case tripAccepted
    case pickupPassanger
    case tripInProgress
    case endTrip
    
    init() {
        self = .requestRide
    }
}

// CustomStringConvertible: 출력의 형태를 사용자가 원하는대로 출력하게 해준다, 버튼이 여러개의 기능을 수행할때 유용하다
enum ButtonAction : CustomStringConvertible{
    case requestRide
    case cancel
    case getDirections
    case pickup
    case dropOff
    
    var description: String {
        switch self {
            
        case .requestRide:
            return "CONFIRM UBERX"
        case .cancel:
            return "CANCEL RIDE"
        case .getDirections:
            return "GET DIRECTIONS"
        case .pickup:
            return "PICKUP PASSENGER"
        case .dropOff:
            return "DROP OFF PASSENGER"
        }
    }
    init(){
        self = .requestRide
    }
}

class RideActionView: UIView {
    //MARK: - Properties
    
    var destination : MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    
    
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    var config = RideActionViewConfiguration()
    var buttonAction = ButtonAction()
    weak var delegate : RideActionViewDelegate?
    var user : User?
    
    private let addressLabel : UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var infoView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        
        
        view.addSubview(infoViewLabel)
        infoViewLabel.centerX(in: view)
        infoViewLabel.centerY(in: view)
        return view
    }()
    
    private let infoViewLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        return label
    }()
    
    private let uberXLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Uber X"
        label.textAlignment = .center
        return label
    }()
    
    private let actionButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .black
        btn.setTitle("CONFIRM UBERX", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        let stack = UIStackView(arrangedSubviews: [titleLabel,addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerX(in: self)
        stack.anchor(top:topAnchor,paddingTop: 12)
        addSubview(infoView)
        
        infoView.centerX(in: self)
        infoView.anchor(top:stack.bottomAnchor,paddingTop: 16)
        infoView.setDimensions(height: 60, width: 60)
        infoView.layer.cornerRadius = 30
        
        addSubview(uberXLabel)
        uberXLabel.anchor(top:infoView.bottomAnchor,paddingTop: 8)
        uberXLabel.centerX(in: self)
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = .lightGray
        addSubview(seperatorView)
        seperatorView.anchor(top:uberXLabel.bottomAnchor,left: leftAnchor,right: rightAnchor,paddingTop: 4,height: 0.75)
        
        addSubview(actionButton)
        actionButton.anchor(left:leftAnchor,bottom: safeAreaLayoutGuide.bottomAnchor,right: rightAnchor,paddingLeft: 12,paddingBotton: 12,paddingRight: 12, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    @objc func actionButtonTapped(){
        switch buttonAction {
        case .requestRide:
            delegate?.uploadTrip(self)
        case .cancel:
            print("DEBUG : Handle cancel..")
        case .getDirections:
            print("DEBUG : Handle getDirections..")
        case .pickup:
            print("DEBUG : Handle pickup..")
        case .dropOff:
            print("DEBUG : Handle dropoff..")
        }
        
    }
    
    //MARK: - Helper Functions
    
    func configureUI(withConfig config : RideActionViewConfiguration){
        switch config {
        case .requestRide:
            buttonAction = .requestRide
            actionButton.setTitle(buttonAction.description, for: .normal)
            if !actionButton.isEnabled {
                
                actionButton.isEnabled = true
            }
        case .tripAccepted:
            guard let user = user else {return}
            
            if user.accountType == .passenger {
                titleLabel.text = "En Route To Passenger"
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            } else {
                buttonAction = .cancel
                actionButton.setTitle(buttonAction.description, for: .normal)
                titleLabel.text = "Driver En Route"
            }
            
            infoViewLabel.text = String(user.fullname.first ?? "X")
            uberXLabel.text = user.fullname
            
            
        case .pickupPassanger:
            titleLabel.text = "Arrived At Passenger Location"
            buttonAction = .pickup
            actionButton.setTitle(buttonAction.description, for: .normal)
        case .tripInProgress:
            guard let user = user else {return}
            if user.accountType == .driver {
                actionButton.setTitle("TRIP IN PROGRESS", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .getDirections
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
            
            titleLabel.text = "En Route To Destination"
        case .endTrip:
            guard let user = user else {return}
            
            if user.accountType == .driver {
                actionButton.setTitle("ARRIVED AT DESTINATION", for: .normal)
                actionButton.isEnabled = false
            } else {
                buttonAction = .dropOff
                actionButton.setTitle(buttonAction.description, for: .normal)
            }
        }
    }
}
