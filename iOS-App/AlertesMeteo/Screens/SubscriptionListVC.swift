//
//  SubscriptionListVC.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 08/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit
import Combine
import Firebase

class SubscriptionListVC: UITableViewController {
	
	// MARK: Properties
	
	private let subscriptionCellReuseIdentifier = "subscriptionCell"
	private let buttonCellReuseIdentifier = "buttonCell"
	
	private var dataSource: SubscriptionsTableViewDataSource!
	
	// MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Abonnements"
		
		view.backgroundColor = .systemGroupedBackground
		
		configureDataSource()
		configureTableView()
    }
	
	// MARK: Events
	
	@objc private func save() {
		#if DEBUG
		print("\(type(of: self)).\(#function): [INFO] Dismiss")
		#endif
		dismiss(animated: true)
	}
	
	// MARK: Configuration
	
    private func configureDataSource() {
        dataSource = SubscriptionsTableViewDataSource(tableView: tableView) { (tableView, indexPath, string) -> UITableViewCell? in
			let snapshot = self.dataSource.snapshot()
			guard indexPath.section < snapshot.sectionIdentifiers.count else { return .none }
			let section = snapshot.sectionIdentifiers[indexPath.section]
			
			switch section {
			case .subscriptions, .availableTopics:
				let cell = tableView.dequeueReusableCell(withIdentifier: self.subscriptionCellReuseIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: self.subscriptionCellReuseIdentifier)
				
				let splits = string.split(separator: "-").map { String($0) }
				cell.textLabel?.text 		= splits[0]
				cell.detailTextLabel?.text 	= splits.count > 1 ? splits[1] : nil
				
				return cell
			case .buttons:
				let cell = tableView.dequeueReusableCell(withIdentifier: self.buttonCellReuseIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: self.buttonCellReuseIdentifier)
				
				cell.textLabel?.text = string
				
				return cell
			}
        }
    }
	
	private func configureTableView() {
		tableView.setEditing(true, animated: false)
	}
	
	// MARK: UIScrollViewDelegate
	
	override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		//super.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
		
		guard scrollView == tableView else { return }
		
		let offsetY = scrollView.contentOffset.y
		let contentHeight = scrollView.contentSize.height
		let height = scrollView.frame.height
		
		if offsetY > contentHeight - height {
			dataSource.fetchAllTopics()
		}
	}
	
	// MARK: UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
		if proposedDestinationIndexPath.section > 0 {
			return IndexPath(row: dataSource.subscriptions.count - 1, section: 0)
		} else {
			return proposedDestinationIndexPath
		}
	}
	
	override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool { indexPath.section == 0 }
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		let snapshot = dataSource.snapshot()
		guard indexPath.section < snapshot.sectionIdentifiers.count else { return .none }
		let section = snapshot.sectionIdentifiers[indexPath.section]
		
		switch section {
		case .subscriptions:
			return .delete
		case .buttons, .availableTopics:
			return .insert
		}
	}

}
