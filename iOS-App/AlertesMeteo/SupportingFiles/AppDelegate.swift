//
//  AppDelegate.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 19/12/2019.
//  Copyright © 2019 ULR ECI A1-2. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		// Use Firebase library to configure APIs
		FirebaseApp.configure()
		
		DispatchQueue.global(qos: .background).async { /*[weak self] in*/
			UNUserNotificationCenter.configure()
//			self?.subscribeToDefaultTopics()
//			self?.testInfluxDBConnection()
		}
		
		return true
	}

	// MARK: UISceneSession Lifecycle

	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// Called when a new scene session is being created.
		// Use this method to select a configuration to create the new scene with.
		return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
	}
	
	// MARK: Notifications
	
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
		// If you are receiving a notification message while your app is in the background,
		// this callback will not be fired till the user taps on the notification launching the application.
		// TODO: Handle data of notification
		print("\(type(of: self)).\(#function): [INFO] userInfo=\(String(describing: userInfo))")
		
		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)
		
		// Print message ID.
//		if let messageID = userInfo[gcmMessageIDKey] {
//			print("\(type(of: self)).\(#function): [INFO] Message ID: \(messageID)")
//		}
		
		// Print full message.
		print(userInfo)
	}

	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		// If you are receiving a notification message while your app is in the background,
		// this callback will not be fired till the user taps on the notification launching the application.
		// TODO: Handle data of notification
		print("\(type(of: self)).\(#function): [INFO] userInfo=\(String(describing: userInfo))")
		
		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)
		
		// Print message ID.
//		if let messageID = userInfo[gcmMessageIDKey] {
//			print("\(type(of: self)).\(#function): [INFO] Message ID: \(messageID)")
//		}
		
		// Print full message.
		print(userInfo)
		
		completionHandler(UIBackgroundFetchResult.newData)
	}
	
	// MARK: Testing
	
	private func subscribeToDefaultTopics() {
		#warning("Example code for subcribing to topics")
		
		let requiredTopics: [String] = [
			"testTopic"
		]
		
		for topic in requiredTopics {
			TopicsHelper.subscribe(to: topic)
		}
	}
	
	private func testInfluxDBConnection() {
		#warning("Example code for querying InfluxDB")
		
		DispatchQueue.global(qos: .background).async { [weak self] in
			let queryString = """
			SELECT wind_speed
			FROM autogen.mesures
			WHERE time > now() - 5m AND time < now()
			AND (location='Chatelaillon' OR location='Aytre')
			GROUP BY location
			LIMIT 5
			"""
			
			guard let endpoint = InfluxDB.Query(fromString: queryString).endpoint else { return }
			
			NetworkingHelper.shared.getJSONObject(from: endpoint) { (result) in
				switch result {
				case .success(let jsonObject):
					#if DEBUG
					print("\(type(of: self)).\(#function): [INFO] Successfully fetched data from InfluxDB: \(jsonObject)")
					#endif
					break
				case .failure:
					#if DEBUG
					print("\(type(of: self)).\(#function): [ERROR] Error fetching data from InfluxDB")
					#endif
					break
				}
			}
		}
	}

}
