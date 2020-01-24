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
	
	@Published var subscriptions = [String]()
	
	private var subscriptionsObserver: NSKeyValueObservation?
	
	func listen() {
		subscriptionsObserver = UserDefaults.standard.observe(\.topicSubscriptions, options: [.initial, .new]) { [weak self] (defaults, changes) in
			guard let self = self else { return }
			guard let newValue = changes.newValue else { return }

			self.subscriptions = newValue
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
	
}
