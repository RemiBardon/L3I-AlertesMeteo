//
//  AlertMessageTableViewCell.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 07/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class AlertMessageTableViewCell: UITableViewCell {
	
	static public let reuseIdentifier = "AlertMessageTableViewCell"
	
	private var messageLabel: UILabel!
	
	public var message: String? {
		didSet { reloadMessage() }
	}
	
	init() {
		super.init(style: .default, reuseIdentifier: AlertMessageTableViewCell.reuseIdentifier)
		
		configure()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	private func configure() {
		messageLabel = UILabel()
		reloadMessage()
		messageLabel.font = UIFont.preferredFont(forTextStyle: .title3)
		messageLabel.lineBreakMode = .byWordWrapping
		messageLabel.numberOfLines = 0 // Inifinite lines
		
		addSubview(messageLabel)
		
		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		
		messageLabel.sizeToFit()
		
		NSLayoutConstraint.activate([
			messageLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
			messageLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
			messageLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			messageLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
		])
	}
	
	private func reloadMessage() {
		messageLabel.text = (message ?? "Pas de message.")
	}
	
}
