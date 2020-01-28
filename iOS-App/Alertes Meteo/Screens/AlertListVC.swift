//
//  AlertListVC.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class AlertListVC: UITableViewController {
	
	private let reuseIdentifier = "alertCell"
	
	private var dataSource: TopicsTableViewDataSource!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemGroupedBackground
		
		configureNavigationBar()
		configureDataSource()
		configureNotificationCenter()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.navigationBar.prefersLargeTitles = true
	}
	
	private func configureNavigationBar() {
		let item = UIBarButtonItem(
			image: UIImage(
				systemName: "bell.circle.fill",
				withConfiguration: UIImage.SymbolConfiguration(textStyle: .title1)
			),
			style: .plain,
			target: self,
			action: #selector(showSubscriptionList)
		)
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
        dataSource = TopicsTableViewDataSource(tableView: tableView) { (tableView, indexPath, alert) -> UITableViewCell? in
			let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier) ?? {
				let cell = UITableViewCell(style: .subtitle, reuseIdentifier: self.reuseIdentifier)
				cell.accessoryType = .disclosureIndicator
				return cell
			}()
			
			cell.textLabel?.text = alert.levelDescription
			cell.detailTextLabel?.text = alert.date?.timeAgoDisplay() ?? alert.timestamp
			
			return cell
        }
    }
	
	@objc private func showSubscriptionList() {
		#if DEBUG
		print("\(type(of: self)).\(#function): Show subscription list")
		#endif
		let vc = SubscriptionListVC(style: .insetGrouped)
		let nc = UINavigationController(rootViewController: vc)
		nc.modalPresentationStyle = .pageSheet
		present(nc, animated: true)
	}
	
	// MARK: - UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let navigationController = navigationController else { return }
		guard indexPath.section < dataSource.topics.count else { return }
		
		let topic = dataSource.topics[indexPath.section]
		
		guard indexPath.row < topic.alerts.count else { return }
		
		let alert = topic.alerts[indexPath.row]
		
		let vc = AlertDetailVC()
		vc.alert = alert
		
		navigationController.pushViewController(vc, animated: true)
	}
	
}
