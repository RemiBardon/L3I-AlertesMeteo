//
//  SubscriptionsTableViewDataSource.swift
//  AlertesMeteo
//
//  Created by BARDON Rémi on 28/03/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit
import Combine
import Firebase

class SubscriptionsTableViewDataSource: UITableViewDiffableDataSource<SubscriptionsTableViewDataSource.Section, String> {
	
	// MARK: Model
	
	enum Section: Hashable { case subscriptions, buttons, availableTopics }
	
	// MARK: Properties
	
	private var subscriptionCanceller: AnyCancellable?
	private let subscriptionsDataSource = SubscriptionsDataSource()
	
	private(set) var subscriptions = [String]()
	
	private let allTopicsDataSource = AllTopicsDataSource()
	private var allTopics = [String]()
	private var availableTopics: [String] { allTopics.filter { !subscriptions.contains($0) } }
	
	private var lastTopic: DocumentSnapshot? = nil
	
	// MARK: Lifecycle
	
	override init(tableView: UITableView, cellProvider: @escaping UITableViewDiffableDataSource<Section, String>.CellProvider) {
		super.init(tableView: tableView, cellProvider: cellProvider)
		#warning("Shouldn't happen, but app crashes if `UserDefaults.standard.topicSubscriptions` contains twice the same topic")
		
		defaultRowAnimation = .fade
		
		configureSubscriptionsDataSource()
		fetchAllTopics()
	}
	
	deinit {
		subscriptionsDataSource.stopListening()
		subscriptionCanceller?.cancel()
	}
	
	// MARK: Methods
	
	private func updateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
		
		if !subscriptions.isEmpty {
			snapshot.appendSections([.subscriptions])
			snapshot.appendItems(subscriptions, toSection: .subscriptions)
		}
		
		snapshot.appendSections([.buttons])
		snapshot.appendItems(["Ajouter un groupe d'alertes"], toSection: .buttons)
		
		if !availableTopics.isEmpty {
			snapshot.appendSections([.availableTopics])
			snapshot.appendItems(availableTopics, toSection: .availableTopics)
		}
		
		DispatchQueue.main.async {
			self.apply(snapshot, animatingDifferences: true)
		}
		
    }
	
	private func configureSubscriptionsDataSource() {
		subscriptionsDataSource.listen()
		subscriptionCanceller = subscriptionsDataSource.$subscriptions
			.receive(on: RunLoop.main)
			.sink { [weak self] (subscriptions: [String]) in
				guard let self = self else { return }

				if self.subscriptions != subscriptions {
					self.subscriptions = subscriptions
					self.updateData()
				}
			}
	}
	
	func fetchAllTopics() {
		allTopicsDataSource.fetchNext(50) { [weak self] (topicSummaries) in
			guard let self = self else { return }
			
			let topicNames = topicSummaries.map { $0.id }
			self.allTopics.append(contentsOf: topicNames)
			
			self.updateData()
		}
	}
	
	// MARK: UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch snapshot().sectionIdentifiers[section] {
		case .subscriptions:
			return "Abonnements"
		case .availableTopics:
			return "Groupes disponibles"
		default:
			return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		switch editingStyle {
		case .delete:
			guard indexPath.row < subscriptions.count else { return }
			let topicName = subscriptions[indexPath.row]
			
			TopicsHelper.unsubscribe(from: topicName)
		case .insert:
			let snapshot = self.snapshot()
			guard indexPath.section < snapshot.sectionIdentifiers.count else { return }
			let section = snapshot.sectionIdentifiers[indexPath.section]
			
			switch section {
			case .buttons:
				if indexPath.row == 0 { TopicsHelper().addNewTopic() }
			case .availableTopics:
				guard indexPath.row < availableTopics.count else { return }
				let topicName = availableTopics[indexPath.row]
				
				TopicsHelper.subscribe(to: topicName)
			default:
				break
			}
		default:
			break
		}
	}
	
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		let snapshot = self.snapshot()
		guard indexPath.section < snapshot.sectionIdentifiers.count else { return false }
		let section = snapshot.sectionIdentifiers[indexPath.section]
		
		switch section {
		case .subscriptions:
			return subscriptions.count > 1
		default:
			return false
		}
	}
	
	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		super.tableView(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
		
		let topicName = subscriptions[sourceIndexPath.row]
		
		// How to move UITableView cells while using UITableViewDiffableDataSource?
		// https://stackoverflow.com/a/60736803/10967642
		
		var snapshot = self.snapshot()
        if let sourceId = itemIdentifier(for: sourceIndexPath) {
            if let destinationId = itemIdentifier(for: destinationIndexPath) {
                guard sourceId != destinationId else {
                    return // Destination is same as source, no move.
                }
				
                // Valid source and destination
                if sourceIndexPath.row > destinationIndexPath.row {
                    snapshot.moveItem(sourceId, beforeItem: destinationId)
                } else {
                    snapshot.moveItem(sourceId, afterItem: destinationId)
                }
            } else {
                // No valid destination, eg. moving to the last row of a section
                snapshot.deleteItems([sourceId])
                snapshot.appendItems([sourceId], toSection: snapshot.sectionIdentifiers[destinationIndexPath.section])
            }
        }

        apply(snapshot, animatingDifferences: false)
		
		TopicsHelper.move(topic: topicName, from: sourceIndexPath.row, to: destinationIndexPath.row)
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }
	
}
