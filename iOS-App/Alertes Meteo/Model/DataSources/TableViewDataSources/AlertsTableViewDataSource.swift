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
	
	enum Section: Int { case main }
	
	private let alertsDataSource = AlertsDataSource()
	private var subscriptionCanceller: AnyCancellable?
	
	private(set) var alerts = [Alert]()
	
	override init(tableView: UITableView, cellProvider: @escaping UITableViewDiffableDataSource<Section, Alert>.CellProvider) {
		super.init(tableView: tableView, cellProvider: cellProvider)
		
		configureAlertsDataSource()
	}
	
	private func configureAlertsDataSource() {
		alertsDataSource.listen()
		subscriptionCanceller = alertsDataSource.$alerts
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
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case Section.main.rawValue:
			return "Toutes les alertes"
		default:
			return nil
		}
	}
	
	deinit {
		alertsDataSource.stopListening()
		subscriptionCanceller?.cancel()
	}
	
}
