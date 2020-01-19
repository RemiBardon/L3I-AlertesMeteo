//
//  AlertDetailViewController.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class AlertDetailViewController: UITableViewController {
	
	var alert: Alert?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemBackground
		
		guard let alert = alert else {
			#if DEBUG
			print("\(type(of: self)).\(#function): Error: alert=nil")
			#endif
			
			// On n'a pas l'alerte, du coup on ne peut rien afficher
			// On affiche donc à l'utilisateur un avertissement et on retourne à la liste après qu'il l'ait lu
			let alert = UIAlertController(title: "Une erreur est survenue", message: "L'alerte n'a pas pu être récupérée.", preferredStyle: .alert)
			let dismissAction = UIAlertAction(title: "Retour", style: .cancel) { [weak self] _ in
				self?.dismiss(animated: true)
			}
			alert.addAction(dismissAction)
			present(alert, animated: true)
			return
		}
		
		title = alert.levelDescription
		
		configureTableView()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		navigationController?.navigationBar.prefersLargeTitles = false
	}
	
	private func configureTableView() {
		tableView.allowsSelection = false
		tableView.separatorStyle = .none
	}
	
	// MARK: - UITableViewDelegate
	
	override func numberOfSections(in tableView: UITableView) -> Int { 1 }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 2
		default:
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.row {
		case 0:
			let cell = tableView.dequeueReusableCell(withIdentifier: AlertMessageTableViewCell.reuseIdentifier) as? AlertMessageTableViewCell ?? AlertMessageTableViewCell()
			
			cell.message = alert?.message
			
			return cell
		case 1:
			let cell = tableView.dequeueReusableCell(withIdentifier: AlertValuesTableViewCell.reuseIdentifier) as? AlertValuesTableViewCell ?? AlertValuesTableViewCell()
			
			cell.alert = alert
			
			return cell
		default:
			return tableView.dequeueReusableCell(withIdentifier: "default") ?? UITableViewCell(style: .default, reuseIdentifier: "default")
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { UITableView.automaticDimension }
	
	override func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool { false }
	
}
