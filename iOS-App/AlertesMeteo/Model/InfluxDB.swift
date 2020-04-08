//
//  InfluxDB.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 27/03/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import Foundation

class InfluxDB {
	
	// MARK: Singleton Pattern
	
	static let shared = InfluxDB()
	
	private init?() {
		guard let config = NSDictionary(contentsOf: URL(fileReferenceLiteralResourceName: "InfluxDB-Config.plist")) as? [String:String] else {
			#if DEBUG
			print("\(type(of: self)).\(#function): [ERROR] Could not find 'InfluxDB-Config.plist'")
			#endif
			return nil
		}
		guard let ip = config["ip"], let port = config["port"], let db = config["db"] else {
			#if DEBUG
			print("\(type(of: self)).\(#function): [ERROR] Missing fields in 'InfluxDB-Config.plist'")
			#endif
			return nil
		}
		
		baseEndpoint = "http://\(ip):\(port)/query?pretty=true&db=\(db)"
	}
	
	// MARK: Properties
	
	private let baseEndpoint: String
	
}

// MARK: - Model

extension InfluxDB {

	class Query {
		
		let query: String
		
		init(fromString sqlQuery: String) {
			query = sqlQuery
		}
		
		lazy var endpoint: URL? = {
			guard let baseEndpoint = InfluxDB.shared?.baseEndpoint,
				let urlString = "\(baseEndpoint)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
				let endpoint = URL(string: urlString)
			else {
				#if DEBUG
				print("\(type(of: self)).\(#function): [ERROR] Invalid endpoint URL")
				#endif
				return nil
			}
			
			return endpoint
		}()
		
	}
	
}
