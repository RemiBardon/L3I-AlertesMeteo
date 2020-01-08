//
//  AlertListViewController.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit
import Combine

class AlertListViewController: UITableViewController {
	
	private let reuseIdentifier = "alertCell"
	
	private let dataSource = TopicsDataSource()
	private var subscriptionCanceller: AnyCancellable?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Alertes météo"
		
		view.backgroundColor = .systemGroupedBackground
		
		configureNavigationBar()
		configureDataSource()
		configureNotificationCenter()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.navigationBar.prefersLargeTitles = true
	}
	
	deinit {
		dataSource.stopListening()
		subscriptionCanceller?.cancel()
	}
	
	private func configureNavigationBar() {
		let item = UIBarButtonItem(title: "Abonnenments", style: .plain, target: self, action: #selector(showSubscriptionList))
		navigationItem.setRightBarButton(item, animated: false)
	}
	
	private func configureNotificationCenter() {
		// Asking Permission to Use Notifications:
		// https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications
		
		let center = UNUserNotificationCenter.current()
		center.getNotificationSettings { settings in
			#if DEBUG
			print("\(type(of: self)).\(#function): notificationSettings.authorizationStatus=", terminator: "")
			switch settings.authorizationStatus {
			case .authorized: 		print(".authorized")
			case .denied: 			print(".denied")
			case .notDetermined: 	print(".notDetermined")
			case .provisional: 		print(".provisional")
			@unknown default: 		print("@unknown")
			}
			#endif
			
			guard settings.authorizationStatus == .authorized else {
				center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
					// Enable or disable features based on authorization.
				}
				return
			}
			
			#if DEBUG
			print("\(type(of: self)).\(#function): notificationSettings.alertSetting=", terminator: "")
			switch settings.alertSetting {
			case .enabled: 			print(".enabled")
			case .disabled: 		print(".disabled")
			case .notSupported: 	print(".notSupported")
			@unknown default: 		print("@unknown")
			}
			#endif
			
			if settings.alertSetting == .enabled {
				// Schedule an alert-only notification.
			} else {
				// Schedule a notification with a badge and sound.
			}
		}
	}
	
	private func configureDataSource() {
		dataSource.listen()
		subscriptionCanceller = dataSource.topicsSubject
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
	
	@objc private func showSubscriptionList() {
		#if DEBUG
		print("\(type(of: self)).\(#function): Show subscription list")
		#endif
		let vc = SubscriptionListViewController(style: .plain)
		let nc = UINavigationController(rootViewController: vc)
		nc.modalPresentationStyle = .pageSheet
		present(nc, animated: true)
	}
	
	// MARK: - UITableViewDelegate
	
	override func numberOfSections(in tableView: UITableView) -> Int { dataSource.topics.count }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { dataSource.topics[section].name }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { dataSource.topics[section].alerts.count }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
		
		#warning("Show default message if no alert in topic")
		
		let alert = dataSource.topics[indexPath.section].alerts[indexPath.row]
		cell.textLabel?.text = alert.levelDescription
		cell.detailTextLabel?.text = alert.message
		cell.accessoryType = .disclosureIndicator
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let navigationController = navigationController else { return }
		
		let vc = AlertDetailViewController()
		vc.alert = dataSource.topics[indexPath.section].alerts[indexPath.row]
		
		navigationController.pushViewController(vc, animated: true)
	}
	
}
