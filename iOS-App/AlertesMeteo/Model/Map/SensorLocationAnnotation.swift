//
//  SensorLocationAnnotation.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 26/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import MapKit

class SensorLocationAnnotation: MKPointAnnotation {
	
	// MARK: Properties
	
	let sensorName: String
	private(set) var timestamp: String
	
	// MARK: Lifecycle
	
	init(sensorName: String, timestamp: String) {
		self.sensorName = sensorName
		self.timestamp 	= timestamp
		
		super.init()
		
		title = sensorName
	}
	
	// MARK: Methods
	
	func setCoordinate(_ coordinate: CLLocationCoordinate2D, timestamp: String) {
		self.coordinate = coordinate
		self.timestamp 	= timestamp
	}
	
}
