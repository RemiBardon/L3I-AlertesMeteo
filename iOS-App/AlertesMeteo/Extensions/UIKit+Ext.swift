//
//  UIKit+Ext.swift
//  Alertes Meteo
//
//  Created by BARDON Rémi on 28/03/2020.
//  Copyright © 2020 ULR ECI A1-2. All rights reserved.
//

import UIKit

extension UIViewController {
	
	static var keyWindowPresentedController: UIViewController? {
		let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
		var viewController = keyWindow?.rootViewController
		if let presentedController = viewController as? UITabBarController {
			viewController = presentedController.selectedViewController
		}
		while let presentedController = viewController?.presentedViewController {
			if let presentedController = presentedController as? UITabBarController {
				viewController = presentedController.selectedViewController
			} else {
				viewController = presentedController
			}
		}
		return viewController
	}
	
	func presentInKeyWindowPresentedController(animated: Bool = true, completion: (() -> Void)? = nil) {
		// UIApplication.shared.keyWindow has been deprecated in iOS 13,
		// so you need a little workaround to avoid the compiler warning
		// https://stackoverflow.com/a/58031897/10967642
		
		let keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
		var viewController = keyWindow?.rootViewController
		while let presentedController = viewController?.presentedViewController {
			viewController = presentedController
		}
		
		DispatchQueue.main.async {
			viewController?.present(self, animated: animated, completion: completion)
		}
	}
	
}

extension UIAlertController {
	
	static func showMessage(title: String?, message: String?, onDismiss: ((UIAlertAction) -> Void)? = nil) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: onDismiss))
		alert.presentInKeyWindowPresentedController()
	}
	
}
