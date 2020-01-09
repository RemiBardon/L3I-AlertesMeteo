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
		
		let requiredTopics: [String] = [
			"testTopic"
		]
		
		var actualTopics: [String] = UserDefaults.standard.stringArray(forKey: "topicSubscriptions") ?? [String]()
		
		for topic in requiredTopics {
			if !actualTopics.contains(topic) {
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
						actualTopics.append(topic)
						UserDefaults.standard.set(actualTopics, forKey: "topicSubscriptions")
					}
				}
			}
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
		print("\(type(of: self)).\(#function): userInfo=\(String(describing: userInfo))")
		
		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)
		
		// Print message ID.
//		if let messageID = userInfo[gcmMessageIDKey] {
//			print("Message ID: \(messageID)")
//		}
		
		// Print full message.
		print(userInfo)
	}

	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		// If you are receiving a notification message while your app is in the background,
		// this callback will not be fired till the user taps on the notification launching the application.
		// TODO: Handle data of notification
		print("\(type(of: self)).\(#function): userInfo=\(String(describing: userInfo))")
		
		// With swizzling disabled you must let Messaging know about the message, for Analytics
		// Messaging.messaging().appDidReceiveMessage(userInfo)
		
		// Print message ID.
//		if let messageID = userInfo[gcmMessageIDKey] {
//			print("Message ID: \(messageID)")
//		}
		
		// Print full message.
		print(userInfo)
		
		completionHandler(UIBackgroundFetchResult.newData)
	}

}
