//
//  Topic.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 08/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import Foundation

class Topic: Hashable {
	
	// MARK: Properties
	
	let name: String
	var alerts = [Alert]()
	
	// MARK: Lifecycle
	
	init(name: String) {
		self.name = name
	}
	
	// MARK: Equatable Requirements
	
	static func == (lhs: Topic, rhs: Topic) -> Bool { lhs.name == rhs.name }
	
	// MARK: Hashable Requirements
	
	func hash(into hasher: inout Hasher) { hasher.combine(name) }
	
}
