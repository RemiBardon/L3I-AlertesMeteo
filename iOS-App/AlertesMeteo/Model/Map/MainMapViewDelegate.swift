//
//  MainMapViewDelegate.swift
//  AlertesMeteo
//
//  Created by BARDON Rémi on 07/04/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import MapKit

class MainMapViewDelegate: NSObject, MKMapViewDelegate {
	
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
			
			// Reseach of the highest alert level in the clustered annotations
			let clusteredAlertAnnotations: [AlertAnnotation] = clusterAnnotation.memberAnnotations.compactMap { $0 as? AlertAnnotation }
			var clusteredLevels = Set<String>()
			for annotation in clusteredAlertAnnotations {
				clusteredLevels.insert(annotation.alert.level)
			}
			let orderedLevels = ["CRITICAL", "WARNING", "INFO", "OK"]
			let maxLevel = orderedLevels.first { clusteredLevels.contains($0) }
			
			// Change annotation color to highest level color
			annotationView.markerTintColor = AlertsHelper.color(forLevel: maxLevel) ?? .systemBlue
			
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
		
		let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "PlaceAnnotation") as? MKMarkerAnnotationView ?? {
			let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "PlaceAnnotation")
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
