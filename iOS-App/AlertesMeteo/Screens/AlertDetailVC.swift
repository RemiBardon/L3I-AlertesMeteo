//
//  AlertDetailVC.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class AlertDetailVC: UITableViewController {
	
	// MARK: Model
	
	typealias MessageCell 	= AlertMessageTableViewCell
	typealias ValuesCell 	= AlertValuesTableViewCell
	
	// MARK: Properties
	
	var alert: Alert?
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.largeTitleDisplayMode = .never
		
		view.backgroundColor = .systemBackground
		
		guard let alert = alert else {
			#if DEBUG
			print("\(type(of: self)).\(#function): Error: alert=nil")
			#endif
			
			// On n'a pas l'alerte, du coup on ne peut rien afficher
			// On affiche donc à l'utilisateur un avertissement et on retourne à la liste après qu'il l'ait lu
			UIAlertController.showMessage(title: "Une erreur est survenue", message: "L'alerte n'a pas pu être récupérée.") { [weak self] _ in
				self?.dismiss(animated: true)
			}
			return
		}
		
		title = alert.levelDescription
		
		configureTableView()
	}
	
	// MARK: Configuration
	
	private func configureTableView() {
		tableView.allowsSelection = false
		tableView.separatorStyle = .none
	}
	
	// MARK: UITableViewDataSource
	
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
			let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier) as? MessageCell ?? MessageCell()
			
			cell.message = alert?.message
			
			return cell
		case 1:
			let cell = tableView.dequeueReusableCell(withIdentifier: ValuesCell.reuseIdentifier) as? ValuesCell ?? ValuesCell()
			
			cell.alert = alert
			
			return cell
		default:
			return tableView.dequeueReusableCell(withIdentifier: "default") ?? UITableViewCell(style: .default, reuseIdentifier: "default")
		}
	}
	
	// MARK: UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { UITableView.automaticDimension }
	
	override func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool { false }
	
}
