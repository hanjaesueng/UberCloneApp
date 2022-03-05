//
//  Extensions.swift
//  uberPractice
//
//  Created by 김현미 on 2022/02/28.
//

import UIKit
import MapKit

extension UIColor {
    static func rgb(red:CGFloat,green:CGFloat,blue : CGFloat) -> UIColor {
        return UIColor.init(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
    
    static let backgroundColor = UIColor.rgb(red: 25, green: 25, blue: 25)
    static let mainBlueTint = UIColor.rgb(red: 17, green: 154, blue: 237)
}

extension UIView {
    
    
    func inputContainerView(image : UIImage,textField : UITextField? = nil, segmentedControl : UISegmentedControl? = nil) -> UIView{
        let view = UIView()
        let imageView = UIImageView()
        imageView.image = image
        imageView.alpha = 0.87
        view.addSubview(imageView)
        
        
        if let textField = textField {
            imageView.centerY(in: view)
            imageView.anchor(left:view.leftAnchor,paddingLeft: 8,width: 24,height: 24)
            
            view.addSubview(textField)
            textField.anchor(left : imageView.rightAnchor, right: view.rightAnchor,paddingLeft: 8)
            textField.centerY(in: view)
        }
        
        if let segmentedControl = segmentedControl {
            imageView.anchor(top:view.topAnchor,left: view.leftAnchor,paddingTop:-8,paddingLeft: 8,width: 24,height: 24)
            view.addSubview(segmentedControl)
            segmentedControl.anchor(left:view.leftAnchor,right: view.rightAnchor,paddingLeft: 8,paddingRight: 8)
            segmentedControl.centerY(in: view,constant:8)
        }
        
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = .lightGray
        view.addSubview(seperatorView)
        seperatorView.anchor(left: view.leftAnchor,bottom: view.bottomAnchor,right: view.rightAnchor,paddingLeft: 8,height: 0.75)
        return view
    }
    
    func anchor(top : NSLayoutYAxisAnchor? = nil,
                left : NSLayoutXAxisAnchor? = nil,
                bottom : NSLayoutYAxisAnchor? = nil,
                right : NSLayoutXAxisAnchor? = nil,
                paddingTop : CGFloat = 0,
                paddingLeft : CGFloat = 0,
                paddingBotton : CGFloat = 0,
                paddingRight : CGFloat = 0,
                width : CGFloat? = nil,
                height : CGFloat? = nil){
        
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        if let top = top {
            topAnchor.constraint(equalTo: top,constant: paddingTop).isActive = true
        }
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBotton).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func centerX(in view:UIView) {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    func centerY(in view:UIView,leftAnchor : NSLayoutXAxisAnchor? = nil,paddingLeft : CGFloat = 0,constant : CGFloat = 0) {
        if translatesAutoresizingMaskIntoConstraints {
            translatesAutoresizingMaskIntoConstraints = false
        }
        centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: constant).isActive = true
        
        if let leftAnchor = leftAnchor {
            anchor(left:leftAnchor,paddingLeft: paddingLeft)
        }
    }
    
    func setDimensions(height : CGFloat,width : CGFloat) {
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func addShadow(){
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.55
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        layer.masksToBounds = false
    }
}

extension UITextField {
    func textField(withPlaceholer placeholer : String, isSecureTextEntry : Bool) -> UITextField {
        let tf = UITextField()
        
        tf.borderStyle = .none
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = .white
        tf.keyboardAppearance = .dark
        tf.attributedPlaceholder = NSAttributedString(string: placeholer, attributes: [.foregroundColor : UIColor.lightGray])
        tf.isSecureTextEntry = isSecureTextEntry
        return tf
    }
}

extension MKPlacemark {
    var address: String? {
        get {
            guard let subThroughfare = subThoroughfare else {return nil}
            guard let thoroughfare = thoroughfare else { return nil}
            guard let locality = locality else {return nil}
            guard let adminArea = administrativeArea else {return nil}
            
            return "\(subThroughfare) \(thoroughfare), \(locality), \(adminArea)"
        }
    }
}

extension MKMapView {
    func zoomToFit(annotations: [MKAnnotation]) {
        var zoomRect = MKMapRect.null
        
        annotations.forEach { anno in
            let annotationPoint = MKMapPoint(anno.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            
            zoomRect = zoomRect.union(pointRect)
        }
        
        let insets = UIEdgeInsets(top: 100, left: 100, bottom: 250, right: 100)
        setVisibleMapRect(zoomRect, edgePadding: insets, animated: true)
    }
}

extension UIViewController {
    
    func presentAlertController(withTitle title : String,message : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert,animated:true,completion:nil)
    }
    func shouldPresentLoadingView(_ present : Bool, message : String? = nil){
        if present {
            let loadingView = UIView()
            loadingView.frame = self.view.frame
            loadingView.backgroundColor = .black
            loadingView.alpha = 0
            loadingView.tag = 1
            
            let indicator = UIActivityIndicatorView()
            indicator.style = UIActivityIndicatorView.Style.whiteLarge
            indicator.center = view.center
            
            let label = UILabel()
            label.text = message
            label.font = UIFont.systemFont(ofSize: 20)
            label.textColor = .white
            label.textAlignment = .center
            label.alpha = 0.87
            
            view.addSubview(loadingView)
            loadingView.addSubview(indicator)
            loadingView.addSubview(label)
            
            label.centerX(in: view)
            label.anchor(top:indicator.bottomAnchor,paddingTop: 32)
            
            indicator.startAnimating()
            
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 0.7
            }
        } else {
            view.subviews.forEach { subView in
                if subView.tag == 1 {
                    UIView.animate(withDuration: 0.3) {
                        subView.alpha = 0
                    } completion: { _ in
                        subView.removeFromSuperview()
                    }

                }
            }
        }
    }
}
