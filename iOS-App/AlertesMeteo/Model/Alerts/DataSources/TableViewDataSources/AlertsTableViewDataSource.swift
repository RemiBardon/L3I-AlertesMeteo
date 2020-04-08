//
//  AlertsTableViewDataSource.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 23/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit
import Combine

class AlertsTableViewDataSource: UITableViewDiffableDataSource<AlertsTableViewDataSource.Section, Alert> {
	
	// MARK: Model
	
	enum Section: Int { case main }
	
	// MARK: Properties
	
	private var subscriptionCanceller: AnyCancellable?
	private let alertsDataSource = AlertsDataSource()
	
	private(set) var alerts = [Alert]()
	
	// MARK: Lifecycle
	
	override init(tableView: UITableView, cellProvider: @escaping UITableViewDiffableDataSource<Section, Alert>.CellProvider) {
		super.init(tableView: tableView, cellProvider: cellProvider)
		
		defaultRowAnimation = .fade
		configureAlertsDataSource()
	}
	
	deinit {
		alertsDataSource.stopListening()
		subscriptionCanceller?.cancel()
	}
	
	// MARK: Methods
	
	private func configureAlertsDataSource() {
		alertsDataSource.listen()
		subscriptionCanceller = alertsDataSource.alertsSubject
			.receive(on: RunLoop.main)
			.sink { [weak self] (alerts: [Alert]) in
				guard let self = self else { return }

				self.alerts = alerts
				self.updateData()
			}
	}
	
	private func updateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Alert>()
		snapshot.appendSections([.main])
		snapshot.appendItems(alerts)
		DispatchQueue.main.async { self.apply(snapshot, animatingDifferences: true) }
    }
	
	// MARK: UITableViewDataSource
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case Section.main.rawValue:
			return "Toutes les alertes"
		default:
			return nil
		}
	}
	
}
