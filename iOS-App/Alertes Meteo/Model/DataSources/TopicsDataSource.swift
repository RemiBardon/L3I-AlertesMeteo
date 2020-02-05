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
	
	let topicsSubject = PassthroughSubject<[Topic], Never>()
	
	private let subscriptionsDataSource = SubscriptionsDataSource()
	private var subscriptionCanceller: AnyCancellable?
	
	private var topicListeners = [String:ListenerRegistration]()
	
	func listen() {
		subscriptionCanceller = subscriptionsDataSource.$subscriptions
			.sink { [weak self] (subscriptions: [String]) in
				guard let self = self else { return }
				
				// Stop listening for changes in unsubscribed topics
				for listener in self.topicListeners.filter({ !subscriptions.contains($0.key) }) {
					listener.value.remove()
					self.topicListeners.removeValue(forKey: listener.key)
				}
				#warning("Delete data related to unsubscribed topic")
				
				// Start listening for changes in subscribed topics
				for topicName in subscriptions.filter({ !self.topicListeners.keys.contains($0) }) {
					// Get realtime updates with Cloud Firestore
					// https://firebase.google.com/docs/firestore/query-data/listen

					let db = Firestore.firestore()
					self.topics.append(Topic(name: topicName))

					self.topicListeners[topicName] = db.collection("alerts")
						.whereField("topics", arrayContains: topicName)
						.order(by: "timestamp", descending: true)
						.limit(to: 20)
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

							guard let topic = self.topics.first(where: { $0.name == topicName }) else { return }

							for diff in querySnapshot.documentChanges {
//								#if DEBUG
//								switch diff.type {
//								case .added:
//									print("\(type(of: self)).\(#function): New alert: ", terminator: "")
//								case .modified:
//									print("\(type(of: self)).\(#function): Modified alert: ", terminator: "")
//								case .removed:
//									print("\(type(of: self)).\(#function): Removed alert: ", terminator: "")
//								}
//								print(String(describing: diff.document.data()))
//								#endif

								let data = diff.document.prepareForDecoding()
								guard let newAlert = try? JSONDecoder().decode(Alert.self, fromJSONObject: data) else { continue }

								let existingIndex = topic.alerts.firstIndex { $0.alertId == newAlert.alertId }
								switch diff.type {
								case .added, .modified:
									if let index = existingIndex {
										topic.alerts[index] = newAlert
									} else if let index = topic.alerts.firstIndex(where: { newAlert.timestamp > $0.timestamp }) {
										topic.alerts.insert(newAlert, at: index)
									} else {
										topic.alerts.append(newAlert)
									}
								case .removed:
									if let index = existingIndex {
										#warning("'Fatal error: Index out of range' when deleting a collection")
										topic.alerts.remove(at: index)
									}
								}
							}
							self.topicsSubject.send(self.topics)
						}
				}
				
				// Rorder topics
				var unorderedTopics = self.topics // We have to store all the topics before we override them in self.topics
				self.topics.removeSubrange(subscriptions.count..<self.topics.count)
				for subscription in subscriptions.enumerated() {
					if let index = unorderedTopics.firstIndex(where: { $0.name == subscription.element }) {
						self.topics[subscription.offset] = unorderedTopics[index]
						unorderedTopics.remove(at: index)
					}
				}
				
				self.topicsSubject.send(self.topics)
			}
		subscriptionsDataSource.listen()
	}
	
	func stopListening() {
		subscriptionsDataSource.stopListening()
		subscriptionCanceller?.cancel()
		for listener in topicListeners {
			listener.value.remove()
		}
		topicListeners.removeAll()
	}
	
	deinit {
		stopListening()
	}
	
}
