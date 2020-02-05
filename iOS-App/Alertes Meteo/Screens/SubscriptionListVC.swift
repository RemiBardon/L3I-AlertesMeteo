//
//  SubscriptionListVC.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 08/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit
import Combine
import FirebaseMessaging

class SubscriptionListVC: UITableViewController {
	
	private let reuseIdentifier = "subscriptionCell"
	private let insertionCellReuseIdentifier = "insertionCell"
	
	private let dataSource = SubscriptionsDataSource()
	private var subscriptionCanceller: AnyCancellable?
	
	private weak var subscribeAction: UIAlertAction?
	private weak var topicNameTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Abonnements"
		
		view.backgroundColor = .systemGroupedBackground
		
		configureDataSource()
		configureTableView()
    }
	
	deinit {
		dataSource.stopListening()
		subscriptionCanceller?.cancel()
	}
	
	private func configureDataSource() {
		dataSource.listen()
		subscriptionCanceller = dataSource.$subscriptions
			.receive(on: RunLoop.main)
			.sink { [weak self] (subscriptions: [String]) in
				guard let self = self else { return }

				self.tableView.reloadData()
				
				// Dismiss the refresh control.
				DispatchQueue.main.async { [weak self] in
					guard let self = self else { return }
					self.tableView.refreshControl?.endRefreshing()
				}
			}
	}
	
	private func configureTableView() {
		tableView.setEditing(true, animated: false)
	}
	
	// MARK: - Events
	
	@objc private func save() {
		#if DEBUG
		print("\(type(of: self)).\(#function): Dismiss")
		#endif
		dismiss(animated: true)
	}
	
	@objc private func addTopic() {
		#if DEBUG
		print("\(type(of: self)).\(#function): Add topic")
		#endif
		
		let alert = UIAlertController(title: "Abonnez-vous à un groupe d'alertes", message: nil, preferredStyle: .alert)
		
		alert.addTextField { (textField: UITextField) in
			self.topicNameTextField = textField
			textField.placeholder = "Nom de l'alerte"
			textField.addTarget(self, action: #selector(self.nameTextFieldChanged), for: .editingChanged)
		}
		alert.addTextField { (textField: UITextField) in
			textField.placeholder = "Groupe de capteurs"
		}
		alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
		let subscribeAction = UIAlertAction(title: "S'abonner", style: .default, handler: { [weak self] (action: UIAlertAction) in
			guard let self = self else { return }
			
			guard let textFields = alert.textFields, textFields.count >= 2 else { return }
			
			guard let topicName = textFields[0].text else {
				#warning("Show alert if unable to subscribe")
				return
			}
			let group = textFields[1].text ?? ""
			
			let topic = self.getTopic(fromTopicName: topicName, andGroup: group)
			
			var actualTopics = UserDefaults.standard.stringArray(forKey: "topicSubscriptions")
			if actualTopics?.contains(topic) != true {
				Messaging.messaging().subscribe(toTopic: topic) { [weak self] error in
					if let error = error {
						#if DEBUG
						print("\(type(of: self)).\(#function): Error subscribing to topic '\(topic)': \(error.localizedDescription)")
						#endif
					} else {
						#if DEBUG
						print("Successfully subscribed to topic '\(topic)'.")
						#endif
						actualTopics?.append(topic)
						UserDefaults.standard.set(actualTopics, forKey: "topicSubscriptions")
					}
				}
			}
		})
		subscribeAction.isEnabled = false
		self.subscribeAction = subscribeAction
		alert.addAction(subscribeAction)
		
		present(alert, animated: true)
	}
	
	@objc private func nameTextFieldChanged() {
		subscribeAction?.isEnabled = topicNameTextField?.text?.isEmpty == false
	}
	
	private func unsubscribe(from topic: String) {
		Messaging.messaging().unsubscribe(fromTopic: topic) { [weak self] error in
			if let error = error {
				#if DEBUG
				print("\(type(of: self)).\(#function): Error unsubscribing from topic '\(topic)': \(error.localizedDescription)")
				#endif
			} else {
				#if DEBUG
				print("Successfully unsubscribed from topic '\(topic)'.")
				#endif
				if var actualTopics = UserDefaults.standard.stringArray(forKey: "topicSubscriptions") {
					actualTopics.removeAll(where: { $0 == topic })
					UserDefaults.standard.set(actualTopics, forKey: "topicSubscriptions")
				}
			}
		}
	}
	
	private func getTopic(fromTopicName topicName: String, andGroup group: String) -> String {
		if group.isEmpty {
			return "\(normalize(topicName))"
		} else {
			return "\(normalize(topicName))-\(normalize(group))"
		}
	}
	
	private func normalize(_ string: String) -> String {
		let foldingOptions: String.CompareOptions = [.diacriticInsensitive, .widthInsensitive, .caseInsensitive]
		let whitespaces = CharacterSet.whitespacesAndNewlines
		
		let string = string
			.folding(options: foldingOptions, locale: nil) 						// Remove accents (https://stackoverflow.com/a/40282304/10967642)
			.components(separatedBy: whitespaces).joined(separator: "_") 		// Replace whitespaces by undescrores
			.components(separatedBy: "-").joined(separator: "_") 				// Replace dashes by underscores to keep undescores as separators
		
		let regex = NSRegularExpression("[^a-zA-Z0-9_.~%-]")
		let range = NSRange(location: 0, length: string.count)
		return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "") // Remove remaining prohibited characters
	}
	
	// MARK: - UITableViewDelegate
	
	override func numberOfSections(in tableView: UITableView) -> Int { 2 }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return dataSource.subscriptions.count
		case 1:
			return 1
		default:
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch indexPath.section {
		case 0:
			let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? {
				let cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
				cell.selectionStyle = .none
				return cell
			}()
			
			if indexPath.row < dataSource.subscriptions.count {
				cell.textLabel?.text = dataSource.subscriptions[indexPath.row]
			}
			
			return cell
		case 1:
			let cell = tableView.dequeueReusableCell(withIdentifier: insertionCellReuseIdentifier) ?? {
				let cell = UITableViewCell(style: .default, reuseIdentifier: insertionCellReuseIdentifier)
				
				let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addTopic))
				cell.addGestureRecognizer(tapGestureRecognizer)
				
				return cell
			}()
			
			cell.textLabel?.text = "Ajouter un groupe d'alertes"
			
			return cell
		default:
			return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
		}
	}
	
	override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool { indexPath.section == 0 }
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		switch indexPath.section {
		case 0:
			return .delete
		case 1:
			return .insert
		default:
			return .none
		}
	}
	
	// MARK: - UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			unsubscribe(from: dataSource.subscriptions[indexPath.row])
			dataSource.subscriptions.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		} else if editingStyle == .insert {
			addTopic()
		}
	}
	
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { indexPath.section == 0 && dataSource.subscriptions.count > 1 }
	
	override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
		if proposedDestinationIndexPath.section > 0 {
			return IndexPath(row: dataSource.subscriptions.count - 1, section: 0)
		} else {
			return proposedDestinationIndexPath
		}
	}
	
	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let topicName = dataSource.subscriptions[sourceIndexPath.row]
		dataSource.move(topic: topicName, from: sourceIndexPath.row, to: destinationIndexPath.row)
	}

}
