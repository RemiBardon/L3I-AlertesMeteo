//
//  Alert.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import Foundation

struct Alert: Decodable {
	
	let id: String
	let timestamp: String
	let type: String
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
	
	var typeDescription: String {
		switch type {
		case "info":
			return "Information"
		case "crit":
			return "Alerte critique"
		case "warn":
			return "Avertissement"
		default:
			return "Alerte"
		}
	}
	
	init(from decoder: Decoder) throws {
		let container 	= try decoder.container(keyedBy: CodingKeys.self)
		id 				= try container.decode(String.self, forKey: .id)
		timestamp 		= try container.decode(String.self, forKey: .timestamp)
		type 			= try container.decode(String.self, forKey: .type)
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
		case type
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
	
}
