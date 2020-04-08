//
//  AMMapButton.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 27/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class AMMapButton: UIButton {
	
	// MARK: Properties
	
	private var buttonSize: CGFloat = 44.0
	private var iconSize: CGFloat = 22.0
	
	// MARK: Lifecycle
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		configure()
	}

	convenience init(icon: UIImage?, buttonSize: CGFloat = 44.0, backgroundColor: UIColor = .label, tintColor: UIColor = .systemBackground) {
		self.init(frame: CGRect(origin: .zero, size: CGSize(width: buttonSize, height: buttonSize)))
		
		if self.buttonSize != buttonSize {
			self.buttonSize = buttonSize
			self.iconSize = buttonSize/2.0
		}
		
		setImage(icon, for: .normal)
		
		self.backgroundColor 	= backgroundColor.withAlphaComponent(0.9)
		self.tintColor 			= tintColor
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	// MARK: Configuration
	
	private func configure() {
		layer.cornerRadius = buttonSize/2.0
		setPreferredSymbolConfiguration(.init(pointSize: iconSize), forImageIn: .normal)
		
		self.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			heightAnchor.constraint(equalToConstant: buttonSize),
			widthAnchor.constraint(equalToConstant: buttonSize)
		])
	}
	
}

