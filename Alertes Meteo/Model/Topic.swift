//
//  Topic.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 08/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import Combine

class Topic {
	
	let name: String
	var alerts = [Alert]()
	
	init(name: String) {
		self.name = name
	}
	
}
