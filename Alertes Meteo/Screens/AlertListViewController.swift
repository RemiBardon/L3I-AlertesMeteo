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
	private let informationCellReuseIdentifier = "informationCell"
	
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
		let item = UIBarButtonItem(image: UIImage(systemName: "bell.circle.fill", withConfiguration: UIImage.SymbolConfiguration(textStyle: .title1)), style: .plain, target: self, action: #selector(showSubscriptionList))
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
		let vc = SubscriptionListViewController(style: .insetGrouped)
		let nc = UINavigationController(rootViewController: vc)
		nc.modalPresentationStyle = .pageSheet
		present(nc, animated: true)
	}
	
	// MARK: - UITableViewDelegate
	
	override func numberOfSections(in tableView: UITableView) -> Int { dataSource.topics.count }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { dataSource.topics[section].name }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let count = dataSource.topics[section].alerts.count
		return count > 0 ? count : 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard indexPath.section < dataSource.topics.count else { return UITableViewCell() }
		
		let topic = dataSource.topics[indexPath.section]
		
		guard indexPath.row < topic.alerts.count else {
			let cell = tableView.dequeueReusableCell(withIdentifier: informationCellReuseIdentifier) ?? {
				let cell = UITableViewCell(style: .default, reuseIdentifier: informationCellReuseIdentifier)
				cell.selectionStyle = .none
				return cell
			}()
			
			cell.textLabel?.text = "Pas d'alerte"
			
			return cell
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) ?? {
			let cell = UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)
			cell.accessoryType = .disclosureIndicator
			return cell
		}()
		
		let alert = topic.alerts[indexPath.row]
		cell.textLabel?.text = alert.levelDescription
		cell.detailTextLabel?.text = alert.message
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard indexPath.section < dataSource.topics.count else { return }
		guard let navigationController = navigationController else { return }
		
		let topic = dataSource.topics[indexPath.section]
		
		guard indexPath.row < topic.alerts.count else { return }
		
		let vc = AlertDetailViewController()
		vc.alert = topic.alerts[indexPath.row]
		
		navigationController.pushViewController(vc, animated: true)
	}
	
}
