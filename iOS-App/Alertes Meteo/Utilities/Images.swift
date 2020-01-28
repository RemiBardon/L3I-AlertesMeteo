//
//  Images.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 26/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit.UIImage

enum Images: String {
	
	case boat = "icons8-sail_boat"
	case filter = "icons8-filter"
	
	var uiImage: UIImage { UIImage(named: rawValue)! }
	
}

// Extend Images for testing purposes
extension Images: CaseIterable {}
