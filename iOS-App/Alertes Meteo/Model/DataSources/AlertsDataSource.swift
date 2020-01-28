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
	
	var alerts = [Alert]()
	
	let alertsSubject = PassthroughSubject<[Alert], Never>()
	let newAlertSubject = PassthroughSubject<Alert, Never>()
	
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
					#if DEBUG
					print("Error retreiving collection: \(error)")
					#endif
					return
				}
				guard let querySnapshot = querySnapshot else {
					#if DEBUG
					print("Error fetching documents: querySnapshot=nil")
					#endif
					return
				}
				
				for diff in querySnapshot.documentChanges {
//					#if DEBUG
//					switch diff.type {
//					case .added:
//						print("New alert: ", terminator: "")
//					case .modified:
//						print("Modified alert: ", terminator: "")
//					case .removed:
//						print("Removed alert: ", terminator: "")
//					}
//					print(String(describing: diff.document.data()))
//					#endif
					
					let data = diff.document.prepareForDecoding()
					guard let newAlert = try? JSONDecoder().decode(Alert.self, fromJSONObject: data) else {
						#if DEBUG
						print("\(type(of: self)).\(#function): Could not decode spot \(data.debugDescription)")
						#endif
						continue
					}
					
					let existingIndex = self.alerts.firstIndex(of: newAlert)
					switch diff.type {
					case .added, .modified:
						if let index = existingIndex {
							self.alerts[index] = newAlert
						} else {
							let index = self.alerts.firstIndex(where: { newAlert.timestamp > $0.timestamp }) ?? self.alerts.count
							self.alerts.insert(newAlert, at: index)
						}
						if diff.type == .added { self.newAlertSubject.send(newAlert) }
					case .removed:
						if let index = existingIndex {
							self.alerts.remove(at: index)
						}
					}
				}
				
				self.alertsSubject.send(self.alerts)
			}
	}
	
	func stopListening() {
		alertsListener?.remove()
		alertsListener = nil
	}
	
}
