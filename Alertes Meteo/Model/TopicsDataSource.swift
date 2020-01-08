//
//  TopicsDataSource.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 08/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import Foundation
import Combine
import FirebaseFirestore

class TopicsDataSource: ObservableObject {
	
	@Published var topics = [(name: String, alerts: [Alert])]()
	
	private var topicListeners = [ListenerRegistration]()
	
	func listen() {
		#warning("Call listen again when topicSubscriptions change")
		
		// Get realtime updates with Cloud Firestore
		// https://firebase.google.com/docs/firestore/query-data/listen
		
		let db = Firestore.firestore()
		
		guard let topicSubscriptions = UserDefaults.standard.stringArray(forKey: "topicSubscriptions") else { return }
		
		for topic in topicSubscriptions {
			topics.append((name: topic, alerts: [Alert]()))
			topicListeners.append(
				db.collection("alerts")
					.whereField("topic", isEqualTo: topic)
					.order(by: "timestamp", descending: true)
					.limit(to: 5)
					.addSnapshotListener { (querySnapshot, error) in
						if let error = error {
							print("\(type(of: self)).\(#function): Error retreiving collection: \(error)")
							return
						}
						guard let querySnapshot = querySnapshot else {
							print("\(type(of: self)).\(#function): Error fetching documents: querySnapshot=nil")
							return
						}
						
						for diff in querySnapshot.documentChanges {
							#if DEBUG
							switch diff.type {
							case .added:
								print("\(type(of: self)).\(#function): New alert: ", terminator: "")
							case .modified:
								print("\(type(of: self)).\(#function): Modified alert: ", terminator: "")
							case .removed:
								print("\(type(of: self)).\(#function): Removed alert: ", terminator: "")
							}
							print(String(describing: diff.document.data()))
							#endif
							
							let data = diff.document.prepareForDecoding()
							guard let newAlert = try? JSONDecoder().decode(Alert.self, fromJSONObject: data) else { continue }
							
							guard var alerts = self.topics.first(where: { (name: String, alerts: [Alert]) -> Bool in
								name == topic
							})?.alerts else { continue }
							
							let existingIndex = alerts.firstIndex(where: { $0.id == newAlert.id })
							switch diff.type {
							case .added, .modified:
								if let index = existingIndex {
									alerts[index] = newAlert
								} else if let index = alerts.firstIndex(where: { newAlert.timestamp > $0.timestamp }) {
									alerts.insert(newAlert, at: index)
								} else {
									alerts.append(newAlert)
								}
							case .removed:
								if let index = existingIndex {
									alerts.remove(at: index)
								}
							}
						}
					}
			)
		}
	}
	
	func stopListening() {
		for listener in topicListeners {
			listener.remove()
		}
		topicListeners.removeAll()
	}
	
}
