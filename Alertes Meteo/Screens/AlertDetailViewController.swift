//
//  AlertDetailViewController.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class AlertDetailViewController: UIViewController {
	
	var alertId: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemBackground
		
		guard let alertId = alertId else {
			#if DEBUG
			print("\(type(of: self)).\(#function): Error: alertId=nil")
			#endif
			
			// On n'a pas l'id de l'alerte, du coup on ne peut rien afficher
			// On affiche donc à l'utilisateur un avertissement et on retourne à la liste après qu'il l'ait lu
			let alert = UIAlertController(title: "Une erreur est survenue", message: "L'alerte n'a pas pu être identifiée.", preferredStyle: .alert)
			let dismissAction = UIAlertAction(title: "Retour", style: .cancel) { [weak self] _ in
				self?.dismiss(animated: true)
			}
			alert.addAction(dismissAction)
			present(alert, animated: true)
			return
		}
		
		title = "Alerte \(alertId)"
	}
	
}
