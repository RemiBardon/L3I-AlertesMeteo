//
//  AlertsViewController.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class AlertsViewController: UIViewController {
	
	override func viewDidLoad() {
		title = "Alertes"
		
		view.backgroundColor = .systemBackground
		
		configureNotificationCenter()
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
	
}
