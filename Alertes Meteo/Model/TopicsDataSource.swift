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
	
	var topics = [Topic]()
	
	let topicsSubject = PassthroughSubject<Void, Never>()
	
	private let subscriptionsDataSource = SubscriptionsDataSource()
	private var subscriptionCanceller: AnyCancellable?
	
	private var topicListeners = [ListenerRegistration]()
	
	func listen() {
		subscriptionCanceller = subscriptionsDataSource.subscriptionsDidChangeOrderSubject
			.sink { [weak self] (change: (topicName: String, indexBefore: Int?, indexAfter: Int?, type: SubscriptionsDataSource.ChangeType)) in
				guard let self = self else { return }
				
				switch change.type {
				case .insertion:
					// Get realtime updates with Cloud Firestore
					// https://firebase.google.com/docs/firestore/query-data/listen
					
					let db = Firestore.firestore()
					self.topics.append(Topic(name: change.topicName))
					
					self.topicListeners.append(
						db.collection("alerts")
							.whereField("topic", isEqualTo: change.topicName)
							.order(by: "timestamp", descending: true)
							.limit(to: 5)
							.addSnapshotListener { [weak self] (querySnapshot, error) in
								guard let self = self else { return }
								
								if let error = error {
									print("\(type(of: self)).\(#function): Error retreiving collection: \(error)")
									return
								}
								guard let querySnapshot = querySnapshot else {
									print("\(type(of: self)).\(#function): Error fetching documents: querySnapshot=nil")
									return
								}
								
								// We cannot use change.indexAfter here because of other changes in the order that could have appened
								guard let topic = self.topics.first(where: { $0.name == change.topicName }) else { return }
								var alertIndexes = [String: Int]()
								for i in 0..<topic.alerts.count {
									alertIndexes[topic.alerts[i].id] = i
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
									
									switch diff.type {
									case .added, .modified:
										if let index = alertIndexes[newAlert.id] {
											topic.alerts[index] = newAlert
										} else if let index = topic.alerts.firstIndex(where: { newAlert.timestamp > $0.timestamp }) {
											topic.alerts.insert(newAlert, at: index)
										} else {
											topic.alerts.append(newAlert)
										}
									case .removed:
										if let index = alertIndexes[newAlert.id] {
											topic.alerts.remove(at: index)
										}
									}
								}
								
								self.topicsSubject.send()
							}
					)
				case .removal:
					self.topics.remove(at: change.indexBefore!)
					#warning("Remove listener from topicListeners")
					self.topicsSubject.send()
				case .move:
					let topic = self.topics[change.indexBefore!]
					self.topics.remove(at: change.indexBefore!)
					#warning("Remove listener from topicListeners")
					self.topics.insert(topic, at: change.indexAfter!)
					self.topicsSubject.send()
				}
		}
		subscriptionsDataSource.listen()
	}
	
	func stopListening() {
		subscriptionsDataSource.stopListening()
		subscriptionCanceller?.cancel()
		for listener in topicListeners {
			listener.remove()
		}
		topicListeners.removeAll()
	}
	
	deinit {
		stopListening()
	}
	
}
