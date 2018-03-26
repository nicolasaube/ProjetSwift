//
// ViewController.swift
//  LazyTourist
//
//  Created by Nicolas Aubé on 24/03/2018.
//  Copyright © 2018 Nico aka Babou le barbar. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces

class ViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var adressLabel: UILabel!
    
    private let locationManager = CLLocationManager()
    private let dataProvider = GoogleDataProvider()
    private let searchRadius: Double = 1000
    private var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
    
    //Rafraichir lieux
    @IBAction func refreshPlaces(_ sender: Any) {
        fetchNearbyPlaces(coordinate: mapView.camera.target)
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        if let location = locationManager.location {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        }
        else {
            print("Ds ta face")
        }
        
        mapView.delegate = self
        
//        blurView.layer.cornerRadius = 15
//        topView.layer.shadowColor = UIColor.black.cgColor
//        topView.layer.shadowOpacity = 1
//        topView.layer.shadowOffset = CGSize(width: 0,height: 5)

	}

    override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        
	}
	// Fonction message pop up avec UIAlertController(SI je veux print a lecran)

	func showAlert(_ title: String) {
		let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
			alert.dismiss(animated: true, completion: nil)
		}))
		self.present(alert, animated: true, completion: nil)
	}
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        // 1 utilise pour transformer des coordonnées en une adresse
        let geocoder = GMSGeocoder()
        
        // 2 fonction reverse
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            
            // 3 fonction ecrire dans le label adresse
            self.adressLabel.text = lines.joined(separator: "\n")
            
            // Pour le padding qui empeche le label de cacher les bails
            let labelHeight = self.adressLabel.intrinsicContentSize.height
            if #available(iOS 11.0, *) {    //Seulement > iOS 11 apparemment
                self.mapView.padding = UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0,
                                                    bottom: labelHeight, right: 0)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    public func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
        // 1
        mapView.clear()
        // 2
        dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
            places.forEach {
                // 3
                let marker = PlaceMarker(place: $0)
                // 4
                marker.map = self.mapView
            }
        }
    }
    
    // Appelé qd la map arrete de bouger car user arrete de bouger
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
    
}

// MARK: - CLLocationManagerDelegate (Ajoute des d'elegate dans une extension)
//1
extension ViewController: CLLocationManagerDelegate {
    // 2Qd authorisation chhange
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 3Authorisé?
        guard status == .authorizedAlways else {
            return
        }
        // 4Updtae position
        locationManager.startUpdatingLocation()
        
        //5
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    // 6 Lorsque changement position
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        
        // 7 Centrage camera
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        
        // 8
        locationManager.stopUpdatingLocation()
        
        fetchNearbyPlaces(coordinate: mapView.camera.target)
    }
}

// MARK: - TypesTableViewControllerDelegate
extension ViewController: TypesTableViewControllerDelegate {
    func typesController(_ controller: TypesTableViewController, didSelectTypes types: [String]) {
        searchedTypes = controller.selectedTypes.sorted()
        dismiss(animated: true)
        fetchNearbyPlaces(coordinate: mapView.camera.target)
    }
}



