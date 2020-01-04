//
//  AlertsDataSource.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import Foundation
import Combine

class AlertsDataSource: ObservableObject {
	
	@Published var alerts = [Alert]()
	
	func refreshAlerts() {
		// Pour l'instant, on fait semblant d'envoyer une requête aux serveurs
		// en attendant un peu puis en ajoutant de nouvelles alertes
		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
			guard let self = self else { return }
			
			let newAlerts: [Alert] = (self.alerts.count..<self.alerts.count+2).map { (n: Int) -> Alert in
				Alert(id: String(describing: n))
			}
			self.alerts.append(contentsOf: newAlerts)
		}
	}
	
}
