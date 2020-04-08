//
//  MapVC.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 25/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import Combine

class MapVC: UIViewController {
	
	// MARK: Model
	
	#if DEBUG
	enum SegmentIndexes: Int {
		case normal, debug
	}
	#endif
	
	// MARK: Properties
	
	private var mapView: MKMapView!
	private let mapViewDelegate = MainMapViewDelegate()
	
	private var sensorLocations = [String: SensorLocationAnnotation]()
	private var overlaysCoordinates = [String: (overlayIndex: Int, coordinates: [CLLocationCoordinate2D])]()
	private var locationsRefs = [String: [String: DatabaseReference]]()
	
	private let sensorLocationsDataSource = SensorLocationsDataSource()
	private var locationsSubscriptionCanceller: AnyCancellable?
	
	private let alertsDataSource = AlertsDataSource()
	private var alertsSubscriptionCanceller: AnyCancellable?
	
	#if DEBUG
	private let editModeSegmentedControl = UISegmentedControl()
	private var boatName = "ios-app-\(Int(Date().timeIntervalSince1970))"
	#endif
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureMapView()
		configureSensorLocationsDataSource()
		configureAlertsDataSource()
		#if DEBUG
		configureEditModeSegmentedControl()
		#endif
		configureFloatingControlsVC()
	}
	
	deinit {
		sensorLocationsDataSource.stopListening()
		locationsSubscriptionCanceller?.cancel()
		alertsDataSource.stopListening()
		alertsSubscriptionCanceller?.cancel()
	}
	
	// MARK: Events
	
	@objc private func showFilters() {
		#if DEBUG
		print("\(type(of: self)).\(#function): [INFO] Tap")
		#endif
	}
	
	#if DEBUG
	@objc private func mapTapped(sender: UITapGestureRecognizer) {
		guard editModeSegmentedControl.selectedSegmentIndex == SegmentIndexes.debug.rawValue else { return }
		
		let coordinate = mapView.convert(sender.location(in: sender.view), toCoordinateFrom: sender.view)
		
		let data: [String:Any] = [
			"sensorName": boatName,
			"timestamp": Date().iso8601,
			"latitude": coordinate.latitude,
			"longitude": coordinate.longitude
		]
		
		let sensorLocationsRef = Database.database().reference().child("sensorLocations")
		sensorLocationsRef.childByAutoId().setValue(data)
	}
	
	@objc func createNewBoat() {
		#if DEBUG
		print("\(type(of: self)).\(#function): [INFO]")
		#endif
		
		boatName = "ios-app-\(Int(Date().timeIntervalSince1970))"
	}
	#endif
	
	// MARK: Configuration
	
	private func configureMapView() {
		mapView = MKMapView(frame: view.bounds)
		mapView.delegate = mapViewDelegate
		
		mapView.isRotateEnabled = false
		mapView.isPitchEnabled 	= false
		
		mapView.mapType = .mutedStandard
		mapView.pointOfInterestFilter = MKPointOfInterestFilter(including: [.airport, .aquarium, .fireStation, .hospital, .marina])
		
		view.addSubview(mapView)

		#if DEBUG
		let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped(sender:)))
		mapView.addGestureRecognizer(gestureRecognizer)
		#endif
	}
	
	private func configureSensorLocationsDataSource() {
		sensorLocationsDataSource.listen()
		
		// Listen for new locations
		locationsSubscriptionCanceller = sensorLocationsDataSource.newLocationSubject
			.receive(on: RunLoop.main)
			.sink { [weak self] (newAnnotation: SensorLocationAnnotation) in
				guard let self = self else { return }
				
				let sensorName = newAnnotation.sensorName
				
				if let existingAnnotation = self.sensorLocations[sensorName] {
					if existingAnnotation.timestamp <= newAnnotation.timestamp {
						existingAnnotation.setCoordinate(newAnnotation.coordinate, timestamp: newAnnotation.timestamp)
					}
				} else {
					self.mapView.addAnnotation(newAnnotation)
					self.sensorLocations[sensorName] = newAnnotation
				}
				
				let index 		= self.overlaysCoordinates[sensorName]?.overlayIndex 	?? self.mapView.overlays.count
				var coordinates = self.overlaysCoordinates[sensorName]?.coordinates 	?? []
				
				if !coordinates.isEmpty {
					self.mapView.removeOverlay(self.mapView.overlays[index])
				}
				
				coordinates.append(newAnnotation.coordinate)
				
				let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
				polyline.title = sensorName
				self.mapView.insertOverlay(polyline, at: index)
				
				self.overlaysCoordinates[sensorName] = (overlayIndex: index, coordinates: coordinates)
			}
	}
	
	private func configureAlertsDataSource() {
		alertsDataSource.listen()
		alertsSubscriptionCanceller = alertsDataSource.newAlertSubject
			.receive(on: RunLoop.main)
			.sink { [weak self] (alert: Alert) in
				guard let self = self else { return }
				guard let latitude = alert.latitude, let longitude = alert.longitude else { return }
				
				let annotation = AlertAnnotation(alert: alert)
				annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
				self.mapView.addAnnotation(annotation)
			}
	}

	#if DEBUG
	private func configureEditModeSegmentedControl() {
		editModeSegmentedControl.backgroundColor = .tertiarySystemBackground
		
		editModeSegmentedControl.insertSegment(withTitle: "Mode normal", at: SegmentIndexes.normal.rawValue, animated: false)
		editModeSegmentedControl.insertSegment(withTitle: "Mode interactif", at: SegmentIndexes.debug.rawValue, animated: false)
		
		editModeSegmentedControl.selectedSegmentIndex = SegmentIndexes.normal.rawValue
	}
	#endif
	
	private func configureFloatingControlsVC() {
		let vc = FloatingControlsVC()
		
		// Markers filtering button
		let filterButton = AMMapButton(icon: Images.filter.uiImage)
		filterButton.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
		vc.addControl(filterButton, in: .bottom)
		
		#if DEBUG
		// New boat creation button
		let newBoatButton = AMMapButton(icon: UIImage(systemName: "goforward.plus"))
		newBoatButton.addTarget(self, action: #selector(createNewBoat), for: .touchUpInside)
		vc.addControl(newBoatButton, in: .topRight)
		
		// Edit mode selection
		vc.addControl(editModeSegmentedControl, in: .top)
		#endif
		
		let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame
		vc.view.frame = CGRect(origin: .zero, size: safeAreaFrame.size)
		
		addChild(vc)
		view.addSubview(vc.view)
		vc.didMove(toParent: self)
	}
	
}
