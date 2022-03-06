//
//  UserInforHeader.swift
//  uberPractice
//
//  Created by jaeseung han on 2022/03/07.
//

import UIKit

class UserInfoHeader : UIView{
    //MARK: - Properties
    
    private let user : User
    private let profileImageView : UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private lazy var fullnameLabel : UILabel = {
        let label = UILabel()
       
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
    
    //MARK: - Lifecycle
    
    init(user:User,frame:CGRect){
        self.user = user
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(profileImageView)
        profileImageView.centerY(in: self,leftAnchor: leftAnchor,paddingLeft: 16)
        profileImageView.setDimensions(height: 64, width: 64)
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
}
