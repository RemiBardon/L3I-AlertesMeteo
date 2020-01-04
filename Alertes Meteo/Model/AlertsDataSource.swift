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
	
	func refreshAlerts() {
		// Pour l'instant, on fait semblant d'envoyer une requête aux serveurs
		// en attendant un peu puis en ajoutant de nouvelles alertes
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
			guard let self = self else { return }
			
			for n in (self.alerts.count..<self.alerts.count+2) {
				let id = String(describing: n)
				self.alerts.append(Alert(id: id))
			}
		}
	}
	
	func listenForNewAlerts() {
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
				
				querySnapshot.documentChanges.forEach { diff in
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
					
					let newAlert = Alert(id: diff.document.documentID)
					let existingIndex = self.alerts.firstIndex(where: { $0.id == newAlert.id })
					switch diff.type {
					case .added, .modified:
						if let index = existingIndex {
							self.alerts[index] = newAlert
						} else if let index = self.alerts.firstIndex(where: { $0.id > newAlert.id }) {
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
	
	func stopListeningForNewAlerts() {
		alertsListener?.remove()
		alertsListener = nil
	}
	
}
