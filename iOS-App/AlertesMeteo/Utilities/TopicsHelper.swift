//
//  TopicsHelper.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 28/03/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit
import Firebase

class TopicsHelper {
	
	private weak var subscribeAction: UIAlertAction?
	private weak var topicNameTextField: UITextField?
	
	func addNewTopic() {
		#if DEBUG
		print("\(type(of: self)).\(#function): [INFO]")
		#endif
		
		let alert = UIAlertController(title: "Abonnez-vous à un groupe d'alertes", message: nil, preferredStyle: .alert)
		
		alert.addTextField { (textField: UITextField) in
			self.topicNameTextField = textField
			textField.placeholder = "Nom de l'alerte"
			textField.addTarget(self, action: #selector(self.nameTextFieldChanged), for: .editingChanged)
		}
		alert.addTextField { (textField: UITextField) in
			textField.placeholder = "Groupe de capteurs"
		}
		alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
		let subscribeAction = UIAlertAction(title: "S'abonner", style: .default, handler: { (action: UIAlertAction) in
			guard let textFields = alert.textFields, textFields.count >= 2, let topicName = textFields[0].text, !topicName.isEmpty else {
				#if DEBUG
				print("\(type(of: self)).\(#function): [WARNING] Requested topic subscription without an alert name")
				#endif
				UIAlertController.showMessage(title: "Impossible de s'abonner", message: "Vous devez entrer un nom d'alerte.")
				return
			}
			let group = textFields[1].text ?? ""
			
			let topic = TopicsHelper.getTopic(fromTopicName: topicName, andGroup: group)
			
			TopicsHelper.subscribe(to: topic)
		})
		subscribeAction.isEnabled = false // Disable action by default, so the user has to enter a character to enable the action button
		self.subscribeAction = subscribeAction
		alert.addAction(subscribeAction)
		
		alert.presentInKeyWindowPresentedController()
	}
	
	@objc private func nameTextFieldChanged() {
		subscribeAction?.isEnabled = topicNameTextField?.text?.isEmpty == false
	}
	
	static func subscribe(to topic: String) {
		guard !UserDefaults.standard.topicSubscriptions.contains(topic) else { return }
		
		Messaging.messaging().subscribe(toTopic: topic) { error in
			if let error = error {
				#if DEBUG
				print("\(type(of: self)).\(#function): [ERROR] Error subscribing to topic '\(topic)': \(error.localizedDescription)")
				#endif
				UIAlertController.showMessage(title: "Impossible de s'abonner", message: "Une erreur est survenue. Merci de réessayer.")
			} else {
				#if DEBUG
				print("\(type(of: self)).\(#function): [INFO] Successfully subscribed to topic '\(topic)'.")
				#endif
				
				var actualTopics = UserDefaults.standard.topicSubscriptions
				
				guard !actualTopics.contains(topic) else { return }
				
				#if DEBUG
				print("\(type(of: self)).\(#function): [INFO] Added topic '\(topic)' to `UserDefaults.standard.topicSubscriptions`.")
				#endif
				
				actualTopics.append(topic)
				UserDefaults.standard.setTopicSubscriptions(to: actualTopics)
			}
		}
	}
	
	static func unsubscribe(from topic: String) {
		Messaging.messaging().unsubscribe(fromTopic: topic) { error in
			if let error = error {
				#if DEBUG
				print("\(type(of: self)).\(#function): [ERROR] Error unsubscribing from topic '\(topic)': \(error.localizedDescription)")
				#endif
				UIAlertController.showMessage(title: "Impossible de se désabonner", message: "Une erreur est survenue. Merci de réessayer.")
			} else {
				#if DEBUG
				print("\(type(of: self)).\(#function): [INFO] Successfully unsubscribed from topic '\(topic)'.")
				#endif
				var actualTopics = UserDefaults.standard.topicSubscriptions
				actualTopics.removeAll(where: { $0 == topic })
				UserDefaults.standard.setTopicSubscriptions(to: actualTopics)
			}
		}
	}
	
	static func getTopic(fromTopicName topicName: String, andGroup group: String) -> String {
		group.isEmpty ? "\(normalize(topicName))" : "\(normalize(topicName))-\(normalize(group))"
	}
	
	static func move(topic topicName: String, from indexBefore: Int, to indexAfter: Int) {
		var actualTopics = UserDefaults.standard.topicSubscriptions
		guard indexBefore < actualTopics.count && indexAfter < actualTopics.count, actualTopics[indexBefore] == topicName else {
			#if DEBUG
			print("\(type(of: self)).\(#function): [ERROR] Tried to update a version of `UserDefaults.standard.topicSubscriptions` that is not the current one")
			#endif
			return
		}
		
		actualTopics.remove(at: indexBefore)
		actualTopics.insert(topicName, at: indexAfter)
		
		UserDefaults.standard.setTopicSubscriptions(to: actualTopics)
	}
	
	private static func normalize(_ string: String) -> String {
		let foldingOptions: String.CompareOptions = [.diacriticInsensitive, .widthInsensitive, .caseInsensitive]
		let whitespaces = CharacterSet.whitespacesAndNewlines
		
		let string = string
			.folding(options: foldingOptions, locale: nil) 						// Remove accents (https://stackoverflow.com/a/40282304/10967642)
			.components(separatedBy: whitespaces).joined(separator: "_") 		// Replace whitespaces by undescrores
			.components(separatedBy: "-").joined(separator: "_") 				// Replace dashes by underscores to keep dashes as separators
		
		let regex = NSRegularExpression("[^a-zA-Z0-9_.~%-]")
		let range = NSRange(location: 0, length: string.count)
		return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "") // Remove remaining prohibited characters
	}
	
}
