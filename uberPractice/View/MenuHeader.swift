//
//  MenuHeader.swift
//  uberPractice
//
//  Created by jaeseung han on 2022/03/06.
//

import UIKit

class MenuHeader : UIView{
    // MARK: - Properties
    
   
    private let user : User
    
    private lazy var profileImageView : UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.addSubview(initialLable)
        initialLable.centerX(in: view)
        initialLable.centerY(in: view)
        return view
    }()
    
    private lazy var initialLable : UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 42)
        label.text = user.firstInitial
        return label
    }()
    
    private lazy var fullnameLabel : UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = user.fullname
        return label
    }()
    
    private lazy var emailLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = user.email
        return label
    }()
    
    // MARK: - Lifecycle
    init(user:User,frame:CGRect){
        self.user = user
        super.init(frame: frame)
        backgroundColor = .backgroundColor
        addSubview(profileImageView)
        profileImageView.anchor(top:safeAreaLayoutGuide.topAnchor,left:leftAnchor,paddingTop: 4,paddingLeft: 12,width : 64, height: 64)
        profileImageView.layer.cornerRadius = 64/2
        
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel,emailLabel])
        stack.distribution = .fillEqually
        stack.spacing = 4
        stack.axis = .vertical
        addSubview(stack)
        stack.centerY(in : profileImageView, leftAnchor: profileImageView.rightAnchor,paddingLeft: 12)
    }
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
}
