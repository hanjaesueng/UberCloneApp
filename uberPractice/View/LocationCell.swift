//
//  LocationCell.swift
//  uberPractice
//
//  Created by 김현미 on 2022/03/01.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {

    // MARK: - Properties
    
    var placemark : MKPlacemark? {
        didSet {
            titleLable.text = placemark?.name
            addressLabel.text = placemark?.address
        }
    }
    
    private let titleLable : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "123 Main Street"
        return label
    }()
    
    private let addressLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "123 Main Street, Washington, DC"
        return label
    }()
    
    // MARK: - LifeCycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [titleLable,addressLabel])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 4
        
        addSubview(stack)
        stack.centerY(in: self,leftAnchor: leftAnchor,paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
