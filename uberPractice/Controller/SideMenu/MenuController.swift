//
//  MenuController.swift
//  uberPractice
//
//  Created by jaeseung han on 2022/03/06.
//


import UIKit

private let reuseIdentifier = "MenuCell"

enum MenuOptions : Int, CaseIterable, CustomStringConvertible {
    case yourTrips
    case settings
    case logout
    
    var description: String {
        switch self {
        case .yourTrips:
            return "Your Trips"
        case .settings:
            return "Settings"
        case .logout:
            return "Log Out"
        }
    }
}

protocol MenuControllerDelegate : AnyObject {
    func didSelect(option : MenuOptions)
}


class MenuController : UIViewController {
    // MARK: - Properties
    
    private let user : User
    weak var delegate : MenuControllerDelegate?
    
    private lazy var menuHeader : MenuHeader = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width - 80, height: 140)
        let view = MenuHeader(user:user,frame: frame)
        
        return view
    }()
    private var tableView : UITableView!
    
    // MARK: - Lifecycle
    
    init(user:User){
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureTableView()
    }
    
    
    // MARK: - Selectors
    
    // MARK: - Helper Functions
    
    func configureTableView() {
        tableView = UITableView()
        view.addSubview(tableView)
        tableView.anchor(top:view.topAnchor,left: view.leftAnchor,bottom: view.bottomAnchor,right: view.rightAnchor)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableHeaderView = menuHeader
    }
}

// MARK: - UITableViewDelegate

extension MenuController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOptions.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        guard let option = MenuOptions(rawValue: indexPath.row) else {return cell}
        cell.textLabel?.text = option.description
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let option = MenuOptions(rawValue: indexPath.row) else {return}
        
        delegate?.didSelect(option: option)
    }

}
