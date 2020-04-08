//
//  AlertsHelper.swift
//  AlertesMeteo
//
//  Created by BARDON Rémi on 07/04/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit.UIColor
import UIKit.UIImage

class AlertsHelper {
	
	// MARK: Static methods
	
	static func levelDescription(for level: String) -> String {
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
