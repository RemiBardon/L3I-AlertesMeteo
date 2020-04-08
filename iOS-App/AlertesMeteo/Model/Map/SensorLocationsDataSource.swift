//
//  SensorLocationsDataSource.swift
//  AlertesMeteo
//
//  Created by BARDON Rémi on 30/03/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import CoreLocation
import Combine
import Firebase

class SensorLocationsDataSource {
	
	// MARK: Properties
	
	private var databaseRef: DatabaseReference!
	private var refHandle: DatabaseHandle?
	
	let newLocationSubject = PassthroughSubject<SensorLocationAnnotation, Never>()
	
	private var sensorLocationsRef: DatabaseReference { databaseRef.child("sensorLocations") }
	
	// MARK: Lifecycle
	
	deinit {
		stopListening()
	}
	
	// MARK: Methods
	
	func listen() {
		// Initialisation of `databaseRef`, important because it's used in computed variable `sensorLocationsRef`
		databaseRef = Database.database().reference()
		
		#warning("Fetch data from InfluxDB instead of using Firebase Realtime Database")
		
		// Listen for new locations in the Firebase Realtime Database
		refHandle = sensorLocationsRef.observe(.childAdded) { [weak self] (snapshot) in
			guard let self = self else { return }
			
			let data = snapshot.prepareForDecoding()
//			#if DEBUG
//			print("\(type(of: self)).\(#function): [INFO] New child: \(data)")
//			#endif
			
			guard let sensorName = data["sensorName"] as? String,
				let timestamp = data["timestamp"] as? String,
				let latitude = data["latitude"] as? Double,
				let longitude = data["longitude"] as? Double
			else {
				#if DEBUG
				print("\(type(of: self)).\(#function): [ERROR] Missing keys in data of added child")
				#endif
				return
			}
			
			let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

			let newAnnotation = SensorLocationAnnotation(sensorName: sensorName, timestamp: timestamp)
			newAnnotation.coordinate = coordinate
			self.newLocationSubject.send(newAnnotation)
		}
		
		// Not listening for deleted locations anymore (only for tests)
	}
	
	func stopListening() {
		if let refHandle = refHandle {
			sensorLocationsRef.removeObserver(withHandle: refHandle)
		}
	}
	
}
