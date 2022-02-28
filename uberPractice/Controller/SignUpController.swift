//
//  SignUpViewController.swift
//  uberPractice
//
//  Created by 김현미 on 2022/02/28.
//

import UIKit
import Firebase

class SignUpController : UIViewController {
    
    // MARK: - properties
    
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
    
    private lazy var fullNameContainerView : UIView = {
        let view = UIView().inputContainerView(image: UIImage(named: "ic_person_outline_white_2x")!, textField: fullNameTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let fullNameTextField : UITextField = {
        return UITextField().textField(withPlaceholer: "Fullname", isSecureTextEntry: false)
    }()

    private lazy var accountTypeContainerView : UIView = {
        let view = UIView().inputContainerView(image: UIImage(named: "ic_account_box_white_2x")!, segmentedControl: accountTypeSegmentedControl)
        view.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return view
    }()
   
    private let accountTypeSegmentedControl : UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Rider","Driver"])
        sc.backgroundColor = .backgroundColor
        sc.tintColor = UIColor(white: 1, alpha: 0.87)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    private let signUpButton : UIButton = {
        let btn = AuthButton(type: .system)
        btn.setTitle("Sign Up", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return btn
    }()
    
    private let alreadyHaveAccountButton : UIButton = {
        let btn = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [.font : UIFont.systemFont(ofSize: 16),.foregroundColor:UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [.font:UIFont.boldSystemFont(ofSize: 16),.foregroundColor:UIColor.mainBlueTint]))
        btn.addTarget(self, action: #selector(handleDismissSignUp), for: .touchUpInside)
        btn.setAttributedTitle(attributedTitle, for: .normal)
        return btn
    }()
   
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - selectors
    
    @objc func handleSignUp(){
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let fullname = fullNameTextField.text else {return}
        let accountTypeIndex = accountTypeSegmentedControl.selectedSegmentIndex
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Failed to register user with error \(error)")
                return
            }
            
            guard let uid = result?.user.uid else {return}
            let values = ["email":email,
                          "fullname":fullname,
                          "accountType":accountTypeIndex] as [String:Any]
            Database.database().reference().child("users").child(uid).updateChildValues(values) {[weak self] error, ref in
                guard let self = self else {return}
                guard error == nil else {
                    print("Failed register user data")
                    return
                }
                
                guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeController else {return}
                controller.configureUI()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleDismissSignUp(){
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Function
    
    func configureUI(){
        
        view.backgroundColor = .backgroundColor
        view.addSubview(titleLabel)
        
        titleLabel.anchor(top:view.safeAreaLayoutGuide.topAnchor)
        titleLabel.centerX(in: view)
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView,fullNameContainerView,passwordContainerView,accountTypeContainerView,signUpButton])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 24
        
        view.addSubview(stack)
        stack.anchor(top:titleLabel.bottomAnchor,left: view.leftAnchor,right: view.rightAnchor,paddingTop: 40,paddingLeft: 16,paddingRight: 16)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(in: view)
        alreadyHaveAccountButton.anchor(bottom:view.safeAreaLayoutGuide.bottomAnchor,height: 32)
    }
}
