//
//  AMMapButton.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 27/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class AMMapButton: UIButton {
	
	private var buttonSize: CGFloat = 44.0
	private var iconSize: CGFloat = 22.0
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		configure()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	init(icon: UIImage?, buttonSize: CGFloat = 44.0, backgroundColor: UIColor = .label, tintColor: UIColor = .systemBackground) {
		if self.buttonSize != buttonSize {
			self.buttonSize = buttonSize
			self.iconSize = buttonSize/2.0
		}
		
		super.init(frame: CGRect(origin: .zero, size: CGSize(width: buttonSize, height: buttonSize)))
		
		setImage(icon, for: .normal)
		self.backgroundColor = backgroundColor.withAlphaComponent(0.9)
		self.tintColor = tintColor
		
		configure()
	}
	
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

