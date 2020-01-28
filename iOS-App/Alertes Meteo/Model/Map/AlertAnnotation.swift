//
//  AlertAnnotation.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 26/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import MapKit

class AlertAnnotation: MKPointAnnotation {
	
	var alert: Alert
	
	init(alert: Alert) {
		self.alert = alert
		
		super.init()
	}
	
}
