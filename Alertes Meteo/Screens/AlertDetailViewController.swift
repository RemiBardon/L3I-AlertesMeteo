//
//  AlertDetailViewController.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 04/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class AlertDetailViewController: UIViewController {
	
	var alert: Alert?
	
	private var scrollView: UIScrollView!
	private var messageLabel: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .systemBackground
		
		guard let alert = alert else {
			#if DEBUG
			print("\(type(of: self)).\(#function): Error: alert=nil")
			#endif
			
			// On n'a pas l'alerte, du coup on ne peut rien afficher
			// On affiche donc à l'utilisateur un avertissement et on retourne à la liste après qu'il l'ait lu
			let alert = UIAlertController(title: "Une erreur est survenue", message: "L'alerte n'a pas pu être récupérée.", preferredStyle: .alert)
			let dismissAction = UIAlertAction(title: "Retour", style: .cancel) { [weak self] _ in
				self?.dismiss(animated: true)
			}
			alert.addAction(dismissAction)
			present(alert, animated: true)
			return
		}
		
		title = alert.typeDescription
		
		configureScrollView()
		configureMessage()
		configureDetails()
	}
	
	private func configureScrollView() {
		scrollView = UIScrollView()
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
		
		view.addSubview(scrollView)
		
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
	}
	
	private func configureMessage() {
		#warning("Can clip if text is too long -> use UITextView instead")
		messageLabel = UILabel()
		messageLabel.text = alert?.message ?? "Pas de message."
		messageLabel.font = UIFont.preferredFont(forTextStyle: .title2)
		
		scrollView.addSubview(messageLabel)
		
		messageLabel.translatesAutoresizingMaskIntoConstraints = false
		
		messageLabel.sizeToFit()
		
		NSLayoutConstraint.activate([
			messageLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
			messageLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
			messageLabel.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor)
		])
	}
	
	private func configureDetails() {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = 8
		
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
		
		scrollView.addSubview(stackView)
		
		stackView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16.0),
			stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor)
		])
	}
	
}
