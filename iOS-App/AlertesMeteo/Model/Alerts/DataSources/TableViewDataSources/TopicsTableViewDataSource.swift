//
//  TopicsTableViewDataSource.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 24/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit
import Combine

class TopicsTableViewDataSource: UITableViewDiffableDataSource<TopicsTableViewDataSource.Section, Alert> {
	
	// MARK: Model
	
	enum Section: Hashable { case topic(name: String) }
	
	// MARK: Properties
	
	private var subscriptionCanceller: AnyCancellable?
	
	private(set) var topics = [Topic]()
	
	// MARK: Lifecycle
	
	override init(tableView: UITableView, cellProvider: @escaping UITableViewDiffableDataSource<Section, Alert>.CellProvider) {
		super.init(tableView: tableView, cellProvider: cellProvider)
		
		defaultRowAnimation = .fade
		configureTopicsDataSource()
	}
	
	deinit {
		subscriptionCanceller?.cancel()
	}
	
	// MARK: Methods
	
	func refreshTopics(completion: (() -> Void)? = nil) {
		TopicsDataSource.shared.fetch(completion: completion)
	}
	
	private func configureTopicsDataSource() {
		subscriptionCanceller = TopicsDataSource.shared.topicsSubject
			.receive(on: RunLoop.main)
			.sink { [weak self] (topics: [Topic]) in
				guard let self = self else { return }

				self.topics = topics
				self.updateData()
			}
	}
	
	private func updateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Alert>()
		for topic in topics {
			guard !topic.alerts.isEmpty else { continue }
			snapshot.appendSections([.topic(name: topic.name)])
			snapshot.appendItems(topic.alerts)
		}
		DispatchQueue.main.async { self.apply(snapshot, animatingDifferences: true) }
    }
	
	// MARK: UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch snapshot().sectionIdentifiers[section] {
		case .topic(name: let name):
			return name
		}
	}
	
}
