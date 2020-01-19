//
//  SubscriptionListViewController.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 08/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit
import Combine
import FirebaseMessaging

class SubscriptionListViewController: UITableViewController {
	
	private let reuseIdentifier = "subscriptionCell"
	private let insertionCellReuseIdentifier = "insertionCell"
	
	private let dataSource = SubscriptionsDataSource()
	private var subscriptionCanceller: AnyCancellable?

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
		subscriptionCanceller = dataSource.subscriptionsDidChangeSubject
			.receive(on: RunLoop.main)
			.sink { [weak self] in
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
			textField.placeholder = "Nom du groupe d'alertes"
		}
		alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
		alert.addAction(UIAlertAction(title: "S'abonner", style: .default, handler: { [weak self] (action: UIAlertAction) in
			guard let self = self else { return }
			guard let topic = alert.textFields?.first?.text else {
				#warning("Show alert if unable to subscribe")
				return
			}

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
		}))
		present(alert, animated: true)
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
