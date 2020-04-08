//
//  DateFormatter+Ext.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 09/03/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import Foundation

// https://stackoverflow.com/a/28016692/10967642

extension ISO8601DateFormatter {
	
	convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone
    }
	
}

extension Formatter {
	
	static let iso8601 = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
	
}

extension Date {
	
    var iso8601: String { Formatter.iso8601.string(from: self) }
	
}

extension String {
	
    var iso8601: Date? { Formatter.iso8601.date(from: self) }
	
}

extension JSONDecoder.DateDecodingStrategy {
	
    static let iso8601withFractionalSeconds = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)
        guard let date = Formatter.iso8601.date(from: string) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: " + string)
        }
        return date
    }
	
}

extension JSONEncoder.DateEncodingStrategy {
	
    static let iso8601withFractionalSeconds = custom {
        var container = $1.singleValueContainer()
        try container.encode(Formatter.iso8601.string(from: $0))
    }
	
}
