//
//  ViewController.swift
//  GeoTargeting
//
//  Created by Eugene Trapeznikov on 4/23/16.
//  Copyright © 2016 Evgenii Trapeznikov. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps

class ViewController: UIViewController {

    
	let locationManager = CLLocationManager()
	//var monitoredRegions: Dictionary<String, Date> = [:]

	override func viewDidLoad() {
		super.viewDidLoad()
        
//        blurView.layer.cornerRadius = 15
//        topView.layer.shadowColor = UIColor.black.cgColor
//        topView.layer.shadowOpacity = 1
//        topView.layer.shadowOffset = CGSize(width: 0,height: 5)

	}

    override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        
	}
	// Fonction message pop up avec UIAlertController

	func showAlert(_ title: String) {
		let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
			alert.dismiss(animated: true, completion: nil)
		}))
		self.present(alert, animated: true, completion: nil)
	}
}

