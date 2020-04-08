//
//  NetworkingHelper.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 27/03/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import Foundation

/// A class that replaces boilerplate code used for networking requests
class NetworkingHelper {
	
	// MARK: Singleton Pattern
	
	static let shared = NetworkingHelper()
	
	private init() {}
	
	// MARK: Model
	
	enum FetchingError: Error {
		case serverError(_ error: Error), invalidStatusCode(_ code: Int?), nilData, serializationError(_ error: Error)
	}
	
	// MARK: Methods
	
	func getJSONObject(from endpoint: URL, completion: @escaping (_ jsonObject: Result<Any, FetchingError>) -> Void) {
		#if DEBUG
		print("\(type(of: self)).\(#function): [INFO] Loading data from \(endpoint)")
		#endif
		
		let task = URLSession.shared.dataTask(with: endpoint) { data, response, error in
			if let error = error {
				#if DEBUG
				print("\(type(of: self)).\(#function): [WARNING] Error getting data: \(error.localizedDescription)")
				#endif
				completion(.failure(.serverError(error)))
				return
			}
			
			guard (response as? HTTPURLResponse)?.statusCode == 200 else {
				#if DEBUG
				print("\(type(of: self)).\(#function): [ERROR] Error getting data: Invalid response: \(response.debugDescription)")
				#endif
				completion(.failure(.invalidStatusCode((response as? HTTPURLResponse)?.statusCode)))
				return
			}
			
			guard let data = data else {
				#if DEBUG
				print("\(type(of: self)).\(#function): [ERROR] Error getting data: nil data")
				#endif
				completion(.failure(.nilData))
				return
			}
			
			guard let jsonObject: Any = {
				do {
					return try JSONSerialization.jsonObject(with: data)
				} catch {
					#if DEBUG
					print("\(type(of: self)).\(#function): [ERROR] Error getting data: Could not parse JSON")
					#endif
					completion(.failure(.serializationError(error)))
					return nil
				}
			}() else { return }
			
			completion(.success(jsonObject))
		}
		task.resume()
	}
	
}
