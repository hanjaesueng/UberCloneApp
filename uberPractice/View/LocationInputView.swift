//
//  LocationInputView.swift
//  uberPractice
//
//  Created by 김현미 on 2022/03/01.
//

import UIKit

protocol LocationInputViewDelegate : AnyObject {
    func dismissLocationInputView()
    func excuteSearch(query : String)
}

class LocationInputView: UIView {

    // MARK: - Properties
    
    var user : User? {
        didSet {titleLabel.text = user?.fullname}
    }
    
    weak var delegate : LocationInputViewDelegate?
    
    private let backButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "baseline_arrow_back_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    private let startLocationIndicatorView : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let linkingView : UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let destinationIndicatorView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // 나중에 할당될때 실행됨
    private lazy var startingLocationTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Current Location"
        tf.backgroundColor = .groupTableViewBackground
        tf.isEnabled = false
        tf.font = UIFont.systemFont(ofSize: 14)
        
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        return tf
    }()
    
    private lazy var destinationLocationTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter a destination.."
        tf.backgroundColor = .lightGray
        tf.returnKeyType = .search
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.delegate = self
        let paddingView = UIView()
        paddingView.setDimensions(height: 30, width: 8)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        return tf
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        addShadow()
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(startLocationIndicatorView)
        addSubview(linkingView)
        addSubview(destinationIndicatorView)
        addSubview(startingLocationTextField)
        addSubview(destinationLocationTextField)
        backButton.anchor(top:topAnchor,left: leftAnchor,paddingTop: 44,paddingLeft: 12,width: 24,height: 24)
        titleLabel.centerY(in: backButton)
        titleLabel.centerX(in: self)
        startingLocationTextField.anchor(top:backButton.bottomAnchor,left: leftAnchor,right: rightAnchor,paddingTop:4,paddingLeft: 40,paddingRight: 40,height: 30)
        destinationLocationTextField.anchor(top:startingLocationTextField.bottomAnchor,left: leftAnchor,right: rightAnchor,paddingTop:12,paddingLeft: 40,paddingRight: 40,height: 30)
        startLocationIndicatorView.centerY(in: startingLocationTextField)
        startLocationIndicatorView.anchor(left:leftAnchor,paddingLeft: 20)
        startLocationIndicatorView.setDimensions(height: 6, width: 6)
        startLocationIndicatorView.layer.cornerRadius = 3
        destinationIndicatorView.centerY(in: destinationLocationTextField)
        destinationIndicatorView.anchor(left:leftAnchor,paddingLeft: 20)
        destinationIndicatorView.setDimensions(height: 6, width: 6)
        linkingView.centerX(in: startLocationIndicatorView)
        linkingView.anchor(top:startLocationIndicatorView.bottomAnchor,bottom: destinationIndicatorView.topAnchor,paddingTop: 4,paddingBotton: 4,width: 0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Selectors
    @objc func handleBackTapped(){
        delegate?.dismissLocationInputView()
    }
    
    
}

//MARK: - UITextFieldDelegate

extension LocationInputView : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text else {return false}
        delegate?.excuteSearch(query: query)
        return true
    }
    
}
