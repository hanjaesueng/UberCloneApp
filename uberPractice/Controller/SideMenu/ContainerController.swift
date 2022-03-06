//
//  ContainerController.swift
//  uberPractice
//
//  Created by jaeseung han on 2022/03/06.
//

import UIKit
import Firebase

class ContainerController : UIViewController {
    // MARK: - Properties
    
    private var homeController = HomeController()
    private var menueController : MenuController!
    private var isExpand = false
    private let blackView = UIView()
    private lazy var xOrigin = self.view.frame.width - 80
    
    private var user:User? {
        didSet {
            guard let user = user else {return}
            homeController.user = user
            configureMenuController(withUser: user)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIFUserIsLoggedIn()
    }
    
    override var prefersStatusBarHidden: Bool {
        return isExpand
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
     
    // MARK: - Selectors
    
    @objc func dismissMenu(){
        isExpand = false
        animateMenu(shouldExpand: isExpand)
    }
    
    // MARK: - API
    
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
            configure()
        }
    }
    func fetchUserData(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        Service.shared.fetchUserdata(uid:currentUid) {[weak self] user in
            guard let self = self else {return}
            self.user = user
            
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {[weak self] in
                guard let self = self else {return}
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav,animated: true,completion: nil)
            }
        } catch {
            print("DEBUG: Error Signing out")
        }
    }
    // MARK: - Helper Functions
    
    func configure(){
        view.backgroundColor = .backgroundColor
        fetchUserData()
        configureHomeController()
        configureBlackView()
    }
    
    func configureHomeController() {
        // container에 home controller 넣기
        addChild(homeController)
        homeController.didMove(toParent: self)
        view?.addSubview(homeController.view)
        homeController.delegate = self
        
    }
    
    func configureMenuController(withUser user : User) {
        menueController = MenuController(user: user)
        addChild(menueController)
        menueController.didMove(toParent: self)
        view.insertSubview(menueController.view, at: 0)
        menueController.delegate = self
    }
    
    func configureBlackView(){
        print("DEBUG: xOrigin is \(xOrigin)")
        self.blackView.frame = CGRect(x: xOrigin, y: 0, width: 80, height: self.view.frame.height)
        blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blackView.alpha = 0
        view.addSubview(blackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        blackView.addGestureRecognizer(tap)
    }
    
    func animateMenu(shouldExpand : Bool,completion : ((Bool)->Void)? = nil){
        
        if shouldExpand {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = self.xOrigin
                self.blackView.alpha = 1
            }, completion: nil)
            
        } else {
            self.blackView.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.homeController.view.frame.origin.x = 0
                
            }, completion: completion)
        }
        animateStatusBar()
    }
    
    func animateStatusBar(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
}

//MARK: - HomeControllerDelegate

extension ContainerController : HomeControllerDelegate {
    func handleMenuToggle() {
        isExpand.toggle()
        animateMenu(shouldExpand: isExpand)
    }
}

//MARK: - MenuControllerDelegate

extension ContainerController : MenuControllerDelegate {
    func didSelect(option: MenuOptions) {
        isExpand.toggle()
        animateMenu(shouldExpand: isExpand) { _ in
            switch option {
            case .yourTrips:
                break
            case .settings:
                guard let user = self.user else {return}
                let controller = SettingController(user: user)
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav,animated: true,completion: nil)
            case .logout:
                let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: {[weak self] _ in
                    guard let self = self else {return}
                    self.signOut()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
