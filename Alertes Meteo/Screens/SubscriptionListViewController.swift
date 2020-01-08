//
//  SubscriptionListViewController.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 08/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit
import Combine

class SubscriptionListViewController: UITableViewController {
	
	private let reuseIdentifier = "subscriptionCell"
	
	private let dataSource = SubscriptionsDataSource()
	private var subscriptionCanceller: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Liste des abonnements"
		
		view.backgroundColor = .systemBackground
		
		configureNavigationBar()
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
		#warning("Add topic")
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

}
