//
//  SubscriptionsDataSource.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 08/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import Foundation
import Combine

class SubscriptionsDataSource: ObservableObject {
	
	var subscriptions = [String]()
	
	let subscriptionsSubject = PassthroughSubject<[String], Never>()
	let subscriptionsDidChangeSubject = PassthroughSubject<Void, Never>()
	let subscriptionsDidChangeOrderSubject = PassthroughSubject<(topicName: String, indexBefore: Int?, indexAfter: Int?, type: ChangeType), Never>()
	
	private var subscriptionsObserver: NSKeyValueObservation?
	
	func listen() {
		subscriptionsObserver = UserDefaults.standard.observe(\.topicSubscriptions, options: [.initial, .new]) { [weak self] (defaults, changes) in
			guard let self = self else { return }
			guard let newValue = changes.newValue else { return }

			// Store the current value and change it before any Subject brodcasts a message
			let storedValue = self.subscriptions
			self.subscriptions = newValue
			
			// Send new value
			self.subscriptionsSubject.send(newValue)
			self.subscriptionsDidChangeSubject.send()
			
			// Send deletions
			for i in 0..<storedValue.count {
				if !newValue.contains(storedValue[i]) {
					self.subscriptionsDidChangeOrderSubject.send((topicName: storedValue[i], indexBefore: i, indexAfter: nil, type: .removal))
				}
			}
			
			// Send insertions
			for i in 0..<newValue.count {
				if !storedValue.contains(newValue[i]) {
					self.subscriptionsDidChangeOrderSubject.send((topicName: newValue[i], indexBefore: nil, indexAfter: i, type: .insertion))
				}
			}
			
			// Send moves
			var commonValues = storedValue.filter { newValue.contains($0) }
			for i in 0..<newValue.count {
				let topicName = newValue[i]
				if let storedIndex = commonValues.firstIndex(of: topicName), storedIndex != i {
					commonValues.remove(at: storedIndex)
					commonValues.insert(topicName, at: i)
					self.subscriptionsDidChangeOrderSubject.send((topicName: topicName, indexBefore: storedIndex, indexAfter: i, type: .move))
				}
			}
		}
	}
	
	func stopListening() {
		subscriptionsObserver?.invalidate()
	}
	
	func move(topic topicName: String, from indexBefore: Int, to indexAfter: Int) {
		guard let topicIndex = subscriptions.firstIndex(of: topicName) else { return }

		// Note: This makes local changes, some other instances may have other versions of the array.
		//       Thet get notified to change thanks to their subscription to UserDefaults.
		subscriptions.remove(at: topicIndex)
		subscriptions.insert(topicName, at: indexAfter)
		
		UserDefaults.standard.set(subscriptions, forKey: "topicSubscriptions")
	}
	
	deinit {
		stopListening()
	}
	
	enum ChangeType {
		case insertion, removal, move
	}
	
}
