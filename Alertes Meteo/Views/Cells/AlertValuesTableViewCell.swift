//
//  AlertValuesTableViewCell.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 07/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class AlertValuesTableViewCell: UITableViewCell {
	
	static public let reuseIdentifier = "AlertValuesTableViewCell"
	
	private var stackView: UIStackView!
	
	public var alert: Alert? {
		didSet { reload() }
	}
	
	init() {
		super.init(style: .default, reuseIdentifier: AlertValuesTableViewCell.reuseIdentifier)
		
		configure()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	private func configure() {
		stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 8
		
		addSubview(stackView)

		stackView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
		])
	}
	
	private func reload() {
		for view in stackView.arrangedSubviews {
			stackView.removeArrangedSubview(view)
		}
		
		if let windSpeed = alert?.windSpeed {
			let label = UILabel()
			label.text = "Vitesse du vent : \(String(describing: windSpeed))km/h"
			stackView.addArrangedSubview(label)
		}
		if let windDirection = alert?.windDirection {
			let label = UILabel()
			label.text = "Direction du vent : \(String(describing: windDirection))°"
			stackView.addArrangedSubview(label)
		}
		if let temperature = alert?.temperature {
			let label = UILabel()
			label.text = "Température : \(String(describing: temperature))°C"
			stackView.addArrangedSubview(label)
		}
		if let battery = alert?.battery {
			let label = UILabel()
			label.text = "Batterie : \(String(describing: battery))%"
			stackView.addArrangedSubview(label)
		}
		if let roll = alert?.roll {
			let label = UILabel()
			label.text = "Roll : \(String(describing: roll))°"
			stackView.addArrangedSubview(label)
		}
		if let pitch = alert?.pitch {
			let label = UILabel()
			label.text = "Pitch : \(String(describing: pitch))°"
			stackView.addArrangedSubview(label)
		}
		if let compass = alert?.compass {
			let label = UILabel()
			label.text = "Direction : \(String(describing: compass))°"
			stackView.addArrangedSubview(label)
		}
		if let latitude = alert?.latitude, let longitude = alert?.longitude {
			let label = UILabel()
			label.text = "Direction : (\(String(describing: latitude)), \(String(describing: longitude)))"
			stackView.addArrangedSubview(label)
		}
	}

}
