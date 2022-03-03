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
        label.text = "Test Address Title"
        label.textAlignment = .center
        return label
    }()
    
    weak var delegate : RideActionViewDelegate?
    
    private let addressLabel : UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Test Address Title iste"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var infoView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .white
        label.text = "X"
        
        view.addSubview(label)
        label.centerX(in: view)
        label.centerY(in: view)
        return view
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
        delegate?.uploadTrip(self)
    }
}
