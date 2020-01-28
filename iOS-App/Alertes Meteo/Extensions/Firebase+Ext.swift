//
//  Firebase+Ext.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import FirebaseFirestore
import FirebaseDatabase

extension QueryDocumentSnapshot {

    func prepareForDecoding() -> [String: Any] {
        var data = self.data()
        data["documentId"] = documentID
        return data
    }

}

extension DataSnapshot {

    func prepareForDecoding() -> [String: Any] {
		var data = value as? [String : Any] ?? [:]
        data["key"] = key
        return data
    }

}
