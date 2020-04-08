//
//  TopicsDataSource.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 08/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import Combine
import Firebase

class TopicsDataSource {
	
	// MARK: Singleton Pattern
	
	static let shared = TopicsDataSource()
	
	private init() {
		configureSubscriptionsDataSource()
	}
	
	// MARK: Properties
	
	var subscriptions = UserDefaults.standard.topicSubscriptions
	
	var topics = [Topic]()
	
	let topicsSubject = PassthroughSubject<[Topic], Never>()
	
	private let subscriptionsDataSource = SubscriptionsDataSource()
	private var subscriptionCanceller: AnyCancellable?
	
	// MARK: Lifecycle
	
	deinit {
		subscriptionsDataSource.stopListening()
		subscriptionCanceller?.cancel()
	}
	
	// MARK: Methods
	
	func fetch(completion: (() -> Void)? = nil) {
		// Delete unused types
		self.topics.removeAll { !subscriptions.contains($0.name) }
		
		// Reorder topics
		var unorderedTopics = self.topics // We have to store all the topics before we override them in self.topics
		for (offset, topicName) in subscriptions.enumerated() {
			if let index = unorderedTopics.firstIndex(where: { $0.name == topicName }) {
				self.topics[offset] = unorderedTopics[index]
				unorderedTopics.remove(at: index)
			} else {
				self.topics.insert(Topic(name: topicName), at: offset)
			}
		}
		
		// Send changes before fetching new data
		self.topicsSubject.send(self.topics)
		
		for topicName in subscriptions {
			let db = Firestore.firestore()
			db.collection("alerts")
				.whereField("topics", arrayContains: topicName)
				.order(by: "timestamp", descending: false)
				.limit(to: 10)
				.getDocuments { [weak self] (querySnapshot, error) in
					completion?()
					guard let self = self else { return }

					if let error = error {
						#if DEBUG
						print("\(type(of: self)).\(#function): [ERROR] Error retreiving documents: \(error)")
						#endif
						return
					}
					guard let querySnapshot = querySnapshot else {
						#if DEBUG
						print("\(type(of: self)).\(#function): [ERROR] Error fetching documents: querySnapshot=nil")
						#endif
						return
					}

					let topic = self.topics.first(where: { $0.name == topicName }) ?? {
						// Just in case,
						let newTopic = Topic(name: topicName)
						self.topics.append(newTopic)
						return newTopic
					}()
					
					let decoder 					= JSONDecoder()
					decoder.keyDecodingStrategy 	= .convertFromSnakeCase
					decoder.dateDecodingStrategy 	= .iso8601withFractionalSeconds

					for diff in querySnapshot.documentChanges {
//						#if DEBUG
//						switch diff.type {
//						case .added:
//							print("\(type(of: self)).\(#function): [INFO] New alert: ", terminator: "")
//						case .modified:
//							print("\(type(of: self)).\(#function): [INFO] Modified alert: ", terminator: "")
//						case .removed:
//							print("\(type(of: self)).\(#function): [INFO] Removed alert: ", terminator: "")
//						}
//						print(String(describing: diff.document.data()))
//						#endif

						let data = diff.document.prepareForDecoding()
						
						guard let newAlert: Alert = {
							do {
								return try decoder.decode(Alert.self, fromJSONObject: data)
							} catch {
								#if DEBUG
								print("\(type(of: self)).\(#function): [ERROR] Could not decode alert \(data.debugDescription): \(error.localizedDescription)")
								#endif
								return nil
							}
						}() else { continue }

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
								#warning("'Fatal error: Index out of range' when deleting the 'alerts' collection in Firestore -> Fixed?")
								topic.alerts.remove(at: index)
							}
						}
					}
					
					self.topicsSubject.send(self.topics)
				}
		}
	}
	
	private func configureSubscriptionsDataSource() {
		subscriptionsDataSource.listen()
		subscriptionCanceller = subscriptionsDataSource.$subscriptions
			.receive(on: RunLoop.main)
			.sink { [weak self] (subscriptions: [String]) in
				guard let self = self else { return }

				if self.subscriptions != subscriptions {
					self.subscriptions = subscriptions
					self.fetch()
				}
			}
	}
	
}
