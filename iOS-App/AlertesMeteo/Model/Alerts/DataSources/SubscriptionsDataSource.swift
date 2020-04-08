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
	
	// MARK: Properties
	
	@Published var subscriptions = [String]()
	
	private var subscriptionsObserver: NSKeyValueObservation?
	
	// MARK: Lifecycle
	
	deinit {
		stopListening()
	}
	
	// MARK: Methods
	
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
	
}
