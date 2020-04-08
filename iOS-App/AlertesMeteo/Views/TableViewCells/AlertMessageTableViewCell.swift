//
//  AlertMessageTableViewCell.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 07/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class AlertMessageTableViewCell: UITableViewCell {
	
	// MARK: Properties
	
	static let reuseIdentifier = "AlertMessageTableViewCell"
	
	private var titleLabel: UILabel!
	private var messageLabel: UILabel!
	
	var message: String? {
		didSet { reloadMessage() }
	}
	
	// MARK: Lifecycle
	
	init() {
		super.init(style: .default, reuseIdentifier: Self.reuseIdentifier)
		
		configureTitleLabel()
		configureMessageLabel()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	// MARK: Methods
	
	private func reloadMessage() {
		messageLabel.text = message ?? "Pas de message."
	}
	
	// MARK: Configuration
	
	private func configureTitleLabel() {
		titleLabel = UILabel()
		titleLabel.text = "Message :"
		titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
		titleLabel.minimumScaleFactor = 0.9
		
		addSubview(titleLabel)
		
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		
		titleLabel.sizeToFit()
		
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor)
		])
	}
	
	private func configureMessageLabel() {
		messageLabel = UILabel()
		reloadMessage()
		messageLabel.font = UIFont.preferredFont(forTextStyle: .title3)
		messageLabel.lineBreakMode = .byWordWrapping
		messageLabel.numberOfLines = 0 // Inifinite lines
		
		addSubview(messageLabel)
		
		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		
		messageLabel.sizeToFit()
		
		NSLayoutConstraint.activate([
			messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
			messageLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
			messageLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			messageLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
		])
	}
	
}
