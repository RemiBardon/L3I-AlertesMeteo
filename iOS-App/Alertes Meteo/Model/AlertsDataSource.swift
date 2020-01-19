//
//  AlertsDataSource.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestore

class AlertsDataSource: ObservableObject {
	
	@Published var alerts = [Alert]()
	
	private var alertsListener: ListenerRegistration?
	
	func listen() {
		// Get realtime updates with Cloud Firestore
		// https://firebase.google.com/docs/firestore/query-data/listen
		
		let db = Firestore.firestore()
		alertsListener = db.collection("alerts")
			.order(by: "timestamp", descending: true)
			.limit(to: 20)
			.addSnapshotListener { (querySnapshot, error) in
				if let error = error {
					print("Error retreiving collection: \(error)")
					return
				}
				guard let querySnapshot = querySnapshot else {
					print("Error fetching documents: querySnapshot=nil")
					return
				}
				
				for diff in querySnapshot.documentChanges {
					#if DEBUG
					switch diff.type {
					case .added:
						print("New alert: ", terminator: "")
					case .modified:
						print("Modified alert: ", terminator: "")
					case .removed:
						print("Removed alert: ", terminator: "")
					}
					print(String(describing: diff.document.data()))
					#endif
					
					let data = diff.document.prepareForDecoding()
					guard let newAlert = try? JSONDecoder().decode(Alert.self, fromJSONObject: data) else { continue }
					
					let existingIndex = self.alerts.firstIndex(where: { $0.id == newAlert.id })
					switch diff.type {
					case .added, .modified:
						if let index = existingIndex {
							self.alerts[index] = newAlert
						} else if let index = self.alerts.firstIndex(where: { newAlert.timestamp > $0.timestamp }) {
							self.alerts.insert(newAlert, at: index)
						} else {
							self.alerts.append(newAlert)
						}
					case .removed:
						if let index = existingIndex {
							self.alerts.remove(at: index)
						}
					}
				}
			}
	}
	
	func stopListening() {
		alertsListener?.remove()
		alertsListener = nil
	}
	
}
