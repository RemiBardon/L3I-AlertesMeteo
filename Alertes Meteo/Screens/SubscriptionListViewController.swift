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
	
	private let dataSource = SubscriptionsDataSource()
	private var subscriptionCanceller: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Liste des abonnements"
		
		view.backgroundColor = .systemBackground
		
		configureNavigationBar()
		configureTableView()
		configureDataSource()
    }
	
	deinit {
		dataSource.stopListening()
		subscriptionCanceller?.cancel()
	}
	
	private func configureNavigationBar() {
		let leftItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(save))
		let rightItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
		
		navigationItem.setLeftBarButton(leftItem, animated: false)
		navigationItem.setRightBarButton(rightItem, animated: false)
	}
	
	private func configureTableView() {
		tableView.allowsSelection = false
	}
	
	private func configureDataSource() {
		dataSource.listen()
		subscriptionCanceller = dataSource.$subscriptions
			.receive(on: RunLoop.main)
			.sink { [weak self] (topics: [String]) in
				guard let self = self else { return }

				self.tableView.reloadData()
				
				// Dismiss the refresh control.
				DispatchQueue.main.async { [weak self] in
					guard let self = self else { return }
					self.tableView.refreshControl?.endRefreshing()
				}
			}
	}
	
	@objc private func save() {
		#if DEBUG
		print("\(type(of: self)).\(#function): Dismiss")
		#endif
		dismiss(animated: true)
	}
	
	@objc private func add() {
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
					guard let self = self else { return }
					
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
			guard let self = self else { return }
			
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
	
	override func numberOfSections(in tableView: UITableView) -> Int { 1 }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { dataSource.subscriptions.count }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
		
		if indexPath.row < dataSource.subscriptions.count {
			let topic = dataSource.subscriptions[indexPath.row]
			cell.textLabel?.text = topic
		} else {
			#if DEBUG
			print("\(type(of: self)).\(#function): Warning: indexPath.row >= dataSource.subscriptions.count")
			#endif
			cell.textLabel?.text = "Topic"
		}
		
		return cell
	}
	
	// MARK: - UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			unsubscribe(from: dataSource.subscriptions[indexPath.row])
			dataSource.subscriptions.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		} else if editingStyle == .insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}

}
