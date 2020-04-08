//
//  Alert.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit.UIColor
import UIKit.UIImage

struct Alert: Decodable, Identifiable, Hashable {
	
	// MARK: Properties
	
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
	
	var levelDescription: String 	{ AlertsHelper.levelDescription(for: level) }
	var levelColor: UIColor? 		{ AlertsHelper.color(forLevel: level) }
	var levelIcon: UIImage? 		{ AlertsHelper.icon(forLevel: level) }
	
	// MARK: Decodable Requirements
	
	init(from decoder: Decoder) throws {
		let container 	= try decoder.container(keyedBy: CodingKeys.self)
		alertId 		= try container.decode(String.self, forKey: .alertId)
		timestamp 		= try container.decode(String.self, forKey: .timestamp)
		date 			= try container.decode(Date.self, 	forKey: .timestamp)
		level 			= try container.decode(String.self, forKey: .level)
		topic 			= try container.decode(String.self, forKey: .topic)
		message 		= try container.decodeIfPresent(String.self, 	forKey: .message)
		windSpeed 		= try container.decodeIfPresent(Float.self, 	forKey: .windSpeed)
		windDirection 	= try container.decodeIfPresent(Float.self, 	forKey: .windDirection)
		temperature 	= try container.decodeIfPresent(Float.self, 	forKey: .temperature)
		battery 		= try container.decodeIfPresent(Float.self, 	forKey: .battery)
		roll 			= try container.decodeIfPresent(Float.self, 	forKey: .roll)
		pitch 			= try container.decodeIfPresent(Float.self, 	forKey: .pitch)
		compass 		= try container.decodeIfPresent(Float.self, 	forKey: .compass)
		latitude 		= try container.decodeIfPresent(Double.self, 	forKey: .latitude)
		longitude 		= try container.decodeIfPresent(Double.self, 	forKey: .longitude)
	}
	
	private enum CodingKeys: String, CodingKey {
		case alertId = "documentId"
		case timestamp
		case level
		case topic
		case message
		case windSpeed
		case windDirection
		case temperature
		case battery
		case roll
		case pitch
		case compass
		case latitude
		case longitude
	}
	
}
