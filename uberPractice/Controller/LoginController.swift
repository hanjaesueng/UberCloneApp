//
//  LoginController.swift
//  uberPractice
//
//  Created by 김현미 on 2022/02/28.
//

import UIKit

class LoginController : UIViewController {
    
    // MARK: - Properties
    
    private let titleLabel : UILabel = {
        let label = UILabel()
        label.text = "UBER"
        label.font = UIFont(name: "Avenir-Light", size: 36)
        label.textColor = UIColor(white: 1, alpha: 0.8)
        return label
    }()
    
    private lazy var emailContainerView : UIView = {
        let view = UIView().inputContainerView(image: UIImage(named: "ic_mail_outline_white_2x")!, textField: emailTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let emailTextField : UITextField = {
        return UITextField().textField(withPlaceholer: "Email", isSecureTextEntry: false)
    }()
    
    private lazy var passwordContainerView : UIView = {
        let view = UIView().inputContainerView(image: UIImage(named: "ic_lock_outline_white_2x")!, textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let passwordTextField : UITextField = {
        return UITextField().textField(withPlaceholer: "Password", isSecureTextEntry: true)
    }()
    
    private let loginButton : UIButton = {
        let btn = AuthButton(type: .system)
        btn.setTitle("Log In", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        return btn
    }()
    
    private let dontHaveAccountButton : UIButton = {
        let btn = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: [.font : UIFont.systemFont(ofSize: 16),.foregroundColor:UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [.font:UIFont.boldSystemFont(ofSize: 16),.foregroundColor:UIColor.mainBlueTint]))
        btn.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        btn.setAttributedTitle(attributedTitle, for: .normal)
        return btn
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: - buttonAction
    @objc func handleShowSignUp(){
        let controller = SignUpController()
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    // MARK: - Helper Function
    
    func configureUI(){
        configureNavigationBar()
        
        view.backgroundColor = .backgroundColor
        view.addSubview(titleLabel)
        
        titleLabel.anchor(top:view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(in: view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,passwordContainerView,loginButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 24
        
        view.addSubview(stack)
        stack.anchor(top:titleLabel.bottomAnchor,left: view.leftAnchor,right: view.rightAnchor,paddingTop: 40,paddingLeft: 16,paddingRight: 16)
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(in: view)
        dontHaveAccountButton.anchor(bottom:view.safeAreaLayoutGuide.bottomAnchor,height: 32)
    }
    
    func configureNavigationBar(){
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
}
