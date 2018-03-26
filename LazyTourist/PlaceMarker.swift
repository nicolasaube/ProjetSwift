//
//  PlaceMarker.swift
//  LazyTourist
//
//  Created by Nicolas Aubé on 24/03/2018.
//  Copyright © 2018 Nico aka Babou le barbar. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class PlaceMarker: GMSMarker {
    // 1
    let place: GMSPlacesClient
    
    // 2
    init(place: GooglePlace) {
        self.place = place
        super.init()
        
        position = place.coordinate
        icon = UIImage(named: place.placeType+"_pin")
        groundAnchor = CGPoint(x: 0.5, y: 1)
        appearAnimation = .pop
    }
}
