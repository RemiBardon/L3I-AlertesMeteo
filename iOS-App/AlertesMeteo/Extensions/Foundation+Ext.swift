//
//  Foundation+Ext.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import Foundation

extension JSONDecoder {
	
    func decode<T>(_ type: T.Type, fromJSONObject object: Any) throws -> T where T: Decodable {
        return try decode(T.self, from: try JSONSerialization.data(withJSONObject: object, options: []))
    }
	
}

// https://stackoverflow.com/a/47856467/10967642
extension UserDefaults {
	
    @objc dynamic var topicSubscriptions: [String] {
		stringArray(forKey: "topicSubscriptions") ?? [String]()
    }
	
	func setTopicSubscriptions(to newSubscriptions: [String]) {
		set(newSubscriptions, forKey: "topicSubscriptions")
	}
	
}

extension Date {
	
	func timeAgoDisplay() -> String {
		let calendar 	= Calendar.current
		let minuteAgo 	= calendar.date(byAdding: .minute, 	value: -1, to: Date())!
		let hourAgo 	= calendar.date(byAdding: .hour, 	value: -1, to: Date())!
		let dayAgo 		= calendar.date(byAdding: .day, 	value: -1, to: Date())!
		let weekAgo 	= calendar.date(byAdding: .day, 	value: -7, to: Date())!
		let monthAgo 	= calendar.date(byAdding: .month, 	value: -1, to: Date())!
		let yearAgo 	= calendar.date(byAdding: .year, 	value: -1, to: Date())!
		
		if minuteAgo < self {
			let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
			return diff <= 1 ? "Il y a \(diff) seconde" : "Il y a \(diff) secondes"
		} else if hourAgo < self {
			let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
			return diff <= 1 ? "Il y a \(diff) minute" : "Il y a \(diff) minutes"
		} else if dayAgo < self {
			let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
			return diff <= 1 ? "Il y a \(diff) heure" : "Il y a \(diff) heures"
		} else if weekAgo < self {
			let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
			return diff <= 1 ? "Il y a \(diff) jour" : "Il y a \(diff) jours"
		} else if monthAgo < self {
			let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
			return diff <= 1 ? "Il y a \(diff) semaine" : "Il y a \(diff) semaines"
		} else if yearAgo < self {
			let diff = Calendar.current.dateComponents([.month], from: self, to: Date()).month ?? 0
			return "Il y a \(diff) mois"
		} else {
			let diff = Calendar.current.dateComponents([.year], from: self, to: Date()).year ?? 0
			return diff <= 1 ? "Il y a \(diff) an" : "Il y a \(diff) ans"
		}
	}
	
}

// https://www.hackingwithswift.com/articles/108/how-to-use-regular-expressions-in-swift
extension NSRegularExpression {
	
	convenience init(_ pattern: String) {
		do {
			try self.init(pattern: pattern)
		} catch {
			preconditionFailure("Illegal regular expression: \(pattern).")
		}
	}
	
}
