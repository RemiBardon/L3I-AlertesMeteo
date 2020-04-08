//
//  Firebase+Ext.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import Firebase

extension QueryDocumentSnapshot {
	
	/// Prepares the snaphot for decoding, adding the documentID for the key 'documentId'
    func prepareForDecoding() -> [String: Any] {
        var data = self.data()
        data["documentId"] = documentID
        return data
    }

}

extension DataSnapshot {
	
	/// Prepares the snaphot for decoding, adding the key for the key 'key'
    func prepareForDecoding() -> [String: Any] {
		var data = value as? [String : Any] ?? [:]
        data["key"] = key
        return data
    }

}
