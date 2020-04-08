//
//  AllTopicsDataSource.swift
//  AlertesMeteo
//
//  Created by BARDON Rémi on 07/04/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import Firebase

class AllTopicsDataSource {
	
	// MARK: Properties
	
	private var lastTopic: DocumentSnapshot? = nil
	
	// MARK: Methods
	
	func fetchNext(_ limit: Int = 20, completion: (([TopicSummary]) -> Void)? = nil) {
		let db = Firestore.firestore()
		
		var topicsRef = db.collection("topics")
			.order(by: "alertCount", descending: true)
			.limit(to: limit)
		
		if let lastTopic = lastTopic {
			topicsRef = topicsRef.start(afterDocument: lastTopic)
		}
		
		topicsRef.getDocuments { [weak self] (querySnapshot, error) in
			guard let self = self, let completion = completion else { return }

			if let error = error {
				#if DEBUG
				print("\(type(of: self)).\(#function): [ERROR] Error retreiving documents: \(error)")
				#endif
				return
			}
			guard let querySnapshot = querySnapshot else {
				#if DEBUG
				print("\(type(of: self)).\(#function): [ERROR] Error fetching documents: querySnapshot=nil")
				#endif
				return
			}
			
			if let lastDocumentSnapshot = querySnapshot.documents.last {
				self.lastTopic = lastDocumentSnapshot
			}
			
			let jsonObject = querySnapshot.documents.map { $0.prepareForDecoding() }
			
			let topics = (try? JSONDecoder().decode([TopicSummary].self, fromJSONObject: jsonObject)) ?? []
			
			completion(topics)
		}
	}
	
}
