//
//  rfc3339.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 13/01/2020.
//
//

// Swift 5 version of: https://gist.github.com/kristopherjohnson/5c75d92b8f2edc6f8686 (old Swift (2014) unit tests available if needed)
// and https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html#//apple_ref/doc/uid/TP40002369-SW1

import Foundation

/// Parse RFC 3339 date string to Date
/// - Parameter rfc3339DateTimeString: String with format "yyyy-MM-ddTHH:mm:ssZ"
public func dateForRFC3339DateTimeString(_ rfc3339DateTimeString: String) -> Date? {
    let formatter = getThreadLocalRFC3339DateFormatter()
	return formatter.date(from: rfc3339DateTimeString)
}

/// Generate RFC 3339 date string for a Date
/// - Parameter date: Date
public func rfc3339DateTimeStringForDate(date: Date) -> String {
    let formatter = getThreadLocalRFC3339DateFormatter()
	return formatter.string(from: date)
}

/// Date formatters are not thread-safe, so use a thread-local instance
private func getThreadLocalRFC3339DateFormatter() -> DateFormatter {
	return cachedThreadLocalObjectWithKey(key: "net.kristopherjohnson.getThreadLocalRFC3339DateFormatter") {
        let en_US_POSIX = Locale(identifier: "en_US_POSIX")
		let rfc3339DateFormatter = DateFormatter()
		rfc3339DateFormatter.locale = en_US_POSIX
        rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd' 'HH':'mm':'ss.SSSSSS"
		// Edit: Changed "ssXXX" for "ss.SSSSSSSSXXX" because we have nanoseconds input
		// Edit: Changed "T" for " " because we have a space
		rfc3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return rfc3339DateFormatter
    }
}

/// Return a thread-local object, creating it if it has not already been created
/// - Parameter create: Closure that will be invoked to create the object
private func cachedThreadLocalObjectWithKey<T>(key: String, create: () -> T) -> T where T : AnyObject {
	let threadDictionary = Thread.current.threadDictionary
	if let cachedObject = threadDictionary[key] as? T {
		return cachedObject
	} else {
		let newObject = create()
		threadDictionary[key] = newObject
		return newObject
	}
}

