//
//  MapVC.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 25/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import Combine

class MapVC: UIViewController {
	
	// MARK: - Properties
	
	private var mapView: MKMapView!
	private var databaseRef: DatabaseReference!
	private var refHandle: DatabaseHandle?
	
	private var sensorLocations = [String: SensorLocationAnnotation]()
	private var overlaysCoordinates = [String: (overlayIndex: Int, coordinates: [CLLocationCoordinate2D])]()
	private var locationsRefs = [String: [String: DatabaseReference]]()
	
	private let alertsDataSource = AlertsDataSource()
	private var subscriptionCanceller: AnyCancellable?
	
	private let editModeSegmentedControl = UISegmentedControl()
	private var boatName = "ios-app-\(Int(Date().timeIntervalSince1970))"
	enum SegmentIndexes: Int {
		case normal, debug
	}
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		configureMapView()
		listenForChanges()
		configureAlertsDataSource()
		configureEditModeSegmentedControl()
		configureFloatingControlsVC()
	}
	
	deinit {
		alertsDataSource.stopListening()
		subscriptionCanceller?.cancel()
	}
	
	// MARK: - Configuration
	
	private func configureMapView() {
		mapView = MKMapView(frame: view.bounds)
		mapView.delegate = self
		
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
	
	private func listenForChanges() {
		databaseRef = Database.database().reference()
		let sensorLocationsRef = databaseRef.child("sensorLocations")
		
		// Listen for new comments in the Firebase database
		refHandle = sensorLocationsRef.observe(.childAdded, with: { [weak self] (snapshot) -> Void in
			guard let self = self else { return }
			
			let data = snapshot.prepareForDecoding()
			#if DEBUG
			print("\(type(of: self)).\(#function): New child: \(data)")
			#endif
			
			#warning("Add debug messages")
			guard let sensorName = data["sensorName"] as? String else { return }
			guard let timestamp = data["timestamp"] as? String else { return }
			guard let latitude = data["latitude"] as? Double, let longitude = data["longitude"] as? Double else { return }
			
			let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
			
			if let existingAnnotation = self.sensorLocations[sensorName] {
				if existingAnnotation.timestamp < timestamp {
					existingAnnotation.setCoordinate(coordinate, timestamp: timestamp)
				}
			} else {
				let newAnnotation = SensorLocationAnnotation(sensorName: sensorName, timestamp: timestamp)
				newAnnotation.coordinate = coordinate
				self.mapView.addAnnotation(newAnnotation)
				self.sensorLocations[sensorName] = newAnnotation
			}
			
			let index 		= self.overlaysCoordinates[sensorName]?.overlayIndex 	?? self.mapView.overlays.count
			var coordinates = self.overlaysCoordinates[sensorName]?.coordinates 	?? []
			
			if !coordinates.isEmpty {
				self.mapView.removeOverlay(self.mapView.overlays[index])
			}
			
			coordinates.append(coordinate)
			
			let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
			polyline.title = sensorName
			self.mapView.insertOverlay(polyline, at: index)
			
			self.overlaysCoordinates[sensorName] = (overlayIndex: index, coordinates: coordinates)
			var sensorLocations = self.locationsRefs[sensorName] ?? {
				let emptyDictionary = [String: DatabaseReference]()
				self.locationsRefs[sensorName] = emptyDictionary
				return emptyDictionary
			}()
			sensorLocations[timestamp] = snapshot.ref
			self.locationsRefs[sensorName] = sensorLocations
		})
		// Listen for deleted comments in the Firebase database
		sensorLocationsRef.observe(.childRemoved, with: { (snapshot) -> Void in
			let data = snapshot.prepareForDecoding()
			
			#if DEBUG
			print("\(type(of: self)).\(#function): Deleted child: \(data)")
			#endif
			
			#warning("Add debug messages")
			guard let sensorName = data["sensorName"] as? String else { return }
			
			if let timestamp = data["timestamp"] as? String {
				self.locationsRefs[sensorName]?.removeValue(forKey: timestamp)
			}
			
			guard let latitude = data["latitude"] as? Double, let longitude = data["longitude"] as? Double else { return }
			
			guard let overlayCoordinates = self.overlaysCoordinates[sensorName] else { return }
			
			for overlayCoordinate in overlayCoordinates.1.enumerated() {
				if overlayCoordinate.element.latitude == latitude && overlayCoordinate.element.longitude == longitude {
					var coordinates = overlayCoordinates.coordinates
					
					guard coordinates.count > overlayCoordinate.offset else { continue }
					
					if overlayCoordinate.offset == coordinates.count - 1 {
						guard let timestamp = data["timestamp"] as? String else { break }
						
						guard let annotation = self.sensorLocations[sensorName] else { break }
						
						if coordinates.count < 2 {
							self.mapView.removeAnnotation(annotation)
						} else {
							let coordinate = coordinates[coordinates.count - 2]
							annotation.setCoordinate(coordinate, timestamp: timestamp)
						}
					}
					
					coordinates.remove(at: overlayCoordinate.offset)
					self.overlaysCoordinates[sensorName] = (overlayIndex: overlayCoordinates.overlayIndex, coordinates: coordinates)
					
					if self.mapView.overlays.count > overlayCoordinates.overlayIndex {
						if let overlay = self.mapView.overlays.first(where: { $0.title == sensorName }) {
							self.mapView.removeOverlay(overlay)
						}
					}
					
					if !coordinates.isEmpty {
						let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
						polyline.title = sensorName
						self.mapView.insertOverlay(polyline, at: overlayCoordinates.overlayIndex)
					} else {
						self.sensorLocations.removeValue(forKey: sensorName)
						self.overlaysCoordinates.removeValue(forKey: sensorName)
					}
				}
			}
		})
	}
	
	private func configureAlertsDataSource() {
		alertsDataSource.listen()
		subscriptionCanceller = alertsDataSource.newAlertSubject
			.receive(on: RunLoop.main)
			.sink { [weak self] (alert: Alert) in
				guard let self = self else { return }
				guard let latitude = alert.latitude, let longitude = alert.longitude else { return }
				
				let annotation = AlertAnnotation(alert: alert)
				annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
				self.mapView.addAnnotation(annotation)
			}
	}
	
	private func configureEditModeSegmentedControl() {
		editModeSegmentedControl.backgroundColor = .tertiarySystemBackground
		
		editModeSegmentedControl.insertSegment(withTitle: "Mode normal", at: SegmentIndexes.normal.rawValue, animated: false)
		editModeSegmentedControl.insertSegment(withTitle: "Mode interactif", at: SegmentIndexes.debug.rawValue, animated: false)
		
		editModeSegmentedControl.selectedSegmentIndex = SegmentIndexes.normal.rawValue
	}
	
	private func configureFloatingControlsVC() {
		let vc = FloatingControlsVC()
		
		let filterButton = AMMapButton(icon: Images.filter.uiImage)
		filterButton.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
		vc.addControl(filterButton, in: .bottom)
		
		let newBoatButton = AMMapButton(icon: UIImage(systemName: "goforward.plus"))
		newBoatButton.addTarget(self, action: #selector(createNewBoat), for: .touchUpInside)
		vc.addControl(newBoatButton, in: .topRight)
		
		let resetBoatsButton = AMMapButton(icon: UIImage(systemName: "trash.fill"))
		resetBoatsButton.addTarget(self, action: #selector(resetBoatLocations), for: .touchUpInside)
		vc.addControl(resetBoatsButton, in: .topRight)
		
		vc.addControl(editModeSegmentedControl, in: .top)
		
		let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame
		vc.view.frame = CGRect(origin: .zero, size: safeAreaFrame.size)
		
		addChild(vc)
		view.addSubview(vc.view)
		vc.didMove(toParent: self)
	}
	
	// MARK: - Events

	#if DEBUG
	@objc private func mapTapped(sender: UITapGestureRecognizer) {
		guard editModeSegmentedControl.selectedSegmentIndex == SegmentIndexes.debug.rawValue else { return }
		
		let coordinate = mapView.convert(sender.location(in: sender.view), toCoordinateFrom: sender.view)
		
		let data: [String:Any] = [
			"sensorName": boatName,
			"timestamp": rfc3339DateTimeStringForDate(date: Date()),
			"latitude": coordinate.latitude,
			"longitude": coordinate.longitude
		]
		
		let sensorLocationsRef = databaseRef.child("sensorLocations")
		sensorLocationsRef.childByAutoId().setValue(data)
	}
	#endif
	
	@objc private func showFilters() {
		#if DEBUG
		print("\(type(of: self)).\(#function): Tap")
		#endif
	}
	
	@objc func createNewBoat() {
		#if DEBUG
		print("\(type(of: self)).\(#function)")
		#endif
		
		boatName = "ios-app-\(Int(Date().timeIntervalSince1970))"
	}
	
	@objc func resetBoatLocations() {
		#if DEBUG
		print("\(type(of: self)).\(#function)")
		#endif
		
		for sensorLocationsRef in locationsRefs.values.flatMap({ $0.filter({ $0.key > "2020-01-30 11:15:09.743000" }).values }) {
			sensorLocationsRef.removeValue()
		}
	}
	
}

// MARK: - MKMapViewDelegate

extension MapVC: MKMapViewDelegate {
	
	func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
		MKClusterAnnotation(memberAnnotations: memberAnnotations)
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard !(annotation is MKUserLocation) else { return nil }
		
		if annotation is SensorLocationAnnotation {
			let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "SensorLocationAnnotation") as? MKMarkerAnnotationView ?? {
				let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "SensorLocationAnnotation")
				annotationView.clusteringIdentifier = "Sensors"
				annotationView.markerTintColor = .systemBlue
				annotationView.glyphImage = Images.boat.uiImage
				return annotationView
			}()
			
			annotationView.annotation = annotation
			
			return annotationView
		} else if let clusterAnnotation = annotation as? MKClusterAnnotation {
			let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "MKClusterAnnotation") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MKClusterAnnotation")
			
			annotationView.annotation = annotation
			
			// Reseach of the more critical level in the clustered annotations
			let clusteredAlertAnnotations: [AlertAnnotation] = clusterAnnotation.memberAnnotations.compactMap { $0 as? AlertAnnotation }
			var clusteredLevels = Set<String>()
			for annotation in clusteredAlertAnnotations {
				clusteredLevels.insert(annotation.alert.level)
			}
			let orderedLevels = ["CRITICAL", "WARNING", "INFO", "OK"]
			let maxLevel = orderedLevels.first { clusteredLevels.contains($0) }
			
			annotationView.markerTintColor = Alert.color(forLevel: maxLevel) ?? .systemBlue
			
			return annotationView
		} else if let alertAnnotation = annotation as? AlertAnnotation {
			let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AlertAnnotation") as? MKMarkerAnnotationView ?? {
				let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "AlertAnnotation")
				annotationView.clusteringIdentifier = "Alerts"
				return annotationView
			}()
			
			annotationView.annotation 		= annotation
			annotationView.markerTintColor 	= alertAnnotation.alert.levelColor
			annotationView.glyphImage 		= alertAnnotation.alert.levelIcon
			
			return annotationView
		}
		
		let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "MKPointAnnotation") as? MKMarkerAnnotationView ?? {
			let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MKPointAnnotation")
			annotationView.clusteringIdentifier = "Places"
			return annotationView
		}()
		return annotationView
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		if overlay is MKPolyline {
			let renderer = MKPolylineRenderer(overlay: overlay)
			renderer.strokeColor = .systemBlue
			renderer.lineWidth = 2
			return renderer
		}
		return MKOverlayRenderer()
	}
	
}
