//
//  AlertsViewController.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class AlertsViewController: UITableViewController {
	
	private let reuseIdentifier = "alertCell"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Alertes météo"
		
		view.backgroundColor = .secondarySystemBackground
		
		configureNotificationCenter()
		configureTableView()
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
	
	private func configureTableView() {
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
	}
	
	// MARK: - UITableViewDelegate
	
	override func numberOfSections(in tableView: UITableView) -> Int { 3 }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		"Section \(section)"
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 20 }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
		cell.textLabel?.text = "Cell (\(indexPath.section);\(indexPath.row))"
		return cell
	}
	
}
