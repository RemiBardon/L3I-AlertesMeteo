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
	
}

// https://stackoverflow.com/a/47616252/10967642
struct UnknownDataCodingKeys: CodingKey {
	
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int?
    init?(intValue: Int) {
        return nil
    }
	
}

extension KeyedDecodingContainer where Key == UnknownDataCodingKeys {
	
	/// Method used to decode unknown key-value data from an object
	///
	/// Usage:
	/// ```
	/// // Unknown data decoding
	/// let container2 = try decoder.container(keyedBy: UnknownDataCodingKeys.self)
	/// unknownData = container2.decodeUnknownKeyValues(exclude: CodingKeys.self)
	///
	/// // Nested unknown data decoding
	/// let container3 = try container.nestedContainer(keyedBy: UnknownDataCodingKeys.self, forKey: .unknownNestedData)
	/// unknownNestedData = container3.decodeUnknownKeyValues(exclude: CodingKeys.self)
	/// ```
	///
	/// - Parameter keyedBy: Coding keys to exclude
    func decodeUnknownKeyValues<T: CodingKey>(exclude keyedBy: T.Type) -> [String: Any] {
        var data = [String: Any]()

        for key in allKeys {
            if keyedBy.init(stringValue: key.stringValue) == nil {
                if let value = try? decode(String.self, forKey: key) {
                    data[key.stringValue] = value
                } else if let value = try? decode(Bool.self, forKey: key) {
                    data[key.stringValue] = value
                } else if let value = try? decode(Int.self, forKey: key) {
                    data[key.stringValue] = value
                } else if let value = try? decode(Double.self, forKey: key) {
                    data[key.stringValue] = value
                } else if let value = try? decode(Float.self, forKey: key) {
                    data[key.stringValue] = value
                } else {
                    NSLog("Key %@ type not supported", key.stringValue)
                }
            }
        }

        return data
    }
	
}
