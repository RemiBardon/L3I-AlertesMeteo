//
//  Alert.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import Foundation
import UIKit.UIColor
import UIKit.UIImage

struct Alert: Decodable, Identifiable, Hashable {
	
	let id = UUID()
	let alertId: String
	let timestamp: String
	let date: Date?
	let level: String
	let topic: String
	let message: String?
	let windSpeed: Float?
	let windDirection: Float?
	let temperature: Float?
	let battery: Float?
	let roll: Float?
	let pitch: Float?
	let compass: Float?
	let latitude: Double?
	let longitude: Double?
	
	var levelDescription: String {
		switch level {
		case "OK":
			return "✅ Retour à la normale"
		case "INFO":
			return "ℹ️ Information"
		case "WARNING":
			return "⚠️ Avertissement"
		case "CRITICAL":
			return "🚨 Alerte critique"
		default:
			return "📢 Alerte"
		}
	}
	
	var levelColor: UIColor? { Alert.color(forLevel: level) }
	
	var levelIcon: UIImage? { Alert.icon(forLevel: level) }
	
	init(from decoder: Decoder) throws {
		let container 	= try decoder.container(keyedBy: CodingKeys.self)
		alertId 				= try container.decode(String.self, forKey: .id)
		timestamp 		= try container.decode(String.self, forKey: .timestamp)
		date 			= dateForRFC3339DateTimeString(timestamp)
		level 			= try container.decode(String.self, forKey: .level)
		topic 			= try container.decode(String.self, forKey: .topic)
		message 		= try container.decodeIfPresent(String.self, forKey: .message)
		windSpeed 		= try container.decodeIfPresent(Float.self, forKey: .windSpeed)
		windDirection 	= try container.decodeIfPresent(Float.self, forKey: .windDirection)
		temperature 	= try container.decodeIfPresent(Float.self, forKey: .temperature)
		battery 		= try container.decodeIfPresent(Float.self, forKey: .battery)
		roll 			= try container.decodeIfPresent(Float.self, forKey: .roll)
		pitch 			= try container.decodeIfPresent(Float.self, forKey: .pitch)
		compass 		= try container.decodeIfPresent(Float.self, forKey: .compass)
		latitude 		= try container.decodeIfPresent(Double.self, forKey: .latitude)
		longitude 		= try container.decodeIfPresent(Double.self, forKey: .longitude)
	}
	
	private enum CodingKeys: String, CodingKey {
		case id = "documentId"
		case timestamp
		case level
		case topic
		case message
		case windSpeed = "wind_speed"
		case windDirection = "wind_direction"
		case temperature
		case battery
		case roll
		case pitch
		case compass
		case latitude
		case longitude
	}
	
	static func color(forLevel level: String?) -> UIColor? {
		switch level {
		case "OK":
			return .systemGreen
		case "INFO":
			return .systemYellow
		case "WARNING":
			return .systemOrange
		case "CRITICAL":
			return .systemRed
		default:
			return nil
		}
	}
	
	static func icon(forLevel level: String?) -> UIImage? {
		switch level {
		case "OK":
			return UIImage(systemName: "checkmark.circle.fill")
		case "INFO":
			return UIImage(systemName: "info.circle.fill")
		case "WARNING":
			return UIImage(systemName: "exclamationmark.bubble.fill")
		case "CRITICAL":
			return UIImage(systemName: "exclamationmark.triangle.fill")
		default:
			return nil
		}
	}
	
}
