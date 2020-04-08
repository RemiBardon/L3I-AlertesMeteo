//
//  TopicSummary.swift
//  AlertesMeteo
//
//  Created by BARDON Rémi on 07/04/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit.UIColor
import UIKit.UIImage

class TopicSummary: Decodable, Identifiable {
	
	// MARK: Properties
	
	let id: String
	let alertCount: Int
	let level: String
	let message: String
	let previousLevel: String?
	
	var levelDescription: String 	{ AlertsHelper.levelDescription(for: level) }
	var levelColor: UIColor? 		{ AlertsHelper.color(forLevel: level) }
	var levelIcon: UIImage? 		{ AlertsHelper.icon(forLevel: level) }
	
	// MARK: Decodable Requirements
	
	required init(from decoder: Decoder) throws {
		let container 	= try decoder.container(keyedBy: CodingKeys.self)
		id 				= try container.decode(String.self, forKey: .id)
		alertCount 		= try container.decode(Int.self, forKey: .alertCount)
		level 			= try container.decode(String.self, forKey: .level)
		message 		= try container.decode(String.self, forKey: .message)
		previousLevel 	= try container.decodeIfPresent(String.self, forKey: .previousLevel)
	}
	
	private enum CodingKeys: String, CodingKey {
		case id = "documentId"
		case alertCount
		case level
		case message
		case previousLevel
	}
	
}
