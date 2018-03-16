//
//  ViewController.swift
//  GeoTargeting
//
//  Created by Eugene Trapeznikov on 4/23/16.
//  Copyright © 2016 Evgenii Trapeznikov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

	@IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var topView: UIView!
    
	let locationManager = CLLocationManager()
	//var monitoredRegions: Dictionary<String, Date> = [:]

	override func viewDidLoad() {
		super.viewDidLoad()
        
        blurView.layer.cornerRadius = 15
        topView.layer.shadowColor = UIColor.black.cgColor
        topView.layer.shadowOpacity = 1
        topView.layer.shadowOffset = CGSize(width: 0,height: 5)
        
        //viewConstraint.constant

		// Parametres localisation user
		locationManager.delegate = self
		locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true

		// Parametres mapView
		mapView.delegate = self
		mapView.showsUserLocation = true
		mapView.userTrackingMode = .follow

	}

    override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        
        // Si statut non determine
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
            // Si authorisation refusée
        else if CLLocationManager.authorizationStatus() == .denied {
            showAlert("Location services were previously denied. Please enable location services for this app in Settings.")
        }
            // Authorise a toujours utiliser les services de localisation
        else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
	}

    func setupData() {
		// check if can monitor regions
		if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            //let requestTab : [MKLocalSearchRequest]
            //Recherche
            let request = MKLocalSearchRequest()
            request.naturalLanguageQuery = "McDonald's"
            request.region = self.mapView.region
            
            print(request.region.center)
            
            let search = MKLocalSearch(request: request)
            search.start { (response, error) in
                guard let response = response else {
                    print("Search error: \(String(describing: error))")
                    return
                }
                print(response.boundingRegion.center)
                
                for item in response.mapItems {
                    
                    // region data
                    if let title = item.name {
                        
                        let coordinate = CLLocationCoordinate2DMake(item.placemark.coordinate.latitude, item.placemark.coordinate.longitude)
                        let regionRadius = 50.0
                        
                        // setup region
                        let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                                                     longitude: coordinate.longitude), radius: regionRadius, identifier: title)
                        self.locationManager.startMonitoring(for: region)
                        
                        // setup annotation
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate;
                        annotation.title = "\(title)";
                        self.mapView.addAnnotation(annotation)
                        
                        // setup circle
                        let circle = MKCircle(center: coordinate, radius: regionRadius)
                        self.mapView.add(circle)
                        
                    }
                }
            }
		}
		else {
			print("System can't track regions")
		}
	}

	// MARK: - MKMapViewDelegate

	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let circleRenderer = MKCircleRenderer(overlay: overlay)
		circleRenderer.strokeColor = UIColor.red
		circleRenderer.lineWidth = 1.0
		return circleRenderer
	}

	// MARK: - CLLocationManagerDelegate

	func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
		showAlert("Vous etes a proximite de \(region.identifier)")
		//monitoredRegions[region.identifier] = Date()
	}
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.last {
            let span = MKCoordinateSpanMake(0.01, 0.02)
            let region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            setupData()
        }
    }

//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        updateRegionsWithLocation(locations[0])
//        print("on update")
//    }

	// MARK: - Comples business logic

//    func updateRegionsWithLocation(_ location: CLLocation) {
//
//        let regionMaxVisiting = 10.0
//        var regionsToDelete: [String] = []
//
//        for regionIdentifier in monitoredRegions.keys {
//            if Date().timeIntervalSince(monitoredRegions[regionIdentifier]!) > regionMaxVisiting {
//                showAlert("Thanks for visiting our restaurant")
//
//                regionsToDelete.append(regionIdentifier)
//            }
//        }
//
//        for regionIdentifier in regionsToDelete {
//            monitoredRegions.removeValue(forKey: regionIdentifier)
//        }
//    }

	// Fonction message pop up avec UIAlertController

	func showAlert(_ title: String) {
		let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
			alert.dismiss(animated: true, completion: nil)
		}))
		self.present(alert, animated: true, completion: nil)
	}
}

