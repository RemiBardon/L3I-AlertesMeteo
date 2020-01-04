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
