//
//  TableViewHeaderWithButton.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 09/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class TableViewHeaderWithButton: UITableViewHeaderFooterView {
	
	private let actionButton = UIButton(type: .system)
	
	var buttonTitle: String? {
		didSet {
			actionButton.setTitle(buttonTitle, for: .normal)
		}
	}
	
	var buttonAction: (() -> ())?
	
	override init(reuseIdentifier: String?) {
		super.init(reuseIdentifier: reuseIdentifier)
		
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configure() {
		actionButton.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
		
		contentView.addSubview(actionButton)
		
		actionButton.translatesAutoresizingMaskIntoConstraints = false
		
		// FIXME: If textLabel is too long, it will go under / over the action button. Same for the button title.
		NSLayoutConstraint.activate([
			actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
		])
	}
	
	@objc func handleAction() {
		buttonAction?()
	}
	
}
