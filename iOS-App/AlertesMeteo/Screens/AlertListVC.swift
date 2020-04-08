//
//  AlertListVC.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class AlertListVC: UITableViewController {
	
	// MARK: Properties
	
	private let reuseIdentifier = "alertCell"
	
	private var dataSource: TopicsTableViewDataSource!
	
	// MARK: Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.largeTitleDisplayMode = .always
		
		view.backgroundColor = .systemGroupedBackground
		
		configureNavigationBar()
		configureDataSource()
		configureRefreshControl()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		refresh()
	}
	
	// MARK: Events
	
	@objc func refresh() {
		#if DEBUG
		print("\(type(of: self)).\(#function): [INFO]")
		#endif
		dataSource.refreshTopics { [weak self] in
			self?.refreshControl?.endRefreshing()
		}
	}
	
	@objc private func showSubscriptionList() {
		#if DEBUG
		print("\(type(of: self)).\(#function): [INFO] Show subscription list")
		#endif
		let vc = SubscriptionListVC(style: .insetGrouped)
		let nc = UINavigationController(rootViewController: vc)
		nc.modalPresentationStyle = .pageSheet
		present(nc, animated: true)
	}
	
	// MARK: Configuration
	
	private func configureNavigationBar() {
		let item = UIBarButtonItem(
			image: UIImage(
				systemName: "bell.circle.fill",
				withConfiguration: UIImage.SymbolConfiguration(textStyle: .title1)
			),
			style: .plain,
			target: self,
			action: #selector(showSubscriptionList)
		)
		navigationItem.setRightBarButton(item, animated: false)
	}
	
    private func configureDataSource() {
        dataSource = TopicsTableViewDataSource(tableView: tableView) { (tableView, indexPath, alert) -> UITableViewCell? in
			let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier) ?? {
				let cell = UITableViewCell(style: .subtitle, reuseIdentifier: self.reuseIdentifier)
				cell.accessoryType = .disclosureIndicator
				return cell
			}()
			
			cell.textLabel?.text = alert.levelDescription
			cell.detailTextLabel?.text = alert.date?.timeAgoDisplay() ?? alert.timestamp
			
			return cell
        }
    }
	
	private func configureRefreshControl() {
		let refreshControl = UIRefreshControl()
		refreshControl.attributedTitle = NSAttributedString(string: "Rafraîchir")
		refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
		self.refreshControl = refreshControl
	}
	
	// MARK: UITableViewDelegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let navigationController = navigationController else { return }
		guard let alert = getAlert(forIndexPath: indexPath, in: tableView) else { return }
		
		let vc = AlertDetailVC()
		vc.alert = alert
		
		#if DEBUG
		print("\(type(of: self)).\(#function): \(alert.alertId): \(alert.timestamp)")
		#endif
		
		navigationController.pushViewController(vc, animated: true)
	}
	
	private func getAlert(forIndexPath indexPath: IndexPath, in tableView: UITableView) -> Alert? {
		let snapshot = dataSource.snapshot()
		guard indexPath.section < snapshot.sectionIdentifiers.count else { return nil }
		let section = snapshot.sectionIdentifiers[indexPath.section]
		let itemIdentifiers = snapshot.itemIdentifiers(inSection: section)
		guard indexPath.item < itemIdentifiers.count else { return nil }
		
		return itemIdentifiers[indexPath.item]
	}
	
}
