//
//  FloatingControlsVC.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 27/01/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

class ClickThroughView: UIView {

	// https://stackoverflow.com/a/38089068/10967642
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let result = super.hitTest(point, with: event)
		return (result == self ? nil : result)
	}
	
}

class FloatingControlsVC: UIViewController {
	
	enum Position: CaseIterable {
		case topLeft, top, topRight, right, bottomRight, bottom, bottomLeft, left, corners, sides, all
	}
	
	private let stackViews: [Position: UIStackView] = {
		var stackViews = [Position: UIStackView]()
		for position in Position.allCases.prefix(8) {
			stackViews[position] = UIStackView()
		}
		return stackViews
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// We need to use a special view that allows the user to click through itself, but still touch controls
		view = ClickThroughView(frame: view.frame)
		
		view.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		
		configureStackViews()
    }
	
	private func configureStackViews() {
		guard let topLeftStackView 		= stackViews[.topLeft],
			  let topStackView 			= stackViews[.top],
			  let topRightStackView 	= stackViews[.topRight],
			  let rightStackView 		= stackViews[.right],
			  let bottomRightStackView 	= stackViews[.bottomRight],
			  let bottomStackView 		= stackViews[.bottom],
			  let bottomLeftStackView 	= stackViews[.bottomLeft],
			  let leftStackView 		= stackViews[.left]
			else { return }
		
		for stackView in stackViews.values {
			stackView.axis 		= .vertical
			stackView.spacing 	= 4

			view.addSubview(stackView)
			stackView.translatesAutoresizingMaskIntoConstraints = false
		}
		
		setStackViewAxis(.horizontal, in: [.top, .bottom])
		
		NSLayoutConstraint.activate([
			topLeftStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
			topLeftStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
			topLeftStackView.trailingAnchor.constraint(lessThanOrEqualTo: topStackView.leadingAnchor),
			
			topStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
			topStackView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
			topStackView.trailingAnchor.constraint(lessThanOrEqualTo: topRightStackView.leadingAnchor),
			
			topRightStackView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
			topRightStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
			topRightStackView.bottomAnchor.constraint(lessThanOrEqualTo: rightStackView.topAnchor),
			
			rightStackView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
			rightStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
			rightStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomRightStackView.topAnchor),
			
			bottomRightStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
			bottomRightStackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
			bottomRightStackView.leadingAnchor.constraint(greaterThanOrEqualTo: bottomStackView.trailingAnchor),
			
			bottomStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
			bottomStackView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
			bottomStackView.leadingAnchor.constraint(greaterThanOrEqualTo: bottomLeftStackView.trailingAnchor),
			
			bottomLeftStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
			bottomLeftStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
			bottomLeftStackView.topAnchor.constraint(greaterThanOrEqualTo: leftStackView.bottomAnchor),
			
			leftStackView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
			leftStackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
			leftStackView.topAnchor.constraint(greaterThanOrEqualTo: topLeftStackView.bottomAnchor),
		])
	}
	
	func addControl(_ control: UIControl, in position: Position) {
		stackViews[position]?.addArrangedSubview(control)
	}
	
	func setStackViewAxis(_ axis: NSLayoutConstraint.Axis, in position: Position) {
		let positions: [Position]? = {
			// Be sure not to return .corners, .sides or .all, otherwise you'll be trapped in an infinite loop!
			switch position {
			case .corners:
				return [.topLeft, .topRight, .bottomRight, .bottomLeft]
			case .sides:
				return [.top, .right, .bottom, .left]
			case .all:
				return [.topLeft, .top, .topRight, .right, .bottomRight, .bottom, .bottomLeft, .left]
			default:
				return nil
			}
		}()
		if let positions = positions {
			setStackViewAxis(axis, in: positions)
		} else {
			stackViews[position]?.axis = axis
		}
	}
	
	func setStackViewAxis(_ axis: NSLayoutConstraint.Axis, in positions: [Position]) {
		for position in positions {
			setStackViewAxis(axis, in: position)
		}
	}

}
