//
//  LocationInputActivationView.swift
//  uberPractice
//
//  Created by 김현미 on 2022/03/01.
//

import UIKit

//class에만 상속하도록 제한
protocol LocationInputActivationViewDelegate : class {
    func presentLocationInputView()
}

class LocationInputActivationView : UIView {
    // MARK: - Properties
    
    weak var delegate : LocationInputActivationViewDelegate?
    
    private let indicatorView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private let placeholderLabel : UILabel = {
        let label = UILabel()
        label.text = "Where to?"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .darkGray
        return label
    }()
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addShadow()
        addSubview(indicatorView)
        indicatorView.centerY(in: self,leftAnchor: leftAnchor,paddingLeft: 16)
        indicatorView.setDimensions(height: 6, width: 6)
        
        addSubview(placeholderLabel)
        placeholderLabel.centerY(in: self,leftAnchor: indicatorView.rightAnchor,paddingLeft: 20)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleShowLocationInputView))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func handleShowLocationInputView(){
        delegate?.presentLocationInputView()
    }
}
