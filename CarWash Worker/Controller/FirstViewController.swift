//
//  FirstViewController.swift
//  CarWash Worker
//
//  Created by Himanshu Joshi on 12/01/21.
//

import UIKit

class FirstViewController: UIViewController {
    
    let activityIndicator: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView()
        return activity
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        
        self.activityIndicator.startAnimating()
        
    }

}
